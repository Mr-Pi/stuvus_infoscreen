#!/usr/bin/env python3

from datetime import datetime
from dateutil import tz
import socket
import threading
import signal
import urllib.request
import json

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

if __name__ == "__main__":
    timer_send_time = threading.Timer(10, send_time)
#    timer_send_time.start()
    departures = urllib.request.urlopen("https://efa-api.asw.io/api/v1/station/5006008/departures/").read().decode("utf-8")
    departures = json.loads(departures)
    new_departures = []
    for i in range(0,10):
        departure = departures[i]
        departure["departureTime"]["timestamp"] = datetime(
                int(departure["departureTime"]["year"]),
                int(departure["departureTime"]["month"]),
                int(departure["departureTime"]["day"]),
                int(departure["departureTime"]["hour"]),
                int(departure["departureTime"]["minute"])
                ).timestamp() + localtz.utcoffset(datetime.now()).total_seconds()
        new_departures.append(departure)
    print(new_departures)
    tcp.connect(DEST_HOST)
    okay=tcp.recv(400)
    print(okay)
    tcp.send("stuvus\n".encode())
    okay=tcp.recv(100)
    print(okay)
    tcp.send(json.dumps(new_departures).encode()+'\n'.encode())
    tcp.close()
    send_time()
#    signal.pause()
