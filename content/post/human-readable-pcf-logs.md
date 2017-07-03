---
title: "Human Readable PCF Logs"
date: 2017-02-24T11:50:07+01:00
draft: false
comments: true
tags:
- "cloud foundry"
- "troubleshooting"
---
Sometimes you need to debug some [Cloud Foundry](https://www.cloudfoundry.org/) jobs. One obvious thing to do is looking into logs. Unfortunately some of the jobs that use `lager` don't log a human readable timestamp but only a epoch time. 

If you don't use a log aggregation tool that allows you to transform the timestamps you might want to take a look at the following script:

{{< gist mrbuk 5d60c22117afc20b032b69b6bc75c789 "plt.py" >}}

## Installation

Installing is pretty easy either via

```
# ensure you are root. if not 'sudo -i'

# copy file content to clipboard and paste in editor
vi /usr/local/bin/plt

chmod +x plt
```

or if you prefer a single _paste_ action:

```
# ensure you are root. if not 'sudo -i'

cat > /usr/local/bin/plt <<EOF
#!/usr/bin/env python

import sys
import json
from datetime import datetime

print sys.argv

file=sys.stdin
if len(sys.argv) >= 2:
        # first argument is the name of the binary
        file = open(sys.argv[1], "r")

# not using the following
#       for line in sys.stdin:
# as this seems to use the 'readlines()' method
# which waits until EOF. So not suitable for 'tail -f'
line = file.readline()
while line:
        try:
                obj=json.loads(line)
                ts=datetime.utcfromtimestamp(float(obj["timestamp"]))
                print "%s,%s,'%s'" % (ts, obj["message"], json.dumps(obj["data"]))
        except:
                print line

        line = file.readline()
EOF
chmod +x /usr/local/bin/plt
```

## Usage

Either stream via pipe

```
tail -f /var/vcap/sys/log/mysql/mariadb_ctrl.combined.log | plt
```

or provide filename as argument

```
plt /var/vcap/sys/log/mysql/mariadb_ctrl.combined.log 

```

# Why not using Go

It would be simpler to write a small Go application that uses _lager_ instead of parsing the logs with python. __But__ transferring a binary is in real life more difficult than copying a few lines of text. Also most Linux distros should have python included even when hardened and being just enough OS.
