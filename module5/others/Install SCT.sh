
#Install SQl CLient Software
#JDBC driver for Microsoft SQL Server
https://www.microsoft.com/en-us/download/details.aspx?displaylang=en&id=11774

#JDBC driver for Aurora SQL
https://dev.mysql.com/downloads/connector/j/


#Install AWS SCT
https://s3.amazonaws.com/publicsctdownload/Windows/aws-schema-conversion-tool-1.0.latest.zip

#Install Visual C++ 2019
https://aka.ms/vs/16/release/VC_redist.x64.exe

#Install MySQl WoekBench
https://www.mysql.com/products/workbench/


#Execute the Command on the MySQL WorkBench
CREATE USER 'aurora_dms' IDENTIFIED BY 'Password1'; 

GRANT ALTER, CREATE, DROP, INDEX, INSERT, UPDATE, DELETE, 
SELECT ON target_database.* TO 'aurora_dms'; 
             

GRANT ALL PRIVILEGES ON awsdms_control.* TO 'aurora_dms';
FLUSH PRIVILEGES;                
                        

#Use AWS SCT to Convert the SQL Server Schema to Aurora MySQL
Project Name = 'AWS Schema Conversion Tool SQL Server to Aurora MySQL'
Location = default
Source Database Engine = 'Microsoft SQL Server'
Target Database Engine = 'Amazon Aurora (MySQL compatible)'

