#!/bin/bash

#Create required directories and set permissions
#mkdir mobility_files
mkdir -p Output/nam
mkdir -p Output/trace
mkdir -p Output/Results
#chmod 777 -R mobility_files

#Create required variables to store the parameter values.
send=0
recv=0
pdr=0
pdrop=0
tp=0
nro=0
co=0
dl=0
jitter=0

#Create required variables to store the average of parameter values.
avg_send=0
avg_recv=0
avg_pdr=0
avg_pdrop=0
avg_tp=0
avg_nro=0
avg_co=0
avg_dl=0
avg_jitter=0
count=2
i=0
#Create header of CSV file.
echo ""| awk 'BEGIN{printf "Simulation_Number,No_of_Packets_Sent,No_of_Packets_Received,Packet_Delivery_Ratio,Packet_Dropping_Ratio,Throughput,Normalized_Routing_Overhead,Control_Overhead,Delay,Jitter"}'>Output/Results/Final_Result.csv

#Main loop which runs 10 times.
while : ; do
	((i++))
		#Creates 10 mobility files. Each of which is named as mob1, mob2, ... , mob10.
		#./setdest -v 2 -n 10 -m 1 -M 10 -t 100 -p 5 -x 800 -y 800 > mobility_files/mob$i		

		#Call TCL script with mobility file as a parameter.
		ns main_Mar8.tcl 

		#Call analysis file and redirect the parameter values to file Result.txt
		printf "########## Simulation number $i ##########\n\n" >> Result.txt		
		awk -f analysis-4-wireless2.awk out_$i.tr >> Result.txt
		printf "\n\n" >> Result.txt		

		#Call analysis file and redirect the parameter values to file tmp_result.
		awk -f analysis-4-wireless2.awk out_$i.tr > tmp_result

		#Extract the parameter value from the file tmp_result and redirect it to the temporary file 1.txt.
		grep "No_of_Packets_Sent:" tmp_result |  awk 'BEGIN{}{print $2;}' > 1.txt
		send=$(<1.txt)

		grep "No_of_Packets_Received:" tmp_result |  awk 'BEGIN{}{print $2;}' > 1.txt
		recv=$(<1.txt)

		grep "Packet_Delivery_Ratio:" tmp_result |  awk 'BEGIN{}{print $2;}' > 1.txt
		pdr=$(<1.txt)

		grep "Packet_Dropping_Ratio:" tmp_result |  awk 'BEGIN{}{print $2;}' > 1.txt
		pdrop=$(<1.txt)
		
		grep "Throughput:" tmp_result |  awk 'BEGIN{}{print $2;}' > 1.txt
		tp=$(<1.txt)
		
		grep "Normalized_Routing_Overhead:" tmp_result |  awk 'BEGIN{}{print $2;}' > 1.txt
		nro=$(<1.txt)
		
		grep "Control_Overhead:" tmp_result |  awk 'BEGIN{}{print $2;}' > 1.txt
		co=$(<1.txt)

		grep "Delay:" tmp_result |  awk 'BEGIN{}{print $2;}' > 1.txt
		dl=$(<1.txt)

		grep "Jitter:" tmp_result |  awk 'BEGIN{}{print $2;}' > 1.txt
		jitter=$(<1.txt)


		#This condition handles if Packet Delivery Ratio is below 1. Sometimes if nodes are apart from each other, PDR is below 1.
		if [ 1 -eq "$(echo "${pdr} < 10" | bc)" ]
		then
			((i--))
		else
			#Add all the values to average variable.
			avg_send=$( bc <<< "$send + $avg_send ")
			avg_recv=$( bc <<< "$recv + $avg_recv ")
			avg_pdr=$( bc <<< "$pdr + $avg_pdr ")
			avg_pdrop=$( bc <<< "$pdrop + $avg_pdrop ")
			avg_tp=$( bc <<< "$tp + $avg_tp ")
			avg_nro=$( bc <<< "$nro + $avg_nro ")
			avg_co=$( bc <<< "$co + $avg_co ")
			avg_dl=$( bc <<< "$dl + $avg_dl ")
			avg_jitter=$( bc <<< "$jitter + $avg_jitter ")

			#Print all the values to CSV file.
			echo  "$i" | awk '{printf "\n%.5f", $1}' >> Output/Results/Final_Result.csv
			echo  "$send" | awk '{printf ", %.5f", $1}' >> Output/Results/Final_Result.csv
			echo  "$recv" | awk '{printf ", %.5f", $1}' >> Output/Results/Final_Result.csv
			echo  "$pdr" | awk '{printf ", %.5f", $1}' >> Output/Results/Final_Result.csv
			echo  "$pdrop" | awk '{printf ", %.5f", $1}' >> Output/Results/Final_Result.csv		
			echo  "$tp" | awk '{printf ", %.5f", $1}' >> Output/Results/Final_Result.csv
			echo  "$nro" | awk '{printf ", %.5f", $1}' >> Output/Results/Final_Result.csv
			echo  "$co" | awk '{printf ", %.5f", $1}' >> Output/Results/Final_Result.csv
			echo  "$dl" | awk '{printf ", %.5f", $1}' >> Output/Results/Final_Result.csv
			echo  "$jitter" | awk '{printf ", %.5f", $1}' >> Output/Results/Final_Result.csv	
		fi

		if [ $i -eq $count ]
		then
			break
		fi
	
	done

#Print all the average values to CSV file.
echo  "" | awk '{printf "\nAverage", $1}' >> Output/Results/Final_Result.csv
echo  "$avg_send $count" | awk '{printf ", %.5f", $1/$2}' >> Output/Results/Final_Result.csv
echo  "$avg_recv $count" | awk '{printf ", %.5f", $1/$2}' >> Output/Results/Final_Result.csv
echo  "$avg_pdr $count" | awk '{printf ", %.5f", $1/$2}' >> Output/Results/Final_Result.csv
echo  "$avg_pdrop $count" | awk '{printf ", %.5f", $1/$2}' >> Output/Results/Final_Result.csv
echo  "$avg_tp $count" | awk '{printf ", %.5f", $1/$2}' >> Output/Results/Final_Result.csv
echo  "$avg_nro $count" | awk '{printf ", %.5f", $1/$2}' >> Output/Results/Final_Result.csv
echo  "$avg_co $count" | awk '{printf ", %.5f", $1/$2}' >> Output/Results/Final_Result.csv
echo  "$avg_dl $count" | awk '{printf ", %.5f", $1/$2}' >> Output/Results/Final_Result.csv
echo  "$avg_jitter $count" | awk '{printf ", %.5f", $1/$2}' >> Output/Results/Final_Result.csv


#Remove all temporary files.
rm 1.txt
rm tmp_result

#Move all output files to their locations.
mv *.nam Output/nam
mv *.tr Output/trace
mv *.txt Output/Results

#Generate and print graphs to their own .png file.
gnuplot gnuplot_script

echo "Completed successfully!"

