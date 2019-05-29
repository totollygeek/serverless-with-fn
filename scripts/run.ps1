# $FN_SERVER = docker inspect --type container -f '{{.NetworkSettings.IPAddress}}' fnserver

# $API_URL = "http://$FN_SERVER" + "8080"
# $API_URL_R = "$API_URL/r"
# $COMPLETER_BASE_URL = "http://$FN_SERVER" + "8081"

# Run Fn Server UI
docker run --rm `
	-it `
	-d `
	--name=fnserver-ui `
	--link fnserver:api `
	-p 4000:4000 `
	-e "FN_API_URL=http://api:8080" `
	fnproject/ui

# Run Prometheus
# docker run --rm `
# 	--name=prometheus `
# 	-d `
# 	-p 9090:9090 `
# 	-v c:\git\tutorials\grafana\prometheus.yml:/etc/prometheus/prometheus.yml `
# 	--add-host="fnserver:172.17.0.1" `
# 	prom/prometheus

# Run Grafana
# docker run --name=grafana `
# 	-d `
# 	-p 5000:3000 `
# 	--add-host="prometheus:172.17.0.1" `
# 	grafana/grafana

# Run Flow service
# docker run --rm `
# 	-p 8081:8081 `
# 	-d `
# 	-e API_URL=$API_URL_R `
# 	-e no_proxy=$FN_SERVER `
# 	--name=flow-service `
# 	fnproject/flow:latest

# Run Flow UI service
# docker run --rm `
# 	-p 3000:3000 `
# 	-d `
# 	--name flowui `
# 	-e API_URL=$API_URL `
# 	-e COMPLETER_BASE_URL=$COMPLETER_BASE_URL `
# 	fnproject/flow:ui
