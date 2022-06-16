#!/bin/bash -l

set -uo pipefail

TOOLS="ecd_tools"
PYTHON3="ecd_python3"
MULTIQC="ecd_multiqc"
RED='\033[0;31m'
GRN='\033[1;32m'
NC='\033[0m'
CYN='\033[0;36m'
ORN='\033[0;33m'

function banner() {
    echo -e "\nThe Program performs Virtual Environment Setup.
    1. Installs Conda (if not pre-installed)
    2. Generates environments required to run Early Cancer Detection pipeline${NC}
${ORN}NOTE: The script requires access to internet.\n${NC}"
    echo -e "---------------------------------------------------"
}

banner

# ------------------------  #
# Virtual Environment Setup #
# ------------------------  #

# 1. Check if conda exists. if not install.
echo -e "${CYN}[INFO] ${NC}Checking if Conda (Virtual Environment Manager) Exists"
conda &> /dev/null
if [ $? -eq 0 ];
then
    echo -e "${CYN}[INFO] ${NC}Conda Exists."
    CONDA_HOME=`which conda`
else
    # download miniconda
    echo -e "${CYN}[INFO] ${NC}${ORN}Conda doesn't exist."
    echo -e "${CYN}[INFO] ${NC}Downloading Conda Package Installer"
    wget -t 3 -c https://repo.anaconda.com/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh -O miniconda.sh &>/dev/null
    if [ $? -eq 0 ];
    then
        echo -e "${CYN}[INFO] ${NC}${GRN}Download Complete"
    else
        echo -e "${RED}[ERR]  ${NC}${RED}Download Failed. Exiting"
        exit 1;
    fi

    # install conda setup script
    echo -e "${CYN}[INFO] ${NC}Installing Downloaded Package"
    bash miniconda.sh -ub &> /dev/null \
    && rm ./miniconda.sh
    if [ $? -eq 0 ];
    then
        echo -e "${CYN}[INFO] ${NC}${GRN}Conda Installation Successful"
        CONDA_HOME=${HOME}/miniconda3/bin/conda
    else
        echo -e "${CYN}[ERR] ${NC}${RED}Failed to Setup Conda${NC}"
    fi
fi

# create environments and install packages from the yml file

## Environment: ecd_tools -- {{{
echo -e "${CYN}[INFO] ${NC}Setting up Conda Virtual Environment (environment 1): ${GRN}${TOOLS}${NC}"
echo -e "${CYN}[INFO] ${NC}Downloading and Installing Packages"
${CONDA_HOME} env create --file tools.yml -n ${TOOLS} >>installation.log 2>&1 
if [ $? -eq 0 ];
then
    echo -e "${CYN}[INFO] ${NC}${GRN}Conda Virtual Environment Setup Complete: ${TOOLS}${NC}"
else
    echo -e "${CYN}[ERR]  ${NC}${RED}Failed to Setup Conda Virtual Environment: ${TOOLS}${NC}"
    echo -e "Exiting. Please check intallation.log for more information."
    exit 1;
fi
## }}} --

## Environment: ecd_python3 -- {{{
echo -e "${CYN}[INFO] ${NC}Setting up Conda Virtual Environment (environment 2): ${GRN}${PYTHON3}${NC}"
echo -e "${CYN}[INFO] ${NC}Downloading and Installing Packages"
${CONDA_HOME} env create --file python3.yml -n ${PYTHON3} >>installation.log 2>&1
if [ $? -eq 0 ];
then
    echo -e "${CYN}[INFO] ${NC}${GRN}Conda Virtual Environment Setup Complete: ${PYTHON3}${NC}"
else
    echo -e "${CYN}[ERR]  ${NC}${RED}Failed to Setup Conda Virtual Environment: ${PYTHON3}${NC}"
    echo -e "Exiting. Please check intallation.log for more information."
    exit 1;
fi
## }}} --

## Environment: ecd_multiqc -- {{{
echo -e "${CYN}[INFO] ${NC}Setting up Conda Virtual Environment (environment 3): ${GRN}${MULTIQC}${NC}"
echo -e "${CYN}[INFO] ${NC}Downloading and Installing Packages"
${CONDA_HOME} env create --file multiqc.yml -n ${MULTIQC} >>installation.log 2>&1
if [ $? -eq 0 ];
then
    echo -e "${CYN}[INFO] ${NC}${GRN}Conda Virtual Environment Setup Complete: ${MULTIQC}${NC}"
else
    echo -e "${CYN}[ERR]  ${NC}${RED}Failed to Setup Conda Virtual Environment: ${MULTIQC}${NC}"
    echo -e "Exiting. Please check intallation.log for more information."
    exit 1;
fi
## }}} --


if [ $? -eq 0 ];
then
    CONDA_DIR=`echo ${CONDA_HOME} | sed 's/\/bin\/conda//g'`
    echo -e "${CYN}[INFO] ${NC}${GRN}Setup Complete!${NC}"
    echo -e "---------------------------------------------------"
    echo -e "\nAdd following lines at the top of the run script:"
    echo -e "export PATH=\"${CONDA_DIR}/envs/$TOOLS/bin:\$PATH\""
    echo -e "export PATH=\"${CONDA_DIR}/envs/$PYTHON3/bin:\$PATH\""
    echo -e "export PATH=\"${CONDA_DIR}/envs/$MULTIQC/bin:\$PATH\"\n"
else
    echo -e "${CYN}[ERR]  ${NC}${RED}Failed to Setup Conda Virtual Environment${NC}"
    exit 1;
fi
