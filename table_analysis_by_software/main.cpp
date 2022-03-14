/* include lib */
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <algorithm>
#include "./rule.h"
#include "./KSet/KSet.h"
// Huwang version add
#include <sys/stat.h>
#include <time.h>
#include <sys/types.h>

using namespace std;
       

/*** Using rdtscp to count this method's performance ***/
__inline__ uint64_t perf_counter(void)
{
  uint32_t lo, hi;
  // take time stamp counter, rdtscp does serialize by itself, and is much cheaper than using CPUID
  __asm__ __volatile__ (
      "rdtscp" : "=a"(lo), "=d"(hi)
      );
  return ((uint64_t)lo) | (((uint64_t)hi) << 32);
}


/*** User define global parameter ***/
int classificationFlag = 1; // do classification or not, if 1=do, 0=undo
int updateFlag = 0; // do update or not, if 1=do, 0=undo
int threshold = 10; // small size bucket linear search threshold
/* Analysis for KSet */
int pre_K = 16;
int SetBits[3] = {8, 8, 8}; // in default, cut bit length will be 8
int max_pri_set[4] = {-1,-1,-1,-1};
int seed = 11;// ??
/* File operation parameter define*/
FILE *fpr; // ruleset file
FILE *fpt; //  trace file


/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  loadrule(FILE *fp)
 *  Description:  load rules from rule file
 * =====================================================================================
 */
vector<Rule> loadrule(FILE *fp) {
   vector<Rule> rule_table; // initial rule table
   uint32_t tmp; // store something temp
   uint32_t max_uint = 0xFFFFFFFF;
   uint32_t mask;
   uint32_t sip1,sip2,sip3,sip4,smask;
   uint32_t dip1,dip2,dip3,dip4,dmask;
   uint32_t sport1,sport2;
   uint32_t dport1,dport2;
   uint32_t protocal,protocol_mask;
   uint32_t ht, htmask;
   
   int i;
   int number_rule=0; // use to count number of rules
   
   // loop to read table from file
   while(1){
      Rule r;
      array<uint32_t,2> points;// foramt: [(uint32_t,uint32_t), (uint32_t,uint32_t), (uint32_t,uint32_t) ...]

      // fscanf return value 18 mean there are 18 field need read
      if(fscanf(fp,"@%d.%d.%d.%d/%d\t%d.%d.%d.%d/%d\t%d : %d\t%d : %d\t%x/%x\t%x/%x\n",
               &sip1, &sip2, &sip3, &sip4, &smask, &dip1, &dip2, &dip3, &dip4, &dmask, &sport1, &sport2,
               &dport1, &dport2,&protocal, &protocol_mask, &ht, &htmask)!= 18) break;

      // Set this rule attribute
      if(smask == 0) {
         points[0] = 0;
         points[1] = 0xFFFFFFFF;
      } 
      else if(smask > 0 && smask <= 8) {
         tmp = sip1<<24;
         mask = ~(max_uint >> smask);
         tmp &= mask;
         points[0] = tmp;
         points[1] = points[0] + (1<<(32-smask)) - 1;
      } 
      else if(smask > 8 && smask <= 16) {
         tmp = sip1<<24; 
         tmp += sip2<<16;
         mask = ~(max_uint >> smask);
         tmp &= mask;
         points[0] = tmp;
         points[1] = points[0] + (1<<(32-smask)) - 1;
      } 
      else if(smask > 16 && smask <= 24) {
         tmp = sip1<<24; 
         tmp += sip2<<16; 
         tmp +=sip3<<8;
         mask = ~(max_uint >> smask);
         tmp &= mask;
         points[0] = tmp;
         points[1] = points[0] + (1<<(32-smask)) - 1;
      } 
      else if(smask > 24 && smask <= 32) {
         tmp = sip1<<24; 
         tmp += sip2<<16; 
         tmp += sip3<<8; 
         tmp += sip4;
         mask = smask != 32 ? ~(max_uint >> smask) : max_uint;
         tmp &= mask;
         points[0] = tmp;
         points[1] = points[0] + (1<<(32-smask)) - 1;
      }
      else {
         printf("Src IP length exceeds 32\n");
         exit(-1);
      }
      r.range[0] = points;

      if(dmask == 0) {
         points[0] = 0;
         points[1] = 0xFFFFFFFF;
      }
      else if(dmask > 0 && dmask <= 8) {
         tmp = dip1<<24;
         mask = ~(max_uint >> dmask);
         tmp &= mask; 
         points[0] = tmp;
         points[1] = points[0] + (1<<(32-dmask)) - 1;
      }
      else if(dmask > 8 && dmask <= 16) {
         tmp = dip1<<24; 
         tmp +=dip2<<16;
         mask = ~(max_uint >> dmask);
         tmp &= mask; 
         points[0] = tmp;
         points[1] = points[0] + (1<<(32-dmask)) - 1;
      }
      else if(dmask > 16 && dmask <= 24) {
         tmp = dip1<<24; 
         tmp +=dip2<<16; 
         tmp+=dip3<<8;
         mask = ~(max_uint >> dmask);
         tmp &= mask; 
         points[0] = tmp;
         points[1] = points[0] + (1<<(32-dmask)) - 1;
      }
      else if(dmask > 24 && dmask <= 32) {
         tmp = dip1<<24; 
         tmp +=dip2<<16; 
         tmp+=dip3<<8; 
         tmp +=dip4;
         mask = dmask != 32 ? ~(max_uint >> dmask) : max_uint;
         tmp &= mask;
         points[0] = tmp;
         points[1] = points[0] + (1<<(32-dmask)) - 1;
      }
      else {
         printf("Dest IP length exceeds 32\n");
         exit(-1);
      }
      r.range[1] = points;

      points[0] = sport1;
      points[1] = sport2;
      r.range[2] = points;

      points[0] = dport1;
      points[1] = dport2;
      r.range[3] = points;

      if(protocol_mask == 0xFF) {
         points[0] = protocal;
         points[1] = protocal;
      }
      else if(protocol_mask== 0) {
         points[0] = 0;
         points[1] = 0xFF;
      }
      else {
         printf("Protocol mask error\n");
         exit(-1);
      }
      r.range[4] = points;

      r.prefix_length[0] = smask;
      r.prefix_length[1] = dmask;
      r.id = number_rule;

      rule_table.push_back(r);
      number_rule++;
   }

   printf("\nRead from outside file. # of rules = %d\n", number_rule);
   
   int max_pri = number_rule-1;
   for(i=0;i<number_rule;i++){
     rule_table[i].priority = max_pri - i;//set rule priority
     /* use to check rule table content success read from file
       printf("%u: %u:%u %u:%u %u:%u %u:%u %u:%u %d\n", i,
       rule[i].range[0][0], rule[i].range[0][1],
       rule[i].range[1][0], rule[i].range[1][1],
       rule[i].range[2][0], rule[i].range[2][1],
       rule[i].range[3][0], rule[i].range[3][1],
       rule[i].range[4][0], rule[i].range[4][1],
       rule[i].priority);
      */
   }
   return rule_table;
}


