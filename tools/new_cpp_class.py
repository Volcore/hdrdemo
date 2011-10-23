#!/usr/bin/python
import sys
import os
import errno
import datetime

year = datetime.date.today().year

HEADER = """\
/*******************************************************************************
    Copyright (c) %(year)s, Volker Schoenefeld
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
         http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#ifndef %(guard)s
#define %(guard)s

#include <shared/codingguides.h>

class %(name)s {
 public:
  %(name)s();
  ~%(name)s();
 private:
  DISALLOW_COPY_AND_ASSIGN(%(name)s);
};

#endif  // %(guard)s
"""

SOURCE = """\
/*******************************************************************************
    Copyright (c) %(year)s, Volker Schoenefeld
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
         http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#include <%(hname)s>

%(name)s::%(name)s() {
}

%(name)s::~%(name)s() {
}
"""

def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc: # Python >2.5
        if exc.errno == errno.EEXIST:
            pass
        else: raise

def main():
    if len(sys.argv)<3:
        print "Need to specify full path and class name!"
        return
    path = sys.argv[1]
    name = sys.argv[2]
    parts = path.split("/")
    hname = path+"/"+name.lower()+".h"
    ccname = path+"/"+name.lower()+".cc"
    print("Creating path %s..."%path)
    mkdir_p(path)
    guard = path.replace("/", "_").upper()+"_"+name.upper()+"_H_"
    args = dict(guard=guard,
                hname=hname,
                 year=year,
                 name=name)
    print("Creating file %s..."%hname)
    if os.path.exists(hname):
      print(" Error: File exists!")
    else:
      f = open(hname, "wt")
      f.write(HEADER%args)
      f.close()
    print("Creating file %s..."%ccname)
    if os.path.exists(ccname):
      print(" Error: File exists!")
    else:
      f = open(ccname, "wt")
      f.write(SOURCE%args)
      f.close()

if __name__ == "__main__":
    main()
