#!/bin/bash
# author: Andre Rosa
# JUNE 26, 2019

# TIPS OFR BASH SCRIPT

#---------------------------------------------------------------------------
# CAPTURES LOCAL MACHINE IP
IPNUM=$(hostname -I | awk '{print $1}') # captures the machine ip
echo $IPNUN
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
# CAPTURES THE NAME OF THE REPOSITORY FROM THE GIT URL
REPO='git@bitbucket.org:username/reponame.git' #using SSH style
basename=$(basename $REPO)
echo $basename
GITFOLDER=${basename%.*}
echo $GITFOLDER
#---------------------------------------------------------------------------
