# NS-2-project
Designing and Implementation of heterogeneous network for supporting Quality of Service Communications


To Install NS2
Step 2: Type following commands on terminal

1 sudo apt-get update

2 sudo apt-get install gcc

3 sudo apt-get install build-essential autoconf automake

4 sudo apt-get install tcl8.5-dev tk8.5-dev

5 sudo apt-get install perl xgraph libxt-dev libx11-dev libxmu-dev



Step 3: Extract NS2

6 sudo cp /home/rana/Downloads/ns-allinone-2.35.tar.gz /opt/

7 cd /opt/

8 sudo tar -zxvf ns-allinone-2.35.tar.gz

9 sudo sed -i '137s/.*/void eraseAll() {this->erase(baseMap::begin(),baseMap::end()); }/' /opt/ns-allinone-2.35/ns-2.35/linkstate/ls.h



Type following commands on terminal



10 cd ns-allinone-2.35

11 sudo ./install



Step 4: Open bashrc file to Set the Environment Variables

Type following commands on terminal



12 sudo gedit ~/.bashrc

go last line 

12



# LD_LIBRARY_PATH

OTCL_LIB=/opt/ns-allinone-2.35/otcl-1.14/

NS2_LIB=/opt/ns-allinone-2.35/lib/

USR_Local_LIB=/usr/local/lib/

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OTCL_LIB:$NS2_LIB:$USR_Local_LIB

# TCL_LIBRARY

TCL_LIB=/opt/ns-allinone-2.35/tcl8.5.10/library/

USR_LIB=/usr/lib/

export TCL_LIBRARY=$TCL_LIBRARY:$TCL_LIB:$USR_LIB                                                                     

# PATH

XGRAPH=/opt/ns-allinone-2.35/xgraph-12.2/:/opt/ns-allinone-2.35/bin/:/opt/ns-allinone-2.35/tcl8.5.10/unix/:/opt/ns-allinone-2.35/tk8.5.10/unix/

NS=/opt/ns-allinone-2.35/ns-2.35/

NAM=/opt/ns-allinone-2.35/nam-1.15/

export PATH=$PATH:$XGRAPH:$NS:$NAM

#----

 

13 source ~/.bashrc

14 ns

15 sudo apt-get install openjdk-8-jdk

if 15 didnot work follow:

sudo add-apt-repository ppa:webupd8team/java

sudo apt-get update



16 sudo chmod -R 777 /opt



download eclipse and copy to home extract and 
