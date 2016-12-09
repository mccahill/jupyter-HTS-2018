#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

set -e

#
# start the notebook via xvfb-run so graphics work
# 
start.sh jupyter notebook $*

