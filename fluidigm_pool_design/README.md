# Order of execution

1. `fetchprimers.sh` retrieves the full list of primers for all genes from Primalscheme results.

2. `separatepools.R` separates primers into unique csv and fasta files by pool designation.

   ```shell
   Rscript separatepools.R -f <file.tsv> -o <dir>
   ```

   

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

   ```shell
   Rscript assessmatricies.R -d <in_dir> -o <out_dir>
   ```

   

5. Split primary pools (designed by primalsceme) into secondary and tertiary pools to minimize identity while keeping pairs together.

   - [ ] write a script to automate this: `splitpools.R`

   - I think I figured out a relatively easy-to-implement algorithm for this. It is essentially a version of [Kruskal’s](https://en.wikipedia.org/wiki/Kruskal%27s_algorithm) with some shortcuts and constraints.
     
     ![Kruskals](README.assets/Kruskals.jpg)
     
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

   - Two new thoughts: 

     1. Is it really necessary to start with the pools designed by Primal Scheme separated into complexly different forests? What if I weight edges connecting primers of overlapping amplicons extremely high to make sure they are separated?
     2. If I’m only using the minimal spanning edges, is it possible I’ll be including primer pairs with high identity in the same trees, just connected by low weight edges? Should I instead be constructing a maximal spanning tree before trimming edges over the threshold? If I did that how would I make sure primer pairs are in the same tree?
        - The minimal spanning tree approach assumes transitivity of identity between primers. I think this is a bad assumption. Imagine a network of three 20 bp primers: two share 95% identity and the third is 50% similar both of the others, matching 10 of the 19 shared bases.
        - The problem with the simple minimal spanning tree approach is that a solution that looks good is actually bad because of the high edge weights if the tree was a complete graph.
        - Related concepts to review:
          -  [Transitive relation](https://en.wikipedia.org/wiki/Transitive_relation) 
          -  [Intransitivity](https://en.wikipedia.org/wiki/Intransitivity) 
          -  [Arc-transitive graph](https://en.wikipedia.org/wiki/Arc-transitive_graph) 
          -  [Edge-transitive graph](https://en.wikipedia.org/wiki/Edge-transitive_graph) 
          -  [Vertex-transitive graph](https://en.wikipedia.org/wiki/Vertex-transitive_graph) 
        - More thoughts:
          - It’s a consequences of the algorithm being short sighted, only looking at the minimal connections to the tree. There is possibly a place I can add a check to see if any other vertex in the node is over the threshold before connecting it to the tree. This actually changes the algorithm quite a bit. It will require growing multiple trees at the same time to create a minimum spanning forest. And then doesn’t require branch trimming at the end. Or I could build trees one at a time and keep a list of rejects to build into the next trees in the forest. The sequential approach will likely produce a long tail of short trees with only one or a few large ones. The parallel approach will create a more even distribution—actually, it will also create few large trees and a long tail of small trees, unless I add a conditional that directs it to create $n$ evenly sized trees ($n$  can be arbitrarily large or unspecified for matching any existing tree). Both are still based on Kruskal’s; they just use multiple incidence matrices, one for for each growing tree, instead of a single incidence matrix for the whole forest.
            - There is a way to make the spanning forest as optimal as the trimmed MST minimum spanning forest. I just need to check all of the separate incidence matrices for the optimal match instead of adding it to the first tree below the threshold. The search can be limited to the first $n$ trees.
            - **Actually this might be the only way to make a non-redundant forest where each tree is in a separate incidence matrix.**
          - I think there is third approach more like Kruskal’s. It's a conditional on step 3 in the figure. A search through all the vertices connecting the new vertex to the … never mind. It would require the algorithm to know how the vertices are connected in the growing forest. 

