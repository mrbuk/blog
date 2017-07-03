---
title: "Pseudo Java Profiler aka sorted thread dump"
date: 2014-03-05T23:20:27+02:00
draft: false
comments: true
tags:
- "java"
- "performance"
- "troubleshooting"
---

Ever wondered what your multi threaded Java application is doing? A thread dump sorted by CPU consumption can help to find out. Having only access to a shell (bash) as well as to the tools bundled with the JDK I came up with the following solution

```
#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 jps-filter-grep-expr"
    exit 1
fi

jps_filter=$1

# extract the PID of the java process
java_app_pid=$(jps -lvm | grep ${jps_filter} | awk '{print $1}')

# get 10 top consuming threads
top_consuming_threads=$(top -n1 -H -p ${java_app_pid} | \
    egrep java | egrep -o '^[^0-9]*[0-9]+ ' | \
    sed -r 's/[^0-9]+//g' | head)

temp_file=$(mktemp)

# create jstack_output
jstack ${java_app_pid} > ${temp_file}

# print for every thread the current stack trace
for thread in ${top_consuming_threads}; do
        echo "Stack trace for Thread '${thread}':"
        printf -v thread_hex "%x" $thread
        grep -A10 "nid=0x${thread_hex}" ${temp_file}
        echo
done;

rm ${temp_file}
```

What we are doing to achieve that is the following:

1. Extract the PID of the Java process from jps
2. Run top once, show the threads and restrict to the PID from 1. and extract the top 10 (head)
3. Run jstack and write result to a temporary file
4. Iterate to the through the list form 2. and for each element using grep
  * find the right thread id
  * extract the next 10 lines after the thread id
5. Delete temporary file
