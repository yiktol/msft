#--------------------------------------------------------------------------------------
# Deply MSSQL 2019 EC2 
#--------------------------------------------------------------------------------------
#Load the Helper function
$name = @("SQLServerData", "SQLServerLog", "SQLServerBackup", "SQLServerTempdb")
$devname = @("b","c","d","e")
[System.Collections.ArrayList]$result = @()
for($i = 1; $i -lt 5; $i++) {
    $bdm = New-Object -TypeName Amazon.EC2.Model.BlockDeviceMapping
    $ebs= New-Object -TypeName Amazon.EC2.Model.EbsBlockDevice
    $bdm.DeviceName = 'xvd'+ $devname[$i -1]
    $bdm.VirtualName = $name[$i - 1]
    $ebs.VolumeSize = 10
    $ebs.VolumeType = "gp2"
    $bdm.Ebs = $ebs
    $result.Add($bdm) > $null
}    

$privsubnet1a = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="priv-1a"}).SubnetId
$sgId = (Get-EC2SecurityGroup  -Filter @{Name="tag:Name"; Values="demodb_sg"}).GroupId
$privkey = (Get-SSMParameterValue -Name /et.local/PrivateKey  –WithDecryption $true).Parameters.Value
$ec2profArn = (Get-IAMInstanceProfile -InstanceProfileName 'EC2SSMCoreRole').Arn

#Create the SQL EC2 Instance
New-EC2Instance `
-ImageId "ami-0977347715a1752de" `
-MinCount 1 -MaxCount 1 `
-SubnetId $privsubnet1a `
-InstanceType "t3.xlarge"`
-KeyName $privkey `
-SecurityGroupId $sgId `
-TagSpecification (Set-Tag instance "mySQL") `
-IamInstanceProfile_Arn $ec2profArn `
-BlockDeviceMapping $result


