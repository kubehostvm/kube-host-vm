#!/bin/bash

last12=${POD_UID: -12}  
dev="tap${last12}"

switch='br-int'
ovs-vsctl del-port "${switch} ${dev}"
