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
set opt(x)             800  
set opt(y)              800  
set opt(ifqlen)         50   
set opt(tr)          ns-wired-and-wireless-aodv.tr
set opt(namtr)       ns-wired-and-wireless-aodv.nam
set opt(nn)             6                       
set opt(adhocRouting)   AODV                   
set opt(cp)             ""                        
set opt(sc)             "scen-3-test"   
set opt(stop)           100                          
set num_wired_nodes      10
set num_bs_nodes         1
# ####################################################################
# Set number of sources
set NumbSrc 8

set ns_   [new Simulator]

#$ns_ use-newtrace
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
  #$ns_ namtrace-all $namtracefd
  $ns_ namtrace-all-wireless $namtracefd $opt(x) $opt(y)
#set tf [open out.tr w]
set windowVsTime [open win2 w]
#set windowVsTime2 [open win2.tr w]
set param [open parameters w]


#set trc  [open tracetcp.tr w]
#set droptrc  [open droptrace.tr w]
set topo   [new Topography]
$topo load_flatgrid $opt(x) $opt(y)


# god needs to know the number of all wireless interfaces
create-god [expr $opt(nn) + $num_bs_nodes]
#create wired nodes
set temp {0.0.0 0.1.0 0.2.0 0.3.0 0.4.0 0.5.0 0.6.0 0.7.0 0.8.0 0.9.0}        
for {set i 0} {$i < $num_wired_nodes} {incr i} {
      set W($i) [$ns_ node [lindex $temp $i]]
}
 
$ns_ at 0.0 "$W(5) color red"
$W(5) color "red"


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
  
  $BS(0) set X_ 50.0
  $BS(0) set Y_ 200.0
  $BS(0) set Z_ 0.0
  $ns_ at 0.0 "$BS(0) color blue"
  $BS(0) color "blue"




  for {set j 0} {$j < $opt(nn)} {incr j} {
    set node_($j) [ $ns_ node [lindex $temp \
            [expr $j+1]] ]
    $node_($j) base-station [AddrParams addr2id [$BS(0) node-addr]]
  }

# Provide initial location of mobilenodes
for {set i 0} {$i < $opt(nn)} { incr i } {
$node_($i) set X_ [expr ($i +1)*200.0]
$node_($i) set Y_ 250.0
$node_($i) set Z_ 0.0
}

 
#ns_ at 0.0 "$node_(0) color blue"
#node_(0) color "blue"
#ns_ at 0.0 "$node_(1) color cyan"
#node_(1) color "cyan"
#ns_ at 1.0 "$node_(1) setdest 25.0 20.0 15.0"
#ns_ at 1.5 "$node_(0) setdest 20.0 18.0 1.0"
#ns_ at 0.5 "$node_(2) setdest 25.0 17.0 10.0"


#create links between wired and BS nodes
#$ns_ duplex-link $W(1) $BS(1) 5Mb 2ms DropTail
$ns_ duplex-link $W(0) $W(1) 5Mb 0.5ms DropTail 
$ns_ queue-limit $W(0) $W(1) 50
$ns_ duplex-link $W(1) $BS(0) 5Mb 0.5ms DropTail 
$ns_ queue-limit $W(1) $BS(0) 150
$ns_ duplex-link $W(2) $W(1) 5Mb 0.5ms DropTail 
$ns_ queue-limit $W(2) $W(1) 50
$ns_ duplex-link $W(2) $W(3) 5Mb 0.5ms DropTail 
$ns_ queue-limit $W(2) $W(3) 50
$ns_ duplex-link $W(1) $W(4) 5Mb 0.5ms DropTail 
$ns_ queue-limit $W(1) $W(4) 50
$ns_ duplex-link $W(3) $W(5) 5Mb 0.5ms DropTail 
$ns_ queue-limit $W(3) $W(5) 50
$ns_ duplex-link $W(4) $W(5) 10Mb 0.5ms DropTail 
$ns_ queue-limit $W(4) $W(5) 100
$ns_ duplex-link $W(2) $W(6) 5Mb 0.5ms DropTail 
$ns_ queue-limit $W(2) $W(6) 50
$ns_ duplex-link $W(6) $W(7) 5Mb 0.5ms DropTail 
$ns_ queue-limit $W(6) $W(7) 50
$ns_ duplex-link $W(7) $W(8) 5Mb 0.5ms DropTail 
$ns_ queue-limit $W(7) $W(8) 50
$ns_ duplex-link $W(8) $W(5) 10Mb 0.01ms DropTail 
$ns_ queue-limit $W(8) $W(5) 100
$ns_ duplex-link $W(9) $W(8) 5Mb 0.5ms DropTail 
$ns_ queue-limit $W(9) $W(8) 0

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


