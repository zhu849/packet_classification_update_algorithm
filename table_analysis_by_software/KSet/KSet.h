#pragma once

/* include lib */
#include <bits/stdc++.h>
#include "../rule.h"

using namespace std;

/* record about subset infomation */
struct anaSet {
   int tablesize;
   int non_empty_seg = 0; // count how many cell non-empty in this subset
   int *seg; // segment table
};


// big segment用priority效能會變差, rmd不會
struct BigSegment {
   int uf = -1; // choice used when field's exact value as hashkey 
   int bf = -1; // -1: not use, 0: list, 1: hash
   int ub = 0; // hash table used bits
   int ht_size = 0; // hash table size
   
   vector<Rule> list; // smaller than threshold2
   vector<Rule> *ht; // hash table
};

struct SegmentNode {
   int nrules = 0;
   int flag = -1; // -1 = NULL, 0 = Small segment, 1 = Big segment
   vector<Rule> classifier; // rule queue storage
   
   // four hash table or list, the number is the search order
   BigSegment b[4];


   int r_flag = -1; // 0: rmd, 1: rm divide by protocol
   int r_max_pri = 0;
   int rp_max_pri[3] = {0};
   vector<Rule> rmd; //remainder
   vector<Rule> rmdp[3]; // partition with protocol, tcp, udp, other
};


/* 
   Used to select field from 5-dimension information as hashkey 
   Group 0 - use first 30 bits of Src IP as index, Src IP field is 0
   Group 1 - use first 30 bits of Dst IP as index, Dst IP field is 1
   Group 2 - use Dst port as index, Dst port field is 3
   Group 3 - use Stc port as index, Src port field is 2 
*/
static inline int part_oder(int n) {
   int field_dim = -1;

   switch(n) {
      case 0:
      case 1:
         field_dim = n;
         break;
      case 2:
         field_dim = 3;
         break;
      case 3:
         field_dim = 2;
         break;
   }

   return field_dim;
}


/* 
   This function only for subset0, used to compute hashkey for hashtable
   But in FPGA design, we always use 16 bit as k
*/
static inline int hashSet0(uint32_t orig, int k) {
   uint32_t v = orig;
   int uk = 32 - k;

   switch(k) {
      case 4:
         v = (v * 0x88888889) >> uk;
         break;
      case 5:
      case 6:
      case 7:
      case 8:
         v = (v * 0x80808081) >> uk;
         break;
      case 9:
      case 10:
      case 11:
      case 12:
      case 13:
      case 14:
      case 15:
      case 16:
         v = (v * 0x80008001) >> uk;
         break;
      default:
         printf("error k\n");
         v = 0;
   }

   return v;
}

/*
   This function is use to hash big group
*/
static inline int exactHash(uint32_t v, int ub) {
   uint32_t res = v;

   int r_ub = 32 - ub;

   switch(ub) {
      case 1:
      case 2:
         res = (res * 0xAAAAAAAB) >> r_ub;
         break;
      case 3:
      case 4:
         res = (res * 0x88888889) >> r_ub;
         break;
      case 5:
      case 6:
      case 7:
      case 8:
         res = (res * 0x80808081) >> r_ub;
         break;
      case 9:
      case 10:
         res = (res * 0x80008001) >> r_ub;
         break;
      default:
         printf("error usedbits: %d\n", ub);
         res = 0;
   }

   return res;
}

static inline bool cmpp(Rule const &a, Rule const &b) {
   return a.priority > b.priority;
}

class KSet : public PacketClassifier {
public:
   KSet(int num1, std::vector<Rule>& classifier, int usedbits);
   ~KSet();
   virtual void ConstructClassifier(const std::vector<Rule>& rules);
   virtual int ClassifyAPacket(const Packet& packet);
   virtual void DeleteRule(const Rule& delete_rule);
   virtual void InsertRule(const Rule& insert_rule);

