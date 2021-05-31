#!/bin/bash
#SBATCH --account=PAS1755
#SBATCH --time=224
#SBATCH --output=slurm-runprimalscheme-%j.out
set -e -u -o pipefail

# execution takes about 17 min for each pass through the 106 fastas
# first time running with the full set of 7 overlaps * 106 fastas took 116 minutes
# set clocktime for 147*11*1.2 for a 20% margin of error in the calculation

# name: slurm_runprimalscheme.sh
# author: Daniel R. Williams
# date: 30 May 2021

# Description:
# This script run runprimalscheme2.sh on SLURM at OSC
#
# input:
# output:
#
# example command:


# move to directory
#cd /fs/scratch/PAS1755/drw_wd/Primal-to-Fluidigm/primalscheme

# open correct python env
module load python/3.7-2019.10
source /fs/scratch/PAS1755/drw_wd/primalscheme/venv/bin/activate

date                              # Report date+time to time script
echo "Starting runprimalscheme.sh script..."  # Report what script is being run
echo -e "---------\n\n"           # Separate from program output

# move to directory
#cd /fs/scratch/PAS1755/drw_wd/Primal-to-Fluidigm/primalscheme

# execute primalscheme here...
# amd pass all arguments exactly as they are with their flags
bash runprimalscheme2.sh "${@}"

echo -e "\n---------\nAll done!"  # Separate from program output
date                              # Report date+time to time script

# exit environment
deactivate
