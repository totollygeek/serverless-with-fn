# This will do a clean deploy of an application in Fn and two functions,
# along with the stats ASP.NET Core application
# This script should be run from the .\scripts folder

# We initialize some variables used below
$appName = 'fndotnet'
$mySqlContainerName = 'mysql0'
$volumeMap = "$($PSScriptRoot):/scripts"
$prometheusYamlMap = "$($PSScriptRoot)/config/prometheus.yml:/etc/prometheus/prometheus.yml"

function Exec([scriptblock] $cmd, [string] $message) {
	Write-Host "+--------------------------"
	Write-Host "| $message..."
	Write-Host "+------------"
	& $cmd
	Write-Host -ForegroundColor Green "+-------+"
	Write-Host -ForegroundColor Green "| Done! |"
	Write-Host -ForegroundColor Green "+-------+"
}

# Run MySQL in docker
Exec {
	& docker run `
		--name $mySqlContainerName `
		-p 3306:3306 -v $volumeMap `
		-e MYSQL_ROOT_PASSWORD='secret123!' `
		-d mysql 
} "Starting MySQL container"

$logCount = 0;
do {
	Write-Host -ForegroundColor Yellow "Waiting for 5 more seconds for MySQL to be up and running"
	Start-Sleep -Seconds 5
	$logCount = 0;
	$output = (docker logs $mySqlContainerName 2>&1)
	foreach ($line in $output) {
		if ($line -like "*Plugin ready for connections*") { $logCount++ }
	}
	Write-Host -ForegroundColor Green "Found $logCount instances"
} while ($logCount -lt 2)

# Create database
Exec {
	& docker exec -i $mySqlContainerName sh /scripts/createdb.sh
} "Creating database inside container"

# Start the Fn Server
Exec {
	& fn start -d
} "Running Fn Server"

# Start the Fn UI
Exec {
	& docker run `
		--name=ui --rm -it `
		-d --link fnserver:api `
		-p 4000:4000 `
		-e "FN_API_URL=http://api:8080" fnproject/ui
} "Starting Fn UI"

# Start Prometheus
Exec {	
	& docker run `
		--rm `
		--name=prometheus `
		-d -p 9090:9090 `
		-v $prometheusYamlMap `
		--add-host="fnserver:172.17.0.1" prom/prometheus
} "Starting Prometheus"

# Start Grafana
Exec {
	& docker run `
		--name=grafana `
		-d -p 5000:3000 `
		--add-host="prometheus:172.17.0.1" grafana/grafana
} "Starting Grafana"

# Create the app
Exec {
	& fn create app $appName
} "Creating Fn app $appName"


# Deploy the detect function
Exec {
	# Change location to detect function
	Set-Location ../src/detect

	& fn --verbose deploy --app $appName --local
} "Deploy function `"detect`""


# Deploy the save function
Exec {	
	# Change location to the save function
	Set-Location ../save

	& fn --verbose deploy --app $appName --local
} "Deploy function `"save`""

$DB_ADDRESS = docker inspect --type container -f '{{.NetworkSettings.IPAddress}}' $mySqlContainerName
& fn config app $appName DB_ADDRESS $DB_ADDRESS

$FN_ADDRESS = docker inspect --type container -f '{{.NetworkSettings.IPAddress}}' fnserver
& fn config app $appName FN_ADDRESS $FN_ADDRESS

# Build stats container image first
Exec { 
	Set-Location ../stats

	& docker build -t stats:latest .

	Set-Location ../../scripts
} "Building stats docker image"

Exec {
	& docker run --name=stats -e ASPNETCORE_ENVIRONMENT=Development -e DB_ADDRESS=$DB_ADDRESS -p 8888:80 -d stats:latest
} "Starting `"stats`" container"