/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  loadpacket(FILE *fp)
 *  Description:  load packets from trace file generated from ClassBench[INFOCOM2005]
 * =====================================================================================
 */
vector<Packet> loadpacket(FILE *fp)
{
   vector<Packet> packets_table;
   unsigned int header[MAXDIMENSIONS];
   unsigned int proto_mask, fid;
   int number_pkt=0; //number of packets
   
   while(1){
      if(fscanf(fp,"%u %u %d %d %d %u %d\n",&header[0], &header[1], &header[2], &header[3], &header[4], 
               &proto_mask, &fid) == -1) break;
      Packet p;
      p.push_back(header[0]);
      p.push_back(header[1]);
      p.push_back(header[2]);
      p.push_back(header[3]);
      p.push_back(header[4]);
      p.push_back(fid);

      packets_table.push_back(p);
      number_pkt++;
   }
   /* use to check trace table content success read from file
   printf("the number of packets = %d\n", number_pkt);
   for(int i=0;i<number_pkt;i++){
      printf("%u: %u %u %u %u %u %u\n", i,
      packets[i][0],
      packets[i][1],
      packets[i][2],
      packets[i][3],
      packets[i][4],
      packets[i][5]);
   }*/

   return packets_table;
}


/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  parseargs(int argc, char *argv[])
 *  Description:  Parse arguments from the console
 * =====================================================================================
 */
void parseargs(int argc, char *argv[])
{
   int c; 
   while ((c = getopt(argc, argv, "k:t:r:e:c:u:h")) != -1){
      switch (c) {
         case 'k':
            //k = atoi(optarg);
            break;
         case 't':
            seed = atoi(optarg);
            break;
         case 'r':  //rule set
            fpr = fopen(optarg, "r");
            break;
         case 'e':  //trace packets for simulations
            fpt = fopen(optarg, "r");
            break;                       
         case 'c':  //classification simulation          
            classificationFlag = atoi(optarg);
            break;            
         case 'u':  //update simulation
            updateFlag = atoi(optarg);
            break;
         case 'h': //help
            printf("./main [-k k][-r ruleset][-e trace][-c (1:classification)][-u (1:update)]\n");
            printf("e.g., ./main -k 8 -r ./ruleset/ipc1_10k -e ./ruleset/ipc1_10k_trace -c 1 -u 1\n");
            exit(1);
            break;
      }
   }
}


/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  count_uni_field(const vector<Rule> &rule, const int number_rule)
 *  Description:  Analyze how many unique range field of 5-dimention
 * =====================================================================================
 */
