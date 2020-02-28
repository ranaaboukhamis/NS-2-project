BEGIN{ 

rt_pkts = 0;################## to calculate total number of routing packets received 
send = 0;
				
recvd = 0;				#variable for storing number of packets received
bytes = 0;				#variable for storing number of bytes transmitted
st = 0;					#variable for start time
ft = 0;					#variable for end time
				
#delay = 0;				#variable for delay
jitter=0;				#variable for jitter
jitter_count=0;			#variable for jitter count
last_pkt_recv_time=0;	#variable for last packet received time

recvdSize = 0 ;
startTime = 1 ;
stopTime = 0 ;
sendLine = 0; 
recvLine = 0; 
fowardLine = 0; 
seqno = -1;     
count = 0; 
} 
$0 ~/^s.* AGT/ { 
        sendLine ++ ; 
} 
  
$0 ~/^r.* AGT/ { 
        recvLine ++ ; 
} 
  
$0 ~/^f.* RTR/ { 
        fowardLine ++ ; 
}
 
{ 
 
#If event is "send" and trace level is AGT(transport layer packet) then increment send by 1.
	#Final value of send will be the total number of data packets sent.

if ( $1 == "s" && $4 == "AGT" && $7 == "tcp" )
{
		if( send == 0 )
		{
		st = $2;   #Starting time of packet transmission will be assigned to st.
		}		

		ft = $2;	   #End time of packet transmission will be assigned to ft.
		st_time[$6] = $2;  #This array holds sending time for each packet and $6 is unique ID such as 0,1,2,3 and so on.	
		send++;
}
##### Check if it is a data packet 
if (( $1 == "r") && ( $7 == "cbr" || $7 =="tcp" ) && ( $4=="AGT" ))
 {
              if( recvd == 0 )
		{
			last_pkt_recv_time = $2;
		}


		else
		{
			jitter += $2 - last_pkt_recv_time;
			jitter_count++;
			last_pkt_recv_time = $2
		}

		recvd++;			
		bytes += $8;  	    #$8 is packet size and final bytes value is the total number of bytes tranmitted from source to destination.

		ft_time[$6] = $2;   #This array holds receiving time for each packet and $6 is unique ID such as 0,1,2,3 and so on.

		delay += ft_time[$6] - st_time[$6]  #Final value of delay is the average delay. 
}
##### Check if it is a routing packet 
if (($1 == "s" || $1 == "f") && $4 == "RTR" && ($7 =="tcp"|| $7 =="message" )) 
rt_pkts++; 

 


#throuput
 event = $1 
time = $2 
node_id = $3 
pkt_size = $8 
level = $4
# Store start time 
  if (level == "AGT" && event == "s" && pkt_size >= 512) { 
    if (time < startTime) { 
             startTime = time 
             } 
       } 
    
  # Update total received packets' size and store packets arrival time 
  if (level == "AGT" && event == "r" && pkt_size >= 512) { 
       if (time > stopTime) { 
             stopTime = time 
             } 
            recvdSize += pkt_size 
       }

}
END{ 


printf("No_of_Packets_Sent: \t\t%.f\n",send);
printf("No of Packets Recieved:\t\t%.f\n",recvd); 
printf("Control Overhead:\t\t%.f\n",rt_pkts); 
printf("Packet_Delivery_Ratio: \t\t%.2f %%\n",recvd/send*100);
printf("Packet_Dropping_Ratio: \t\t%.2f %%\n",(send-recvd)/send*100);
printf("Normalized Routing Load: \t\t%.3f\n", rt_pkts/recvd); 
printf("Throughput: \t\t\t%.2f Kbps\n",bytes*8/(ft-st)/1000);
printf("Average Throughput[kbps] = %.2f\t\t StartTime=%.2f\tStopTime=%.2f\n",(recvdSize/(stopTime-startTime))*(8/1000),startTime,stopTime) 
  printf "s:%d r:%d, r/s Ratio:%.4f, f:%d \n", sendLine, recvLine, (recvLine/sendLine),fowardLine; 
#printf("Delay: \t\t\t\t%.2f Seconds\n",delay/recv);
printf("Jitter: \t\t\t%.2f\n",jitter/jitter_count);



    

}
