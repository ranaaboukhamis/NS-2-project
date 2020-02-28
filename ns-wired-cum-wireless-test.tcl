### This simulation is an example of combination of wired and wireless 
### topologies.


global opt
set opt(chan)       Channel/WirelessChannel
set opt(prop)       Propagation/TwoRayGround
set opt(netif)      Phy/WirelessPhy
set opt(mac)        Mac/802_11
set opt(ifq)        Queue/DropTail/PriQueue
set opt(ll)         LL
set opt(ant)        Antenna/OmniAntenna
set opt(x)             670   
set opt(y)              670   
set opt(ifqlen)         50   
set opt(tr)          ns-wired-and-wireless-feb10.tr
set opt(namtr)       ns-wired-and-wireless-feb10.nam
set opt(nn)             6                       
set opt(adhocRouting)   DSDV                      
set opt(cp)             ""                        
set opt(sc)             "scen-3-test"   
set opt(stop)           10                           
set num_wired_nodes      10
set num_bs_nodes         1


set ns_   [new Simulator]
$ns_ color 1 Blue
$ns_ color 2 Red
$ns_ color 3 Yellow

$ns_ rtproto Session 
# set up for hierarchical routing
  $ns_ node-config -addressType hierarchical
  AddrParams set domain_num_ 2          
  #lappend cluster_num 2 1 1  
  lappend cluster_num 10 1   
            
  AddrParams set cluster_num_ $cluster_num
  #lappend eilastlevel 1 1 4 1   
  lappend eilastlevel 1 1 1 1 1 1 1 1 1 1 7   
         
  AddrParams set nodes_num_ $eilastlevel 

  set tracefd  [open $opt(tr) w]
  $ns_ trace-all $tracefd
  set namtracefd [open $opt(namtr) w]
  $ns_ namtrace-all $namtracefd


set trc  [open tracetcp.tr w]

set droptrc  [open droptrace.tr w]

  set topo   [new Topography]
  $topo load_flatgrid $opt(x) $opt(y)
  # god needs to know the number of all wireless interfaces
  create-god [expr $opt(nn) + $num_bs_nodes]

  #create wired nodes
  set temp {0.0.0 0.1.0 0.2.0 0.3.0 0.4.0 0.5.0 0.6.0 0.7.0 0.8.0 0.9.0}        
  for {set i 0} {$i < $num_wired_nodes} {incr i} {
      set W($i) [$ns_ node [lindex $temp $i]]
  } 
$ns_ at 0.0 "$W(5) color orange"
$W(5) color "orange"
  $ns_ node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propInstance [new $opt(prop)] \
                 -phyType $opt(netif) \
                 -channel [new $opt(chan)] \
                 -topoInstance $topo \
                 -wiredRouting ON \
                 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace OFF

  set temp {1.0.0 1.0.1 1.0.2 1.0.3 1.0.4 1.0.5 1.0.6}   
  set BS(0) [$ns_ node [lindex $temp 0]]
 
  $BS(0) random-motion 0 
  
  $BS(0) set X_ 1.0
  $BS(0) set Y_ 2.0
  $BS(0) set Z_ 0.0
  $ns_ at 0.0 "$BS(0) color blue"
  $BS(0) color "blue"
 
  
  #configure for mobilenodes
  $ns_ node-config -wiredRouting OFF

  for {set j 0} {$j < $opt(nn)} {incr j} {
    set node_($j) [ $ns_ node [lindex $temp \
            [expr $j+1]] ]
    $node_($j) base-station [AddrParams addr2id [$BS(0) node-addr]]
  }

$ns_ at 0.0 "$node_(0) color blue"
$node_(0) color "blue"
$ns_ at 0.0 "$node_(1) color cyan"
$node_(1) color "cyan"
$ns_ at 1.0 "$node_(1) setdest 25.0 20.0 15.0"
$ns_ at 1.5 "$node_(0) setdest 20.0 18.0 1.0"
$ns_ at 0.5 "$node_(2) setdest 25.0 17.0 10.0"


  #create links between wired and BS nodes
#$ns_ duplex-link $W(1) $BS(1) 5Mb 2ms DropTail
$ns_ duplex-link $W(0) $W(1) 5Mb 2ms DropTail 
$ns_ duplex-link $W(1) $BS(0) 5Mb 2ms DropTail 
$ns_ duplex-link $W(2) $W(1) 5Mb 2ms DropTail 
$ns_ duplex-link $W(2) $W(3) 5Mb 2ms DropTail 
$ns_ duplex-link $W(1) $W(4) 5Mb 2ms DropTail 
$ns_ duplex-link $W(3) $W(5) 5Mb 2ms DropTail 
$ns_ duplex-link $W(4) $W(5) 5Mb 2ms DropTail 
$ns_ duplex-link $W(2) $W(6) 5Mb 2ms DropTail 
$ns_ duplex-link $W(6) $W(7) 5Mb 2ms DropTail 
$ns_ duplex-link $W(7) $W(8) 5Mb 2ms DropTail 
$ns_ duplex-link $W(8) $W(5) 5Mb 2ms DropTail 
$ns_ duplex-link $W(9) $W(8) 5Mb 2ms DropTail 


