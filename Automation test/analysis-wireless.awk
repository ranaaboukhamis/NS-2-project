##########################################

##### Created by durgesh technoclass #####

##########################################

#Packet delivery ratio is the ratio of total number of data packets received at destination to the total number of data packets sent from source.

#Packet dropping ratio is the ratio of total number of data packets dropped to the total number of data packets sent from source.

#Throughput means the average number of bits transmitted per unit time.

#Normalized routing overhead is the ratio of number of routing packets to the total number of data packets received.

#Control overhead means the number of routing packets which are required in the network for data transmission.

#Delay is the time taken by packet to reach to destination from source.

#Jitter is the variation in delay of each packet.


BEGIN {
	send = 0;				#variable for storing number of packets sent
	recv = 0;				#variable for storing number of packets received
	bytes = 0;
 	drop=0;				#variable for storing number of bytes transmitted
	st = 0;					#variable for start time
	ft = 0;					#variable for end time
	rtr = 0;				#variable for number of routing packets
	delay = 0;				#variable for delay
	jitter=0;				#variable for jitter
	jitter_count=0;			#variable for jitter count
	last_pkt_recv_time=0;	#variable for last packet received time
}

{
	#$1 means first column in out.tr file.
	#If event is "send" and trace level is RTR(routing packet) and packet type should not be cbr and udp and ack then increment rtr by 1 and so on.
	#Final value of rtr will be the total number of routing packets sent.

	if (( $1 == "s" || $1 == "f" )  && $4 == "RTR" && $7 == "message" )
	{	
		rtr++;
	}
	
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

	#If event is "receive" and trace level is AGT(transport layer packet) then increment recv by 1.
	#Final value of recv will be the total number of data packets received.

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
		bytes += $8;  	    #$8 is packet size and final bytes value is the total number of bytes tranmitted from source to destination.

		ft_time[$6] = $2;   #This array holds receiving time for each packet and $6 is unique ID such as 0,1,2,3 and so on.

		delay += ft_time[$6] - st_time[$6]  #Final value of delay is the average delay.
	}
	if ($1 == "D" || $1 =="d" )
		drop++;
}


END {
	if(recv == 0) recv=1; #Handled issue when recv value is 0 which causes other values to raise a divide by zero error.

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

