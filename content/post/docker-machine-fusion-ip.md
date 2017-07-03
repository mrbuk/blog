---
title: "Docker Machine wrong IP with Fusion driver"
date: 2016-01-29T20:00:07+02:00
draft: false
comments: true
tags: 
- "docker"
- "productivity"

---

Using docker-machine with VMWare Fusion may result in some weird behaviour if one has configured a static lease for the machine that docker will use.

After trying to start the Docker VM using docker-machine an error message was printed that told me that the IP address changed and hence the certificates are not valid anymore. Option 1 regenerating the certificates didn't sound right. Option 2 configuring a static lease for the VM sounded better. After that happened a weird problem showed up. Once the machine has booted (`docker-machine restart default`) docker-machine was not able to connect to the VM as is was still using the old IP.

```
$ docker-machine env default
Error checking TLS connection: Error checking and/or regenerating the certs: There was an error validating certificates for host "192.168.193.132:2376": dial tcp 192.168.193.132:2376: i/o timeout
You can attempt to regenerate them using 'docker-machine regenerate-certs [name]'.
Be advised that this will trigger a Docker daemon restart which will stop running containers.
```

Doing an `inspect` on the machine the configuration showed the right IP

```
$ docker-machine inspect default
{
    "ConfigVersion": 3,
    "Driver": {
        "IPAddress": "192.168.193.131",
        "MachineName": "default",
        "SSHUser": "docker",
        "SSHPort": 22,
        ...
    }
    ...
}
```

Checking with `ip` the old IP appears

```
$ docker-machine ip default
192.168.193.132
``` 

No matter how many times the machine was stopped, restarted, killed the old IP remained.

Checking the code of the [Docker Machine Fusion Driver](https://github.com/docker/machine/blob/v0.5.6/drivers/vmwarefusion/fusion_darwin.go#L451) revealed that (at least for 0.5.6) the following file is used to determine the IP address

```        
// DHCP lease table for NAT vmnet interface
var dhcpfile = "/var/db/vmware/vmnet-dhcpd-vmnet8.leases"
```

Taking a look into that file showed some wrong entries. The problem seems to be that this file is only populated with dynamically assigned addresses. If e.g. one has created a static lease in

    /Library/Preferences/VMware\ Fusion/vmnet8/dhcpd.conf

the lease won't show up in the file that docker checks. So as a workaround I have created a lease my self 

```
lease 192.168.193.131 {
    starts 2 2016/01/26 14:01:49;
    ends 2 2017/01/26 14:03:49;
    hardware ethernet 00:xx:xx:xx:xx:xx;
    uid 00:xx:xx:xx:xx:xx;
    client-hostname "box";
}
```

I think that using `vmrun` instead of checking the dhcp lease file would make more sense.
```
/Applications/VMware\ Fusion.app/Contents/Library/vmrun -T ws GetGuestIPAddress ~/.docker/machine/machines/default/default.vmx
192.168.193.131
```

Unfortunately I could not get access to any documentation saying since which version that feature is available. Alternatively the current approach could be enriched to check first the following file for static leases

    /Library/Preferences/VMware\ Fusion/vmnet8/dhcpd.conf

**NOTE:** `vmrun` is already used for [checking if the vm runs](https://github.com/docker/machine/blob/v0.5.6/drivers/vmwarefusion/fusion_darwin.go#L200)

**UPDATE: 10.04.2016:** It seems that GetGuestIPAddress only works with installed VM Guest tools. I have modified the docker-machine fusion driver so that it also checks the regular config. [Pull request](https://github.com/docker/machine/pull/3289), [Issue](https://github.com/docker/machine/issues/2137)

