# different_length_compare_analysis
* In this experiment, analysis whether this algorithm is limited by compare logic of length.
* Original experiment is use 104 bits tuple space data and 171 bits data entry data.
* Detail data format is in the architecture design file.

## Scenario
* Scenario A - Use just 64 bit tuple space data to compare and assume entry data is just srcIP, srcIP_len, dstIP, dstIP_len, ruleID, Index with 32+6+32+6+11+11(cover 1738 of index entry)=98 bits.
* Scenario B - Use just 32 bit tuple space data to compare and assume entry data is just dstIP, dstIP_len, ruleID, Index with 32+6+11+11(cover 1738 of index entry)=60 bits.
* Scenario C - Use full 104 bit tuple space data to compare and assume entry data is 177 bits.
## Analysis Result
|Bit Lens|Content/Format|Frequency(MHz)|Setup Slack Time(ns)|
|---|---|---|---|
|60|Src_IP:32<br>Src_IP_lens:6<br>RuleID:11<br>Index:11|170.32|1.129|
|98|Src_IP:32<br>Src_IP_lens:6<br>Dst_IP:32<br>Dst_IP_ lens:6<br>RuleID:11<br>Index:11|162.65|0.852|
|171|Src_IP:32<br>Src_IP_lens:6<br>Dst_IP:32<br>Dst_IP_ lens:6<br>Src_port_upper:16<br>Src_port_lower:16<br>Dst_port_upper:16<br>Dst_port_lower:16<br>Protocol:8<br>Wildcard:1<br><br>RuleID:11<br>Index:11|152.69|0.451|