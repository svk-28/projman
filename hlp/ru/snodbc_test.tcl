#!/usr/bin/tclsh
######################################################
#                scripts
#        Distributed under GNU Public License
# Author:  
# Copyright (c) "", 2006, 
######################################################

package require snodbc

database db PCS Administrator ",bkfqy+"
db tables sm_address_range
puts [ db "SELECT * from sm_address_range"]

db disconnect



