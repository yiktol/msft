Amazon Linux 2 LTS [2] with SQL Server 2019 Standard. (t3.xlarge)

2. Add additional 4xebs volumes(sizes 5,6,7,8GB)
3. Login to Instance
4. Type: 

sudo su 
lsblk

echo " Formating devices..."
sudo mkfs -t ext4 /dev/nvme1n1
sudo mkfs -t ext4 /dev/nvme2n1
sudo mkfs -t ext4 /dev/nvme3n1
sudo mkfs -t ext4 /dev/nvme4n1

echo " Creating mount points..."
sudo mkdir /SQLServerData
sudo mkdir /SQLServerLog
sudo mkdir /SQLServerBackup
sudo mkdir /SQLServerTempDB

echo "Mounting devices..."
sudo mount /dev/nvme1n1 /SQLServerData
sudo mount /dev/nvme2n1 /SQLServerLog
sudo mount /dev/nvme3n1 /SQLServerBackup
sudo mount /dev/nvme4n1 /SQLServerTempDB

echo "SQL server runs under mssql user and group."
echo "Changing ownership..."
sudo chown mssql /SQLServerData
sudo chgrp mssql /SQLServerData
sudo chown mssql /SQLServerLog
sudo chgrp mssql /SQLServerLog
sudo chown mssql /SQLServerBackup
sudo chgrp mssql /SQLServerBackup
sudo chown mssql /SQLServerTempDB
sudo chgrp mssql /SQLServerTempDB

echo "Checking everything looks OK..."
lsblk
df -h

echo "getting the UUID for each device..."
echo "`sudo file -s /dev/nvme1n1 | awk '{print $8}'` /SQLServerData    	 ext4    defaults,nofail 0 2" >> fstab
echo "`sudo file -s /dev/nvme2n1 | awk '{print $8}'` /SQLServerLog    	 ext4    defaults,nofail 0 2" >> fstab
echo "`sudo file -s /dev/nvme3n1 | awk '{print $8}'` /SQLServerBackup    ext4    defaults,nofail 0 2" >> fstab
echo "`sudo file -s /dev/nvme4n1 | awk '{print $8}'` /SQLServerTempDB    ext4    defaults,nofail 0 2" >> fstab



cat /etc/fstab

UUID=3f4ce7ea-2fee-456c-9894-2e15d72eeef8    /SQLServerData    	 ext4    defaults,nofail 0 2
UUID=11db9458-2b62-4482-8655-26474c78d5ab    /SQLServerLog   	 ext4    defaults,nofail 0 2
UUID=5757076d-1f42-44eb-be04-806fe3a43f09    /SQLServerBackup    ext4    defaults,nofail 0 2
UUID=c728c270-bc13-4bc9-ad57-a6c8bde1b3dd    /SQLServerTempDB    ext4    defaults,nofail 0 2


# Test
echo "Getting disk info before mounting..."
df -h

echo "Unmounting..."
sudo umount /SQLServerData
sudo umount /SQLServerLog
sudo umount /SQLServerBackup
sudo umount /SQLServerTempDB

echo "Mounting all disk..."
sudo mount -a

echo "Getting disk info after mounting..."
df -h

#Configuring the MS SQL Server

echo "Stopping the MSSQL service..."
sudo systemctl stop mssql-server

echo "Set the SQL SysAdmin password..."
sudo /opt/mssql/bin/mssql-conf set-sa-password

echo "Changing the default location of the data to the new mount points..."
sudo /opt/mssql/bin/mssql-conf set filelocation.defaultdatadir /SQLServerData
sudo /opt/mssql/bin/mssql-conf set filelocation.defaultlogdir /SQLServerLog
sudo /opt/mssql/bin/mssql-conf set filelocation.defaultbackupdir /SQLServerBackup

echo "Setting the memory limit availbale to the Server..."
sudo /opt/mssql/bin/mssql-conf set memory.memorylimitmb 14336

echo "Setting the trace flag 1222 ON to help identifying deadlocks..."
sudo /opt/mssql/bin/mssql-conf traceflag 1222 on

echo "Restarting the MSSQL service..."
sudo systemctl restart mssql-server
sudo systemctl status mssql-server
sudo systemctl enable mssql-server

#Connect using SQL Server Management Studio (SSMS)
#Go to Server Properties


#Migrate the TempDB
#MoveTempDB.sql
use master;
go
alter database tempdb
modify file (name = tempdev, filename = '/SQLServerTempDB/tempdb.mdf');
alter database tempdb
modify file (name = tempdev2, filename = '/SQLServerTempDB/tempdb2.mdf');
alter database tempdb
modify file (name = tempdev3, filename = '/SQLServerTempDB/tempdb3.mdf');
alter database tempdb
modify file (name = tempdev4, filename = '/SQLServerTempDB/tempdb4.mdf');
alter database tempdb
modify file (name = templog, filename = '/SQLServerTempDB/templog.ldf');
go

#Confirm
#GetTemDB.sql
select name, physical_name as currentlocation
from sys.master_files
where database_id = DB_ID(N'tempdb');
go


#Adding user
echo "Adding ec2-user to mssql group..."
sudo usermod -aG mssql ec2-user

echo "Resetting permission on home directory and its content recursively..."
sudo chmod -R 755 /home/ec2-user


#Create EC2 Role for SQL on Linux
sqlonlinux_role
- AmazonEC2ReadOnlyAccess
- CloudWatchReadOnlyAccess
- CloudWatchAgentServerPolicy
- CloudWatchAgentAdminPolicy 
- AmazonSSMManagedInstanceCore
- AmazonSSMDirectoryServiceAccess


# Install CloudWatch Agent using SSM

Agent Name: AmazonCloudWatchAgent
version: latest
#Note: make sure the SQL instance has Internet access


##SSm Parameter String Value CW-Linux-UsedDiskSpace
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
    },
    "metrics": {
        "append_dimensions": {
            "InstanceId": "${aws:InstanceId}"
        },
        "metrics_collected": {
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            },
            "statsd": {
                "metrics_aggregation_interval": 60,
                "metrics_collection_interval": 10,
                "service_address": ":8125"
            }
        }
    }
}

# Use SSM Run Commant to push policy to Cloudwatch Agent
Document: AmazonCloudWatch-ManageAgent 
Location: CW-Linux-UsedDiskSpace

#CloudWatch agent configuration wizard
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard

#Restart CloutWatch Agent (Optional)
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status









