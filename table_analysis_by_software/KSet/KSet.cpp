#include "KSet.h"
#include <sys/stat.h>
#include <time.h>
#include <sys/types.h>
using namespace std;



/* 
 * ===  FUNCTION  ======================================================================
 *  Description:  Constructor for KSet class
 * =====================================================================================
 */
KSet::KSet(int num1, std::vector<Rule>& classifier, int usedbits){
   num = num1; // record subset num
   usedbit = usedbits; // use how many bits represent this segment table
   numrules = classifier.size();// # of rules
   tablesize = pow(2, usedbits);
   threshold = 10;
   threshold2 = 4;
   nodeKSet = new SegmentNode[tablesize]; // real segment table
   bigSetPrefix = 30;// used to split group 0&1 threshold
   bigSetPrefix3 = 7;

   locate_segment= 32 - usedbits;//?

   /* Performance analysis*/
   Total_Rules_in_Linear_Node = 0;
   Total_Rules_in_Big_Node = 0;
   Total_Tablesize_in_Big_Node = 0;

   // count number of linear or PSTSS segment in the set
   NULL_Node_Count = 0;
   Small_Node_Count = 0;
   Big_Node_Count = 0;

   total_linear_memory_in_KB = 0;
   total_big_memory_in_KB = 0;
   total_memory_in_KB = 0;

   // initialize bucket size and group counter
   for(int j=0;j<5;j++){
      num_group[j] = 0;
      for(int k=0;k<10;k++)
         bucket_small_group[j][k] = 0;
      for(int k=0;k<200;k++)
         bucket_big_group[j][k] = 0;
   }
}


/* 
 * ===  FUNCTION  ======================================================================
 *  Description:  destructor for KSet class
 * =====================================================================================
 */
KSet::~KSet() {
   delete [] nodeKSet;
}

/* 
 * ===  FUNCTION  ======================================================================
 *  Description:  This function is for big segment. Split big segment to big/small group  
 * =====================================================================================
 */
int simple_part(const vector<Rule> &rules, BigSegment *b, vector<Rule> &rmd, int bits, int t, int num_group[5], int bucket_small_group[5][10], int bucket_big_group[5][200]) {
   int i,j;
   uint32_t v;
   int hash;
   int hash_table_size = 0;
   vector<Rule> tmp[4];

   /*
    Split to 5 group by ours define
    b[0] - Group 0
    b[1] - Group 1
    b[2] - Group 2
    b[3] - Group 3
    rmd - others queue
   */
   for(i=0; i<rules.size(); i++) {
      // Group 0 - Src IP prefix length >= 30
      if(rules[i].prefix_length[0] >= bits) {
         b[0].list.push_back(rules[i]);
         num_group[0]++;
      }
      // Group 1 - Dst IP Prefix length >= 30
      else if(rules[i].prefix_length[1] >= bits){
         b[1].list.push_back(rules[i]);
         num_group[1]++;
      }
      // Group 2 - Dst port is exact value
      else if(rules[i].range[3][0] == rules[i].range[3][1]){
         b[2].list.push_back(rules[i]);
         num_group[2]++;
      }
      // Group 3 - Src port is exact value
      else if(rules[i].range[2][0] == rules[i].range[2][1]){
         b[3].list.push_back(rules[i]);
         num_group[3]++;
      }
      // Group 4 - Others
      else{
         rmd.push_back(rules[i]);
         num_group[4]++;
      }
   }
   
   for(i=0; i<4; i++) {
      // non element
      if(b[i].list.size() == 0) {
         b[i].bf = -1; // used exact field
         b[i].uf = -1; // non use list and hash
      }
      // this is a small group, only use list
      else if(b[i].list.size() <= t) { 
         b[i].bf = 0; // use list
         b[i].uf = part_oder(i);
         hash_table_size++;
         bucket_small_group[i][b[i].list.size()]++;
      }
      // this is a big group, use hash
      else { 
         b[i].bf = 1; // use hash
         b[i].uf = part_oder(i);

         // check how many bit should use
         b[i].ub = log2(b[i].list.size());
         b[i].ht_size = pow(2, b[i].ub);

         hash_table_size += b[i].ht_size;

         // allocate a new space
         b[i].ht = new vector<Rule>[b[i].ht_size];

         for(j=0; j< b[i].list.size(); j++) {
            v = b[i].list[j].range[b[i].uf][0];

            // select first (32 - bits) bits to hash
            if((i==0) || (i==1)) 
               v >>= (32 - bits);

            hash = exactHash(v, b[i].ub);
            b[i].ht[hash].push_back(b[i].list[j]);
         }
         bucket_big_group[i][b[i].list.size()]++;
      }
   }

   return hash_table_size;
}


