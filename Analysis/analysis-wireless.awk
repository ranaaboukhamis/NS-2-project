
BEGIN {
	send = 0;				
	recv = 0;				
	bytes = 0;
 	drop=0;				
	st = 0;					
	ft = 0;					
	rtr = 0;				
	delay = 0;				
	jitter=0;				
	jitter_count=0;			
	last_pkt_recv_time=0;
}
{	
	if (( $1 == "s" || $1 == "f" )  && $4 == "RTR" && $7 == "message" )
	{	
		rtr++;
	}
	
	
	if ( $1 == "s" && $4 == "AGT" && $7 == "tcp" )
	{
		if( send == 0 )
		{
			st = $2;   
		}		

		ft = $2;	   
		st_time[$6] = $2;   	
		send++;
	}

	if ( $1 == "r" && $4 == "AGT" && $7 == "tcp" )
	{
		if( recv == 0 )
		{
			last_pkt_recv_time = $2;
		}
		else
		{
			jitter += $2 - last_pkt_recv_time;
			jitter_count++;
			last_pkt_recv_time = $2
		}

		recv++;			
		bytes += $8;  	   
		ft_time[$6] = $2;   
		delay += ft_time[$6] - st_time[$6]  #Final value of delay is the average delay.
	}
	if ($1 == "D" || $1 =="d" )
		drop++;
}

END {
	if(recv == 0) recv=1; 
	#Printing results
	printf("No_of_Packets_Sent: \t\t%.f\n",send);
	printf("No_of_Packets_Received: \t%.f\n",recv);
	printf("No_of_Packets_Dropped: \t\t%.f\n",drop);
	printf("Packet_Delivery_Ratio: \t\t%.2f %%\n",recv/send*100);
	printf("Packet_Dropping_Ratio: \t\t%.2f %%\n",drop/send*100);
	printf("Throughput: \t\t\t%.2f Kbps\n",bytes*8/(ft-st)/1000);
	printf("Normalized_Routing_Overhead: \t%.2f %%\n",rtr/recv*100);
	printf("Control_Overhead: \t\t%d\n",rtr);
	printf("Delay: \t\t\t\t%.2f Seconds\n",delay/recv);
	printf("Jitter: \t\t\t%.2f\n",jitter/jitter_count);
}

