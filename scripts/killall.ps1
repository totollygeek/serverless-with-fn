# We initialize some variables used below
$appName = 'fndotnet'
$mySqlContainerName = 'mysql0'


# Delete the fn app if it is there
& fn delete app $appName

# Drop the stats container if there
& docker rm stats -f
& docker rm $mySqlContainerName -f
& docker rm ui -f
& docker rm prometheus -f
& docker rm grafana -f

# Stop Fn Server
& fn stop