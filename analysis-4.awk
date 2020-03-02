BEGIN {
	
	max_node = 2000;
	nSentPackets = 0.0 ;		
	nReceivedPackets = 0.0 ;
	rTotalDelay = 0.0 ;
	max_pckt = 10000;
	
	idHighestPacket = 0;
	idLowestPacket = 100000;
	rStartTime = 10000.0;
	rEndTime = 0.0;
	nReceivedBytes = 0;
 	rtr = 0;
	nDropPackets = 0.0;
	jitter=0;				#variable for jitter
	jitter_count=0;			#variable for jitter count
	last_pkt_recv_time=0;	#variable for last packet received time
	temp = 0;
        frd_rtr=0;
	drop_rtr=0;
	rcv_rtr=0;
	snd_rtr=0;
	frd_agent=0;
	drop_agent=0;
	rcv_agent=0;
	snd_agent=0;
	rTime=0;
	for (i=0; i<max_node; i++) {
		node_thr[i] = 0;		
	}

	total_retransmit = 0;
	for (i=0; i<max_pckt; i++) {
		retransmit[i] = 0;		
	}

}

{
if ( $5 == "---" ) {
				#	event = $1;    time = $2;    node = $3;    type = $4;    reason = $5;    node2 = $5;    
				#	packetid = $6;    mac_sub_type=$7;    size=$8;    source = $11;    dest = $10;

					strEvent = $1 ;		rTime = $2 ;
					node = $3 ;
					strAgt = $4 ;		idPacket = $6 ;
					strType = $7 ;		nBytes = $8;

			
					num_retransmit = $20;
			
					sub(/^_*/, "", node);
					sub(/_*$/, "", node);
		#Final value of rtr will be the total number of routing packets sent.
		if (( $1 == "s" || $1 == "f" || $1=="r" )  && $4 == "RTR" && ($7 =="tcp"|| $7 =="message" ) )
			{	
				rtr++;
			}
		if ( $1 == "f"   && $4 == "RTR"  )
		{
		frd_rtr++;
		}
		if ( $1 == "r"   && $4 == "RTR"  )
		{
		rcv_rtr++;
		}
		if ( $1 == "d"   && $4 == "RTR"  )
		{
		drop_rtr++;
		}
		if ( $1 == "s"   && $4 == "RTR"  )
		{
		snd_rtr++;
		}
		f ( $1 == "f"   && $4 == "AGT"  )
		{
		frd_agent++;
		}
		if ( $1 == "r"   && $4 == "AGT"  )
		{
		rcv_agent++;
		}
		if ( $1 == "d"   && $4 == "AGT" )
		{
		drop_agent++;
		}
		if ( $1 == "s"   && $4 == "AGT"  )
		{
		snd_agent++;
		}
 
		#If event is "send" and trace level is AGT(transport layer packet) then increment send by 1.
	#Final value of send will be the total number of data packets sent.

#if ( $1 == "s" && $4 == "AGT" && $7 == "tcp" )
	
		if (strType == "tcp" && $4 == "AGT" ) 
			{
				if (idPacket > idHighestPacket) idHighestPacket = idPacket;
				if (idPacket < idLowestPacket) idLowestPacket = idPacket;

				if(rTime>rEndTime) rEndTime=rTime;
				if(rTime<rStartTime) rStartTime=rTime;

				if ( strEvent == "s" ) {
					nSentPackets += 1 ;	rSentTime[ idPacket ] = rTime ;
				}

				if ( strEvent == "r" && idPacket >= idLowestPacket) 
				{
 					if (nReceivedPackets==0)
					{
						last_pkt_recv_time = $2;
					}
					else
					{
						jitter += $2 - last_pkt_recv_time;
						jitter_count++;
						last_pkt_recv_time = $2
					}

					nReceivedPackets += 1 ;		
					nReceivedBytes += nBytes;
					rReceivedTime[ idPacket ] = rTime ;
					rDelay[idPacket] = rReceivedTime[ idPacket] - rSentTime[ idPacket ];
					rTotalDelay += rDelay[idPacket]; 
					node_thr[node] += nBytes;
				}
			}

			if( strEvent == "d"   &&   strType == "tcp" )
			{
				if(rTime>rEndTime) rEndTime=rTime;
				if(rTime<rStartTime) rStartTime=rTime;
				nDropPackets += 1;
			}

			


	}
	else {
		strEvent = $1;  
		rTime = $2;
		from_node = $3;
		to_node = $4;
		pkt_type = $5;
		pkt_size = $6;
		flgStr = $7;  #---
		flow_id = $8; 
		src_addr = $9; #0.0.0.0 
		dest_addr = $10;# 2.0.0.0
		#seq_no = $11;
		pkt_id = $11;

		sub(/^_*/, "", node);
		sub(/_*$/, "", node);

		
		
		if(pkt_type == "tcp"){

			if (pkt_id > idHighestPacket)
				 idHighestPacket = pkt_id;
			if (pkt_id < idLowestPacket) 
				idLowestPacket = pkt_id;	
			
		
			if(rTime<rStartTime) 
				rStartTime=rTime;
			if(rTime>rEndTime) 
				rEndTime=rTime;	
			if ( strEvent == "+" && pkt_size >= 512) {
				
				source = int(from_node)
				potential_source = int(src_addr)
				if(source == potential_source) {
					nSentPackets += 1 ;	
					rSentTime[ pkt_id ] = rTime ;
					send_flag[pkt_id] = 1;
				}
				
				
				
			}
			potential_dest = int(to_node)
			dest = int(dest_addr) 
			if ( strEvent == "r" && potential_dest == dest && pkt_size >= 512) {
				nReceivedPackets += 1 ;		nReceivedBytes += pkt_size;
				potential_source = int(src_addr)
				rReceivedTime[ pkt_id ] = rTime ;
				rDelay[pkt_id] = rReceivedTime[ pkt_id] - rSentTime[ pkt_id ];
				rTotalDelay += rDelay[pkt_id]; 
				node_thr[potential_source] += pkt_size;
			}
			if(strEvent == "d" && pkt_size >= 512){
				#printf("Packet Dropped\n");
				
				nDropPackets += 1;
			}
		}
		else if(pkt_type == "ack")
			{
			if(strEvent == "d" ){
				#printf("Packet Dropped\n");
				
				nDropPackets += 1;
			}
		}		



	}



}