void count_uni_field(const vector<Rule> &rule, const int number_rule) {
   int i, j, k;
   vector<r_uni> uni_r[5];
   int flag = 0; // this flag mean this range have been insert to queue, not need to do insert operation

   // traverse all rules
   for(i=0; i<number_rule; i++) {
      // check for 5-dimension of this rule
      for(j=0; j<5; j++) {
         flag = 0;

         // check this rule range whether exist in now queue
         for(k=0; k<uni_r[j].size(); k++) { 
            // use this range's upper bound and lower bound to check equal or not
            if((uni_r[j][k].lo == rule[i].range[j][0]) && (uni_r[j][k].hi == rule[i].range[j][1])) {
               flag = 1;
               uni_r[j][k].num++;
               break;
            }
         }

         // this rule not found in now queue, insert to queue
         if(flag == 0) { 
            r_uni tmp;
            tmp.lo = rule[i].range[j][0];
            tmp.hi = rule[i].range[j][1];
            tmp.num = 1;
            uni_r[j].push_back(tmp);
         }
      }
   }

   printf("\n========== Analyze Unique field ==========\n");
   printf("SA: %d, DA: %d, SP: %d, DP: %d, Proto: %d\n", uni_r[0].size(), uni_r[1].size(), uni_r[2].size(), uni_r[3].size(), uni_r[4].size());
   printf("\n========================================\n");

   /* Des Port analyze format
   for(i=0; i<uni_r[3].size(); i++)
      printf("lower bound:%d, upper bound:%d, num:%d\n", uni_r[3][i].lo, uni_r[3][i].hi, uni_r[3][i].num);
   */
}

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  count_dinst_field(const vector<Rule> &rule, const int number_rule)
 *  Description:  Analyze how many unique exact field of 5-dimention
 * =====================================================================================
 */
void count_dinst_field(const vector<Rule> &rule, const int number_rule) {
   int i, j, k;
   int flag = 0; // this flag mean this exact field have been insert to queue, not need to do insert operation
   vector<int> uni_r[5];

   for(i=0; i<number_rule; i++) {
      for(j=0; j<5; j++) {
         flag = 0;

         // check this value of field is exact value
         if(rule[i].range[j][0] == rule[i].range[j][1]) {
            // check this value whether exist in now queue
            for(k=0; k<uni_r[j].size(); k++) { 
               if(uni_r[j][k] == rule[i].range[j][0]) { 
                  flag = 1;
                  break;
               }
            }

            // this rule not found in now queue, insert to queue
            if(flag == 0) 
               uni_r[j].push_back(rule[i].range[j][0]);
         }
      }
   }

   printf("\n========== Unique single(exact) value ==========\n");
   printf("SA: %d, DA: %d, SP: %d, DP: %d, Proto: %d\n", uni_r[0].size(), uni_r[1].size(), uni_r[2].size(), uni_r[3].size(), uni_r[4].size());
   printf("\n========================================\n");
}


/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  count_prefix_dist(const vector<Rule> &rule, const int number_rule)
 *  Description:  Analyze Src/Des prefix distribution of rule table
 * =====================================================================================
 */
void count_prefix_dist(const vector<Rule> &rule, const int number_rule) {
   int i, j, k;
   int rule_pf_length;
   int src_prefix_length[33] = {0};
   int des_prefix_length[33] = {0};

   printf("\n========== In Count Prefix Distribution Function ==========\n");

   // traverse all rules
   for(i=0; i<number_rule; i++) {
      rule_pf_length = rule[i].prefix_length[0];
      src_prefix_length[rule_pf_length]++;
      rule_pf_length = rule[i].prefix_length[1];
      des_prefix_length[rule_pf_length]++;
   }

   printf("\n===== Src IP address prefix distribution =====\n");
   for(j=0; j<33; j++)
      printf("%d: %.4f %%\n", j, ((float)src_prefix_length[j]/number_rule)*100);
   printf("\n=============================================\n");

   printf("\n===== Des IP address prefix distribution =====\n");
   for(j=0; j<33; j++)
      printf("%d: %.4f %%\n", j, ((float)des_prefix_length[j]/number_rule)*100);
   printf("\n=============================================\n");
}

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  anaK(const int number_rule, const vector<Rule> &rule, int *usedbits, vector<Rule> set[4], int k)
 *  Description:  Analyze about subset information
 * =====================================================================================
 */
