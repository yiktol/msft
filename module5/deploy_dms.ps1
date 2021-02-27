#----------------------------------------------------------------------------
#Deploy Replication Instance
#----------------------------------------------------------------------------

#Create Security Group
$vpcId = (Get-EC2Vpc -Filter @{Name="tag:Name"; Values="MSFT-VPC"}).VpcId
$pubsubnet1a = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="msft-pub-1a"}).SubnetId
$pubsubnet1b = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="msft-pub-1b"}).SubnetId

New-EC2SecurityGroup `
-GroupName DEMO-ALLOW-DMS-MYSQL-MSSQL `
-GroupDescription "Allow MSSQL and MySQL" `
-VpcId $vpcId `
-TagSpecification (Set-Tag security-group "msft-dms_sg")

#Configure Security Group to open ports 1433 and 3306
$sgId = (Get-EC2SecurityGroup  -Filter @{Name="tag:Name"; Values="msft-dms_sg"}).GroupId

$mssql = Set-IngressRule "tcp" 1433 1433 "0.0.0.0/0"
$mysql = Set-IngressRule "tcp" 3306 3306 "0.0.0.0/0"

Grant-EC2SecurityGroupIngress `
-GroupId $sgId `
-IpPermission @( $mssql, $mysql )

$replicationSubnetGroupId = 'msft-replication-subnet-group'
New-DMSReplicationSubnetGroup `
-ReplicationSubnetGroupIdentifier $replicationSubnetGroupId `
-ReplicationSubnetGroupDescription 'MSFT Replication Subnet Group' `
-SubnetId @($pubsubnet1a, $pubsubnet1b) `
-Tag @{Key='Name'; Value='MSFT-DMS-Subnet-Group'} 

#Create a DMS Replication Instance
New-DMSReplicationInstance `
-ReplicationInstanceIdentifier "myDMS" `
-AllocatedStorage 50 `
-AvailabilityZone "ap-southeast-1a" `
-ReplicationInstanceClass "dms.t3.medium" `
-ReplicationSubnetGroupIdentifier $replicationSubnetGroupId `
-VpcSecurityGroupId $sgId 

#List all DMS Relication Instances
Get-DMSReplicationInstance

#----------------------------------------------------------------------------
#Define the Source Endpoint
#----------------------------------------------------------------------------

$passwd = (Get-SSMParameterValue -Name /et.local/AdminPassword  –WithDecryption $true).Parameters.Value
$user = (Get-SSMParameterValue -Name /et.local/AdminUser  –WithDecryption $true).Parameters.Value
$saUser = (Get-SSMParameterValue -Name /et.local/saUser –WithDecryption $true).Parameters.Value

#EC2 as Source
$instandeIP = ((Get-EC2Instance -Filter @{Name="tag:Name";Values="SQLonEC2"}).Instances).PrivateDnsName
New-DMSEndpoint `
-EndpointType source `
-EndpointIdentifier "ec2sqlsource" `
-EngineName "sqlserver" `
-ServerName $instandeIP `
-MicrosoftSQLServerSettings_ServerName "EC2MSSQL" `
-MicrosoftSQLServerSettings_Port 1433 `
-MicrosoftSQLServerSettings_Username $saUser `
-MicrosoftSQLServerSettings_Password $passwd `
-MicrosoftSQLServerSettings_DatabaseName "BikeStores" 

#RDS as Source
New-DMSEndpoint `
-EndpointType source `
-EndpointIdentifier "rdssqlserversource" `
-EngineName "sqlserver" `
-ServerName ((Get-RDSDBInstance -DBInstanceIdentifier mymssql).Endpoint).Address `
-MicrosoftSQLServerSettings_ServerName "RDSMSSQL" `
-MicrosoftSQLServerSettings_Port 1433 `
-MicrosoftSQLServerSettings_Username $user `
-MicrosoftSQLServerSettings_Password $passwd `
-MicrosoftSQLServerSettings_DatabaseName "BikeStores" 


#----------------------------------------------------------------------------
#Define the Target Endpoint
#----------------------------------------------------------------------------
#Aurora as Target
New-DMSEndpoint `
-EndpointType target `
-EndpointIdentifier "auroradb-instance-1"`
-EngineName "aurora" `
-ServerName ((Get-RDSDBInstance -DBInstanceIdentifier "auroradb-instance-1").Endpoint).Address `
-Port 3306 `
-Username $user `
-Password $passwd

Test-DMSConnection `
-ReplicationInstanceArn (Get-DMSReplicationInstance).ReplicationInstanceArn `
-EndpointArn (Get-DMSEndpoint -Filter @{Name="endpoint-type";Values="source"}).EndpointArn

#----------------------------------------------------------------------------
#Create Replication Task
#----------------------------------------------------------------------------

$tablemap = Get-Content -Raw configs/tablemap.json
New-DMSReplicationTask `
-ReplicationTaskIdentifier "MSSQLtoAURORA" `
-MigrationType full-load `
-ReplicationInstanceArn (Get-DMSReplicationInstance).ReplicationInstanceArn `
-SourceEndpointArn (Get-DMSEndpoint -Filter @{Name="endpoint-type";Values="source"}).EndpointArn `
-TargetEndpointArn (Get-DMSEndpoint -Filter @{Name="endpoint-type";Values="target"}).EndpointArn `
-TableMapping $tablemap

Start-DMSReplicationTask `
-ReplicationTaskArn (Get-DMSReplicationInstance).ReplicationInstanceArn `
-StartReplicationTaskType StartReplication



#---------------------------------------------------------------------------------
