#!/bin/bash -x

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl join_cluster 'coney@coney'
rabbitmqctl start_app
rabbitmqctl set_policy ha-all '' '{"ha-mode":"all","ha-sync-mode":"automatic"}'