END {
	rTime = rEndTime - rStartTime ;
	rThroughput = (nReceivedBytes/(rTime))*(8/1000);
	rPacketDeliveryRatio = nReceivedPackets / nSentPackets * 100 ;
	rPacketDropRatio = nDropPackets / nSentPackets * 100;


	if ( nReceivedPackets != 0 ) {
		rAverageDelay = rTotalDelay / nReceivedPackets ;
	}

	

	for (i=0; i<max_pckt; i++) {
		total_retransmit += retransmit[i] ;		
	}


printf("Sart Time:\t\t%15.2f\n",rStartTime)
printf("End Time:\t\t%15.2f\n",rEndTime)
printf("Simulation Time:     \t\t%15.2f\n",rTime)
printf("No of Packets_Sent: \t\t%15.2f\n",nSentPackets);
printf("No of Packets Recieved:\t\t%15.2f\n",nReceivedPackets); 
printf("No of Dropped Packet:\t\t%15.2f\n",nDropPackets); 
printf("Packet_Delivery_Ratio: \t\t%15.2f %%\n",rPacketDeliveryRatio);
printf("Packet_Dropping_Ratio: \t\t%15.2f %%\n",rPacketDropRatio);
printf("Throughput:   \t\t\t%.2f [Kbps]\n",rThroughput);
printf("Average Delay: \t\t%15.2f Seconds\n",rAverageDelay);
printf("Jitter:    \t\t%15.2f\n",jitter/jitter_count);
printf("Normalized_Routing_Overhead:    \t%.2f %%\n",rtr/nReceivedPackets);
printf("Control overhead:       \t\t%d\n",rtr);
printf("No of Packet forwarded by router: \t\t%d\n",frd_rtr);
printf("No of Packet received by router: \t\t%d\n",rcv_rtr);
printf("No of Packet sent by router: \t\t%d\n",snd_rtr);
printf("No of Packet dropped by router:\t\t%d\n",drop_rtr);
printf("No of Packet forwarded by Agent:\t\t%d\n",frd_agent);
printf("No of Packet received by Agent:\t\t%d\n",rcv_agent);
printf("No of Packet sent by Agent:   \t\t%d\n",snd_agent);
printf("No of Packet dropped by Agent:  \t\t%d\n",drop_agent);
		





}
