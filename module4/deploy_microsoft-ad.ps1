#--------------------------------------------------------------------------------------
# Deploy AWS Managed Microsoft Active Directory
#--------------------------------------------------------------------------------------

$directoryName = 'et.local'
$vpcId = (Get-EC2Vpc -Filter @{Name="tag:Name"; Values="MSFT-VPC"}).VpcId
$privsubnet1a = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="msft-priv-1a"}).SubnetId
$privsubnet1b = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="msft-priv-1b"}).SubnetId

#Get Admin Password from SSM
$passwd = (Get-SSMParameterValue -Name /et.local/Admin  –WithDecryption $true).Parameters.Value

#Deploy AWS Managed AD
New-DSMicrosoftAD `
-Name $directoryName `
-ShortName ET `
-Password $passwd `
-edition Standard `
-VpcSettings_VpcId $vpcId `
-VpcSettings_SubnetIds $privsubnet1a,$privsubnet1b 

$directoryId = (Get-DSDirectory | Where-Object { $_.Name -like $directoryName }).DirectoryId

#Create DHCP Options
$options = @( `
@{Key="domain-name";Values=@($directoryName)}, `
@{Key="domain-name-servers";Values=@((Get-DSDirectory -DirectoryId $directoryId).DnsIpAddrs)}, `
@{Key="ntp-servers";Values=@((Get-DSDirectory -DirectoryId $directoryId).DnsIpAddrs)}, `
@{Key="netbios-name-servers";Values=@((Get-DSDirectory -DirectoryId $directoryId).DnsIpAddrs)}, `
@{Key="netbios-node-type";Value=2})

New-EC2DhcpOption `
-DhcpConfiguration $options `
-TagSpecification (Set-Tag dhcp-options "msft-dhcpoptions")

#Apply DHCP Option to VPC
$dhcpOptionId = (Get-EC2DhcpOption -Filter @{Name="tag:Name"; Values="msft-dhcpoptions"}).DhcpOptionsId
Register-EC2DhcpOption `
-DhcpOptionsId $dhcpOptionId `
-VpcId $vpcId




