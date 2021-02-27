#--------------------------------------------------------------------------------------
# MSSQL EC2 Security Group
#--------------------------------------------------------------------------------------

$vpcId = (Get-EC2Vpc -Filter @{Name="tag:Name"; Values="VPC-DEMO"}).VpcId

#Create Security Group for MSSQL
New-EC2SecurityGroup `
-GroupName DEMO-ALLOW-MSSQL `
-GroupDescription "DEMO SG to Allow MS SQL Server Access" `
-VpcId $vpcId `
-TagSpecification (Set-Tag security-group "demodb_sg")

#Create Security Group Ingress Rules
$rule1 = Set-IngressRule "tcp" 1433 1433 "10.10.0.0/16"
$rule2 = Set-IngressRule "tcp" 3389 3389 "10.10.0.0/16"
$rule3 = Set-IngressRule "icmp"  0 0 "10.10.0.0/16"

$sgId = (Get-EC2SecurityGroup  -Filter @{Name="tag:Name"; Values="demodb_sg"}).GroupId

#Apply Rules to Security Group
Grant-EC2SecurityGroupIngress `
-GroupId $sgId `
-IpPermission @( $rule1, $rule2, $rule3 )