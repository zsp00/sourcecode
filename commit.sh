#!/bin/bash
while true
do
 git pull
 git add .
 git commit -m "commit new code"
 git push origin main
 sleep 60
done