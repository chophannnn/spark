#!/bin/bash

echo "chophan" | sudo -S service ssh start

$SPARK_HOME/sbin/start-all.sh

tail -f /dev/null
