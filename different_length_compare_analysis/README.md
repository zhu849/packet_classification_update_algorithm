# different_length_compare_analysis
* In this experiment, analysis whether this algorithm is limited by compare logic of length.
* Original experiment is use 104 bits tuple space data and 171 bits data entry data.
* Detail data format is in the architecture design file.

## Scenario
* Scenario A - Use just 64 bit tuple space data to compare and assume entry data is just srcIP, srcIP_len, dstIP, dstIP_len, ruleID, Index with 32+6+32+6+11+11(cover 1738 of index entry)=98 bits.
* Scenario B - Use just 32 bit tuple space data to compare and assume entry data is just dstIP, dstIP_len, ruleID, Index with 32+6+11+11(cover 1738 of index entry)=60 bits.

## Analysis Result