$ns_ duplex-link-op $W(0) $W(1) orient right
$ns_ duplex-link-op $W(1) $BS(0) orient down-right 
#$ns_ duplex-link-op $W(1) $BS(1) orient down-left
$ns_ duplex-link-op $W(1) $W(2) orient down
$ns_ duplex-link-op $W(1) $W(4) orient up-left
$ns_ duplex-link-op $W(2) $W(3) orient up-right
$ns_ duplex-link-op $W(2) $W(6) orient right
$ns_ duplex-link-op $W(3) $W(5) orient left-up
$ns_ duplex-link-op $W(4) $W(5) orient right-up
$ns_ duplex-link-op $W(6) $W(7) orient right-up
$ns_ duplex-link-op $W(7) $W(8) orient left-up
$ns_ duplex-link-op $W(8) $W(5) orient left
$ns_ duplex-link-op $W(8) $W(9) orient right

#$ns_ duplex-link-op $W(1) $BS(0) orient left-down

#Set Queue Size of link (n8-n5) to 10
$ns_ queue-limit $W(8) $W(5) 10

#Monitor the queue for link (n8-n5). (for NAM)
$ns_ duplex-link-op $W(8) $W(5) queuePos 0.5

#Set Queue Size of link (n4-n5) to 10
$ns_ queue-limit $W(4) $W(5) 10

#Monitor the queue for link (n4-n5). (for NAM)
$ns_ duplex-link-op $W(4) $W(5) queuePos 0.5

$ns_ cost $W(1) $W(4) 1
$ns_ cost $W(2) $W(3) 1
$ns_ cost $W(3) $W(2) 1
$ns_ cost $W(5) $W(3) 1
$ns_ cost $W(3) $W(5) 1
$ns_ cost $W(4) $W(1) 1
$ns_ cost $W(2) $W(6) 1
$ns_ cost $W(6) $W(2) 1
$ns_ cost $W(7) $W(6) 1
$ns_ cost $W(6) $W(7) 1
$ns_ cost $W(5) $W(8) 1
$ns_ cost $W(8) $W(5) 1
$ns_ cost $W(9) $W(8) 1
$ns_ cost $W(8) $W(9) 1


$ns_ rtmodel-at 2 down $W(1) $W(4)
################# Houssam ###########################
$ns_ rtmodel-at 2.9 down $W(2) $W(3)
################# Houssam ###########################
$ns_ rtmodel-at 5.0 down $W(2) $W(3)
#$ns_ rtmodel-at 2.5 up $W(2) $W(3)
$ns_ rtmodel-at 5.5 up $W(1) $W(4)

  # setup TCP connections
  set tcp1 [new Agent/TCP]
  $tcp1 set fid_ 1
  set sink1 [new Agent/TCPSink]
  $ns_ attach-agent $W(0) $tcp1
  $ns_ attach-agent $W(5) $sink1
  $ns_ connect $tcp1 $sink1
  set ftp1 [new Application/FTP]
  $ftp1 attach-agent $tcp1
  $ns_ at 1 "$ftp1 start"
    #from node1 to W5
  set tcp2 [new Agent/TCP]
  $tcp2 set fid_ 2
  set sink2 [new Agent/TCPSink]
  $ns_ attach-agent $node_(1) $tcp2
  $ns_ attach-agent $W(5) $sink2
  $ns_ connect $tcp2 $sink2
  set ftp2 [new Application/FTP]
  $ftp2 attach-agent $tcp2
  $ns_ at 1.2 "$ftp2 start"
  #response from W5 to node 1
  set tcp22 [new Agent/TCP]
  $tcp22 set fid_ 2
  set sink22 [new Agent/TCPSink]
  $ns_ attach-agent $W(5) $tcp22
  $ns_ attach-agent $node_(1) $sink22
  $ns_ connect $tcp22 $sink22
  set ftp22 [new Application/FTP]
  $ftp22 attach-agent $tcp22
  $ns_ at 1.7 "$ftp22 start"
  
  # 11 1 12 2 13 3 14 4 15
  # setup TCP connections
#wireless 13 to wireless 15
set tcp3 [new Agent/TCP]
$ns_ attach-agent $node_(2) $tcp3
set sink3 [new Agent/TCPSink]
$ns_ attach-agent $node_(5) $sink3
$ns_ connect $tcp3 $sink3
set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3
$tcp3 set fid_ 3
$ns_ at 3 "$ftp3 start"

#$ns_ trace-queue $W(1) $W(0) $trc 
#$ns_ trace-queue $W(4) $W(5) $trc 
#$ns_ trace-queue $W(8) $W(5) $trc 




set qfile [$ns_ monitor-queue $W(8) $W(5)  [open queue.tr w] 0.05]
[$ns_ link $W(8) $W(5)] queue-sample-timeout;

set qfile [$ns_ monitor-queue $W(4) $W(5)  [open queue.tr w] 0.05]
[$ns_ link $W(4) $W(5)] queue-sample-timeout;

  for {set i 0} {$i < $opt(nn)} {incr i} {
      $ns_ initial_node_pos $node_($i) 20
   }

  for {set i } {$i < $opt(nn) } {incr i} {
      $ns_ at $opt(stop).0000010 "$node_($i) reset";
  }
  $ns_ at $opt(stop).0000010 "$BS(0) reset";

  $ns_ at $opt(stop).1 "puts \"NS EXITING...\" ; $ns_ halt"

  puts "Starting Simulation..."
  $ns_ run
