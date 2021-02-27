
#--------------------------------------------------------------------------------------
# Deploy Windows 2019 EC2 to Automatically join the Domain
#--------------------------------------------------------------------------------------
$vpcId = (Get-EC2Vpc -Filter @{Name="tag:Name"; Values="MSFT-VPC"}).VpcId

#Create Security Group
New-EC2SecurityGroup `
-GroupName MSFT-RDP-ONLY `
-GroupDescription "Allow RDP Access" `
-VpcId $vpcId `
-TagSpecification (Set-Tag security-group "msft-allow_rdp")

#Create the Security Rules
$rdp = Set-IngressRule "tcp" 3389 3389 "0.0.0.0/0"

#Apply Rules to Security Group to open ports 3389 and 80
$sgId = (Get-EC2SecurityGroup -Filter @{Name="tag:Name"; Values="msft-allow_rdp"}).GroupId
Grant-EC2SecurityGroupIngress `
-GroupId $sgId `
-IpPermission @( $rdp )


$UserData = Get-Content -Raw configs/userData.txt
$pubsubnet1a = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="msft-pub-1a"}).SubnetId

#Deploy a Domain Joined Windows 2019 EC2
New-EC2Instance `
-ImageId "ami-0e5035da109917399" `
-MinCount 1 -MaxCount 1 `
-SubnetId $pubsubnet1a `
-InstanceType "t3.medium"`
-KeyName "APAC-SG_keypair" `
-SecurityGroupId $sgId `
-TagSpecification (Set-Tag instance "RDGateway")`
-IamInstanceProfile_Arn arn:aws:iam::875692608981:instance-profile/EC2SSMCoreRole `
-UserData $UserData -EncodeUserData


