#--------------------------------------------------------------------------------------
# Windows 2019 EC2 Security Group
#--------------------------------------------------------------------------------------

$vpcId = (Get-EC2Vpc -Filter @{Name="tag:Name"; Values="VPC-DEMO"}).VpcId

#Create Security Group
New-EC2SecurityGroup `
-GroupName DEMO-ALLOW-RDP-HTTP `
-GroupDescription "DEMO SG to Allow RDP and HTTP" `
-VpcId $vpcId `
-TagSpecification (Set-Tag security-group "demohttp_sg")

#Create the Security Rules
$rule1 = Set-IngressRule "tcp" 3389 3389 "0.0.0.0/0"
$rule2 = Set-IngressRule "tcp" 80 80 "0.0.0.0/0"

$sgId = (Get-EC2SecurityGroup -Filter @{Name="tag:Name"; Values="demohttp_sg"}).GroupId

#Apply Rules to Security Group to open ports 3389 and 80
Grant-EC2SecurityGroupIngress `
-GroupId $sgId `
-IpPermission @( $rule1, $rule2 )