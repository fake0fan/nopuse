#!/usr/bin/python3

from bottle import route, run, template, view
from datetime import datetime
import simplejson as json
import queue
import threading
import zmq

queue = queue.Queue()

@route('/index')
@view('index')
def index():
  return None

@route('/data')
def data():
  global queue
  if queue.empty():
    return json.dumps({})

  labels, cpu_u, cpu_s, mem_u, mem_s = [], [], [], [], []
  mem_swap, mem_free, mem_buff, mem_cache = [], [], [], []
  cpu_user, cpu_system, system_in, system_cs = [], [], [], []
  for i in range(queue.qsize()):
    item = queue.get()
    if item is None:
        break
    labels.append(datetime.fromtimestamp(item["time"]).isoformat()[11:20])
    cpu_u.append(item["cpu-u"])
    cpu_s.append(item["cpu-s"])
    cpu_user.append(item["cpu-user"])
    cpu_system.append(item["cpu-system"])
    mem_u.append(item["mem-u"])
    mem_s.append(item["mem-s"])
    mem_swap.append(item["mem-swap"])
    mem_free.append(item["mem-free"])
    mem_buff.append(item["mem-buff"])
    mem_cache.append(item["mem-cache"])
    system_in.append(item["system-in"])
    system_cs.append(item["system-cs"])

  return json.dumps(dict(labels=labels, cpu_u=cpu_u, cpu_s=cpu_s, mem_u=mem_u, mem_s=mem_s,
      mem_swap=mem_swap, mem_free=mem_free, mem_buff=mem_buff, mem_cache=mem_cache,
      cpu_user=cpu_user, cpu_system=cpu_system, system_in=system_in, system_cs=system_cs))

def receiver():
  global queue 
  context = zmq.Context()
  results_receiver = context.socket(zmq.PULL)
  results_receiver.bind("tcp://*:15558")
  while True:
    cache = results_receiver.recv_json()
    print(cache)
    queue.put(cache)

threading.Thread(target=receiver).start()
run(host='0.0.0.0', port=28180)
