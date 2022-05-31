#!/bin/bash -l

set -uo pipefail

TOOLS="ecd_tools"
PYTHON3="ecd_python3"
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
    else
        echo -e "${CYN}[ERR] ${NC}${RED}Failed to Setup Conda${NC}"
    fi
fi

# create environments and install packages from the yml file
echo -e "${CYN}[INFO] ${NC}Setting up Conda Virtual Environment (environment 1): ${GRN}${TOOLS}${NC}"
echo -e "${CYN}[INFO] ${NC}Downloading and Installing Packages"
${HOME}/miniconda3/bin/conda env create --file tools.yml -n ${TOOLS} >>installation.log 2>&1

echo -e "${CYN}[INFO] ${NC}Setting up Conda Virtual Environment (environment 2): ${GRN}${PYTHON3}${NC}"
echo -e "${CYN}[INFO] ${NC}Downloading and Installing Packages"
${HOME}/miniconda3/bin/conda env create --file python3.yml -n ${PYTHON3} >>installation.log 2>&1

if [ $? -eq 0 ];
then
    echo -e "${CYN}[INFO] ${NC}${GRN}Conda Virtual Environment Setup Complete${NC}"
    echo -e "---------------------------------------------------"
    echo -e "\nAdd following lines at the top of the run script:"
    echo -e "export PATH='${HOME}/miniconda3/envs/$TOOLS/bin:\$PATH'" 
    echo -e "export PATH='${HOME}/miniconda3/envs/$PYTHON3/bin:\$PATH'\n"
else
    echo -e "${CYN}[ERR]  ${NC}${RED}Failed to Setup Conda Virtual Environment${NC}"
    exit 1;
fi
