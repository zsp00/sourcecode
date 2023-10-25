#!/bin/bash
while true
do
 git add .
 git commit -m "commit new code"
 git push origin main
 sleep 500
done