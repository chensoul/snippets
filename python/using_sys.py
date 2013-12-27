#!/usr/bin/python

if __name__ == '__main__':
        print 'This program is being run by itself'
else:
        print 'I am being imported from another module'

import sys

dir()

print 'args:'
for i in sys.argv:
        print i

dir(sys)

print '\n\nPATH is',sys.path,'\n'
