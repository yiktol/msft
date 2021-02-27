#---------------------------------------------------------------------
#Deploy MS SQL on Linux
#---------------------------------------------------------------------
 
 # Set volume size and block mappings of OS drive
$name = @("SQLServerData", "SQLServerLog", "SQLServerBackup", "SQLServerTempdb")
$devname = @('b','c','d','e')
[System.Collections.ArrayList]$result = @()
for($i = 1; $i -lt 5; $i++) {
    $bdm = New-Object -TypeName Amazon.EC2.Model.BlockDeviceMapping
    $ebs= New-Object -TypeName Amazon.EC2.Model.EbsBlockDevice
    $bdm.DeviceName = '/dev/sd' + $devname[$i -1]
    $bdm.VirtualName = $name[$i -1]
    $ebs.VolumeSize = 10
    $ebs.VolumeType = 'gp2'
    $bdm.Ebs = $ebs
    $result.Add($bdm) > $null
}

$pubsubnet1a = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="msft-pub-1a"}).SubnetId
$sgId = (Get-EC2SecurityGroup  -Filter @{Name="tag:Name"; Values="msft-ssh_rdp_sql"}).GroupId
$privkey = (Get-SSMParameterValue -Name /et.local/PrivateKey  –WithDecryption $true).Parameters.Value
$ec2profArn = (Get-IAMInstanceProfile -InstanceProfileName 'EC2SSMCoreRole').Arn

New-EC2Instance `
-ImageId "ami-0ca6a38661cf4219b" `
-MinCount 1 -MaxCount 1 `
-SubnetId $pubsubnet1a `
-InstanceType "t3.xlarge"`
-KeyName $privkey `
-SecurityGroupId $sgId `
-TagSpecification (Set-Tag instance "SQLonLinux") `
-IamInstanceProfile_Arn $ec2profArn `
-BlockDeviceMapping $result

