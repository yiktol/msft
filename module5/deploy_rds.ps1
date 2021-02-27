
#---------------------------------------------------------------------
#Create RDS MS SQL
#---------------------------------------------------------------------

#Create Security Group
$vpcId = (Get-EC2Vpc -Filter @{Name="tag:Name"; Values="MSFT-VPC"}).VpcId
New-EC2SecurityGroup `
-GroupName DEMO-ALLOW-RDS-MSSQL `
-GroupDescription "Allow RDS MS SQL" `
-VpcId $vpcId `
-TagSpecification (Set-Tag security-group "rds_sg")

#Configure Security Group to open ports 1433
$sgId = (Get-EC2SecurityGroup  -Filter @{Name="tag:Name"; Values="rds_sg"}).GroupId

$ip1 = Set-IngressRule "tcp" 1433 1433 "0.0.0.0/0"
Grant-EC2SecurityGroupIngress `
-GroupId $sgId `
-IpPermission @( $ip1 )

#Create MS SQL RDS Instance
$passwd = (Get-SSMParameterValue -Name /et.local/AdminPassword  –WithDecryption $true).Parameters.Value
$user = (Get-SSMParameterValue -Name /et.local/AdminUser).Parameters.Value
$subnetgroup = 'msft-public-subnet'

New-RDSDBInstance `
-DBInstanceIdentifier myMSSQL `
-AllocatedStorage 20 `
-DBInstanceClass db.m5.large `
-Engine sqlserver-se `
-MasterUsername $user `
-MasterUserPassword $passwd `
-MultiAZ $false `
-PubliclyAccessible $true `
-StorageType gp2 `
-DBSubnetGroupName $subnetgroup `
-VpcSecurityGroupId $sgId `
-BackupRetentionPeriod 0 `
-EnablePerformanceInsight $false `
-LicenseModel license-included

