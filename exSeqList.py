#!/usr/bin/python

from __future__ import print_function
import sys, os, datetime, time

#Python script to extract fasta sequences from multi-fasta files.
#Not useful for extracting larger numbers of reads from raw sequencing data.
#This should be used to create subsets from gene or protein lists after using
#signalP or targetP.
#How-to use:
#   python exSeqList.py
#correspondance: d.zendler@gmx.de
#Tested on python version 2.7.15_1, MacOS High Sierra 10.13.6

#Taken from: https://www.agnosticdev.com/content/how-open-file-python
#Matt Eaton on Sun, 12/17/2017 - 10:35 PM
class File():
    def __init__(self):
        self.file_lines_seqIDs = []
        self.file_lines_multiFasta = []
        self.file_input_1 = ""
        self.file_input_2 = ""
        self.complete_content1 = ""
        self.complete_content2 = ""
        self.file_input_stdin1 = None
        self.file_input_stdin2 = None
        self.working_path = ""
        self.sequence_name = ""

        self.parse_stdin()
        if self.file_input_seqID is not "" or self.file_input_stdin1 is not None:
            self.read_content_of_file()
        else:
            exit("Somthing went wrong with parsing your input file. Exiting. SeqIDs")
        if len(self.file_lines_seqIDs) == 0:
            exit("Nothing to read here. Exiting")

        if self.file_input_multiFasta is not "" or self.file_input_stdin2 is not None:
            self.read_content_of_file()
        else:
            exit("Somthing went wrong with parsing your input file. Exiting. Fasta")
        if len(self.file_lines_multiFasta) == 0:
            exit("Nothing to read here. Exiting")

    def parse_stdin(self):
        if len(sys.argv) == 3 and sys.argv[1] is not None:
            self.file_input_seqID = sys.argv[1]
            if self.file_input_seqID == "h" or self.file_input_seqID == "-h" or self.file_input_seqID == "-help" or self.file_input_seqID == "help":
                print(" _________________________________________________________________________________________")
                print("|Extract sequences from a multi Fasta file using a sequence name list.                    |\n|")
                print("|Type: python seqIDs_file multiFasta.fa                                                   |\n|")
                print("|If still in desperate need for help see: https://github.com/zendl0r/sequence_annotation  |")
                print(" ----------------------------------------------------------------------------------------- ")
                exit()
            self.file_input_multiFasta = sys.argv[2]
            self.working_path = os.getcwd()
        elif not sys.stdin.isatty():
            self.file_input_stdin1 = sys.stdin
        else:
            print(" _________________________________________________________________________________________")
            print("|Extract sequences from a multi Fasta file using a sequence name list.                    |\n|")
            print("|Type: python seqIDs_file multiFasta.fa                                                   |\n|")
            print("|If still in desperate need for help see: https://github.com/zendl0r/sequence_annotation  |")
            print(" ----------------------------------------------------------------------------------------- ")
            exit()

    def read_content_of_file(self):
        try:
            if self.file_input_stdin1 is None:
                    with open(self.file_input_seqID, 'r') as file_obj:
                        self.complete_content1 = file_obj.read()
            else:
                self.complete_content1 = self.file_input_stdin1.read()
            self.file_lines_seqIDs = self.complete_content1.split("\n")

            if self.file_input_stdin2 is None:
                    with open(self.file_input_multiFasta, 'r') as file_obj:
                        self.complete_content2 = file_obj.read()
            else:
                self.complete_content2 = self.file_input_stdin2.read()
            self.file_lines_multiFasta = self.complete_content2.split()
        except ValueError:
            error_raised = "Error loading file: " + str(sys.exc_info()[0])
            print("This program needs an input file to continue. Exiting")

def findIndexOfSeq(seqID):
    """function to find the index of the sequences to be extracted"""
    file = File()
    indexList = []
    count = 0
    for line in seqID:
        #sys.stdout.write("indexing progress: %d%%   \r" % (count))
        #sys.stdout.flush()
        if line != "":
            if '>' not in line:
                line = ">" + line
            indexList.append(file.file_lines_multiFasta.index(line))
            count = count + 1
    return indexList, count

def extractSeqs(indexList):
    """function to extract the sequences"""
    file = File()
    seq = ''
    for ind in indexList:
        seq = seq + file.file_lines_multiFasta[ind] + "\n"
        ind = ind + 1
        while ind < len(file.file_lines_multiFasta):
            if '>' not in file.file_lines_multiFasta[ind]:
                seq = seq + file.file_lines_multiFasta[ind] + "\n"
                ind = ind + 1
            else:
                break
    return seq

def main():
    now = datetime.datetime.now()
    file = File()
    out = open(file.file_input_seqID + '.fa', 'w')
    count1 = 0
    indexList, count1 = findIndexOfSeq(file.file_lines_seqIDs)
    print("exSeqList.py - Number of sequences to extract: " + str(count1))
    seq = extractSeqs(indexList)
    #print(seq)
    out.write(seq)
    out.close()

if __name__ == "__main__":
    main()
