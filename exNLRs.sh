#!/bin/sh
echo "#"
echo "# Calling shell script from: "$(dirname $0)

###################################################
NLRparserHome=$HOME'/PostDoc/Programs/NLRparser/' #  Edit this line to get thepath to your NLR-parser directrory
###################################################

# Setting up variables
wd=$(dirname $1)
SeqFile=$(basename -- "$1")
SeqFileName="$(echo $SeqFile | cut -d'.' -f1)"

if [ -z "$1" ]
    then
      echo "Please feed the script some input."
      echo $1
    else
      echo "# Calling fasta file from:   "$(dirname $1)
      echo "# "
      echo "# --------------------------------------------------------"
      echo "# "
      echo "# Predicting NLRs with mast and NLRparser: starting script"
      if [ ! -d $wd'/NLR' ]
          then
            echo "#  - Creating directory NLR"
            mkdir $wd'/NLR'
          else
            echo "#  - "$wd"/NLR already exists"
      fi
      echo "#  - Starting mast "$(mast -version)" with NLRparser meme.xml"

      mast $NLRparserHome'/meme.xml' $1 -o $wd'/NLR/meme' | tee $wd'/NLR/exNLRs.stderr'

      echo "#  - mast results are written to NLR/meme/"
      echo "#"
      echo "# --------------------------------------------------------"
      echo "#"
      echo "# Parsing mast results"
      echo "#  - Parsing mast results with NLRparser"

      java -jar $NLRparserHome'NLR-parser.jar' -i $wd'/NLR/meme/mast.xml' -a $1 -o $wd'/NLR/'$SeqFileName'.nlrparser' 2>> $wd'/NLR/exNLRs.stderr'

      echo "#  - NLRparser results written to NLR/"$SeqFileName".nlrparser"
      echo "#"
      echo "# --------------------------------------------------------"
      echo "#"

      # Remove header line in NLR-parser output:
      tail -n +2 $wd'/NLR/'$SeqFileName'.nlrparser' 1> $wd'/NLR/'$SeqFileName'.nlrparser1' 2>> $wd'/NLR/exNLRs.stderr'
      NLRs=$wd'/NLR/'$SeqFileName'.nlrparser1'

      # Some stats about the predicted NLRs:
      echo "$(wc -l < $NLRs | cut -f 1 -d '/')\ttotal" | tee $wd'/NLR/'$SeqFileName'.nlrparser.stats'

      echo "$(grep -w 'complete' $NLRs | wc -l)\tcomplete NLRs" | tee -a $wd'/NLR/'$SeqFileName'.nlrparser.stats'
      echo "$(grep -w 'CNL.*complete' $NLRs | wc -l)\tcomplete CNLs" | tee -a $wd'/NLR/'$SeqFileName'.nlrparser.stats'
      echo "$(grep -w 'TNL.*complete' $NLRs | wc -l)\tcomplete TNLs" | tee -a $wd'/NLR/'$SeqFileName'.nlrparser.stats'
      echo "$(grep -w 'complete' $NLRs | cut -f2 | grep -w 'N/A' | wc -l)\tcomplete NA" | tee -a $wd'/NLR/'$SeqFileName'.nlrparser.stats'

      echo "$(grep -w 'partial' $NLRs | wc -l)\tpartial NLRs" | tee -a $wd'/NLR/'$SeqFileName'.nlrparser.stats'
      echo "$(grep -w 'CNL.*partial' $NLRs | wc -l)\tpartial CNLs" | tee -a $wd'/NLR/'$SeqFileName'.nlrparser.stats'
      echo "$(grep -w 'TNL.*partial' $NLRs | wc -l)\tpartial TNLs" | tee -a $wd'/NLR/'$SeqFileName'.nlrparser.stats'
      echo "$(grep -w 'partial' $NLRs | cut -f2 | grep -w 'N/A' | wc -l)\tpartial NA" | tee -a $wd'/NLR/'$SeqFileName'.nlrparser.stats'
      echo ""
      echo "# NLR stats saved to file "$wd'/NLR/'$SeqFileName'.nlrparser.stats'
      echo ""

      # Call Rscript to plot the stats in a bar plot:
      Rscript $NLRparserHome'/plot-nlr.r' $wd'/NLR/'$SeqFileName'.nlrparser.stats' --save 2>> $wd'/NLR/exNLRs.stderr'

      # If there are no NLRs predicted just exit without further steps
      if [ $(wc -l < $NLRs) == 0 ]
          then
            echo ""
            echo "# Nothing to do here. No complete NLRs predicted."
            echo "# Date:                          "$(date +%d-%m-%Y_%H-%M-%S)
            exit 1
          else
            echo "# "
            echo "# Extracting sequence names of "$(grep -w 'complete' $NLRs | wc -l)" complete and "$(grep -w 'partial' $NLRs | wc -l)" partial NLRs"

            grep -w 'complete' $NLRs > $wd'/NLR/'$SeqFileName'.complete.nlrparser' 2>> $wd'/NLR/exNLRs.stderr'
            cut -f 1 $wd'/NLR/'$SeqFileName'.complete.nlrparser' > $wd'/NLR/'$SeqFileName'.complete.nlrparser.seqname' 2>> $wd'/NLR/exNLRs.stderr'

            grep -w 'CNL' $wd'/NLR/'$SeqFileName'.complete.nlrparser' > $wd'/NLR/'$SeqFileName'.CNL.complete.nlrparser' 2>> $wd'/NLR/exNLRs.stderr'
            cut -f 1 $wd'/NLR/'$SeqFileName'.CNL.complete.nlrparser' > $wd'/NLR/'$SeqFileName'.CNL.complete.nlrparser.seqname' 2>> $wd'/NLR/exNLRs.stderr'

            grep -w 'TNL' $wd'/NLR/'$SeqFileName'.complete.nlrparser' > $wd'/NLR/'$SeqFileName'.TNL.complete.nlrparser' 2>> $wd'/NLR/exNLRs.stderr'
            cut -f 1 $wd'/NLR/'$SeqFileName'.TNL.complete.nlrparser' > $wd'/NLR/'$SeqFileName'.TNL.complete.nlrparser.seqname' 2>> $wd'/NLR/exNLRs.stderr'

            grep -w 'partial' $NLRs > $wd'/NLR/'$SeqFileName'.partial.nlrparser' 2>> $wd'/NLR/exNLRs.stderr'
            cut -f 1 $wd'/NLR/'$SeqFileName'.partial.nlrparser' > $wd'/NLR/'$SeqFileName'.partial.nlrparser.seqname' 2>> $wd'/NLR/exNLRs.stderr'

            echo "# Sequence names are written in NLR/"$SeqFileName'.nlrparser.seqname1'
            echo "# "
            echo "# --------------------------------------------------------"
            echo "# "
            echo "# Extracting complete NLR sequences and NB-Arc domains"
            echo "#  - running python script exSeqList.py"

            python $NLRparserHome'/exSeqList.py' $wd'/NLR/'$SeqFileName'.complete.nlrparser.seqname' $1 2>> $wd'/NLR/exNLRs.stderr'

            echo "#  - running python script exNB.py"

            python $NLRparserHome'/exNB.py' $wd'/NLR/'$SeqFileName'.complete.nlrparser' 2>> $wd'/NLR/exNLRs.stderr'

            echo "#  - Fasta file with complete NLRs written to "$wd'/NLR/'$SeqFileName'.complete.nlrparser.seqname.fa'
            echo "# "
            echo "# --------------------------------------------------------"
            echo "# "
            echo "# Extracting complete CNL sequences and NB-Arc domains"
            echo "#  - running python script exSeqList.py"

            python $NLRparserHome'/exSeqList.py' $wd'/NLR/'$SeqFileName'.CNL.complete.nlrparser.seqname' $1 2>> $wd'/NLR/exNLRs.stderr'

            echo "#  - running python script exNB.py"

            python $NLRparserHome'/exNB.py' $wd'/NLR/'$SeqFileName'.CNL.complete.nlrparser' 2>> $wd'/NLR/exNLRs.stderr'

            echo "#  - Fasta file with complete CNLs written to "$wd'/NLR/'$SeqFileName'.CNL.complete.nlrparser.seqname.fa'
            echo "# "
            echo "# --------------------------------------------------------"
            echo "# "
            echo "# Searching for MADA motif in extracted complete CNLs"
            echo "#  - running hmmersearch with MADA.hmm"

            hmmsearch --max --tblout $wd'/NLR/'$SeqFileName'.CNL.complete.nlrparser.seqname.mada.tbl' -o $wd'/NLR/'$SeqFileName'.CNL.complete.nlrparser.seqname.mada' $NLRparserHome'/mada.hmm' $wd'/NLR/'$SeqFileName'.CNL.complete.nlrparser.seqname.fa' 2>> $wd'/NLR/exNLRs.stderr'

            echo "#  - hmmersearch results written to: - "$wd'/NLR/'$SeqFileName'.CNL.complete.nlrparser.seqname.mada'
            echo "#                                    - "$wd'/NLR/'$SeqFileName'.CNL.complete.nlrparser.seqname.mada.tbl'
            echo "#  - extracting CNL sequences and their NB domain with MADA motif"
            echo "#    - extracting sequences with full e-value < 0.01"

            grep -v "^#" $wd'/NLR/'$SeqFileName'.CNL.complete.nlrparser.seqname.mada.tbl' | awk '$5<0.01' | cut -d ' ' -f 1 > $wd'/NLR/'$SeqFileName'.CNL.mada.seqname' 2>> $wd'/NLR/exNLRs.stderr'
            <$wd'/NLR/'$SeqFileName'.CNL.mada.seqname' xargs -I % grep -e % $wd'/NLR/'$SeqFileName'.CNL.complete.nlrparser' > $wd'/NLR/'$SeqFileName'.CNL.mada.seqname.nb' 2>> $wd'/NLR/exNLRs.stderr'

            echo "#    -"$(wc -l < $wd'/NLR/'$SeqFileName'.CNL.mada.seqname')" CNLs with MADA motif to extract"

            python $NLRparserHome'/exSeqList.py' $wd'/NLR/'$SeqFileName'.CNL.mada.seqname' $wd'/NLR/'$SeqFileName'.CNL.complete.nlrparser.seqname.fa' 2>> $wd'/NLR/exNLRs.stderr'
            python $NLRparserHome'/exNB.py' $wd'/NLR/'$SeqFileName'.CNL.mada.seqname.nb' 2>> $wd'/NLR/exNLRs.stderr'

            echo "# "
            echo "#  - Fasta files with MADA CNLs and MADA CNLs NB domain written to:"
            echo "#    - MADA CNLs:    " $wd'/NLR/'$SeqFileName'.CNL.mada.seqname.fa'
            echo "#    - MADA CNLs NB: " $wd'/NLR/'$SeqFileName'.CNL.mada.seqname.nb.nb.fa'
            echo "# --------------------------------------------------------"
            echo "# "
            echo "# Extracting complete TNL sequences and NB-Arc domains"
            echo "#  - running python script exSeqList.py"

            python $NLRparserHome'/exSeqList.py' $wd'/NLR/'$SeqFileName'.TNL.complete.nlrparser.seqname' $1 2>> $wd'/NLR/exNLRs.stderr'

            echo "#  - running python script exNB.py"

            python $NLRparserHome'/exNB.py' $wd'/NLR/'$SeqFileName'.TNL.complete.nlrparser' 2>> $wd'/NLR/exNLRs.stderr'

            echo "#  - Fasta file with complete CNLs written to "$wd'/NLR/'$SeqFileName'.TNL.complete.nlrparser.seqname.fa'
            echo "# "
            echo "# --------------------------------------------------------"
            echo "# "
            echo "# Extracting partial NLR sequences and NB-Arc domains"
            echo "#  - running python script exSeqList.py"

            python $NLRparserHome'/exSeqList.py' $wd'/NLR/'$SeqFileName'.partial.nlrparser.seqname' $1 2>> $wd'/NLR/exNLRs.stderr'

            echo "#  - running python script exNB.py"

            python $NLRparserHome'/exNB.py' $wd'/NLR/'$SeqFileName'.partial.nlrparser' 2>> $wd'/NLR/exNLRs.stderr'

            echo "#  - Fasta file with partial NLRs written to "$wd'/NLR/'$SeqFileName'.partial.nlrparser.seqname.fa'
            echo "# "
            echo "# --------------------------------------------------------"
            echo "#"
            echo "# Sequences of complete and partial NLRs (CNL, TNL, NA) extracted"
            echo "# Cleaning"

            rm $NLRs 2>> $wd'/NLR/exNLRs.stderr'
            mkdir $wd'/NLR/seqname'

            SEQNAME=$wd'/NLR/'*.seqname
            echo "#  - Moving all files with sequence names to /NLR/seqname"
            for f in $SEQNAME
            do
              mv $f $wd'/NLR/seqname'
            done

            mkdir $wd'/NLR/fasta'
            FASTA=$wd'/NLR/'*.fa
            echo "#  - Moving all fasta files to /NLR/fasta"
            for f in $FASTA
            do
              mv $f $wd'/NLR/fasta'
            done

            mkdir $wd'/NLR/nlrparser'
            NLRPARSER=$wd'/NLR/'*.nlrparser
            echo "#  - Moving all nlrparser files to /NLR/nlrparser"
            for f in $NLRPARSER
            do
              mv $f $wd'/NLR/nlrparser'
            done

            mkdir $wd'/NLR/mada'
            MADA=$wd'/NLR/'*.mada*
            echo "#  - Moving all mada related files to /NLR/mada"
            for f in $MADA
            do
              echo $f
              mv $f $wd'/NLR/mada'
            done

            mkdir $wd'/NLR/plot'
            mv $wd'/NLR/'$SeqFileName'.nlrparser.stats' $wd'/NLR/plot'
            mv $wd'/NLR/'$SeqFileName'.nlrparser.stats.pdf' $wd'/NLR/plot'

            echo "# Date:                          "$(date +%d-%m-%Y_%H-%M-%S)
      fi
fi
