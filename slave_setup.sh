#!/bin/bash -x

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
rabbitmqctl stop_app
sleep 1
# rabbitmqctl reset
rabbitmqctl join_cluster 'rabbit@rabbit'
sleep 1
rabbitmqctl start_app
sleep 1

