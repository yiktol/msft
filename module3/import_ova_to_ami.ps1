#--------------------------------------------------------------------------------------
# Upload OVA and convert to AMI
#--------------------------------------------------------------------------------------

# Create the vmimport Role. 
$importPolicyDocument = Get-Content -Raw -Path trust-policy.json

New-IAMRole `
-RoleName vmimport `
-AssumeRolePolicyDocument $importPolicyDocument

# Add a policy allowing EC2 access to the bucket containing our image
$bucketName = "yikyakyukbucket01"
$rolePolicyDocument = Get-Content -Raw -Path role-policy.json

#Apply Policy to Role
Write-IAMRolePolicy `
-RoleName vmimport `
-PolicyName vmimport `
-PolicyDocument $rolePolicyDocument

# Uploading the OVA Image
Write-S3Object `
-BucketName $bucketName `
-Key "win2016.ova" `
-File OVA\win2016.ova

#Start Converting OVA to AMI
Import-EC2Image `
-DiskContainer (Set-ImageContainer "OVA" $bucketName "win2016.ova") `
-Description "Windows 2016 Standard Image Import" `
-Platform "Windows" `
-LicenseType "AWS" `
-TagSpecification (Set-Tag import-image-task "myOVAImport")

$importtaskId = (Get-EC2ImportImageTask -Filter @{Name="tag:Name"; Values="myOVAImport"}).ImportTaskId

#Verification
Get-EC2ImportImageTask `
-ImportTaskId $importtaskId 

Get-EC2Image -owner self

Stop-EC2ImportTask `
-ImportTaskId $importtaskId `
-Force

