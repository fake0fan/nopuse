#!/usr/bin/python3

from bottle import route, run, template, view
from datetime import datetime
import simplejson as json
import threading
import zmq

cache = None

@route('/index')
@view('index')
def index():
  return None

@route('/data')
def data():
  global cache 
  if cache is None:
    return json.dumps({})
  return json.dumps(cache)

def receiver():
  global cache
  context = zmq.Context()
  results_receiver = context.socket(zmq.PULL)
  results_receiver.bind("tcp://*:15558")
  while True:
    cache = results_receiver.recv_json()
    print(cache)

threading.Thread(target=receiver).start()
run(host='0.0.0.0', port=28180)
