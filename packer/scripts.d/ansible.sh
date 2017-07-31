#!/usr/bin/env bash

set -x

sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get full-upgrade -y
sudo apt-get install -y python ansible
