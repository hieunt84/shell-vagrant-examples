#!/bin/bash
#Script run from host vagrant

# node 1
sudo galera_new_cluster

# node 2
sudo systemctl start mariadb

# node 3
sudo systemctl start mariadb
