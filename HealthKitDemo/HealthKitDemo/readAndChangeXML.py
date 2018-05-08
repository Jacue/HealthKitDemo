import xml.etree.cElementTree as ET
import urllib2
import json
import time

lastLat = ""
lastLng = ""

startLat = 31.1897856995
startLng = 121.6360759735

endLat = 31.1580977566
endLng = 121.6516516542435

currentLat = startLat
currentLng = startLng


def getPokemonLocation():
	global currentLat,currentLng
	# global randomLng
	try:
		# response = urllib2.urlopen("http://172.16.255.195/", timeout = 1)
		# return json.load(response)
		currentLat = currentLat + (endLat - startLat) / 3600 
		currentLng = currentLng + (endLng - startLng) / 3600
		return {"lat": str(currentLat), "lng":str(currentLng)}
	except urllib2.URLError as e:
		print e.reason

def generateXML():
	global lastLat, lastLng
	geo = getPokemonLocation()
	if geo != None:
		if geo["lat"] != lastLat or geo["lng"] != lastLng:
			lastLat = geo["lat"]
			lastLng = geo["lng"]
			gpx = ET.Element("gpx", version="1.1", creator="Xcode")
			wpt = ET.SubElement(gpx, "wpt", lat=geo["lat"], lon=geo["lng"])
			ET.SubElement(wpt, "name").text = "FakeLocation"
			ET.ElementTree(gpx).write("FakeLocation.gpx")
			print "Location Updated!", "latitude:", geo["lat"], "longitude:" ,geo["lng"]

def start():
	while True:
		generateXML()
		time.sleep(1)


start()