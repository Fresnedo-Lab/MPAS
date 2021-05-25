# Order of execution

1. `fetchprimers.sh` retrieves the full list of primers for all genes from Primalscheme results.

2. `separatepools.R` separates primers into unique csv and fasta files by pool designation.

3. Submit each pool separately to clustal omega for identity analysis.

   - Install ClustalOmega?

     - http://www.clustal.org/omega/ the MacOS binary works on my computer.

     ```shell
     # TODO IDK what to do here. Biopython needs the commandline version installed to work.
     ```

   - run clustalOmega from commandline

     ```shell
     # get list of primalscheme's output files
     LIST=($(echo ../out/pools/*.fasta))
     
     mkdir ../out/pools/clustalout
     
     for file in ${LIST[@]}; do echo "file: " $file; pool=$(basename -s ".fasta" $file); clustalo --force --full --full-iter -v -t "DNA" -i ../out/pools/"${pool}".fasta -o ../out/pools/clustalout/"${pool}"_aligned.fasta --distmat-out=../out/pools/clustalout/"${pool}".pim; done
     
     # clustalo --force --full --full-iter -v -t "DNA" -i ../out/pools/pool1.fasta -o ../out/pools/clustalout/pool1_aligned.fasta --distmat-out=../out/pools/clustalout/pool1.pim 
     
     ```

     

   - How to install biopython

     ```shell
     # launch interactive session
     sinteractive -A PAS1755 -t 60
     
     # move to appropriate directory
     cd /fs/scratch/PAS1755/drw_wd/
     
     # OSC specific instructions
     module load python/3.6-conda5.2
     conda create -y -n clustalo-env -c conda-forge python=3.9
     # conda activate clustalo-env
     source activate clustalo-env
     conda install -y biopython
     
     # test
     # TODO
     
     # exit environment
     # conda deactivate
     source deactivate
     
     # end interactive session
     exit
     ```

   - Can be accessed in Python via biopython package [ClustalOmegaCommandLine](https://biopython.org/docs/1.75/api/Bio.Align.Applications.html#Bio.Align.Applications.ClustalOmegaCommandline). Run this from inside the active python3 environment:

     ```python
     from Bio.Align.Applications import ClustalOmegaCommandline
     in_file = "../out/pools/pool1.fasta"
     out_file = "../out/pools/clustalout/pool1_aligned.fasta"
     clustalomega_cline = ClustalOmegaCommandline(infile=in_file, outfile=out_file, verbose=True, auto=True)
     print(clustalomega_cline)
     # clustalo -i unaligned.fasta -o aligned.fasta --auto -v
     
     # run with this command:
     clustalomega_cline()
     
     # exit python
     exit()
     ```
     
     New way to run this script from shell:
     
     ```shell
     # launch interactive session
     sinteractive -A PAS1755 -t 60
     
     # move to appropriate directory
     # /Users/aperium/Documents/GitHub/Primal-to-Fluidigm/fluidigm_pool_design/scripts
     cd /fs/scratch/PAS1755/drw_wd/Primal-to-Fluidigm/fluidigm_pool_design/scripts
     mkdir "../out/pools/clustalout/"
     
     # conda activate clustalo-env
     source activate clustalo-env
     
     python3 runclustalomega.py
     
     # conda deactivate
     source deactivate
     ```

4. `assessmatricies.R` processes clustal omega results into a pairwise comparison of primer identity.

5. Split primary pools (designed by primalsceme) into secondary and tertiary pools to minimize identity while keeping pairs together.

   - [ ] write a script to automate this: `splitpools.R`
   - I think I figured out a relatively easy-to-implement algorithm for this. It is essentially a version of [Kruskal’s](https://en.wikipedia.org/wiki/Kruskal%27s_algorithm) with some shortcuts and constraints.
     1. Move all edges connecting primer pairs to the incidence matrix and remove them from the list of unused edges (the `.pim.csv` files of pairwise identity, essentially).
     2. Find lowest edge weight and move all edges with that weight from the list of unused edges to the incidence matrix.
     3. If not all vertices are represented in the incidence matrix, repeat starting at 2; else proceed.
        - It may be valuable to continue until a minimum spanning tree is created, then cut verticies that are too big.
     4. Pruning: any edges with intolerable weight (identity within the pool) get cut. These become separate trees or are discarded as 
     5. Split the forest up into individual trees, each of which are a separate pool.
   - For comparison, here is Wikipedia’s summary of Kruskal’s Algorithm:
     1. create a forest *F* (a set of trees), where each vertex in the graph is a separate tree
     2. create a set *S* containing all the edges in the graph
     3. while *S* is nonempty and *F* is not yet spanning
        - remove an edge with minimum weight from *S*
        - if the removed edge connects two different trees then add it to the forest *F*, combining two trees into a single tree
   - Wikipedia is a bit more eloquent than I was. The *S* is my “unused vertices list” from the list of pairwise identities. The *F* is the incident matrix I mentioned.
   - It should be relatively easy to implement in R using tidyverse. Can only hope R will be able to handle it relatively quickly.

