#!/usr/bin/python
# douglas.diaz@...
# Jun-2023
# Meant to work with Python 2.6 on Solaris 10

import datetime
import socket
import urllib2
import urllib


# timeout in seconds
timeout = 3
socket.setdefaulttimeout(timeout)


HOSTNAME=socket.gethostname()


NMS='172.16.99.144'

data = {}

data['from']=HOSTNAME
data['msg']=HOSTNAME + ' rebooted! Reboot completed at ' + str(datetime.datetime.now())  + ' (Python-retrieved OS date)'
data['data']=''

url_values = urllib.urlencode(data)
req = urllib2.Request(url='http://' + NMS + '/tbot/tbot.php' + '?' + url_values)

try:
    # https://docs.python.org/2/library/urllib2.html
    # the HTTP request will be a POST instead of a GET when the data parameter is provided
    f = urllib2.urlopen(req)
except URLError as e:
    if hasattr(e, 'reason'):
        print 'We failed to reach a server.'
        print 'Reason: ', e.reason
    elif hasattr(e, 'code'):
        print 'The server couldn\'t fulfill the request.'
        print 'Error code: ', e.code
