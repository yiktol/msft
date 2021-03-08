#Import Helper Functions
. ../others/helper.ps1

#Import AWS PowerShell Module
Import-Module -Name AWSPowerShell.NetCore


$bucketName = "yikyakyukbucket01"
$privkey = (Get-SSMParameterValue -Name /et.local/PrivateKey  –WithDecryption $true).Parameters.Value

Write-S3Object `
-BucketName $bucketName `
-Key "templates/msft-template.yaml" `
-File msft-template.yaml

Write-S3Object `
-BucketName $bucketName `
-Key "templates/ad-fsx-rdgw.yaml" `
-File ad-fsx-rdgw.yaml

$p1 = New-Object -Type Amazon.CloudFormation.Model.Parameter
$p1.ParameterKey = "Environment"
$p1.ParameterValue = "Staging"

$p2 = New-Object -Type Amazon.CloudFormation.Model.Parameter
$p2.ParameterKey = "KeyName"
$p2.ParameterValue = $privkey

$p3 = New-Object -Type Amazon.CloudFormation.Model.Parameter
$p3.ParameterKey = "DomainName"
$p3.ParameterValue = "et.local"

New-CFNStack `
-StackName "CPE-Stack" `
-TemplateURL https://$bucketName.s3-ap-southeast-1.amazonaws.com/templates/msft-template.yaml `
-Parameter @( $p1 ) 

New-CFNStack `
-StackName "AD-RDGW-FSX-Stack" `
-TemplateURL https://$bucketName.s3-ap-southeast-1.amazonaws.com/templates/ad-fsx-rdgw.yaml `
-Parameter @( $p1, $p2, $p3 ) 