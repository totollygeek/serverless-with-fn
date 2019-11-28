# This will do a clean deploy of an application in Fn and two functions,
# along with the stats ASP.NET Core application
# This script should be run from the .\scripts folder

# We initialize some variables used below
$appName = 'fndotnet'
$mySqlContainerName = 'mysql0'
$volumeMap = "$($PSScriptRoot):/scripts"

function Exec([scriptblock] $cmd, [string] $message) {
	Write-Host -NoNewline "$message..."
	& $cmd
	Write-Host -ForegroundColor Green " Done!"
}

# Run MySQL in docker
Exec {
	& docker run --name $mySqlContainerName -p 3306:3306 -v $volumeMap -e MYSQL_ROOT_PASSWORD=secret123! -d mysql
} "Starting MySQL container"

Exec { Start-Sleep -Seconds 20 } "Waiting for 20 seconds for MySQL to be up and running"

# Create database
Exec {
	& docker exec -i $mySqlContainerName sh /scripts/createdb.sh
} "Creating database inside container"

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