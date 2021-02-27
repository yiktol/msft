#---------------------------------------------------------------------
#Deploy MS SQL on EC2
#---------------------------------------------------------------------
 
#Create Security Group
$vpcId = (Get-EC2Vpc -Filter @{Name="tag:Name"; Values="MSFT-VPC"}).VpcId
New-EC2SecurityGroup `
-GroupName DEMO-ALLOW-RDP-MSSQL `
-GroupDescription "Allow SSH, RDP and MS SQL" `
-VpcId $vpcId `
-TagSpecification (Set-Tag security-group "msft-ssh_rdp_sql")

#Configure Security Group to open ports 1433
$sgId = (Get-EC2SecurityGroup  -Filter @{Name="tag:Name"; Values="msft-ssh_rdp_sql"}).GroupId

$mssql = Set-IngressRule "tcp" 1433 1433 "0.0.0.0/0"
$ssh = Set-IngressRule "tcp" 22 22 "0.0.0.0/0"
$rdp = Set-IngressRule "tcp" 3389 3389 "0.0.0.0/0"

Grant-EC2SecurityGroupIngress `
-GroupId $sgId `
-IpPermission @( $mssql, $ssh, $rdp )


 # Set volume size and block mappings of OS drive
$name = @("SQLServerData", "SQLServerLog", "SQLServerBackup", "SQLServerTempdb")
$devname = @('b','c','d','e')
[System.Collections.ArrayList]$result = @()
for($i = 1; $i -lt 5; $i++) {
    $bdm = New-Object -TypeName Amazon.EC2.Model.BlockDeviceMapping
    $ebs= New-Object -TypeName Amazon.EC2.Model.EbsBlockDevice
    $bdm.DeviceName = 'xvd' + $devname[$i -1]
    $bdm.VirtualName = $name[$i -1]
    $ebs.VolumeSize = 10
    $ebs.VolumeType = 'gp2'
    $bdm.Ebs = $ebs
    $result.Add($bdm) > $null
}

$pubsubnet1a = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="msft-pub-1a"}).SubnetId
$privkey = (Get-SSMParameterValue -Name /et.local/PrivateKey  –WithDecryption $true).Parameters.Value
$ec2profArn = (Get-IAMInstanceProfile -InstanceProfileName 'EC2SSMCoreRole').Arn

New-EC2Instance `
-ImageId "ami-0977347715a1752de" `
-MinCount 1 -MaxCount 1 `
-SubnetId $pubsubnet1a `
-InstanceType "t3.xlarge"`
-KeyName $privkey `
-SecurityGroupId $sgId `
-TagSpecification (Set-Tag instance "SQLonEC2")  `
-IamInstanceProfile_Arn $ec2profArn `
-BlockDeviceMapping $result


