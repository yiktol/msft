# Get Exexution Policy
Get-ExecutionPolicy -List

#Set Execution Policy
Set-ExecutionPolicy RemoteSigned

# Trust the PSGallery
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Install AWS PowerShell
Install-Module -Name AWSPowerShell

#Get Module
Get-Module -ListAvailable -Name AWSPowerShell

#Update AWS PowerShell
Update-Module -Name AWSPowerShell

#Get Module AWS PowerShell
Get-Module -Name AWSPowerShell

#Import AWS PowerShell Module
Import-Module -Name AWSPowerShell

#List AWS Service Version
Get-AWSPowerShellVersion -ListServiceVersionInfo


#Create Authentication Profile
Set-AWSCredential -AccessKey <AccessKey> -SecretKey <SecretKey> -StoreAs default

#Remove Authentication Profile
Remove-AWSCredentialProfile -ProfileName default

#Initialize AWS Default Configuration
Initialize-AWSDefaultConfiguration -Region <region> `
                                   -AccessKey <AccessKey>`
                                   -SecretKey <SecretKety>







    
