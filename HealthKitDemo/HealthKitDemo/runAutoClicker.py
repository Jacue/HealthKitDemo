import os
import urllib2
import json
import time

startLat = 31.1897856995
startLng = 121.6360759735

endLat = 31.1580977566
endLng = 121.6516516542435

currentLat = startLat
currentLng = startLng


def checkConnected():
	global currentLat,currentLng
	# global randomLng
	try:
		# response = urllib2.urlopen("http://172.16.255.195/", timeout = 1)
		# return json.load(response)
		currentLat = currentLat + (endLat - startLat) / 360
		currentLng = currentLng + (endLng - startLng) / 360
		return {"lat": str(currentLat), "lng":str(currentLng)}

	except urllib2.URLError as e:
		print e.reason

def clickAction():
	os.system("./autoClicker -x 100 -y 35")
	time.sleep(10)
	print "clicking!!"

def start():
	while True:
		if checkConnected() != None:
			clickAction()

start()