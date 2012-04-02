#!/bin/bash

n=$1
n=$((n+1))
mkdir -p /tmp/kvik
touch /tmp/kvik/${n}
echo `date +%s` >> /tmp/kvik/${n}
sleep 2
exit 0
