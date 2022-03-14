/* pre-process header file */
#ifndef  RULE_H
#define  RULE_H


/* include lib */
#include <math.h>
#include <stdint.h>
#include <time.h>
#include <vector>
#include <array>
using namespace std;//using prefix "std"

/* parameter define */
#define LowDim 0 //??
#define HighDim 1 //??
#define MAXDIMENSIONS 5 //??
#define Null -1 // ??
#define PTR_SIZE 4 //??

/* This is main storage queue of packet. 
   And those packet reader from file.  */
typedef vector<uint32_t> Packet;
/* "Rule" structure */
struct Rule {
   Rule(int dim = 5) : dim(dim), range(dim, {{0, 0}}), prefix_length(dim, 0){}; // initialize via a constructor

   int dim;// Express how many field of this rule dimension
   int priority; // Express this rule's priority
   int id; // Express this rule's id, sometime we will use priority as id(maybe?

   /*
      prefix length[0] = src address prefix length
      prefix length[1] = dst address prefix length
   */
   vector<uint32_t> prefix_length; // Define a uint32_t type vector named "prefix_length", this vector will be like [1,2,5,7,-1,-3,8,-1...]
   /* 
      range[0] = src address cover range
      range[1] = dst address cover range
      range[2] = src port cover range
      range[3] = dst port cover range
      range[4] = protocol cover range
   */
   vector<array<uint32_t,2>> range; // Define a (unit32_t,unit32_t) type vector named "range", this vector will be like [(1,2),(3,4),(5,6),(7,8),(9,10)...]
};

/* Abstract describe functional of packet classifier */
class PacketClassifier {
public:
   virtual void ConstructClassifier(const vector<Rule>& rules) = 0; // Initialize classifier
   virtual int ClassifyAPacket(const Packet& packet) = 0; // Main operation to classify
   virtual void DeleteRule(const Rule& rule) = 0; // Delete operation
   virtual void InsertRule(const Rule& rule) = 0; // Insert operation
private:
};

/* This is use for analyze how many kind of ranges
   Use for count_uni_field function of main  */
typedef struct range_unique {
   int lo; // check whether equal to range[][0]
   int hi; // check whether equal to range[][1]
   int num;// total number of this type of range
} r_uni;

#endif