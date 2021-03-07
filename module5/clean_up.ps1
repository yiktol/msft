#----------------------------------------------------------------------
#Clean-Up Aurora
#----------------------------------------------------------------------
#Delete Aurora DB Instance
Remove-RDSDBInstance `
-DBInstanceIdentifier auroradb-instance-1 `
-DeleteAutomatedBackup $true `
-SkipFinalSnapshot $true `
-Force 

#Delete Aurora Cluster
Remove-RDSDBCluster `
-DBClusterIdentifier aurora-cluster `
-SkipFinalSnapshot $true `
-Force

$sgId = (Get-EC2SecurityGroup  -Filter @{Name="tag:Name"; Values="msft-aurora_sg"}).GroupId
Remove-EC2SecurityGroup `
-GroupId $sgId `
-Force 


#----------------------------------------------------------------------
#Clean-Up RDS
#----------------------------------------------------------------------

#Clean Up
Remove-RDSDBInstance `
-DBInstanceIdentifier mymssql `
-DeleteAutomatedBackup $true `
-SkipFinalSnapshot $true `
-Force 

$sgId = (Get-EC2SecurityGroup  -Filter @{Name="tag:Name"; Values="rds_sg"}).GroupId
Remove-EC2SecurityGroup `
-GroupId $sgId `
-Force 

$subnetgroup = 'msft-public-subnet'
Remove-RDSDBSubnetGroup `
-DBSubnetGroupName $subnetgroup `
-Force

#----------------------------------------------------------------------
#Clean-Up SQL on EC2
#----------------------------------------------------------------------

#Delete EC2 Instance
$instandeID = ((Get-EC2Instance -Filter @{Name="tag:Name";Values="SQLonEC2"}).Instances).InstanceId
Remove-EC2Instance `
-InstanceId $instandeID `
-Force 

$sgId = (Get-EC2SecurityGroup  -Filter @{Name="tag:Name"; Values="msft-ssh_rdp_sql"}).GroupId
Remove-EC2SecurityGroup `
-GroupId $sgId `
-Force 

#----------------------------------------------------------------------
#Clean-Up SQL on Linux
#----------------------------------------------------------------------

#Delete EC2 Instance
$instandeID = ((Get-EC2Instance -Filter @{Name="tag:Name";Values="SQLonLinux"}).Instances).InstanceId
Remove-EC2Instance `
-InstanceId $instandeID `
-Force 

#----------------------------------------------------------------------
#Clean-Up DMS
#----------------------------------------------------------------------

#Delete DMS Relication Instance
$ReplicationTaskArn = ((Get-DMSReplicationTask -Filter @{Name="endpoint-arn";Values=(Get-DMSEndpoint -Filter @{Name="endpoint-type";Values="source"}).EndpointArn}).ReplicationTaskArn)
Remove-DMSReplicationTask `
-ReplicationTaskArn $ReplicationTaskArn `
-Force 

Remove-DMSReplicationInstance `
-ReplicationInstanceArn $(Get-DMSReplicationInstance).ReplicationInstanceArn `
-Force 

Remove-DMSEndpoint `
-EndpointArn (Get-DMSEndpoint -Filter @{Name="endpoint-type";Values="source"}).EndpointArn `
-Force

Remove-DMSEndpoint `
-EndpointArn (Get-DMSEndpoint -Filter @{Name="endpoint-type";Values="target"}).EndpointArn `
-Force

$sgId = (Get-EC2SecurityGroup  -Filter @{Name="tag:Name"; Values="msft-dms_sg"}).GroupId
Remove-EC2SecurityGroup `
-GroupId $sgId `
-Force 

Remove-DMSReplicationSubnetGroup `
-ReplicationSubnetGroupIdentifier 'msft-replication-subnet-group' `
-Force