void anaK(const int number_rule, const vector<Rule> &rule, int *usedbits, vector<Rule> set[4], int k) {
   int i, j;

   uint32_t tmpKey;
   int hash;

   int pre_seg[4] = {0}; // count # of rules in this subset
   int max[3] = {-1};
   anaSet Set[3]; // subset 0-2, this parameter just for analyze some infomation about subset, real rule will store in "set" parameter

   // traverse all rules
   for(i=0; i<number_rule; i++) {
      /* Set 0
         1. src address prefix length >= 16
         2. des address prefix length >= 16
      */
      if((rule[i].prefix_length[0]>=k) && (rule[i].prefix_length[1]>=k)) {
         // find out max priority rule in this subset
         if(rule[i].priority>max_pri_set[0]) 
            max_pri_set[0]=rule[i].priority;
         pre_seg[0]++;
      }
      /* Set 1
         1. src address prefix length >= 16
         2. des address prefix length < 16
      */
      else if((rule[i].prefix_length[0]>=k) && (rule[i].prefix_length[1]<k)) {
         if(rule[i].priority>max_pri_set[1]) 
            max_pri_set[1]=rule[i].priority;
         pre_seg[1]++;
      }
      /* Set 2
         1. src address prefix length < 16
         2. des address prefix length >= 16
      */
      else if((rule[i].prefix_length[0]<k) && (rule[i].prefix_length[1]>=k)) {
         if(rule[i].priority>max_pri_set[2]) 
            max_pri_set[2]=rule[i].priority;
         pre_seg[2]++;
      }
      /* Set 3
         1. src address prefix length < 16
         2. des address prefix length < 16
      */
      else {
         if(rule[i].priority>max_pri_set[3]) 
            max_pri_set[3]=rule[i].priority;
         pre_seg[3]++;
      }
   }
   printf("\n========== Pre-Compute ==========\n");
   printf("\n========== # of rule in each subset ==========\n");
   printf("Set 0: %d, Set 1: %d, Set 2: %d, Set 3: %d\n\n", pre_seg[0], pre_seg[1], pre_seg[2], pre_seg[3]);
   printf("\n========== max priority rule in each subset ==========\n");
   printf("max_pri[0]: %d, max_pri[1]: %d, max_pri[2]: %d, max_pri[3]: %d\n\n", max_pri_set[0], max_pri_set[1], max_pri_set[2], max_pri_set[3]);
   
   /*
   // compute how many bits should use
   for(i=0; i<3; i++) {
      if(pre_seg[i] == 0) // used bit = 0
         continue;

      if(8<log2(pre_seg[i])<16) // 8 < used bit < 16
         usedbits[i] = log2(pre_seg[i]);
      else if(16<log2(pre_seg[i])) // 16 < used bit 
         usedbits[i] = 16;
      else // used bit < 16
         usedbits[i] = 8;
   }
   */
   // in FPGA design, we all use 16 bits to store
   for(i=0;i<3;i++)
      usedbits[i] = 16;

   printf("========== How many bits used to describe this subset ==========\n");
   printf("Set 0: %d bits, Set 1: %d bits, Set 2: %d bits\n\n", usedbits[0], usedbits[1], usedbits[2]);


   // reset max priority of each set
   for(i=0; i<4; i++) 
      max_pri_set[i] = -1;

   // put rules in each set and analyze
   for(i=0; i<3; i++) {
      Set[i].tablesize = pow(2, usedbits[i]);
      Set[i].seg = new int[Set[i].tablesize];

      for(j=0;j<Set[i].tablesize;j++)
         Set[i].seg[j] = 0;
   }

   // traverse all rules
   for(i=0; i<number_rule; i++) {
      /* Set 0
         1. src address prefix length >= k0
         2. des address prefix length >= k0
         in FPGA design k0=16
      */
      if((rule[i].prefix_length[0]>=usedbits[0]) && (rule[i].prefix_length[1]>=usedbits[0])) {
         set[0].push_back(rule[i]);
         if(rule[i].priority>max_pri_set[0]) 
            max_pri_set[0]=rule[i].priority;

         // compute orig_key - first 16 bits use src address first 16 bits and last 16 bits use dst addrsss 16 bits
         tmpKey = rule[i].range[0][0] >> (32-usedbits[0]);
         tmpKey <<= usedbits[0];
         tmpKey += (rule[i].range[1][0] >> (32-usedbits[0]));

         // compute real hash key for segment table
         hash = hashSet0(tmpKey, usedbits[0]);

         if(Set[0].seg[hash] == 0) // empty
            Set[0].non_empty_seg++;

         Set[0].seg[hash]++;
      }
      /* Set 1
         1. src address prefix length >= 16
         2. des address prefix length < 16
      */
      else if(rule[i].prefix_length[0]>=usedbits[1]) {
         set[1].push_back(rule[i]);
         if(rule[i].priority>max_pri_set[1]) 
            max_pri_set[1]=rule[i].priority;

         // compute hash key for segment table
         tmpKey = rule[i].range[0][0] >> (32-usedbits[1]);

         if(Set[1].seg[tmpKey] == 0) // empty
            Set[1].non_empty_seg++;

         Set[1].seg[tmpKey]++;
      }
      /* Set 2
         1. src address prefix length < 16
         2. des address prefix length >= 16
      */
      else if(rule[i].prefix_length[1]>=usedbits[2]) {
         set[2].push_back(rule[i]);
         if(rule[i].priority>max_pri_set[2]) 
            max_pri_set[2]=rule[i].priority;

         // compute hash key for segment table
         tmpKey = rule[i].range[1][0] >> (32-usedbits[2]);

         if(Set[2].seg[tmpKey] == 0) // empty
            Set[2].non_empty_seg++;

         Set[2].seg[tmpKey]++;
      }
      /* Set 3
         1. src address prefix length < 16
         2. des address prefix length < 16
      */
      else {
         set[3].push_back(rule[i]);
         if(rule[i].priority>max_pri_set[3]) 
            max_pri_set[3]=rule[i].priority;
      }
   }

   // find out # of rules max in segment
   for(i=0; i<3; i++) {
      for(j=0; j<Set[i].tablesize; j++) {
         if(max[i] < Set[i].seg[j])
            max[i] = Set[i].seg[j];
      }
   }

   printf("\n========== After Compute ==========\n");
   printf("===== # of rule in Subset 0-3 =====\n");
   printf("Set 0: %d, Set 1: %d, Set 2: %d, Set 3: %d\n\n", set[0].size(), set[1].size(), set[2].size(), set[3].size());
   printf("===== Max priority rule in each subset =====\n");
   printf("max_pri[0]: %d, max_pri[1]: %d, max_pri[2]: %d, max_pri[3]: %d\n\n", max_pri_set[0], max_pri_set[1], max_pri_set[2], max_pri_set[3]);
   printf("===== # of non empty segment in subset =====\n");
   printf("non-empty_seg[0] = %d, non-empty_seg[1] = %d, non-empty_seg[2] = %d\n\n", Set[0].non_empty_seg, Set[1].non_empty_seg, Set[2].non_empty_seg);
   printf("===== Average rules with every non-empty segment =====\n");
   printf("AVG[0]: %.3f, AVG[1]: %.3f, AVG[2]: %.3f\n\n", (float)set[0].size()/Set[0].non_empty_seg, (float)set[1].size()/Set[1].non_empty_seg, (float)set[2].size()/Set[2].non_empty_seg);
   printf("===== Max rules in subset's hashtable segment =====\n");
   printf("MAX[0]: %d, MAX[1]: %d, MAX[2]: %d\n\n", max[0], max[1], max[2]);
}


