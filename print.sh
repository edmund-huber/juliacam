#!/bin/bash
set -xeuo pipefail

mkdir -p stl/
rm stl/*.stl || true
openscad juliacam.scad -D part=1 -o stl/juliacam_1.stl
openscad juliacam.scad -D part=2 -o stl/juliacam_2.stl
