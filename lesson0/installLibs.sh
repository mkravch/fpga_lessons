#!/bin/bash
#############################################################
# Copyright (c) 1986-2019 Xilinx, Inc. All rights reserved.  #
#############################################################

if [ "$EUID" -ne 0 ]; then
   echo "This script must be run as root" 
   exit 1
fi

user=`who am i | awk '{print $1}'`
if [ "foo${user}" == "foo" ] ; then
        tmp=`tty`
        user=`ls -l ${tmp} | awk '{print $3}'`
fi
tstamp=$(date '+%Y-%m-%d_%H-%M-%S')
scriptName=`basename "$0"`
logFile=$PWD/${scriptName}_${tstamp}
touch $logFile; chmod 777 $logFile

root=$(readlink -f $(dirname ${BASH_SOURCE[0]}))

 ############################### Check OS version requirement ###################
# use lsb_release to get the OS info, if lsb_release is not installed then       #
# try to extract the os inof from  /etc/os-release                               #
 ################################################################################
test=$(lsb_release >/dev/null; echo $?)
if [ $test == 0 ]; then
  OSDIST=`lsb_release -i |awk -F: '{print tolower($2)}' | tr -d ' \t'`
  OSREL=`lsb_release -r |awk -F: '{print tolower($2)}' |tr -d ' \t' | awk -F. '{print $1}'`
elif [ -f /etc/os-release ] ; then
  echo "No lsb_release found, extracting info from: /etc/os-release "  >> $logFile
  echo "No lsb_release found, trying to extract OS info from: /etc/os-release"
  OSDIST=$(awk -F= '$1=="ID" { print $2 ;}' /etc/os-release)
  OSDIST=$(echo "$OSDIST" | tr -d '"')
  OSREL=$(awk -F= '$1=="VERSION_ID" { print $2 ;}' /etc/os-release)
  OSREL=$(echo "$OSREL" | tr -d '"')
else
 echo "I could not detect the OS and version. Please install lsb and run this script again."
 echo "To install lsb_release on Ubuntu run: 'sudo apt-get install -y lsb"
 echo "To install lsb_release on CentOS/REHL run: sudo yum install -y lsb"
 echo "Could not detect the OS and version. please install lsb_release and run this script again" >> $logFile
 echo "To install lsb_release on Ubuntu run: 'sudo apt-get install -y lsb" >> $logFile
 echo "To install lsb_release on CentOS/REHL run: sudo yum install -y lsb" >> $logFile
 exit 1
fi
echo "$OSDIST-$OSREL install"
echo "$OSDIST-$OSREL install" >> $logFile

doUbuntu()
{
### AIE Tools prerequisite libraries
   apt-get update | tee -a $logFile
   apt-get install -y libc6-dev-i386 net-tools | tee -a $logFile
   apt-get install -y graphviz | tee -a $logFile
   apt-get install -y make | tee -a $logFile
### Vitis Tools prerequisite libraries
   apt-get install -y unzip | tee -a $logFile
   apt-get install -y zip | tee -a $logFile
   apt-get install -y g++ | tee -a $logFile
   apt-get install -y libtinfo5 | tee -a $logFile
   apt-get install -y xvfb | tee -a $logFile
   apt-get install -y git | tee -a $logFile
   apt-get install -y libncursesw5 | tee -a $logFile
   apt-get install -y libc6-dev-i386 | tee -a $logFile
   apt-get install -y libnss3-dev | tee -a $logFile
   apt-get install -y libgdk-pixbuf2.0-dev | tee -a $logFile
   apt-get install -y libgtk-3-dev | tee -a $logFile
   apt-get install -y libxss-dev  | tee -a $logFile
   apt-get install -y libasound2   | tee -a $logFile
   apt-get install -y compat-openssl10  | tee -a $logFile
   apt-get install -y fdisk  | tee -a $logFile
}

doCentOs_RHEL_common()
{
### AIE Tools prerequisite libraries
    yum install -y graphviz | tee -a $logFile
    yum install -y redhat-lsb | tee -a $logFile
    yum install -y openssl | tee -a $logFile
    yum install -y libXScrnSaver | tee -a $logFile
    yum install -y xorg-x11-utils | tee -a $logFile
### Vitis Tools prerequisite libraries
    yum install -y gcc | tee -a $logFile
    yum install -y gcc-c++ | tee -a $logFile
    yum install -y git | tee -a $logFile
    ### To install kernel headers and kernel development packages
    yum install -y kernel-headers-`uname -r` | tee -a $logFile
    yum install -y kernel-devel-`uname -r` | tee -a $logFile
    yum install -y Xvfb | tee -a $logFile
}

doCentOs()
{
    yum install -y epel-release | tee -a $logFile
}

doRHELOs()
{
    LIBTINFO=$(find "/lib64/" -type f -name "libtinfo.so*") 
    ln -s $LIBTINFO /lib64/libtinfo.so.5
}

if [[ $OSDIST == "ubuntu" ]]; then
  doUbuntu
fi

if [[ $OSDIST == "centos" ]]; then
  doCentOs_RHEL_common
  doCentOs
fi

if [[ $OSDIST == "redhat"* ]]; then
  doCentOs_RHEL_common
fi

if [[ $OSDIST == "rhel"* ]]; then
  doCentOs_RHEL_common
  doRHELOs
fi

if [[ $OSDIST == "almalinux"* ]]; then
  doCentOs_RHEL_common
  doRHELOs
fi

echo "INFO: For more information please check $logFile log."
