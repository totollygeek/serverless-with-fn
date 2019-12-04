#!/bin/sh
for i in {1..1000}
do
	curl -X GET -A "iphone" http://localhost:8080/t/fndotnet/detect
done