/* Non use in FPGA design, don't care it
void anaSet0(const vector<Rule>& rules, int usedbit) {
   int i, j;
   uint32_t value;
   uint32_t hash;
   int locate_segment= 32 - usedbit;
   vector <uint32_t> v_list, h_list;
   int v_flag, h_flag;

   for(i=0; i<rules.size(); i++) {
      value = rules[i].range[0][0] >> locate_segment;
      value <<= usedbit;
      value += (rules[i].range[1][0] >> locate_segment);
      hash = hashSet0(value, usedbit);

      // find distinct value
      v_flag = 0;
      for(j=0; j<v_list.size(); j++) {
         if(v_list[j] == value) {
            v_flag = 1;
            break;
         }
      }
      if(v_flag == 0)
         v_list.push_back(value);
      // find distinct hash
      h_flag = 0;
      for(j=0; j<h_list.size(); j++) {
         if(h_list[j] == hash) {
            h_flag = 1;
            break;
         }
      }
      if(h_flag == 0)
         h_list.push_back(hash);

   }
   printf("distinct value: %d, distinct_hash: %d\n", v_list.size(), h_list.size());
}
*/


/*
void priority_ratio(const vector<Rule> set[4]) { // old
   int i, j;
   int count[3] = {0}; // count number of rules which priority is bigger than next set's max priority

   if(max_pri_set[1] > max_pri_set[2]) {

      for(i=0; i<3; i++) {
         for(j=0; j<set[i].size(); j++) {
            if(set[i][j].priority > max_pri_set[i+1])
               count[i]++;
         }
      }      
   }
   else {
      // Set 0
      for(j=0; j<set[0].size(); j++) {
         if(set[0][j].priority > max_pri_set[2])
            count[0]++;
      }
      // Set 2
      for(j=0; j<set[2].size(); j++) {
         if(set[2][j].priority > max_pri_set[1])
            count[2]++;
      }
      // Set 1
      for(j=0; j<set[1].size(); j++) {
         if(set[1][j].priority > max_pri_set[3])
            count[1]++;
      }
   }
   printf("pri_ratio[0]: %.3f%%, pri_ratio[1]: %.3f%%, pri_ratio[2]: %.3f%%\n", (float)count[0]/set[0].size()*100, (float)count[1]/set[1].size()*100, (float)count[2]/set[2].size()*100);
}*/

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  priority_ratio(const vector<Rule> set[4])
 *  Description:  Count subset bigger than others subset ratio
 *                In FPGA, We don't care about it.
 * =====================================================================================
 */
