#----------------------------------------------------------------------
#Deploy Aurora
#----------------------------------------------------------------------

#Create Security Group
$vpcId = (Get-EC2Vpc -Filter @{Name="tag:Name"; Values="MSFT-VPC"}).VpcId
$pubsubnet1a = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="msft-pub-1a"}).SubnetId
$pubsubnet1b = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="msft-pub-1b"}).SubnetId

New-EC2SecurityGroup `
-GroupName DEMO-ALLOW-AURORA-MYSQL `
-GroupDescription "Allow Aurora MySQL" `
-VpcId $vpcId `
-TagSpecification (Set-Tag security-group "msft-aurora_sg")

#Configure Security Group to open ports 3306
$sgId = (Get-EC2SecurityGroup  -Filter @{Name="tag:Name"; Values="msft-aurora_sg"}).GroupId
$mysql= Set-IngressRule "tcp" 3306 3306 "0.0.0.0/0"

Grant-EC2SecurityGroupIngress `
-GroupId $sgId `
-IpPermission @( $mysql )

$passwd = (Get-SSMParameterValue -Name /et.local/AdminPassword  –WithDecryption $true).Parameters.Value
$user = (Get-SSMParameterValue -Name /et.local/AdminUser).Parameters.Value
$subnetgroup = 'msft-public-subnet'

#Create DB Subnet Group using Public Subnets
New-RDSDBSubnetGroup `
-DBSubnetGroupName $subnetgroup `
-DBSubnetGroupDescription 'MSFT Public SUbnet' `
-SubnetId @($pubsubnet1a, $pubsubnet1b) `
-Tag  @{Key='Name'; Value='MSFT-Public-Subnets'} 


#Create Aurora Cluster
New-RDSDBCluster `
-DBClusterIdentifier aurora-cluster `
-Engine aurora-mysql `
-EngineMode provisioned `
-MasterUsername $user `
-DBSubnetGroupName $subnetgroup `
-VpcSecurityGroupId $sgId `
-MasterUserPassword $passwd

#Create Aurora DB Instance
New-RDSDBInstance `
-DBClusterIdentifier aurora-cluster `
-DBInstanceIdentifier auroradb-instance-1 `
-DBInstanceClass db.t3.medium `
-StorageType aurora `
-Engine aurora-mysql `
-MultiAZ $false `
-PubliclyAccessible $true `
-EnablePerformanceInsight $false 