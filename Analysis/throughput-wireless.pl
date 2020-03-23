
$infile=$ARGV[0];
$tonode=$ARGV[1];
$granularity=$ARGV[2];
$sum=0;
$clock=0;
      open (DATA,"<$infile")
        || die "Can't open $infile $!";
  
    while (<DATA>) {
             @x = split(' ');
#column 1 is time 
if ($x[1]-$clock <= $granularity)
{
#checking if the event corresponds to a reception 
if ($x[0] eq 'r') 
{ 
#checking if the destination corresponds to arg 1
if ($x[2] eq $tonode) 
{ 
#checking if the packet type is TCP
if ($x[6] eq 'tcp') 
{
    $sum=$sum+$x[7];
}}}}
else
{   $throughput=$sum/$granularity*(8/1000);
    print STDOUT "$x[1] $throughput\n";
    $clock=$clock+$granularity;
    $sum=0;
}   }
   $throughput=$sum/$granularity;
    print STDOUT "$x[1] $throughput\n";
    $clock=$clock+$granularity;
    $sum=0;

    close DATA;
exit(0);
 