/* 
 * ===  FUNCTION  ======================================================================
 *  Description:  Construct hierarchical with segment table & big segment table & group 
                  table & protocol table. 
 * =====================================================================================
 */
void KSet::ConstructClassifier(const vector<Rule>& rules) {
   uint32_t hashkey = 0;
   int i, j;

   // allocate rules to segment table's cell with different subset 
   for(i=0; i<rules.size(); i++) {
      // different subset have different hash method
      switch(num) {
         case 0:
            hashkey = rules[i].range[0][0] >> locate_segment;
            hashkey <<= usedbit;
            hashkey += (rules[i].range[1][0] >> locate_segment);
            hashkey = hashSet0(hashkey, usedbit);
            break;
         case 1:
            hashkey = rules[i].range[0][0] >> locate_segment;
            break;
         case 2:
            hashkey = rules[i].range[1][0] >> locate_segment;
            break;
         case 3:
            hashkey = 0;
            break;
         default:
            printf("not suitable case.\n");
      }
      nodeKSet[hashkey].classifier.push_back(rules[i]);
      nodeKSet[hashkey].nrules++;      
   }

   // traverse rule table
   for(i=0; i<tablesize; i++) {

      if(nodeKSet[i].nrules == 0)
         NULL_Node_Count++;
      else if(nodeKSet[i].nrules <= threshold) { // small segment
         nodeKSet[i].flag = 0;
         Small_Node_Count++;
         Total_Rules_in_Linear_Node += nodeKSet[i].nrules;
      }
      else { // big segment
         nodeKSet[i].flag = 1;
         Big_Node_Count++;
         Total_Rules_in_Big_Node += nodeKSet[i].nrules;

         // if this is in subset 0-2
         if(num != 3) 
            Total_Tablesize_in_Big_Node += simple_part(nodeKSet[i].classifier, nodeKSet[i].b, nodeKSet[i].rmd, bigSetPrefix, threshold2, num_group, bucket_small_group, bucket_big_group);
         else // just for subset 3
            Total_Tablesize_in_Big_Node += simple_part(nodeKSet[i].classifier, nodeKSet[i].b, nodeKSet[i].rmd, bigSetPrefix3, threshold2, num_group, bucket_small_group, bucket_big_group);


         /* check remained */
         // remained queue is empty
         if(nodeKSet[i].rmd.size() == 0)
            nodeKSet[i].r_flag = -1;
         // remained queue is small group, can use linear search
         else if(nodeKSet[i].rmd.size() <= threshold2) { 
            nodeKSet[i].r_flag = 0;
            Total_Tablesize_in_Big_Node++;
         }
         // remained queue is big group, it should be divide by protocol(tcp/udp & other)
         else { 
            nodeKSet[i].r_flag = 1;
            Total_Tablesize_in_Big_Node += 3;
            printf("******************************************************\n");
            for(j=0; j<nodeKSet[i].rmd.size(); j++) {
               if(nodeKSet[i].r_max_pri < nodeKSet[i].rmd[j].priority)
                  nodeKSet[i].r_max_pri = nodeKSet[i].rmd[j].priority;
               /* 
                  rmdp[0] = tcp 
                  rmdp[1] = udp
                  rmdp[2] = other
               */
               if(nodeKSet[i].rmd[j].range[4][0] == 6) { // tcp
                  nodeKSet[i].rmdp[0].push_back(nodeKSet[i].rmd[j]);
                  if(nodeKSet[i].rp_max_pri[0] < nodeKSet[i].rmd[j].priority)
                     nodeKSet[i].rp_max_pri[0] = nodeKSet[i].rmd[j].priority;
               }
               else if(nodeKSet[i].rmd[j].range[4][0] == 17) { // udp
                  nodeKSet[i].rmdp[1].push_back(nodeKSet[i].rmd[j]);
                  if(nodeKSet[i].rp_max_pri[1] < nodeKSet[i].rmd[j].priority)
                     nodeKSet[i].rp_max_pri[1] = nodeKSet[i].rmd[j].priority;
               }
               else {
                  nodeKSet[i].rmdp[2].push_back(nodeKSet[i].rmd[j]);
                  if(nodeKSet[i].rp_max_pri[2] < nodeKSet[i].rmd[j].priority)
                     nodeKSet[i].rp_max_pri[2] = nodeKSet[i].rmd[j].priority;
               }
            }
         }

      }
   }
   printf("Subset %d - hash table size: %d, NULL segment node:%d, small segment node:%d, big segment node:%d\n", num, tablesize, NULL_Node_Count, Small_Node_Count, Big_Node_Count);
   printf("===== Group Distribution =====\n");
   printf("# of rules in G0:%d, G1:%d, G2:%d, G3:%d, G4:%d\n\n", num_group[0], num_group[1], num_group[2], num_group[3], num_group[4]);
   for(j=0;j<3;j++){
      printf("===== Group %d Distribution =====\n",j);
      for(i=0;i<10;i++){
         if(bucket_small_group[j][i] != 0)
            printf("G%d small group bucket size %d = %d\n", j, i, bucket_small_group[j][i]);
      }
      for(i=0;i<200;i++){
         if(bucket_big_group[j][i] != 0)
            printf("G%d big group bucket size %d = %d\n", j, i, bucket_big_group[j][i]);
      }
      printf("\n");
   }
   printf("===== Remained Rules Protocol Distribution =====\n");
   printf("Total Remained Rules:%d, TCP:%d, UDP:%d, Others:%d\n", nodeKSet[i].rmd.size(), nodeKSet[i].rmdp[0].size(), nodeKSet[i].rmdp[1].size(), nodeKSet[i].rmdp[2].size());
}


