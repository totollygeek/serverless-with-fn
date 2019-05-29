# This will do a clean deploy of an application in Fn and two functions,
# along with the stats ASP.NET Core application
# This script should be run from the .\scripts folder

# We initialize some variables used below
$appName = 'devdays'
$mySqlContainerName = 'mysql0'

# Delete the fn app if it is there
fn delete app $appName

# Create the app
fn create app $appName

# Change location to detect function
Set-Location ..\src\detect

# Deploy the function
fn --verbose deploy --app $appName --local

# Change location to the save function
Set-Location ..\save

# Deploy the function
fn --verbose deploy --app $appName --local

$DB_ADDRESS = docker inspect --type container -f '{{.NetworkSettings.IPAddress}}' $mySqlContainerName
fn config app $appName DB_ADDRESS $DB_ADDRESS

$FN_ADDRESS = docker inspect --type container -f '{{.NetworkSettings.IPAddress}}' fnserver
fn config app $appName FN_ADDRESS $FN_ADDRESS

# Drop the stats container if there
docker rm stats -f

# Run the new one
docker run --name=stats -e ASPNETCORE_ENVIRONMENT=Development -e DB_ADDRESS=$DB_ADDRESS -p 8888:80 -d stats:latest

# Change location back to where we are
Set-Location ..\..\scripts