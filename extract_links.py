#!/usr/bin/python
# 
# extracts links from html source file and prints them to screen

import re
from sys import argv

filename = str(argv[1])

links_regex = re.compile('<a href=[\'"]?([^\'" >]+)', re.IGNORECASE)
html = open(filename).read()
links = links_regex.findall(html)
print '\n'.join(links)
