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
	jitter=0;				
	jitter_count=0;			
	last_pkt_recv_time=0;
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
	jitter=0;
	jitter_count=0;
	for (i=0; i<max_node; i++) {
		node_thr[i] = 0;		
	}

	total_retransmit = 0;
	for (i=0; i<max_pckt; i++) {
		retransmit[i] = 0;		
	}

}
{
if ( $5 != "---" ) {

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
			if ( strEvent == "+") {
				
					nSentPackets += 1 ;	
					rSentTime[ pkt_id ] = rTime ;
					send_flag[pkt_id] = 1;
				
			}
			potential_dest = int(to_node)
			dest = int(dest_addr) 

			if ( strEvent == "r" && pkt_size >= 512) {
				
				if( nReceivedPackets == 0 )
				{
					rTime = $2;
				}


				else
				{
					jitter += $2 - rTime;
					jitter_count++;
					rTime = $2
				}

				nReceivedPackets += 1 ;		
				nReceivedBytes += pkt_size;
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
				
			#	nDropPackets += 1;
			}
		}
		else	
		{
			if(strEvent == "d")
			#	nDropPackets += 1;
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
printf("Simulation Time:     \t\t%15.2f\n",rTime)
printf("No_of_Packets_Sent: \t\t%15.2f\n",nSentPackets);
printf("No_of_Packets_Recieved:\t\t%15.2f\n",nReceivedPackets); 
printf("No of Dropped Packet:\t\t%15.2f\n",nDropPackets); 
printf("Packet_Delivery_Ratio: \t\t%15.2f %%\n",rPacketDeliveryRatio);
printf("Packet_Dropping_Ratio: \t\t%15.2f %%\n",rPacketDropRatio);
printf("Throughput:   \t\t\t\t%.2f [Mbps]\n",rThroughput/1024);
printf("Delay: \t\t\t\t%15.2f Seconds\n",rAverageDelay);
printf("Jitter: \t\t\t\t%.2f\n",jitter/jitter_count);






}