void priority_ratio(const vector<Rule> set[4]) {
   int i, j;
   int count[3] = {0}; // count number of rules which priority is bigger than next set's max priority

   printf("\n========== Analyze Priority Ratio ==========\n");

   if(max_pri_set[1] > max_pri_set[2]) {
      printf("===== Subset 1 priority bigger than subset 2 =====\n");
      for(j=0; j<set[0].size(); j++) {
         // Set 0
         if(set[0][j].priority > max_pri_set[1])
            count[0]++;
         // Set 1
         if(set[0][j].priority > max_pri_set[2])
            count[1]++;
         // Set 2
         if(set[0][j].priority > max_pri_set[3])
            count[2]++;
      }
      for(j=0; j<set[1].size(); j++) {
         // Set 1
         if(set[1][j].priority > max_pri_set[2])
            count[1]++;
         // Set 2
         if(set[1][j].priority > max_pri_set[3])
            count[2]++;
      }
      for(j=0; j<set[2].size(); j++) {
         // Set 2
         if(set[2][j].priority > max_pri_set[3])
            count[2]++;
      }

      printf("pri_ratio[0]: %.3f%%, pri_ratio[1]: %.3f%%, pri_ratio[2]: %.3f%%\n\n", 
         (float)count[0]/set[0].size()*100, (float)count[1]/(set[0].size()+set[1].size())*100, (float)count[2]/(set[0].size()+set[1].size()+set[2].size())*100);
   }
   else { //max_pri_set[2] > max_pri_set[1]
      printf("===== Subset 2 priority bigger than subset 1 =====\n");

      for(j=0; j<set[0].size(); j++) {
         // Set 0
         if(set[0][j].priority > max_pri_set[2])
            count[0]++;
         // Set 1
         if(set[0][j].priority > max_pri_set[1])
            count[1]++;
         // Set 2
         if(set[0][j].priority > max_pri_set[3])
            count[2]++;
      }
      for(j=0; j<set[2].size(); j++) {
         // Set 1
         if(set[2][j].priority > max_pri_set[1])
            count[1]++;
         // Set 2
         if(set[2][j].priority > max_pri_set[3])
            count[2]++;
      }      
      for(j=0; j<set[1].size(); j++) {
         // Set 2
         if(set[1][j].priority > max_pri_set[3])
            count[2]++;
      }


      printf("pri_ratio[0]: %.3f%%, pri_ratio[1]: %.3f%%, pri_ratio[2]: %.3f%%\n\n", 
         (float)count[0]/set[0].size()*100, (float)count[1]/(set[0].size()+set[2].size())*100, (float)count[2]/(set[0].size()+set[1].size()+set[2].size())*100);
   }
}

