---
title: "Restrict your LG31MU97 on MacOS to 50Hz"
date: 2017-10-05T01:40:00+02:00
draft: false
comments: true
tags:
- osx
- productivity
---

_**Caution:** Before doing anything please make sure that you have working backup. **Apply at your own risk!**_

I am using a [LG31MU97-B](http://www.lg.com/us/monitors/lg-31MU97-B-4k-ips-led-monitor) display with a MacBook Pro 15" (Mid 2015). According to the displays EDID the recommended resolution is _4096x2160@**60Hz**_. Unfortunately when running at that refresh rate the display turns black after a while and becomes unusable. This seems to be a limitation of that particular setup under MacOS.

The only known fix - other than switching to Linux or Windows - is to use a 50Hz based resolution. Unfortunately MacOS only supports HiDPI with the preferred resolution which according to the displays EDID is the 60Hz one. To get HiDPI working the idea is to disable the 60Hz resolution by patching the EDID in following file 

```
/System/Library/Displays/Contents/Resources/Overrides/DisplayVendorID-1e6d/DisplayProductID-76e7
```

After spending some time looking into the EDID the plan was to remove one timing descriptor and recalculate the checksum at the end of the extension block. The changes are marginal (first file is the orginal, the second is the patched one) but very effective:

```
$ diff ./DisplayProductID-76e7 /System/Library/Displays/Contents/Resources/Overrides/DisplayVendorID-1e6d/DisplayProductID-76e7
22c22
<       x3AReQMAAwAoeNkAh/8PTwAHAB8Abwg9AC8ABwC0uACH/w+fADsAVwBvCD0ALwAHAAAA
---
>       x3AReQMAAwAUtLgAh/8PnwA7AFcAbwg9AC8ABwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
24c24
<       AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOeQ
---
>       AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAECQ
```

The result is the following file:

{{< gist mrbuk 4af9fe3e5f797339f3df4e95fdc44d23 "DisplayProductID-76e7" >}}

To disable the _4096x2160@**60Hz**_ resolution overwrite the patched file to the above mentioned location and restart the Mac. Now the default resolution is _4096x2160@**50Hz**_ meaning all supported HiDPI resolutions should work.
