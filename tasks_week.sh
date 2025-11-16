#!/bin/bash
set -e

#find /tmp/navpage -type f > /tmp/navpage/navpage.txt
cat /etc/cron.d/root-cron | tee /tmp/navpage/root-cron.txt > /dev/null