int main(int argc, char const *argv[])
{
   /* parameter define */
   vector<Rule> rule_table, build_table, update_table;
   vector<Rule> set_4[4];
   vector<Packet> packets;
   vector<int> results;

   int i, j, t;
   int number_rule = 0;
   int number_build_rule = 0;
   int number_update_rule = 0;
   int num_set[4] = {0};
   
   /* parameter use for analysis performance by rdtscp method*/
   uint64_t t1, t2, t3, t4;
   double time_rdtscp, time_rdtscp2, time_search;

   parseargs(argc, argv); // get user command

   if(fpr != NULL){
      rule_table = loadrule(fpr);
      number_rule = rule_table.size();

      printf("\nTotal number of rules in rule table: %d\n", number_rule);

      /* Analyze rule table field */
      count_uni_field(rule_table, number_rule);
      count_dinst_field(rule_table, number_rule);
      count_prefix_dist(rule_table, number_rule);

      // check whether have update operation, if flag=1 will split rule table to 95% for build and 5% for update operation from initial rule table
      if(updateFlag == 1) {
         // random select rule from table to do update operation, 95% for build and 5% for operation
         srand(seed);
         int randn;

         for(i=0; i<number_rule; i++) {
            randn = rand() % 100;
            if(randn < 95)
               build_table.push_back(rule_table[i]);
            else
               update_table.push_back(rule_table[i]);
         }

         number_build_rule = build_table.size();
         number_update_rule = update_table.size();
         printf("\nThe number of rules for build = %d\n", number_build_rule);
         printf("The number of rules for update = %d\n", number_update_rule);
         anaK(number_build_rule, build_table, SetBits, set_4, pre_K);
      }
      else // not need update operation, use all rule table to build 
         anaK(number_rule, rule_table, SetBits, set_4, pre_K);

      //anaSet0(set_4[0], SetBits[0]);
      priority_ratio(set_4);// just for analysis performance



      printf("========== Construction ==========\n");      
      for(i=0; i<4; i++)
         num_set[i] = set_4[i].size();

      /* Initialize segment table */
      KSet set0(0, set_4[0], SetBits[0]);
      KSet set1(1, set_4[1], SetBits[1]);
      KSet set2(2, set_4[2], SetBits[2]);
      KSet set3(3, set_4[3], 0);

      t1 = perf_counter();
      if(num_set[0] > 0) {set0.ConstructClassifier(set_4[0]);}
      if(num_set[1] > 0) {set1.ConstructClassifier(set_4[1]);}
      if(num_set[2] > 0) {set2.ConstructClassifier(set_4[2]);}
      if(num_set[3] > 0) {set3.ConstructClassifier(set_4[3]);}
      t2 = perf_counter();

      time_rdtscp = (double)(t2-t1)/1e3/3200;
      printf("\n===== Construction time: %.3f ms =====\n\n", time_rdtscp);

      // print memory usage
      set0.prints();
      set1.prints();
      set2.prints();
      set3.prints();


      /* Those code untrace 2022/02/26
         if(classificationFlag == 1) {
            // classification
            printf("\n**************** Classification ****************\n");
            packets = loadpacket(fpt);
            int number_pkt = packets.size();
            printf("\tThe number of packet in the trace file = %d\n", number_pkt);
            const int trials = 1; //run 10 times circularly
            printf("\tTotal packets (run %d times circularly): %d\n", trials, packets.size()*trials);
            int match_miss = 0;

            int match_pri = -2;
            int matchid[number_pkt] = {0};
            int pri_stop[4] = {0}; // record every packet stop search in which set, to count the priority ratio
            Packet p;

            if(max_pri_set[1] < max_pri_set[2]) {
               printf("B\n");
               for (t = 0; t < trials; t++) {
                  t1 = perf_counter();
                  
                  for(i=0;i<number_pkt;i++) {
                     p=packets[i];                               
                     match_pri = -1;
                     if(num_set[0] > 0) match_pri = set0.ClassifyAPacket(p);
                     if(match_pri < max_pri_set[2] && num_set[2] > 0) match_pri = max(match_pri, set2.ClassifyAPacket(p));
                     if(match_pri < max_pri_set[1] && num_set[1] > 0) match_pri = max(match_pri, set1.ClassifyAPacket(p));
                     if(match_pri < max_pri_set[3] && num_set[3] > 0) match_pri = max(match_pri, set3.ClassifyAPacket(p));
                     matchid[i] = number_rule - 1 - match_pri;
                  }
                  */
                  /*
                  for(i=0;i<number_pkt;i++) {
                     p=packets[i];                               
                     match_pri = -1;
                     if(num_set[0] > 0) {
                        match_pri = set0.ClassifyAPacket(p);
                     }
                     if(match_pri < max_pri_set[2] && num_set[2] > 0) {
                        match_pri = max(match_pri, set2.ClassifyAPacket(p));
                     } 
                     else {
                        if(match_pri != -1) { // stop search
                           pri_stop[0]++;
                           matchid[i] = number_rule - 1 - match_pri;
                           continue;
                        }
                        
                     }
                     if(match_pri < max_pri_set[1] && num_set[1] > 0) {
                        match_pri = max(match_pri, set1.ClassifyAPacket(p));
                     } 
                     else {
                        if(match_pri != -1) { // stop search
                           pri_stop[1]++;
                           matchid[i] = number_rule - 1 - match_pri;
                           continue;
                        }
                     }
                     if(match_pri < max_pri_set[3] && num_set[3] > 0) {
                        match_pri = max(match_pri, set3.ClassifyAPacket(p));
                     }
                     else {
                        if(match_pri != -1) { // stop search
                           pri_stop[2]++; 
                           matchid[i] = number_rule - 1 - match_pri;
                           continue;
                        }
                     }
                     if(match_pri != -1) {
                        pri_stop[3]++;
                     }
                     matchid[i] = number_rule - 1 - match_pri;
                  }*/
                  /*
                  t2 = perf_counter();
                  time_rdtscp += (double)(t2-t1)/3200;
                  printf("?");
                  for(i = 0;i < number_pkt;i++) {                  
                     if(matchid[i] == -1) match_miss++;                  
                     else if(packets[i][5] < matchid[i]) match_miss++; // > is correct: match a rule with a higher priority (i.e., smaller rule id)
                  }
               }
               //printf("priority count: %d: %d, %d: %d\n", pri_stop[0], pri_stop[1], pri_stop[2], pri_stop[3]);
               //printf("priority ratio: %.3f: %.3f: %.3f: %.3f\n", (float)pri_stop[0]/packets.size()*100, (float)pri_stop[1]/packets.size()*100, (float)pri_stop[2]/packets.size()*100, (float)pri_stop[3]/packets.size()*100);
               printf("\t%d packets are classified, %d of them are misclassified\n", number_pkt * trials, match_miss);
               printf("\tTotal classification time: %.3f s\n", time_rdtscp / 1e6 / trials);
               printf("\tAverage classification time: %.3f us\n", time_rdtscp / (trials * packets.size()));
               printf("\tThroughput: %.3f Mpps\n", 1 / (time_rdtscp / (trials * packets.size())));    
            }
            else if(max_pri_set[1] >= max_pri_set[2]) {
               printf("A\n");
               for (t = 0; t < trials; t++) {
                  t1 = perf_counter();
                  
                  for(i=0;i<number_pkt;i++) {
                     p=packets[i];                               
                     match_pri = -1;
                     if(num_set[0] > 0) match_pri = set0.ClassifyAPacket(p);
                     if(match_pri < max_pri_set[1] && num_set[1] > 0) match_pri = max(match_pri, set1.ClassifyAPacket(p));
                     if(match_pri < max_pri_set[2] && num_set[2] > 0) match_pri = max(match_pri, set2.ClassifyAPacket(p));
                     if(match_pri < max_pri_set[3] && num_set[3] > 0) match_pri = max(match_pri, set3.ClassifyAPacket(p));
                     matchid[i] = number_rule - 1 - match_pri;
                  }
                  */
                  /*
                  for(i=0;i<number_pkt;i++) {
                     p=packets[i];                               
                     match_pri = -1;
                     if(num_set[0] > 0) {
                        match_pri = set0.ClassifyAPacket(p);
                     }
                     if(match_pri < max_pri_set[1] && num_set[1] > 0) {
                        match_pri = max(match_pri, set1.ClassifyAPacket(p));
                     } 
                     else {
                        if(match_pri != -1) { // stop search
                           pri_stop[0]++;
                           matchid[i] = number_rule - 1 - match_pri;
                           continue;
                        }
                     }
                     if(match_pri < max_pri_set[2] && num_set[2] > 0) {
                        match_pri = max(match_pri, set2.ClassifyAPacket(p));
                     } 
                     else {
                        if(match_pri != -1) { // stop search
                           pri_stop[1]++;
                           matchid[i] = number_rule - 1 - match_pri;
                           continue;
                        }
                     }
                     if(match_pri < max_pri_set[3] && num_set[3] > 0) {
                        match_pri = max(match_pri, set3.ClassifyAPacket(p));
                     }
                     else {
                        if(match_pri != -1) { // stop search
                           pri_stop[2]++; 
                           matchid[i] = number_rule - 1 - match_pri;
                           continue;
                        }
                     }
                     if(match_pri != -1) {
                        pri_stop[3]++;
                     }
                     matchid[i] = number_rule - 1 - match_pri;
                  }*/
                  /*
                  t2 = perf_counter();
                  time_rdtscp += (double)(t2-t1)/3200;
                  printf("?");
                  for(i = 0;i < number_pkt;i++) {                  
                     if(matchid[i] == -1) match_miss++;                  
                     else if(packets[i][5] < matchid[i]) match_miss++; // > is correct: match a rule with a higher priority (i.e., smaller rule id)
                  }
               }
               //printf("priority count: %d: %d, %d: %d\n", pri_stop[0], pri_stop[1], pri_stop[2], pri_stop[3]);
               //printf("priority ratio: %.3f: %.3f: %.3f: %.3f\n", (float)pri_stop[0]/packets.size()*100, (float)pri_stop[1]/packets.size()*100, (float)pri_stop[2]/packets.size()*100, (float)pri_stop[3]/packets.size()*100);
               printf("\t%d packets are classified, %d of them are misclassified\n", number_pkt * trials, match_miss);
               printf("\tTotal classification time: %.3f s\n", time_rdtscp / 1e6 / trials);
               printf("\tAverage classification time: %.3f us\n", time_rdtscp / (trials * packets.size()));
               printf("\tThroughput: %.3f Mpps\n", 1 / (time_rdtscp / (trials * packets.size())));    

            }
         }

         if(updateFlag == 1) {
            printf("\n**************** Update ****************\n");
            printf("\tThe number of updated rules = %d\n", number_update_rule);
            int srcmask, dstmask;
            
            t1 = perf_counter();
            // insert
            for(int i=0; i<number_update_rule; i++) {
               srcmask = update[i].prefix_length[0];
               dstmask = update[i].prefix_length[1];
               if((srcmask>=SetBits[0]) && (dstmask>=SetBits[0])) set0.InsertRule(update[i]);
               else if(srcmask>=SetBits[1]) set1.InsertRule(update[i]);
               else if(dstmask>=SetBits[2]) set2.InsertRule(update[i]);
               else  set3.InsertRule(update[i]);
            }
            t2 = perf_counter();
            
            // delete
            for(int i=0; i<number_update_rule; i++) {
               srcmask = update[i].prefix_length[0];
               dstmask = update[i].prefix_length[1];
               if((srcmask>=SetBits[0]) && (dstmask>=SetBits[0])) set0.DeleteRule(update[i]);
               else if(srcmask>=SetBits[1]) set1.DeleteRule(update[i]);
               else if(dstmask>=SetBits[2]) set2.DeleteRule(update[i]);
               else  set3.DeleteRule(update[i]);
            }
            t3 = perf_counter();
            time_rdtscp = (double)(t2-t1)/3200;
            time_rdtscp2 = (double)(t3-t2)/3200;
            printf("\tInsert time = %.3f s, delete time = %.3f s\n", time_rdtscp / 1e6, time_rdtscp2 / 1e6);
            printf("\tTotal update time: %.3f s\n", (time_rdtscp+time_rdtscp2)/1e6);
            printf("\tAverage insert time: %.3f us, Average delete time: %.3f us\n", time_rdtscp/number_update_rule, time_rdtscp2/number_update_rule);
            printf("\tAverage update time: %.3f us\n", (time_rdtscp+time_rdtscp2)/(number_update_rule*2));
         }
      */
   }
   return 0;
}