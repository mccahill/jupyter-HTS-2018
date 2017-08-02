import argparse
import re
import sys
import os

search_string = '("cell_type": "code",.*?)("source": \[)(.*?)(\n\s*\]\n\s*})'
search_re = re.compile(search_string,re.DOTALL)

def main():
    parser = argparse.ArgumentParser(description="Strip code blocks from a Jupyter notebook")
    parser.add_argument("JUPYTER_NOTEBOOK", type=file)
    parser.add_argument("-o", "--output",metavar="OUTFILE")
    parser.add_argument("-d", "--directory",metavar="OUTFILE")
    args = parser.parse_args()

    if args.output:
        outname = args.output
    else:
        root,ext = os.path.splitext(args.JUPYTER_NOTEBOOK.name)
        if args.directory:
            root = os.path.join(args.directory,os.path.basename(root))
        outname = root + "_clean" + ext
    print >>sys.stderr, outname
    outhandle = open(outname,"w")
        

        

    stripped_string,repl_count = search_re.subn(replace_source,args.JUPYTER_NOTEBOOK.read(),re.DOTALL)
    print "Replaced:", repl_count
    outhandle.write(stripped_string)

    
def replace_source(matchobj):
    return "".join(matchobj.group(1,2,4))


    
if __name__ == "__main__":
    main()
        
