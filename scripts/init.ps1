param (
	[string]$name = $( Read-Host "Function name" )
)

fn init --init-image daniel15/fn-dotnet-init --trigger http $name
