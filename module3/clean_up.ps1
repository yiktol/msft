#--------------------------------------------------------------------------------------
# Clean UP VM Import/Export
#--------------------------------------------------------------------------------------
Get-IamRole `
-RoleName vmimport

Remove-IAMRolePolicy `
-PolicyName vmimport `
-RoleName vmimport `
-Force

Remove-IAMRole `
-RoleName vmimport `
-Force

Remove-S3Object `
-BucketName $bucketName `
-Key "win2016.ova" `
-Force

$importtaskId = (Get-EC2ImportImageTask -Filter @{Name="tag:Name"; Values="myOVAImport"}).ImportTaskId
$imageId = (Get-EC2Image -Filter @{Name="name"; Values=$importtaskId}).ImageId

Unregister-EC2Image `
-ImageId $imageId

Remove-EC2Volume `
-VolumeId vol-00f806b62049c03e8 `
-Force
(Get-EC2Snapshot | Where-Object { $_.Description -contains $imageId })

Remove-EC2Snapshot `
-SnapshotId  snap-03857c58c324c7ebd `
-Force

#--------------------------------------------------------------------------------------
# Clean UP #Delete EC2 Instance
#--------------------------------------------------------------------------------------

$instandeID = ((Get-EC2Instance -Filter @{Name="tag:Name";Values="IISWebServer"}).Instances).InstanceId
Remove-EC2Instance `
-InstanceId $instandeID `
-Force 

$sgId = (Get-EC2SecurityGroup -Filter @{Name="tag:Name"; Values="msft-http_sg"}).GroupId
Remove-EC2SecurityGroup `
-GroupId $sgId `
-Force 
