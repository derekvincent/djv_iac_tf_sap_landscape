#!/bin/bash

## Update the software and install the S3 Fuse application 

BUCKET=${ download_bucket }${ download_prefix }
SAPSAPROUTTAB="saprouttab"
SERVICE="saprouter.service"
ROUTDIR="${ saprout_dir }"

${ script }