#!/usr/bin/env python3
# A short program to parse nm_cli output to display NetworkManager settings

import subprocess as sp

TEXT_RED = '\033[31m'
TEXT_GREEN = '\033[32m'
TEXT_YELLOW = '\033[33m'
TEXT_NOCOLOR = '\033[0m'

conn = sp.run(['nmcli', 'connection', 'show', '--active'], stdout=sp.PIPE)
networks = conn.stdout.decode().split('\n')

if len(networks) == 0:
    print("Not connected")
else:
    nw = networks[1].split()
    print(TEXT_GREEN + "{}: {}".format(nw[3], nw[0]) + TEXT_NOCOLOR)

