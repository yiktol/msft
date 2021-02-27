#--------------------------------------------------------------------------------------
# Windows 2019 EC2 Security Group
#--------------------------------------------------------------------------------------

$vpcId = (Get-EC2Vpc -Filter @{Name="tag:Name"; Values="MSFT-VPC"}).VpcId
$vpcCidr = (Get-EC2Vpc -Filter @{Name="tag:Name"; Values="MSFT-VPC"}).CidrBlock

#Create Security Group
New-EC2SecurityGroup `
-GroupName MSFT-FSx `
-GroupDescription "MSFT Amazon FSx SG" `
-VpcId $vpcId `
-TagSpecification (Set-Tag security-group "msft-fsx-sg")

$sgId = (Get-EC2SecurityGroup -Filter @{Name="tag:Name"; Values="msft-fsx-sg"}).GroupId

#Create the Security Rules
$smb = Set-IngressRule "tcp" 445 445 $vpcCidr
$admin = Set-IngressRule "tcp" 5985 5985 $vpcCidr

$ad1 = Set-EgressRule "tcp" 88 88 $vpcCidr
$ad2 = Set-EgressRule "tcp" 135 135 $vpcCidr
$ad3 = Set-EgressRule "tcp" 389 389 $vpcCidr
$ad4 = Set-EgressRule "tcp" 445 445 $vpcCidr
$ad5 = Set-EgressRule "tcp" 464 464 $vpcCidr
$ad6 = Set-EgressRule "tcp" 636 636 $vpcCidr
$ad7 = Set-EgressRule "tcp" 3268 3269 $vpcCidr
$ad8 = Set-EgressRule "tcp" 9389 9389 $vpcCidr
$ad9 = Set-EgressRule "tcp" 49152 65535 $vpcCidr
$ad10 = Set-EgressRule "udp" 88 88 $vpcCidr
$ad11 = Set-EgressRule "udp" 123 123 $vpcCidr
$ad12 = Set-EgressRule "udp" 464 464 $vpcCidr
$ad13 = Set-EgressRule "udp" 389 389 $vpcCidr
$dns1 = Set-EgressRule "tcp" 53 53 $vpcCidr
$dns2 = Set-EgressRule "udp" 53 53 $vpcCidr
$all = Set-EgressRule "all" 0 0  "0.0.0.0/0"

#Apply Rules to Security Group
Grant-EC2SecurityGroupIngress `
-GroupId $sgId `
-IpPermission @( $smb, $admin )

Revoke-EC2SecurityGroupEgress `
-GroupId $sgId  `
-IpPermission $all

Grant-EC2SecurityGroupEgress `
-GroupId $sgId `
-IpPermission @( $ad1, $ad2, $ad3, $ad4, $ad5, $ad6, $ad7, $ad8, $ad9, $ad10, $ad11, $ad12, $ad13, $dns1, $dns2)


#--------------------------------------------------------------------------------------
# Deploy Amazon FSx
#--------------------------------------------------------------------------------------
$directoryName = 'et.local'
$directoryId = (Get-DSDirectory | Where-Object { $_.Name -like $directoryName }).DirectoryId
$privsubnet1a = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="msft-priv-1a"}).SubnetId

New-FSXFileSystem `
-FileSystemType WINDOWS `
-StorageType SSD `
-StorageCapacity 32 `
-SecurityGroupId $sgId `
-SubnetId $privsubnet1a `
-Tag @{Key='Name'; Value='MSFT-FSx'} `
-WindowsConfiguration @{`
    ThroughputCapacity=8;`
    ActiveDirectoryId=$directoryId;`
    AutomaticBackupRetentionDays=0;}




