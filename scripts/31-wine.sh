#!/bin/bash

sudo emerge virtual/wine --autounmask{,-write,-continue}
sudo dispatch-conf
