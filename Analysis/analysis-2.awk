BEGIN {counter1 = 0; counter2 = 0;}
 $1~/s/ && /AGT/  { counter1 ++ }
 $1~/r/ && /AGT/  { counter2 ++ }
 END {  print ( counter1, counter2) }
