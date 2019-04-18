#!/usr/bin/python3

from datetime import datetime
import subprocess
import time
import zmq

command = ["vmstat", "1"]
keys = {
    "r": 0,  # process waiting, cpu queue length
    "b": 1,  # process uninterruptible_sleep
    "swpd": 2,  # virtual memory
    "free": 3,  # remaining memory
    "buff": 4,  # buff memory
    "cache": 5,  # cache memory
    "si": 6,  # swap in
    "so": 7,  # swap out
    "bi": 8,  # blocks received_per_second
    "bo": 9,  # blocks sent_per_second
    "in": 10,  # system interrupts_per_second
    "cs": 11,  # system context_switches_per_second
    "us": 12,  # user
    "sy": 13,  # system
    "id": 14,  # idle
    "wa": 15,  # wait
    "st": 16,  # stolen
}
total_mem = 134217728  # 128GB
total_swap = 10485760 # 10GB

def parse(stat, filter=None):
  if filter is None:
    return stat

  res = { "time": int(datetime.now().timestamp()) }
  if "cpu-u" in filter:
    res["cpu-u"] = stat[keys["us"]] + stat[keys["sy"]] + stat[keys["st"]]
  if "cpu-s" in filter:
    res["cpu-s"] = stat[keys["r"]]
  if "cpu-user" in filter:
    res["cpu-user"] = stat[keys["us"]]
  if "cpu-system" in filter:
    res["cpu-system"] = stat[keys["sy"]]
  if "mem-u" in filter:
    res["mem-u"] = (1 - round(stat[keys["free"]] / total_mem, 2)) * 100
  if "mem-s" in filter:
    res["mem-s"] = stat[keys["si"]] / (stat[keys["so"]] + 1)
  if "mem-swap" in filter:
    res["mem-swap"] = round(stat[keys["swpd"]]/total_swap, 2) * 100
  if "mem-free" in filter:
    res["mem-free"] = round(stat[keys["free"]]/total_mem, 2) * 100
  if "mem-buff" in filter:
    res["mem-buff"] = round(stat[keys["buff"]]/total_mem, 2) * 100
  if "mem-cache" in filter:
    res["mem-cache"] = round(stat[keys["cache"]]/total_mem, 2) * 100
  if "system-in" in filter:
    res["system-in"] = stat[keys["in"]]
  if "system-cs" in filter:
    res["system-cs"] = stat[keys["cs"]]

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
    stdout = [int(d) for d in stdout]
    print(stdout)
    filter_list = ["cpu-u", "cpu-s", "cpu-user", "cpu-system", "mem-u", "mem-s", "mem-swap", "mem-free", "mem-buff", "mem-cache", "system-in", "system-cs"]
    stat = parse(stdout, filter_list)
    sender.send_json(stat)


if __name__ == "__main__":
  main()