   void prints(){
      total_tablesize_memory_in_KB = (double)(tablesize*(PTR_SIZE))/1024;
      //total_linear_memory_in_KB = (double)(Total_Rules_in_Linear_Node*28)/1024; // rule: 24 bytes + pointer
      //total_big_memory_in_KB = (double)((Total_Rules_in_Big_Node*28)+(Total_Tablesize_in_Big_Node*PTR_SIZE))/1024; // rule: 24 bytes + pointer
      

      switch(num) {
         case 0:
            printf("\n========== Set 0 ==========\n");
            total_linear_memory_in_KB = (double)(Total_Rules_in_Linear_Node*28)/1024; // rule: 24 bytes + pointer
            total_big_memory_in_KB = (double)((Total_Rules_in_Big_Node*28)+(Total_Tablesize_in_Big_Node*PTR_SIZE))/1024; // rule: 24 bytes + pointer
            break;
         case 1:
            printf("\n========== Set 1 ==========\n");
            if(usedbit == 16) { // k = 16, save 2 bytes
               total_linear_memory_in_KB = (double)(Total_Rules_in_Linear_Node*22)/1024; // rule: 24 bytes + pointer
               total_big_memory_in_KB = (double)((Total_Rules_in_Big_Node*22)+(Total_Tablesize_in_Big_Node*PTR_SIZE))/1024; // rule: 24 bytes + pointer
            } 
            else { // k = 8~15, save 1 byte
               total_linear_memory_in_KB = (double)(Total_Rules_in_Linear_Node*23)/1024; // rule: 24 bytes + pointer
               total_big_memory_in_KB = (double)((Total_Rules_in_Big_Node*23)+(Total_Tablesize_in_Big_Node*PTR_SIZE))/1024; // rule: 24 bytes + pointer                
            }
            break;
         case 2:
            printf("\n========== Set 2 ==========\n");
            if(usedbit == 16) { // k = 16, save 2 bytes
               total_linear_memory_in_KB = (double)(Total_Rules_in_Linear_Node*22)/1024; // rule: 24 bytes + pointer
               total_big_memory_in_KB = (double)((Total_Rules_in_Big_Node*22)+(Total_Tablesize_in_Big_Node*PTR_SIZE))/1024; // rule: 24 bytes + pointer
            } 
            else { // k = 8~15, save 1 byte
               total_linear_memory_in_KB = (double)(Total_Rules_in_Linear_Node*23)/1024; // rule: 24 bytes + pointer
               total_big_memory_in_KB = (double)((Total_Rules_in_Big_Node*23)+(Total_Tablesize_in_Big_Node*PTR_SIZE))/1024; // rule: 24 bytes + pointer                
            }
            break;
         case 3:
            printf("\n========== Set 3 ==========\n");
            total_linear_memory_in_KB = (double)(Total_Rules_in_Linear_Node*28)/1024; // rule: 24 bytes + pointer
            total_big_memory_in_KB = (double)((Total_Rules_in_Big_Node*28)+(Total_Tablesize_in_Big_Node*PTR_SIZE))/1024; // rule: 24 bytes + pointer
            break;
      }
      total_memory_in_KB = total_tablesize_memory_in_KB + total_linear_memory_in_KB + total_big_memory_in_KB;

      printf("# of rules: %d, rules in small segment table: %d, rules in big segment table: %d\n", numrules, Total_Rules_in_Linear_Node, Total_Rules_in_Big_Node);
      printf("tablesize: %d, NULL segment = %d, Small segment = %d, Big segment = %d\n\n", tablesize, NULL_Node_Count, Small_Node_Count, Big_Node_Count);

      // memory with KB
      printf("Memory with KB\n");
      printf("Segment Table Memory: %.3f(KB), Small Segment Table Memory: %.3f(KB), Big Segment Table Memory: %.3f(KB)\n", 
            total_tablesize_memory_in_KB, total_linear_memory_in_KB, total_big_memory_in_KB);

      printf("Total memory: %.3f(KB), Byte/rule: %.3f\n\n", total_memory_in_KB, double(total_memory_in_KB*1024)/numrules);

   }

private:
   //std::vector<Rule> rules;
   SegmentNode *nodeKSet;

   int num; // identify which sets
   int usedbit;
   int tablesize;
   int locate_segment; // 32 - kset

   int numrules;
   int threshold;
   int threshold2;
   int bigSetPrefix;
   int bigSetPrefix3;

   int Total_Rules_in_Linear_Node;
   int Total_Rules_in_Big_Node;
   int Total_Tablesize_in_Big_Node;

   // count number of Small or Big segment in the set
   int NULL_Node_Count;
   int Small_Node_Count;
   int Big_Node_Count;

   double   total_tablesize_memory_in_KB;
   double   total_linear_memory_in_KB;
   double   total_big_memory_in_KB;
   double   total_memory_in_KB;

   // use to analysis zhu849 FPGA design global parameter
   // subset group bucket size
   int num_group[5]; // # of rules in group
   int bucket_small_group[5][10];
   int bucket_big_group[5][200];
};