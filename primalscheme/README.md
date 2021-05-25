# Readme

Run the scripts in this order:

1. `makefastas.R`
2. `runprimalscheme.sh`
3. `grepcoverage.sh`
4. `formatcoverage.R`
5. `analyzecoverage.R`

## 1. Prepare fasta files and matching primal scheme script, and set parameters

The parameters are also hard-coded in `makefastas.R` if no parameters are provided.

```{shell}
# These are determined by PCR requirements. FLuidigm has strict parameters. Illumina MiSeq is less picky.
AMPMIN=180
AMPMAX=500
OVERLAP=70
INPATH="TK_Amplicons_090319.xlsx"
SHEET=4
NAME="Short.name"
SEQ="seq"

module load R
Rscript makefastas.R $AMPMIN $AMPMAX $OVERLAP $INPATH $SHEET $NAME $SEQ
```

**Optional:** Cluster by tree output using Clustal$\Omega$. This is an optional manual process for the moment. Only really useful if some of the genes have very high sequence similarity to each other because they are homologs. Clustered genes must be similar in length or PrimalScheme will reject the cluster. Combine genes in each cluster into a single fasta file with each gene as a separate record.

## 2. Install PrimalScheme as a Python3 virtual environment

These steps based on [PrimalScheme’s GitHub](https://github.com/aresti/primalscheme/blob/master/README.md). Installing from source for more configuration options.

```shell
# move to appropriate directory
cd /fs/scratch/PAS1755/drw_wd/

# load the latest python
module spider python
module load python/3.7-2019.10

# install from source in editable mode
git clone https://github.com/aresti/primalscheme.git primalscheme
cd primalscheme
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip # added to upgrade pip
pip install .
pip install flit
flit install --pth-file

# test
primalscheme -V

# exit environment
deactivate

```



## 3. Configure PrimalScheme

The configuration file is located at `/fs/scratch/PAS1755/drw_wd/primalscheme/src/primalscheme/config.py`. Manually edit this file to change parameters that are not available from CLI (like *T*~m~).



## 4. Run PrimalScheme from Python environment

SLURM version:

```shell
cd /fs/scratch/PAS1755/drw_wd/Primal-to-Fluidigm/primalscheme
module load git

#this script contains all the stuff in the non-SLURM version packaged up nicely.
sbatch slurm_runprimalscheme.sh

# to view activity
squeue -u $USER
```



Non SLURM version:

```shell
# open correct python env
module load python/3.7-2019.10
source /fs/scratch/PAS1755/drw_wd/primalscheme/venv/bin/activate

# test
primalscheme -V

# execute primalscheme here...
runprimalscheme.sh

# exit environment
deactivate

```



## 5. Extract coverage and prepare visuals

Updated version:

```shell
cd /fs/scratch/PAS1755/drw_wd/Primal-to-Fluidigm/primalscheme/
# cd /Users/aperium/Documents/GitHub/Primal-to-Fluidigm/primalscheme/

Rscript formatcoverage2.R
Rscript analyzecoverage2.R

```

View the file `coverage_by_overlap2.png`



Old version:

```shell
cd /fs/scratch/PAS1755/drw_wd/Primal-to-Fluidigm/primalscheme/
# cd /Users/aperium/Documents/GitHub/Primal-to-Fluidigm/primalscheme/
sh grepcoverage.sh

# cd ~
# module purge
# module load R
# Rscript /fs/scratch/PAS1755/drw_wd/reduced_primal_by_clustal/primalscheme/formatcoverage.R
# Rscript /fs/scratch/PAS1755/drw_wd/reduced_primal_by_clustal/primalscheme/analyzecoverage.R

Rscript formatcoverage.R
Rscript analyzecoverage.R

cd /fs/scratch/PAS1755/drw_wd/Primal-to-Fluidigm/primalscheme/
# cd /Users/aperium/Documents/GitHub/Primal-to-Fluidigm/primalscheme/ 
```



## old - 2. Run primal scheme

```{shell}
cd /fs/scratch/PAS1755/drw_wd/reduced_primal_by_clustal/primalscheme/
mkdir overlap_70 overlap_65 overlap_60 overlap_55 overlap_50


module load singularity
singularity shell /fs/scratch/PAS1755/Containers/Primal_1.3.2/Primal.sif
source /home/python3env/bin/activate
#sh runprimalscheme_onlyclusters.sh

# This fastas named in the list with specified overlaps
LIST=( 1_FEH_TK 1_FFT_TK 1_SST_TK 2cMDE4PCT1_TK 4C5DP2CMDEK1_TK 4H3M2EDPR2_TK CPT2_TK DOG_1_TK ETR1_TK FDPS1_TK FDPS2_TK FTC_TK FT_TK GDPS1_TK IPPK_TK PMEI_TK PPO_TK REF_TK e4H3M2EDPS1_TK cluster_4H3M2EDPR_TK cluster_CPT_TK cluster_GGDPS_TK)
OVERLAPS=( 50 55 60 65 70 )
for OVERLAP in ${OVERLAPS[@]}; do for GENE in ${LIST[@]}; do primalscheme multiplex -a 180 -a 200 -n $GENE -t $OVERLAP -o overlap_$OVERLAP/$GENE -f fastas/$GENE.fasta; done; done

exit

```



## old - 3. Copy over existing primal output for genes run separately (if needed)

```{shell}
cd /fs/scratch/PAS1755/drw_wd/reduced_primal_by_clustal/primalscheme/

# ls /fs/scratch/PAS1755/drw_wd/reduced_primal_by_clustal/primalscheme/fastas | awk 'BEGIN {FS = ".fasta"}{OFS = "\t"} {print $1}'

LIST=( 1_FEH_TK 1_FFT_TK 1_SST_TK 2cMDE4PCT1_TK 4C5DP2CMDEK1_TK 4H3M2EDPR2_TK CPT2_TK DOG_1_TK ETR1_TK FDPS1_TK FDPS2_TK FTC_TK FT_TK GDPS1_TK IPPK_TK PMEI_TK PPO_TK REF_TK e4H3M2EDPS1_TK)
OVERLAPS=( 50 55 60 65 70 )

for OVERLAP in ${OVERLAPS[@]}; do for GENE in ${LIST[@]}; do cp -pruv /fs/scratch/PAS1755/drw_wd/103_separate_genes/primalscheme/overlap_$OVERLAP/$GENE overlap_$OVERLAP; done; done


for OVERLAP in ${OVERLAPS[@]}; do for GENE in ${LIST[@]}; do primalscheme multiplex -a 180 -a 200 -n $GENE -t 50 -o overlap_$OVERLAP/$GENE -f fastas/$GENE.fasta; done; done
```



## old - 4. Extract and prepare the coverage log summary and produce visusuals

```{shell}
cd /fs/scratch/PAS1755/drw_wd/reduced_primal_by_clustal/primalscheme/
sh grepcoverage.sh

cd ~
module purge
module load R
Rscript /fs/scratch/PAS1755/drw_wd/reduced_primal_by_clustal/primalscheme/formatcoverage.R
Rscript /fs/scratch/PAS1755/drw_wd/reduced_primal_by_clustal/primalscheme/analyzecoverage.R

cd /fs/scratch/PAS1755/drw_wd/reduced_primal_by_clustal/primalscheme/

```

