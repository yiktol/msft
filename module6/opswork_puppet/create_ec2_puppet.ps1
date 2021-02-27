#Import AWS PowerShell Module
Import-Module -Name AWSPowerShell

function Set-Tag {
    param ($tag, $name)
    $tag1 = @{ Key="Name"; Value=$name }
    $tagspec = new-object Amazon.EC2.Model.TagSpecification
    $tagspec.ResourceType = $tag
    $tagspec.Tags.Add($tag1)
    Write-Output $tagspec
}

New-EC2Instance `
-ImageId "ami-0f7d1dc682797b5ad" `
-MinCount 1 -MaxCount 1 `
-SubnetId "subnet-0437941576c531394" `
-InstanceType "t3.small"`
-KeyName "APAC-SG_keypair" `
-SecurityGroupId "sg-039eae34861deb924" `
-TagSpecification (Set-Tag instance "EC2WINPUPPET") 

#Delete EC2 Instance
$instandeID = ((Get-EC2Instance -Filter @{Name="tag:Name";Values="EC2WINPUPPET"}).Instances).InstanceId
Remove-EC2Instance `
-InstanceId $instandeID `
-Force 