// under untrace 2022/02/26

int linear_search(const Packet &packet, const vector<Rule> &rules) {
   int match_id = -1;
   int i;

   for(i=0; i<rules.size(); i++) {
      if((packet[0] >= rules[i].range[0][0]) && (packet[0] <= rules[i].range[0][1]) &&
         (packet[1] >= rules[i].range[1][0]) && (packet[1] <= rules[i].range[1][1]) &&
         (packet[2] >= rules[i].range[2][0]) && (packet[2] <= rules[i].range[2][1]) &&
         (packet[3] >= rules[i].range[3][0]) && (packet[3] <= rules[i].range[3][1]) &&
         (packet[4] >= rules[i].range[4][0]) && (packet[4] <= rules[i].range[4][1])) {
         match_id = rules[i].priority;
         break;
      }
   }

   return match_id;
}

int KSet::ClassifyAPacket(const Packet &packet) {
   int i;
   uint32_t value = 0;
   uint32_t v2;
   int h2;
   int match_id = -1;

   // find segment node
   switch(num) {
      case 0:
         value = packet[0] >> locate_segment;
         value <<= usedbit;
         value += (packet[1] >> locate_segment);
         value = hashSet0(value, usedbit);
         break;
      case 1:
         value = packet[0] >> locate_segment;
         break;
      case 2:
         value = packet[1] >> locate_segment;
         break;
      case 3:
         value = 0;
         break;
      default:
         printf("not suitable case.\n");
   }

   if(nodeKSet[value].flag == 0) { // small
      match_id = linear_search(packet, nodeKSet[value].classifier);
   }
   else if(nodeKSet[value].flag == 1) { // big
      
      for(i=0; i<4; i++) {
         if(nodeKSet[value].b[i].bf == 0) { // small list
            match_id = max(match_id, linear_search(packet, nodeKSet[value].b[i].list));
         }
         else if(nodeKSet[value].b[i].bf == 1) { // big hash
            // check used field, then do hash
            v2 = packet[nodeKSet[value].b[i].uf];
            if((i == 0) || (i == 1)) {
               if(num != 3) {
                  v2 >>= (32 - bigSetPrefix);
               }
               else {
                  v2 >>= (32 - bigSetPrefix3);
               }
            }

            h2 = exactHash(v2, nodeKSet[value].b[i].ub);
            match_id = max(match_id, linear_search(packet, nodeKSet[value].b[i].ht[h2]));
         }

      }
      // search remainder
      if(nodeKSet[value].r_flag == 0) {
         if(nodeKSet[value].r_max_pri > match_id) {
            match_id = max(match_id, linear_search(packet, nodeKSet[value].rmd));
         }
      }
      else if(nodeKSet[value].r_flag == 1){
         if(packet[4] == 6) { // tcp
            if(nodeKSet[value].rp_max_pri[0] > match_id) {
               match_id = max(match_id, linear_search(packet, nodeKSet[value].rmdp[0]));
            }
         }
         else if(packet[4] == 17) { // udp
            if(nodeKSet[value].rp_max_pri[1] > match_id) {
               match_id = max(match_id, linear_search(packet, nodeKSet[value].rmdp[1]));
            }
         }
         // remainder 2
         if(nodeKSet[value].rp_max_pri[2] > match_id) {
            match_id = max(match_id, linear_search(packet, nodeKSet[value].rmdp[2]));
         }
      }


   }


   return match_id;
}

