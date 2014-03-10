#!/bin/sh

echo "Status of volumes: " >> /tmp/raidstatusinfo
/usr/sbin/mfiutil show volumes >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Status of drives: " >> /tmp/raidstatusinfo
/usr/sbin/mfiutil show drives >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Events: " >> /tmp/raidstatusinfo
/usr/sbin/mfiutil show events >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Logs from /var/log/messages: " >> /tmp/raidstatusinfo
/usr/bin/less /var/log/messages | grep mfi0 >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Status of adapter: " >> /tmp/raidstatusinfo
/usr/sbin/mfiutil show adapter >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Status of firmware: " >> /tmp/raidstatusinfo
/usr/sbin/mfiutil show firmware >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Status of battery: " >> /tmp/raidstatusinfo
/usr/sbin/MegaCli -AdpBbuCmd -GetBbuStatus -a0 >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Status Physical Disks: " >> /tmp/raidstatusinfo
/usr/sbin/MegaCli -PDList -a0 -AppLogFile /var/log/MegaCli.log >> /tmp/raidstatusinfo

echo "=================================================================================== " >> /tmp/raidstatusinfo
echo "Status disks in RAID: " >> /tmp/raidstatusinfo
/usr/sbin/MegaCli -CfgDsply -a0 -AppLogFile /var/log/MegaCli.log >> /tmp/raidstatusinfo

/usr/local/sbin/check_megaraid_sas >> /tmp/status
s=`/usr/bin/less /tmp/status`
/usr/bin/less /tmp/raidstatusinfo | mail -s "RAIDStatus: $s" vittrok@gmail.com raidmon@neohost.com.ua
rm /tmp/raidstatusinfo
rm /tmp/status