#!/usr/bin/python
# douglas.diaz@...
# Jun-2023

import sys
import socket
#import argparse # Not available with Solaris 10 Python 2.6 default installatio
import datetime
import subprocess
##import psutil # Not available with Solaris 10 Python 2.6 default installation
import urllib
import urllib2


# timeout in seconds
timeout = 3
socket.setdefaulttimeout(timeout)


HOSTNAME=socket.gethostname()
NMS='172.16.99.144'
data = {}


# Not available with Solaris 10 Python 2.6 default installatio
#parser = argparse.ArgumentParser()
#parser.add_argument("--rebooted", help="notify reboot complete")
#parser.add_argument("--rebooting", help="notify reboot complete")
#args = parser.parse_args()

##f = open("/var/log/notifyreboot.log", "a")

data['msg']=''
if len(sys.argv) > 1:
	if sys.argv[1] == 'rebooted':
	#if args.rebooted:
		data['msg']='OS reboot complete. '
		##f.write("System rebooted\n")
	elif sys.argv[1] == 'rebooting':
	#if args.rebooting:
		data['msg']='The OS is going down for reboot NOW! '
		##f.write("System rebooting\n")


##last_reboot = psutil.boot_time()


# Gets output from OS shell command: last | head
p = subprocess.Popen(['last -n 9'], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
out, err = p.communicate()


data['from']=HOSTNAME
data['msg']=data['msg']+'Current system datetime: ' + str(datetime.datetime.now())
data['data']=out

url_values = urllib.urlencode(data)
req = urllib2.Request(url='http://' + NMS + '/tbot/tbot.php' + '?' + url_values)


try:
    # https://docs.python.org/2/library/urllib2.html
    # the HTTP request will be a POST instead of a GET when the data parameter is provided
    u = urllib2.urlopen(req)
except URLError as e:
    if hasattr(e, 'reason'):
        print 'We failed to reach a server.'
        print 'Reason: ', e.reason
    elif hasattr(e, 'code'):
        print 'The server couldn\'t fulfill the request.'
        print 'Error code: ', e.code

##f.close()
