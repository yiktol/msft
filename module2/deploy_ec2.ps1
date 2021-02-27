#--------------------------------------------------------------------------------------
# Deploy Windows 2019 EC2
#--------------------------------------------------------------------------------------

#Setup the Requirements
$userData = Get-Content -Raw configs/userData.txt
$pubsubnet1a = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="pub-1a"}).SubnetId
$sgId = (Get-EC2SecurityGroup  -Filter @{Name="tag:Name"; Values="demohttp_sg"}).GroupId
$privkey = (Get-SSMParameterValue -Name /et.local/PrivateKey  –WithDecryption $true).Parameters.Value
$ec2profArn = (Get-IAMInstanceProfile -InstanceProfileName 'EC2SSMCoreRole').Arn

#Create the EC2 Instance
New-EC2Instance `
-ImageId "ami-0e5035da109917399" `
-MinCount 1 -MaxCount 1 `
-SubnetId $pubsubnet1a `
-InstanceType "t3.medium"`
-KeyName $privkey `
-SecurityGroupId $sgId `
-TagSpecification (Set-Tag instance "myEC2") `
-IamInstanceProfile_Arn $ec2profArn `
-UserData $userData -EncodeUserData


