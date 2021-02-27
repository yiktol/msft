#--------------------------------------------------------------------------------------
# Create SSM Document and UserData Files
#--------------------------------------------------------------------------------------
$u = '_'
$directoryName = 'et.local'
$directoryId = (Get-DSDirectory | Where-Object { $_.Name -like $directoryName }).DirectoryId
$ssmDocumentName = "awsconfig_Domain_$directoryId$u$directoryName"


$ssmDocumentTemplate = 'templates/awsconfig_Domain_template.json'
$destination_file = "configs/$ssmDocumentName.json"
(Get-Content $ssmDocumentTemplate) | Foreach-Object {
    $_ -replace '%directoryId%', $directoryId `
        -replace '%directoryName%', $directoryName `
        -replace '%dnsIpAddresses1%', ((Get-DSDirectory).DnsIpAddrs)[0] `
        -replace '%dnsIpAddresses2%', ((Get-DSDirectory).DnsIpAddrs)[1]
} | Set-Content $destination_file 


(Get-Content 'templates/userData_template.txt') | Foreach-Object {
    $_ -replace '%ssmDocumentName%', $ssmDocumentName
} | Set-Content 'configs/userData.txt'


New-SSMDocument `
    -Content (Get-Content -Raw $destination_file) `
    -Name $ssmDocumentName `
    -DocumentType "Command"

Get-SSMDocument `
    -Name $ssmDocumentName 


