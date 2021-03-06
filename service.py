#!/usr/bin/env python3

from datetime import datetime
from dateutil import tz
import socket
import threading
import signal
import urllib.request
import json
import os

udp = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
tcp = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
localtz = tz.tzlocal()
#DEST_HOST = ('192.168.22.99', 4444)
DEST_HOST = ('127.0.0.1', 4444)

def send_time():
    now = datetime.now()
    timestamp = now.timestamp() + localtz.utcoffset(now).total_seconds()

    print(timestamp)
    udp.sendto(bytes('stuvus/clock/set:%f:32' % timestamp, 'ASCII'), DEST_HOST)

def get_departures(station_id):
    departures = urllib.request.urlopen("https://efa-api.asw.io/api/v1/station/{}/departures/".format(station_id)).read().decode("utf-8")
    departures = json.loads(departures)
    new_departures = []
    for departure in departures:
        if departure["direction"] == "Universität (Schleife)":
            continue
        departure["departureTime"]["timestamp"] = datetime(
                int(departure["departureTime"]["year"]),
                int(departure["departureTime"]["month"]),
                int(departure["departureTime"]["day"]),
                int(departure["departureTime"]["hour"]),
                int(departure["departureTime"]["minute"])
                ).timestamp() + localtz.utcoffset(datetime.now()).total_seconds()
        new_departures.append(departure)
    new_departures.sort(key = lambda x: x['departureTime']['timestamp'])
    return new_departures

if __name__ == "__main__":
#    timer_send_time = threading.Timer(10, send_time)
#    timer_send_time.start()
    departures = []
    departures.extend( get_departures('5006008') )  # Universität
    departures.extend( get_departures('5006021') )  # Universität (Schleife)
    departures.sort(key = lambda x: x['departureTime']['timestamp'])
    print(json.dumps(departures))
    tcp.connect(DEST_HOST)
    okay=tcp.recv(400)
    tcp.send("stuvus\n".encode())
    okay=tcp.recv(100)
    tcp.send(json.dumps(departures).encode('utf-8')+'\n'.encode('utf-8'))
    tcp.close()
    send_time()
    os.system('wget -O /home/pi/stuvus/meteogram.png https://www.yr.no/place/Germany/Baden-W%C3%BCrttemberg/Universit%C3%A4t_Stuttgart_Campus_Vaihingen/meteogram.png')
#    signal.pause()
