#!/usr/bin/python

'''
This  script is used to generate a set of random-ish events to 
simulate log data from a Juniper Netscreen FW.  It was built
around using netcat to feed data into Flume for ingestion 
into a Hadoop cluster.

Once you have Flume configured you would use the following 
command to populate data:

./gen_events.py 2>&1 | nc 127.0.0.1 9999

'''

import random
from time import sleep

protocols = ['6', '17']
common_ports = ['20','21','22','23','25','80','109','110','119','143','156','161','389','443']
action_list = ['Deny', 'Accept', 'Drop', 'Reject'];
src_network = '192.168.1.0/24'

dest_network = '172.35.0.0/16'

fo = open("replay_log.txt", "w")
while (1 == 1):
    proto_index = random.randint(0,1)
    protocol = protocols[proto_index]
    src_port_index = random.randint(0,13)
    dest_port_index = random.randint(0,13)
    src_port = common_ports[src_port_index]
    dest_port = common_ports[dest_port_index]
    action_index = random.randint(0,3)
    action = action_list[action_index]
    src_ip_index = random.randint(1,254)
    src_ip = src_network
    dest_ip_index = random.randint(1,65535)
    dest_ip = dest_network
    event = "%s,%s,%s,%s,%s,%s" % (action,src_ip,dest_ip,src_port,dest_port,protocol)
    fo.write(event + "\n")
    print event
    sleep(0.3)


fo.close()
