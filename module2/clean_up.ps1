#------------------------------------------------------------------------------------------------
#Delete EC2 Instance (mySQL)
$instandeID = ((Get-EC2Instance -Filter @{Name="tag:Name";Values="mySQL"}).Instances).InstanceId
Remove-EC2Instance `
-InstanceId $instandeID `
-Force 

$sgId = (Get-EC2SecurityGroup  -Filter @{Name="tag:Name"; Values="demodb_sg"}).GroupId
Remove-EC2SecurityGroup `
-GroupId $sgId `
-Force 

#------------------------------------------------------------------------------------------------
#Delete EC2 Instance (myEC2)
$instandeID = ((Get-EC2Instance -Filter @{Name="tag:Name";Values="myEC2"}).Instances).InstanceId
Remove-EC2Instance `
-InstanceId $instandeID `
-Force 

$sgId = (Get-EC2SecurityGroup  -Filter @{Name="tag:Name"; Values="demohttp_sg"}).GroupId
Remove-EC2SecurityGroup `
-GroupId $sgId `
-Force 

#------------------------------------------------------------------------------------------------
#Delete VPC

$natgw=(Get-EC2NatGateway).NatGatewayId 
foreach ($item in $natgw) {
    Remove-EC2NatGateway `
    -NatGatewayId $item `
    -Force       
}

$eip=(Get-EC2Address).AllocationId 
foreach ($item in $eip) {
    Remove-EC2Address `
    -AllocationId $item `
    -Force       
}

$vpcId = (Get-EC2Vpc -Filter @{Name="tag:Name"; Values="VPC-DEMO"}).VpcId
$igw = (Get-EC2InternetGateway -Filter @{Name="tag:Name"; Values="demo-igw"}).InternetGatewayId
Dismount-EC2InternetGateway `
-VpcId $vpcId `
-InternetGatewayId $igw `
-Force

Remove-EC2InternetGateway `
-InternetGatewayId $igw `
-Force

$subnets=(Get-EC2Subnet).SubnetId
foreach ($item in $subnets) {
    if ($vpcId -eq (Get-EC2Subnet -SubnetId $item).VpcId){
        Remove-EC2Subnet `
        -SubnetId $item `
        -Force
    }   
}

$rts = ("internet", "priv-rt-1a", "priv-rt-1b")
foreach ($item in $rts) {
    $rt = (Get-EC2RouteTable -Filter @{Name="tag:Name"; Values=$item}).RouteTableId
    if ($rt) {
        Remove-EC2RouteTable `
        -RouteTableId $rt `
        -Force
    }
}

Remove-EC2Vpc `
-VpcId $vpcId `
-Force