# We define three files that will be used to trace the queue size , the bandwidth
# and losses at the bottleneck.
#set qsize [open queuesize.tr w]
#set qbw [open queuebw.tr w]
#set qlost [open queuelost.tr w]

#$ns_ duplex-link-op $W(1) $BS(0) orient left-down

#Set Queue Size of link (n8-n5) to 10
$ns_ queue-limit $W(8) $W(5) 10

#Monitor the queue for link (n8-n5). (for NAM)
$ns_ duplex-link-op $W(8) $W(5) queuePos 0.5

#Set Queue Size of link (n4-n5) to 10
$ns_ queue-limit $W(4) $W(5) 10

#Monitor the queue for link (n4-n5). (for NAM)
$ns_ duplex-link-op $W(4) $W(5) queuePos 0.5


#Set Queue Size of link (basestation- w1) to 10
$ns_ queue-limit $BS(0) $W(1) 10
#Monitor the queue for link (basestation- w1). (for NAM)
$ns_ duplex-link-op $BS(0) $W(1) queuePos 0.5

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


$ns_ rtmodel-at 20 down $W(1) $W(4)
################# Houssam ###########################
$ns_ rtmodel-at 25 down $W(2) $W(3)
################# Houssam ###########################
$ns_ rtmodel-at 35 up $W(2) $W(3)
#$ns_ rtmodel-at 2.5 up $W(2) $W(3)
$ns_ rtmodel-at 40 up $W(1) $W(4)





# ####################################################################
# Create TCP Sources
for {set j 1} {$j<=$NumbSrc} { incr j } {
set tcp($j) [new Agent/TCP]
$tcp($j) set window_ 100   ;#maxVound on Window Size
$tcp($j) set oacketSize_ 1000    ;#packet size used by sender
$tcp($j) set overhead_ 0   ;# !=0 adds random time between sends

}

# ####################################################################
# Create TCP Destinations
for {set j 1} {$j<=$NumbSrc} { incr j } {
set sink($j) [new Agent/TCPSink]
}
# ####################################################################

# Create a random generator for starting the ftp and for bottleneck link delays
set rng [new RNG]
$rng seed 2

# parameters for random variables for begenning of ftp connections 
set RVstart [new RandomVariable/Uniform]
$RVstart set min_ 0
$RVstart set max_ 7
$RVstart use-rng $rng   

#We define random starting times for each connection
for {set i 1} {$i<=$NumbSrc} { incr i } {
set startT($i)  [expr [$RVstart value]]
set dly($i) 1
puts $param "startT($i)  $startT($i) sec"
}

         

# Color the packets
$tcp(1) set fid_ 1
$ns_ color 1 blue
$tcp(2) set fid_ 2
$ns_ color 2 yellow
$tcp(3) set fid_ 3
$ns_ color 3 cyan
$tcp(4) set fid_ 4
$ns_ color 4 green
$tcp(5) set fid_ 5
$ns_ color 5 orange

# setup TCP connections
##wired to wired
$ns_ attach-agent $W(0) $tcp(1)
$ns_ attach-agent $W(5) $sink(1)
$ns_ connect $tcp(1) $sink(1)
set ftp(1) [new Application/FTP]
$ftp(1) attach-agent $tcp(1)
#$ns_ at 1 "$ftp(1) start"


#wireless to wired
#from node 11 to server 5
$ns_ attach-agent $node_(0) $tcp(2)
$ns_ attach-agent $W(5) $sink(2)
$ns_ connect $tcp(2) $sink(2)
set ftp(2) [new Application/FTP]
$ftp(2) attach-agent $tcp(2)
#$ns_ at 1.5 "$ftp(2) start"


