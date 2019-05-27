fn create app devdays

Set-Location ..\src\detect

fn --verbose deploy --app devdays --local

Set-Location ..\save

fn --verbose deploy --app devdays --local

$DB_ADDRESS = docker inspect --type container -f '{{.NetworkSettings.IPAddress}}' mysql0
fn config app devdays DB_ADDRESS $DB_ADDRESS

$FN_ADDRESS = docker inspect --type container -f '{{.NetworkSettings.IPAddress}}' fnserver
fn config app devdays FN_ADDRESS $FN_ADDRESS

docker run --name=stats -e ASPNETCORE_ENVIRONMENT=Development -e DB_ADDRESS=$DB_ADDRESS -p 8888:80 -d stats:latest

Set-Location ..\..\scripts