void linear_delete(const Rule& delete_rule, vector<Rule> &rules, int *nrules, int *numrules) {
   int i, j;
   int del_flag = 1; // default insert

   for(i=0; i<rules.size(); i++){
      if(rules[i].id == delete_rule.id &&
         rules[i].range[0][0] == delete_rule.range[0][0] &&
         rules[i].range[0][1] == delete_rule.range[0][1] &&
         rules[i].range[1][0] == delete_rule.range[1][0] &&
         rules[i].range[1][1] == delete_rule.range[1][1] &&
         rules[i].range[2][0] == delete_rule.range[2][0] &&
         rules[i].range[2][1] == delete_rule.range[2][1] &&
         rules[i].range[3][0] == delete_rule.range[3][0] &&
         rules[i].range[3][1] == delete_rule.range[3][1] &&
         rules[i].range[4][0] == delete_rule.range[4][0] &&
         rules[i].range[4][1] == delete_rule.range[4][1]) break;
   }
   if(i == (rules.size()-1)) { // not found
      del_flag = 0;
   }

   if(del_flag == 1) {
      for(j=i; j<(rules.size()-1); j++){
         rules[j]=rules[j+1];
      }
      rules.pop_back();
      (*nrules)--;
      (*numrules)--;
   }

}

void KSet::DeleteRule(const Rule& delete_rule) {
   uint32_t value = 0;
   int big_bits;
   uint32_t v2;
   int h2;

   // find segment node
   switch(num) {
      case 0:
         value = delete_rule.range[0][0] >> locate_segment;
         value <<= usedbit;
         value += (delete_rule.range[1][0] >> locate_segment);
         value = hashSet0(value, usedbit);
         break;
      case 1:
         value = delete_rule.range[0][0] >> locate_segment;
         break;
      case 2:
         value = delete_rule.range[1][0] >> locate_segment;
         break;
      case 3:
         value = 0;
         break;
      default:
         printf("not suitable case.\n");
   }

   if(nodeKSet[value].flag == 0) { // small
      if(nodeKSet[value].nrules > 0){
         linear_delete(delete_rule, nodeKSet[value].classifier, &nodeKSet[value].nrules, &numrules);

      }
   }
   else if(nodeKSet[value].flag == 1) { // big
      if(nodeKSet[value].nrules > 0){
         if(num != 3) {
            big_bits = bigSetPrefix;
         }
         else {
            big_bits = bigSetPrefix3;
         }
         // find which b[]
         if(delete_rule.prefix_length[0] >= big_bits) { // SrcIP
            if(nodeKSet[value].b[0].bf == 0) { // list
               linear_delete(delete_rule, nodeKSet[value].b[0].list, &nodeKSet[value].nrules, &numrules);
            }
            else if(nodeKSet[value].b[0].bf == 1) { // hash table
               v2 = delete_rule.range[0][0] >> (32 - big_bits);
               h2 = exactHash(v2, nodeKSet[value].b[0].ub);
               linear_delete(delete_rule, nodeKSet[value].b[0].ht[h2], &nodeKSet[value].nrules, &numrules);
            }
         }
         else if(delete_rule.prefix_length[1] >= big_bits) { // DstIP
            if(nodeKSet[value].b[1].bf == 0) { // list
               linear_delete(delete_rule, nodeKSet[value].b[1].list, &nodeKSet[value].nrules, &numrules);
            }
            else if(nodeKSet[value].b[1].bf == 1) { // hash table
               v2 = delete_rule.range[1][0] >> (32 - big_bits);
               h2 = exactHash(v2, nodeKSet[value].b[1].ub);
               linear_delete(delete_rule, nodeKSet[value].b[1].ht[h2], &nodeKSet[value].nrules, &numrules);
            }
         }
         else if(delete_rule.range[3][0] == delete_rule.range[3][1]) { // DstPort
            if(nodeKSet[value].b[2].bf == 0) { // list
               linear_delete(delete_rule, nodeKSet[value].b[2].list, &nodeKSet[value].nrules, &numrules);
            }
            else if(nodeKSet[value].b[2].bf == 1) { // hash table
               v2 = delete_rule.range[3][0];
               h2 = exactHash(v2, nodeKSet[value].b[2].ub);
               linear_delete(delete_rule, nodeKSet[value].b[2].ht[h2], &nodeKSet[value].nrules, &numrules);
            }
         }
         else if(delete_rule.range[2][0] == delete_rule.range[2][1]) { // SrcPort
            if(nodeKSet[value].b[3].bf == 0) { // list
               linear_delete(delete_rule, nodeKSet[value].b[3].list, &nodeKSet[value].nrules, &numrules);
            }
            else if(nodeKSet[value].b[3].bf == 1) { // hash table
               v2 = delete_rule.range[2][0];
               h2 = exactHash(v2, nodeKSet[value].b[3].ub);
               linear_delete(delete_rule, nodeKSet[value].b[3].ht[h2], &nodeKSet[value].nrules, &numrules);
            }
         }
         else { // rmd
            if(nodeKSet[value].r_flag == 0) {
               linear_delete(delete_rule, nodeKSet[value].rmd, &nodeKSet[value].nrules, &numrules);
            }
            else if(nodeKSet[value].r_flag == 1) {
               if(delete_rule.range[4][0] == 6) { // tcp
                  linear_delete(delete_rule, nodeKSet[value].rmdp[0], &nodeKSet[value].nrules, &numrules);
               }
               else if(delete_rule.range[4][0] == 17) { // udp
                  linear_delete(delete_rule, nodeKSet[value].rmdp[1], &nodeKSet[value].nrules, &numrules);
               }
               else { // other
                  linear_delete(delete_rule, nodeKSet[value].rmdp[2], &nodeKSet[value].nrules, &numrules);
               }
            }
         }

      }
   }
   else if(nodeKSet[value].flag == -1){
      printf("num = %d, the segment is empty, delete failed! rule id=%d\n", num, delete_rule.id);
   }
}

