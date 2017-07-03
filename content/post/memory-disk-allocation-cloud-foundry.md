---
title: "Memory/disk allocation of Cloud Foundry apps"
date: 2016-10-04T21:04:57+02:00
draft: false
comments: true
tags:
- "cloud foundry"
- "operations"
---

With the help of the cf api, cf cli and [jq](https://stedolan.github.io/jq/) one can pretty easily check the amount of memory/storage allocated for apps/containers deployed in CF:

```
cf curl /v2/apps | jq '[.resources[].entity | \
 select(.memory > 1) | \
 {"mem": . | (.memory * .instances), \
 "disk": . | (.disk_quota * .instances)}] | \
 {"instances": map(.) | length, \
 "mem_total": map(.mem) | add, \
 "disk_total": map(.disk) | add}'
 
{
  "instances": 5,
  "mem_total": 32768,
  "disk_total": 32768
}
```
Values are in MB.

**Note:** above mentioned command only works if you have less than 100 apps (and you set the page size to 100). In all other cases you will only get the amount for the apps on the first page returned by the api. If you are interested in getting more than that use the following script:

```
import json
import subprocess
import sys
 
 
filtered_objects=dict()
next_url = "/v2/apps?page=1&results-per-page=100"
 
while next_url:
      print >> sys.stderr, 'Calling: %s' % next_url
 
      cf_curl_command='cf curl "%s"' % next_url
      cf_curl_output=subprocess.Popen(cf_curl_command, shell=True, stdout=subprocess.PIPE).stdout
 
      obj=json.load(cf_curl_output)
 
      next_url=obj["next_url"]
      resources=obj["resources"]
 
      for element in resources:
            entity = element["entity"]
            memory_per_instance = float(entity["memory"])
            if memory_per_instance > 1:
                  state = entity["state"]
                  memory_per_app = float(entity["instances"]) * memory_per_instance
 
                  if state not in filtered_objects:
                        filtered_objects[state] = 0.0
 
                  filtered_objects[state] = filtered_objects.get(state, 0.0) + memory_per_app
 
 
print json.dumps(filtered_objects)
```

Compared to `jq` before you have all power of python. Also you don't need to take care of authentication as `cf curl` is invoked. To run simply do `python script_name.py` on the machine where you have logged in using `cf login` before.
