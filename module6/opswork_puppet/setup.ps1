#On Puppet Master

puppet module install puppetlabs-dsc --version 1.9.4
puppet module install puppetlabs-iis --version 7.1.0


#On Windows Ec2
#Install puppet Agent
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}; `
$webClient = New-Object System.Net.WebClient;`
$webClient.DownloadFile('https://puppetmaster-jocodltonakad6uu.ap-southeast-1.opsworks-cm.io:8140/packages/current/install.ps1', 'install.ps1'); `
.\install.ps1#