#!/usr/bin/env python
"""Open a manpage in the host nvim instance."""
# Setup: put this file on your $PATH with name man
from __future__ import print_function
import os
import sys

addr = os.environ.get("NVIM_LISTEN_ADDRESS", None)

if not addr:
    sys.argv[0] = '/usr/bin/man'
    os.execvp(sys.argv[0], sys.argv)

from neovim import attach
nvim = attach("socket", path=addr)
nvim.command('Man ' + ' '.join(sys.argv[1:]))