void linear_insert(const Rule& insert_rule, vector<Rule> &rules, int *nrules, int *numrules) {
   int i;
   int ins_flag = 1; // default insert

   // if alreadly exist
   for(i=0;i<rules.size();i++){
      if(rules[i].id == insert_rule.id &&
         rules[i].range[0][0] == insert_rule.range[0][0] &&
         rules[i].range[0][1] == insert_rule.range[0][1] &&
         rules[i].range[1][0] == insert_rule.range[1][0] &&
         rules[i].range[1][1] == insert_rule.range[1][1] &&
         rules[i].range[2][0] == insert_rule.range[2][0] &&
         rules[i].range[2][1] == insert_rule.range[2][1] &&
         rules[i].range[3][0] == insert_rule.range[3][0] &&
         rules[i].range[3][1] == insert_rule.range[3][1] &&
         rules[i].range[4][0] == insert_rule.range[4][0] &&
         rules[i].range[4][1] == insert_rule.range[4][1]) {
         ins_flag = 0;
         break;
      }
   }
   if(ins_flag == 1) {
      rules.insert(upper_bound(rules.begin(), rules.end(), insert_rule, cmpp), insert_rule);
      (*nrules)++;
      (*numrules)++;
   }

}

void KSet::InsertRule(const Rule& insert_rule) {
   uint32_t value = 0;
   int big_bits;
   uint32_t v2;
   int h2;

   // find segment node
   switch(num) {
      case 0:
         value = insert_rule.range[0][0] >> locate_segment;
         value <<= usedbit;
         value += (insert_rule.range[1][0] >> locate_segment);
         value = hashSet0(value, usedbit);
         break;
      case 1:
         value = insert_rule.range[0][0] >> locate_segment;
         break;
      case 2:
         value = insert_rule.range[1][0] >> locate_segment;
         break;
      case 3:
         value = 0;
         break;
      default:
         printf("not suitable case.\n");
   }

   if(nodeKSet[value].flag == 0) { // small
      if(nodeKSet[value].nrules > 0){
         linear_insert(insert_rule, nodeKSet[value].classifier, &nodeKSet[value].nrules, &numrules);
      }
   }
   else if(nodeKSet[value].flag == 1) { // big
      if(nodeKSet[value].nrules > 0){
         if(num != 3) {
            big_bits = bigSetPrefix;
         }
         else {
            big_bits = bigSetPrefix3;
         }
         // find which b[]
         if(insert_rule.prefix_length[0] >= big_bits) { // SrcIP
            if(nodeKSet[value].b[0].bf == 0) { // list
               linear_insert(insert_rule, nodeKSet[value].b[0].list, &nodeKSet[value].nrules, &numrules);
            }
            else if(nodeKSet[value].b[0].bf == 1) { // hash table
               v2 = insert_rule.range[0][0] >> (32 - big_bits);
               h2 = exactHash(v2, nodeKSet[value].b[0].ub);
               linear_insert(insert_rule, nodeKSet[value].b[0].ht[h2], &nodeKSet[value].nrules, &numrules);
            }
            else if(nodeKSet[value].b[0].bf == -1) { // no space create for list
               nodeKSet[value].b[0].bf = 0;
               nodeKSet[value].b[0].uf = 0;
               linear_insert(insert_rule, nodeKSet[value].b[0].list, &nodeKSet[value].nrules, &numrules);
            }
         }
         else if(insert_rule.prefix_length[1] >= big_bits) { // DstIP
            if(nodeKSet[value].b[1].bf == 0) { // list
               linear_insert(insert_rule, nodeKSet[value].b[1].list, &nodeKSet[value].nrules, &numrules);
            }
            else if(nodeKSet[value].b[1].bf == 1) { // hash table
               v2 = insert_rule.range[1][0] >> (32 - big_bits);
               h2 = exactHash(v2, nodeKSet[value].b[1].ub);
               linear_insert(insert_rule, nodeKSet[value].b[1].ht[h2], &nodeKSet[value].nrules, &numrules);
            }
            else if(nodeKSet[value].b[1].bf == -1) { // no space create for list
               nodeKSet[value].b[1].bf = 0;
               nodeKSet[value].b[1].uf = 1;
               linear_insert(insert_rule, nodeKSet[value].b[1].list, &nodeKSet[value].nrules, &numrules);
            }
         }
         else if(insert_rule.range[3][0] == insert_rule.range[3][1]) { // DstPort
            if(nodeKSet[value].b[2].bf == 0) { // list
               linear_insert(insert_rule, nodeKSet[value].b[2].list, &nodeKSet[value].nrules, &numrules);
            }
            else if(nodeKSet[value].b[2].bf == 1) { // hash table
               v2 = insert_rule.range[3][0];
               h2 = exactHash(v2, nodeKSet[value].b[2].ub);
               linear_insert(insert_rule, nodeKSet[value].b[2].ht[h2], &nodeKSet[value].nrules, &numrules);
            }
            else if(nodeKSet[value].b[2].bf == -1) { // no space create for list
               nodeKSet[value].b[2].bf = 0;
               nodeKSet[value].b[2].uf = 3;
               linear_insert(insert_rule, nodeKSet[value].b[2].list, &nodeKSet[value].nrules, &numrules);
            }
         }
         else if(insert_rule.range[2][0] == insert_rule.range[2][1]) { // SrcPort
            if(nodeKSet[value].b[3].bf == 0) { // list
               linear_insert(insert_rule, nodeKSet[value].b[3].list, &nodeKSet[value].nrules, &numrules);
            }
            else if(nodeKSet[value].b[3].bf == 1) { // hash table
               v2 = insert_rule.range[2][0];
               h2 = exactHash(v2, nodeKSet[value].b[3].ub);
               linear_insert(insert_rule, nodeKSet[value].b[3].ht[h2], &nodeKSet[value].nrules, &numrules);
            }
            else if(nodeKSet[value].b[3].bf == -1) { // no space create for list
               nodeKSet[value].b[3].bf = 0;
               nodeKSet[value].b[3].uf = 2;
               linear_insert(insert_rule, nodeKSet[value].b[3].list, &nodeKSet[value].nrules, &numrules);
            }
         }
         else { // rmd
            if(nodeKSet[value].r_flag == 0) {
               linear_insert(insert_rule, nodeKSet[value].rmd, &nodeKSet[value].nrules, &numrules);
            }
            else if(nodeKSet[value].r_flag == 1) {
               if(insert_rule.range[4][0] == 6) { // tcp
                  linear_insert(insert_rule, nodeKSet[value].rmdp[0], &nodeKSet[value].nrules, &numrules);
               }
               else if(insert_rule.range[4][0] == 17) { // udp
                  linear_insert(insert_rule, nodeKSet[value].rmdp[1], &nodeKSet[value].nrules, &numrules);
               }
               else { // other
                  linear_insert(insert_rule, nodeKSet[value].rmdp[2], &nodeKSet[value].nrules, &numrules);
               }
            }
            else if(nodeKSet[value].r_flag == -1) { // no space create for list
               nodeKSet[value].r_flag = 0;
               linear_insert(insert_rule, nodeKSet[value].rmd, &nodeKSet[value].nrules, &numrules);
            }
         }
      }
   }
   else if(nodeKSet[value].flag == -1){
      //printf("num = %d, the segment is empty, create a new segment! rule id=%d\n", num, insert_rule.id);
      nodeKSet[value].flag = 0;
      nodeKSet[value].nrules++;
      nodeKSet[value].classifier.push_back(insert_rule);
      nodeKSet[value].classifier.insert(upper_bound(nodeKSet[value].classifier.begin(), nodeKSet[value].classifier.end(), insert_rule, cmpp), insert_rule);
      numrules++;
   }

}
