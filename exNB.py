#Python script to extract fasta sequences from multi-fasta files
#How-to use:
#   python /path/to/script/extract_fasta.py /path/to/sequence/list/sequence_list.txt
#   /path/to/fasta/file/fasta_file.fa
#correspondance: d.zendler@gmx.de
#Tested on python version 2.7.15_1, MacOS High Sierra 10.13.6

from __future__ import print_function
import sys, os, datetime, time
import cProfile
import re
#------------------------------------------------------------------------------
#Taken from: https://www.agnosticdev.com/content/how-open-file-python
#Matt Eaton on Sun, 12/17/2017 - 10:35 PM
class File():
    def __init__(self):
        #Initializing the variables for the file
        self.file_lines1 = []
        self.file_input_1 = ""
        self.complete_content1 = ""
        self.file_input_stdin1 = None
        self.working_path = ""
        self.sequence_name = ""
        #Check if there is a filename indicated
        self.parse_stdin()
        if self.file_input_name1 is not "" or self.file_input_stdin1 is not None:
            self.read_content_of_file()
        else:
            exit("Somthing went wrong with parsing your input file. Exiting.")
        if len(self.file_lines1) == 0:
            exit("Nothing to read here. Exiting")

    def parse_stdin(self):
        if len(sys.argv) == 2 and sys.argv[1] is not None:
            self.file_input_name1 = sys.argv[1]
            if self.file_input_name1 == "h" or self.file_input_name1 == "-h" or self.file_input_name1 == "-help" or self.file_input_name1 == "help":
                print(" _________________________________________________________________________________________")
                print("|Extract the NB-Arc domain sequence and with gene name into a multifasta file             |\n|")
                print("|To use this script type:           python /path/to/exNB.py /path/to/Fasta.fa        |\n|")
                print("|If still in desperate need for help see: https://github.com/daniel-ze/exNLRs             |")
                print(" ----------------------------------------------------------------------------------------- ")
                exit()
            self.working_path = os.path.dirname(os.path.realpath(sys.argv[1]))
        elif not sys.stdin.isatty():
            self.file_input_stdin1 = sys.stdin
        else:
            print("There was an issue locating your input.")
            exit("Please provide a valid filename/file as input")

    def read_content_of_file(self):
        try:
            if self.file_input_stdin1 is None:
                    with open(self.file_input_name1, 'r') as file_obj:
                        self.complete_content1 = file_obj.read()
            else:
                self.complete_content1 = self.file_input_stdin1.read()
            self.file_lines1 = self.complete_content1.split("\n")

        except ValueError:
            error_raised = "Error loading file: " + str(sys.exc_info()[0])
            print("This program needs an input file to continue. Exiting")

#Taken from: https://www.agnosticdev.com/content/how-open-file-python
#Matt Eaton on Sun, 12/17/2017 - 10:35 PM
#------------------------------------------------------------------------------
def exNB(lines):
    """Function to write the NB-Arc domain extracted by NLR-parser as multifasta"""
    file = File()
    seq = ''
    seq_fail = ''
    count = 0
    for line in lines:
        if line != "":
            line_sep = line.split("\t")

            if line_sep[5] != "N/A":
                seq = seq + ">" + line_sep[0] + "_nb\n"
                seq = seq + line_sep[5] + "\n"
                count = count + 1
            else:
                seq_fail = seq_fail + ">" + line_sep[0] + "\n"

    return seq, seq_fail, count

def main():
    file = File()
    cwd = file.working_path
    file_name = file.file_input_name1.split('/')
    file_name = ''.join(file_name[-1:])
    out1 = open(cwd + '/' + file_name + '.nb.fa', 'w')
    out2 = open(cwd + '/' + file_name + '.nb_failed.lst', 'w')
    nb, nb_fail, count1 = exNB(file.file_lines1)
    out1.write(nb)
    out2.write(nb_fail)
    out1.close()
    out2.close()

#------------------------------------------------------------
if __name__ == "__main__":
    main()
