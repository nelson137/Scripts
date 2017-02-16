from time import time
from subprocess import Popen, PIPE
from re import search
from sys import argv

def main(args):
    startTime = int(time())
    while True:
        if (int(time())-startTime) % int(args[0]) == 0:
            search = Popen(['pip', 'search', 'myplatform'], stdout=PIPE).communicate()[0]
            vPat = r''

if __name__ == '__main__':
    args = argv[1:]
    main(args)
