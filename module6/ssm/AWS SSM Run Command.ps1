$defaultRegion = "ap-southeast-1"
$managedInstanceId = ((Get-EC2Instance -Filter @{Name="tag:Name";Values="SQLonEC2"}).Instances).InstanceId

Initialize-AWSDefaultConfiguration -ProfileName default -Region $defaultRegion

$secretValue = (Get-SSMParameterValue `
-Name /dev/admin-password `
-WithDecryption $true).Parameters.Value


$runPSCommand = Send-SSMCommand `
-InstanceId $managedInstanceId `
-DocumentName "AWS-RunPowerShellScript" `
-Parameter @{'commands'=@("Write-Host `"Admin {{ssm:/dev/admin-name}} & password $secretValue`"")}

Get-SSMCommandInvocationDetail -CommandId $runPSCommand.CommandId -InstanceId $managedInstanceId