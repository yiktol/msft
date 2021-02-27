
#------------------------------------------------------------------------------
function Set-Tag {
    param ($tag, $name)
    $tag1 = @{ Key="Name"; Value=$name }
    $tagspec = new-object Amazon.EC2.Model.TagSpecification
    $tagspec.ResourceType = $tag
    $tagspec.Tags.Add($tag1)
    Write-Output $tagspec
}

function Set-IngressRule {
    param($protocol, $fromport, $toport, $ipranges)
    $ip = New-Object Amazon.EC2.Model.IpPermission
    $ip.IpProtocol = $protocol
    $ip.FromPort = $fromport
    $ip.ToPort = $toport
    $ip.IpRanges.Add($ipranges)
    Write-Output $ip
}

function Set-EgressRule {
    param($protocol, $fromport, $toport, $ipranges)
    $ip = New-Object Amazon.EC2.Model.IpPermission
    $ip.IpProtocol = $protocol
    $ip.FromPort = $fromport
    $ip.ToPort = $toport
    $ip.IpRanges.Add($ipranges)
    Write-Output $ip
}

function Set-ImageContainer {
    param($format, $bucketname, $s3key)
    $windowsContainer = New-Object Amazon.EC2.Model.ImageDiskContainer
    $windowsContainer.Format = $format
    $userBucket = New-Object Amazon.EC2.Model.UserBucket
    $userBucket.S3Bucket = $bucketName
    $userBucket.S3Key = $s3key
    $windowsContainer.UserBucket = $userBucket
    Write-Output $windowsContainer
}