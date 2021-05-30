# Readme

Run the scripts in this order:

1. `makefastas.R`
2. `runprimalscheme.sh`
3. `grepcoverage.sh`
4. `formatcoverage.R`
5. `analyzecoverage.R`

## 1. Prepare fasta files

```{shell}
# module load R
Rscript makefastas.R -f <file.xlsx> -o <fasta_dir> -s 4 -n Short.name -q seq
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
runprimalscheme2.sh

# exit environment
deactivate

```



## 5. Extract coverage and prepare visuals

Updated version:

```shell
cd /fs/scratch/PAS1755/drw_wd/Primal-to-Fluidigm/primalscheme/
# cd /Users/aperium/Documents/GitHub/Primal-to-Fluidigm/primalscheme/

Rscript formatcoverage2.R -d <dir> -o <file.csv>
Rscript analyzecoverage2.R

```

View the file `coverage_by_overlap2.png`



