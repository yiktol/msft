#--------------------------------------------------------------------------------------
# Deploy Windows 2019 IIS Web Server
#--------------------------------------------------------------------------------------
$vpcId = (Get-EC2Vpc -Filter @{Name="tag:Name"; Values="VPC-DEMO"}).VpcId

#Create Security Group
New-EC2SecurityGroup `
-GroupName DEMO-ALLOW-HTTP `
-GroupDescription "Allow HTTP" `
-VpcId $vpcId `
-TagSpecification (Set-Tag security-group "msft-http_sg")

#Create the Security Rules
$http = Set-IngressRule "tcp" 80 80 "0.0.0.0/0"
$rdp = Set-IngressRule "tcp" 3389 3389 "0.0.0.0/0"
$sgId = (Get-EC2SecurityGroup -Filter @{Name="tag:Name"; Values="msft-http_sg"}).GroupId

#Apply Rules to Security Group to open port 80
Grant-EC2SecurityGroupIngress `
-GroupId $sgId `
-IpPermission @( $http, $rdp )

$pubsubnet1a = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="msft-pub-1a"}).SubnetId
$userData = Get-Content -Raw configs/userData.txt
$privkey = (Get-SSMParameterValue -Name /et.local/PrivateKey  –WithDecryption $true).Parameters.Value
$ec2profArn = (Get-IAMInstanceProfile -InstanceProfileName 'EC2SSMCoreRole').Arn

New-EC2Instance `
-ImageId "ami-0c65e8b52315f51f8" `
-MinCount 1 -MaxCount 1 `
-SubnetId $pubsubnet1a `
-InstanceType "t3.medium" `
-KeyName $privkey `
-SecurityGroupId $sgId `
-TagSpecification (Set-Tag instance "IISWebServer") `
-IamInstanceProfile_Arn $ec2profArn `
-UserData $userData -EncodeUserData

