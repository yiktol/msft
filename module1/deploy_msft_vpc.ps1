
#------------------------------------------------------------------------------

# Create VPC
New-EC2VPC `
-CidrBlock 10.10.0.0/16 `
-TagSpecification (Set-Tag vpc "MSFT-VPC")

$vpcId = (Get-EC2Vpc -Filter @{Name="tag:Name"; Values="MSFT-VPC"}).VpcId

#Enable VPC DNS Hostname
Edit-EC2VpcAttribute `
-VpcId $vpcId `
-EnableDnsHostname $true

#Enable VPC DNS Support
Edit-EC2VpcAttribute `
-VpcId $vpcId `
-EnableDnsSupport $true

#----------------------------------------------------------------------------------
# Create Public Subnet in AZ 1a
New-EC2Subnet `
-VpcId $vpcId `
-AvailabilityZone ap-southeast-1a `
-CidrBlock 10.10.11.0/24 `
-TagSpecification (Set-Tag subnet msft-pub-1a)

$pubsubnet1a = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="msft-pub-1a"}).SubnetId

#Enable Public Address for AZ 1a
Edit-EC2SubnetAttribute `
-SubnetId $pubsubnet1a `
-MapPublicIpOnLaunch $true



# Create Private Subnet in AZ 1a
New-EC2Subnet `
-VpcId $vpcId `
-AvailabilityZone ap-southeast-1a `
-CidrBlock 10.10.12.0/24 `
-TagSpecification (Set-Tag subnet msft-priv-1a)

$privsubnet1a = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="msft-priv-1a"}).SubnetId




# Create Public Subnet in AZ 1b
New-EC2Subnet `
-VpcId $vpcId `
-AvailabilityZone ap-southeast-1b `
-CidrBlock 10.10.21.0/24 `
-TagSpecification (Set-Tag subnet msft-pub-1b)

$pubsubnet1b = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="msft-pub-1b"}).SubnetId

#Enable Public Address for AZ 1b
Edit-EC2SubnetAttribute `
-SubnetId $pubsubnet1b `
-MapPublicIpOnLaunch $true




# Create Private Subnet in AZ 1b
New-EC2Subnet `
-VpcId $vpcId `
-AvailabilityZone ap-southeast-1b `
-CidrBlock 10.10.22.0/24 `
-TagSpecification (Set-Tag subnet msft-priv-1b)

$privsubnet1b = (Get-EC2Subnet -Filter @{Name="tag:Name"; Values="msft-priv-1b"}).SubnetId

#-----------------------------------------------------------------------------
#Create Internet Gateway
New-EC2InternetGateway `
-TagSpecification (Set-Tag internet-gateway msft-igw)

$igw = (Get-EC2InternetGateway -Filter @{Name="tag:Name"; Values="msft-igw"}).InternetGatewayId

#Attach Internet gateway to VPC
Add-EC2InternetGateway `
-InternetGatewayId $igw `
-VpcId $vpcId


#--------------------------------------------------------------------------
#Modify Routing Table for Public Subnet
New-EC2RouteTable `
-VpcId $vpcId `
-TagSpecification (Set-Tag route-table  msft-internet)

$internetrt = (Get-EC2RouteTable -Filter @{Name="tag:Name"; Values="msft-internet"}).RouteTableId

#Add Internet Route to Internet Routing Table
New-EC2Route `
-RouteTableId $internetrt `
-DestinationCidrBlock 0.0.0.0/0 `
-GatewayId $igw

#Associate Internet Routing table to Public Subnets
Register-EC2RouteTable `
-RouteTableId $internetrt `
-SubnetId $pubsubnet1a

Register-EC2RouteTable `
-RouteTableId $internetrt `
-SubnetId $pubsubnet1b

#--------------------------------------------------------------------------------

# Tag the Main Routing Table
$rts=(Get-EC2RouteTable -Filter @{Name="vpc-id"; Values=$vpcId}).RouteTableId
foreach ($item in $rts) {
    if ((Get-EC2RouteTable -RouteTableId $item -Filter @{Name="association.main"; Values="true"})){
        $mainrt = $item
        New-EC2Tag `
        -Resource $mainrt `
        -Tag @{Key="Name"; Value="msft-main"}
    }     
}


#--------------------------------------------------------------------------------------------
# Create EIP 1 for Public Subnet 1a
New-EC2Address 
New-EC2Tag `
-Resource (Get-EC2Address).AllocationId `
-Tag @{Key="Name"; Value="msft-eip-1a"}

$allocIdEIP1 = (Get-EC2Address -Filter @{Name="tag:Name"; Values="msft-eip-1a"}).AllocationId

# Associate NAT gatway to Public Subnet 1a 
New-EC2NatGateway `
-SubnetId $pubsubnet1a `
-AllocationId $allocIdEIP1 `
-TagSpecification (Set-Tag natgateway msft-natgw-1a)

$nat1gw = (Get-EC2NatGateway -Filter @{Name="tag:Name"; Values="msft-natgw-1a"}).NatGatewayId

#Modify Routing Table for Private Subnet 1a
New-EC2RouteTable `
-VpcId $vpcId `
-TagSpecification (Set-Tag route-table  msft-priv-rt-1a)

$privrt1a = (Get-EC2RouteTable -Filter @{Name="tag:Name"; Values="msft-priv-rt-1a"}).RouteTableId

New-EC2Route `
-RouteTableId $privrt1a `
-DestinationCidrBlock 0.0.0.0/0 `
-GatewayId $nat1gw

#Associate Private Subnet with NAT Gateway
Register-EC2RouteTable `
-RouteTableId $privrt1a `
-SubnetId $privsubnet1a

#---------------------------------------------------------------------------------------------------
# Create EIP 2 for Public Subnet 1b
New-EC2Address
$eips=(Get-EC2Address).AllocationId 
foreach ($item in $eips) {
    if (-NOT ($allocIdEIP1 -eq $item)){
        New-EC2Tag `
        -Resource $item `
        -Tag @{Key="Name"; Value="msft-eip-1b"}         
    }
}

$allocIdEIP2 = (Get-EC2Address -Filter @{Name="tag:Name"; Values="msft-eip-1b"}).AllocationId

# Associate NAT gatway to Public Subnet 1b
New-EC2NatGateway `
-SubnetId $pubsubnet1b `
-AllocationId $allocIdEIP2 `
-TagSpecification (Set-Tag natgateway msft-natgw-1b)

#Modify the Private Subnet Routing Table for NAT gateway
$nat2gw = (Get-EC2NatGateway -Filter @{Name="tag:Name"; Values="msft-natgw-1b"}).NatGatewayId

#Modify Routing Table for Private Subnet 1b
New-EC2RouteTable `
-VpcId $vpcId `
-TagSpecification (Set-Tag route-table  msft-priv-rt-1b)

$privrt1b = (Get-EC2RouteTable -Filter @{Name="tag:Name"; Values="msft-priv-rt-1b"}).RouteTableId

New-EC2Route `
-RouteTableId $privrt1b `
-DestinationCidrBlock 0.0.0.0/0 `
-GatewayId $nat2gw

#Associate Private Subnet with NAT Gateway
Register-EC2RouteTable `
-RouteTableId $privrt1b `
-SubnetId $privsubnet1b


