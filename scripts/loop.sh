#!/bin/sh
for i in {1..1000}
do
	curl -X POST -d '{}' http://localhost:8080/invoke/01DV2VEFH3NG8G00RZJ0000002
done