#wireless to wireless
#from node 13 to node 16
$ns_ attach-agent $node_(2) $tcp(3)
$ns_ attach-agent $node_(5) $sink(3)
$ns_ connect $tcp(3) $sink(3)
set ftp(3) [new Application/FTP]
$ftp(3) attach-agent $tcp(3)
#$ns_ at 3.0 "$ftp(3) start"



$ns_ attach-agent $node_(5) $tcp(4)
$ns_ attach-agent $node_(2) $sink(4)
$ns_ connect $tcp(4) $sink(4)
set ftp(4) [new Application/FTP]
$ftp(4) attach-agent $tcp(4)
#$ns_ at 1.2 "$ftp(4) start"


##wired to wired
$ns_ attach-agent $W(9) $tcp(5)
$ns_ attach-agent $W(5) $sink(5)
$ns_ connect $tcp(5) $sink(5)
set ftp(5) [new Application/FTP]
$ftp(5) attach-agent $tcp(5)
#$ns_ at 2.3 "$ftp(5) start"


#wireless to wired
#from node 14 to server 5
$ns_ attach-agent $W(6) $tcp(6)
$ns_ attach-agent $W(5) $sink(6)
$ns_ connect $tcp(6) $sink(6)
set ftp(6) [new Application/FTP]
$ftp(6) attach-agent $tcp(6)
#$ns_ at 1.5 "$ftp(2) start"

#wireless to wired to wireless
#t0 node 11 from server 5
$ns_ attach-agent $W(5) $tcp(7)
$ns_ attach-agent $node_(0) $sink(7)
$ns_ connect $tcp(7) $sink(7)
set ftp(7) [new Application/FTP]
$ftp(7) attach-agent $tcp(7)

$ns_ attach-agent $node_(4) $tcp(8)
$ns_ attach-agent $node_(1) $sink(8)
$ns_ connect $tcp(8) $sink(8)
set ftp(8) [new Application/FTP]
$ftp(8) attach-agent $tcp(8)
#$ns_ at 1.2 "$ftp(4) start"


#Schedule events for the FTP agents:
for {set i 1} {$i<=$NumbSrc} { incr i } {
$ns_ at $startT($i) "$ftp($i) start"
$ns_ at $opt(stop) "$ftp($i) stop"
}  
#$ns_ trace-queue $W(1) $W(0) $trc 
#$ns_ trace-queue $W(4) $W(5) $trc 
#$ns_ trace-queue $W(8) $W(5) $trc 




####################################################################
# Monitor avg queue length of link 

set qfile1 [$ns_ monitor-queue $W(8) $W(5)  [open queue8-5.tr w] 0.05]
[$ns_ link $W(8) $W(5)] queue-sample-timeout;

set qfile [$ns_ monitor-queue $W(4) $W(5)  [open queue4-5.tr w] 0.05]
[$ns_ link $W(4) $W(5)] queue-sample-timeout;

set qfile [$ns_ monitor-queue $BS(0) $W(1)  [open queue10-1.tr w] 0.05]
[$ns_ link $BS(0) $W(1)] queue-sample-timeout;

############################################
#################PLOTTING TCP WINDOWS ###################
proc plotTCPWin {tcpSource file k} {
global ns_ NumbSrc
set time 0.03
set now [$ns_ now]
set cwnd [$tcpSource set cwnd_]
if {$k == 1} {
   puts -nonewline $file "$now \t $cwnd \t" 
  } else { 
   if {$k < $NumbSrc } { 
   puts -nonewline $file "$cwnd \t" } 
}
if { $k == $NumbSrc } {
   puts -nonewline $file "$cwnd \n" }
$ns_ at [expr $now+$time] "plotTCPWin  $tcpSource $file $k" }

# The procedure will now be called for all tcp sources
for {set j 1} {$j<=$NumbSrc} { incr j } {
$ns_ at 0.1 "plotTCPWin  $tcp($j) $windowVsTime $j" 
}

# The procedure will now be called for all tcp sources for wirless node
#for {set j 6} {$j<=$NumbSrc} { incr j } {
#$ns_ at 0.1 "plotTCPWin  $tcp($j) $windowVsTime2 $j" 
#}



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
