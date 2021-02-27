#--------------------------------------------------------------------------------------
# Clean-Up SSM Document
#--------------------------------------------------------------------------------------
$u = '_'
$directoryName = 'et.local'
$directoryId = (Get-DSDirectory | Where-Object { $_.Name -like $directoryName }).DirectoryId
$ssmDocumentName = "awsconfig_Domain_$directoryId$u$directoryName"

Remove-SSMDocument `
-Name $ssmDocumentName `
-Force

#--------------------------------------------------------------------------------------
# Clean-Up Windows 2019 EC2
#--------------------------------------------------------------------------------------
$instandeID = ((Get-EC2Instance -Filter @{Name="tag:Name";Values="RDGateway"}).Instances).InstanceId
Remove-EC2Instance `
-InstanceId $instandeID `
-Force 

$sgId = (Get-EC2SecurityGroup  -Filter @{Name="tag:Name"; Values="msft-allow_rdp"}).GroupId
Remove-EC2SecurityGroup `
-GroupId $sgId `
-Force 

#--------------------------------------------------------------------------------------
# Clean-Up Amazon FSx
#--------------------------------------------------------------------------------------

$FileSystemId = (Get-FSXFileSystem).FileSystemId

Remove-FSXFileSystem `
-FileSystemId $FileSystemId `
-Force

$sgId = (Get-EC2SecurityGroup  -Filter @{Name="tag:Name"; Values="msft-fsx-sg"}).GroupId
Remove-EC2SecurityGroup `
-GroupId $sgId `
-Force 

#--------------------------------------------------------------------------------------
# Clean-Up AWS Managed Microsoft Active Directory
#--------------------------------------------------------------------------------------
$vpcId = (Get-EC2Vpc -Filter @{Name="tag:Name"; Values="MSFT-VPC"}).VpcId
$directoryId = (Get-DSDirectory | Where-Object { $_.Name -like $directoryName }).DirectoryId
$dhcpOptionId = (Get-EC2DhcpOption -Filter @{Name="tag:Name"; Values="default"}).DhcpOptionsId

Remove-DSDirectory `
-DirectoryId $directoryId `
-Force

Register-EC2DhcpOption -DhcpOptionsId $dhcpOptionId -VpcId $vpcId

$dhcpOptionIds = (Get-EC2DhcpOption -Filter @{Name="tag:Name"; Values="msft-dhcpoptions"}).DhcpOptionsId
foreach ($item in $dhcpOptionIds) {
    Remove-EC2DhcpOption -DhcpOptionsId $item -Force
    }     




