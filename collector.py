#!/usr/bin/python3

from datetime import datetime
import subprocess
import time
import zmq

command = ["vmstat", "1"]
values = {
    "waiting": 0,
    "user": 12,
    "system": 13,
    "idle": 14,
    "wait": 15,
    "stolen": 16,
}

def parse(stat, filter=None):
  if filter is None:
    return stat

  res = { "time": int(datetime.now().timestamp()) }
  if "utilization" in filter:
    res["utilization"] = int(stat[values["user"]]) + int(stat[values["system"]]) + int(stat[values["stolen"]])
  if "saturation" in filter:
    res["saturation"] = int(stat[values["waiting"]])

  return res

def main():
  process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=False)
  context = zmq.Context()
  sender = context.socket(zmq.PUSH)
  sender.connect("tcp://proj103:15558")
  while True:
    stdout = process.stdout.readline().rstrip().split()
    if stdout[0] == b"procs" or stdout[0] == b"r":
      continue
    print(stdout)
    stat = parse(stdout, ["utilization", "saturation"])
    sender.send_json(stat)



if __name__ == "__main__":
  main()
