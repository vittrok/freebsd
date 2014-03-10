#!/bin/sh

echo "Status of arrays: " >> /tmp/raidstatusinfo
/usr/bin/less /tmp/hptarrays >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Status of Physical Disks: " >> /tmp/raidstatusinfo
hptraidconf -u RAID -p hpt query devices >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Events: " >> /tmp/raidstatusinfo
/usr/bin/less /tmp/hpteventssorted >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Logs from /var/log/messages: " >> /tmp/raidstatusinfo
/usr/bin/less /var/log/messages | grep rr26xx >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Status of adapter: " >> /tmp/raidstatusinfo
hptraidconf -u RAID -p hpt query controllers >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Status of array1: " >> /tmp/raidstatusinfo
hptraidconf -u RAID -p hpt query arrays 1 >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Status of array2: " >> /tmp/raidstatusinfo
hptraidconf -u RAID -p hpt query arrays 2 >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Status of Physical Disk 1: " >> /tmp/raidstatusinfo
hptraidconf -u RAID -p hpt query devices 1/1 >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Status of Physical Disk 2: " >> /tmp/raidstatusinfo
hptraidconf -u RAID -p hpt query devices 1/2 >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Status of Physical Disk 3: " >> /tmp/raidstatusinfo
hptraidconf -u RAID -p hpt query devices 1/3 >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Status of Physical Disk 4: " >> /tmp/raidstatusinfo
hptraidconf -u RAID -p hpt query devices 1/4 >> /tmp/raidstatusinfo

s=`/usr/bin/less /tmp/statuss`
/usr/bin/less /tmp/raidstatusinfo | mail -s "RAIDStatus: $s" vittrok@gmail.com
rm /tmp/raidstatusinfo
rm /tmp/statuss
