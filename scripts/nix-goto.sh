#!/bin/sh
cd $(dirname $(readlink $(whereis $1)))/..
