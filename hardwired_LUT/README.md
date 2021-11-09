# Hardwired LUT Example
## Useage
* mylut - main file with one rule match design.
	* In this design use IPv4 = `140.116.80.*/22`. Binary format is `100011_000111_010001_0100**_******_**`.
	* Store with 6\*LUT6 that data content is `100011`, `000111`, `010001`, `0100**`, `******`, `******`
* tb - testbench read testcase file, there have a file named `ipv4_data.txt`
	* Remember modify file path by yourself.
	* In this case result is below:
	|Testcase|INIT Binary Format|Result|
	|----|----|-----|
	|1|100011_000111_010001_010000_000000_000000|matched|
	|2|100011_000111_010001_010000_000000_111111|matched|
	|3|100011_000111_010001_010000_000000_000011|matched|
	|4|100011_000111_010001_010000_000001_000000|matched|
	|5|011100_111000_101110_101111_111110_111111|unmatched|
	|6|011100_111000_101110_101111_111110_000000|unmatched|
	|7|100011_111000_101110_101111_111110_111111|unmatched|
	|8|100011_000111_010001_011100_000000_000011|unmatched|