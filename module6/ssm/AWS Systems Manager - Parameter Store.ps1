get-ssmparameterlist

write-ssmparameter -name /dev/admin-name -value 'admin@et.local' -type String

get-ssmparameter -name /dev/admin-name

write-ssmparameter -name /dev/admin-password -value 'p@ssw04d' -type SecureString

#Encrypted
get-ssmparameter -name /dev/admin-password

#Decrypted
(Get-SSMParameterValue -Name /dev/admin-password  –WithDecryption $true).Parameters