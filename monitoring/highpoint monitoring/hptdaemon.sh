#!/bin/sh

#Remove before work - clean files
rm -f /tmp/ID
rm -f /tmp/SB
rm -f /tmp/hptarrays
rm -f /tmp/hpterrors
rm -f /tmp/hptevents
rm -f /tmp/hpteventssorted
rm -f /tmp/hpteventssorted2

#We append this file, so we must create it first
touch /tmp/ID
touch /tmp/SB
touch /tmp/hptarrays
touch /tmp/hpterrors
touch /tmp/hptevents
touch /tmp/hpteventssorted
touch /tmp/hpteventssorted2

#Number of the last existent Warning
#To know how many are Warnings exists for now necessary to complete command:
#hptraidconf -u RAID -p hpt events | grep War
#number of lines will be number of Warnings
count_of_last_existed_warn=4;

#Write status of arrays to /tmp/hptarrays
hptraidconf -u RAID -p hpt query arrays > /tmp/hptarrays

#echo "####################### START ###########################"

#Remember status s1 and s2 of 2 RAID-massives
while read ID CAP TYP STAT BLOCK SEC CACH NAME
do
#    echo -e "$ID\t $CAP\t $TYP\t $STAT\t $NAME\t"
        case $ID in
                "1")
#                   echo $ID:$STAT;
                    s1=$STAT;
                    ;;
                "2")
#                   echo $ID:$STAT;
                    s2=$STAT;
                    ;;
        esac
done < /tmp/hptarrays

#echo "####################### SHOW STATUS 1,2 ###########################"
#echo $s1:$s2

#Write all events taken from RAID-kontroller to /tmp/hptevents
hptraidconf -u RAID -p hpt events > /tmp/hptevents

#Write all War events taken from /tmp/hptevents  to /tmp/hpteventssorted
cat /tmp/hptevents | grep War > /tmp/hpteventssorted

#Sort events by ID of event, distinct of status of event (War, for example)
#Write result to file /tmp/hpteventssorted2
#echo "####################### SORT EVENTS BY NUMBERS DISTINCT DIGITS FROM 'War'  ###########################"
while read ID STAT DATE TIME USER RAID IP FAILED TO LOG ON SYSTEM
do
#    echo "ID&STAT              DATE            TIME            USER    RAID            IP              FAILED  TO      LOG     ON      SYSTEM"
#    echo -e "$ID\t\t $STAT\t $DATE\t $TIME\t $USER\t $RAID\t $IP\t $FAILED\t $TO\t $LOG\t $ON\t $SYSTEM\t"
    case $ID in
        *War)
#           echo -e "$ID\t\t $STAT\t $DATE\t $TIME\t $USER\t $RAID\t $IP\t $FAILED\t $TO\t $LOG\t $ON\t $SYSTEM\t" WAR FOUND!;
# In SB we write number of position in string grom which word "War" starts. sd = SB-1
            echo $ID | awk '{ print index ( $1,"War" ) }' > /tmp/SB
            SB=`cat /tmp/SB`
#           echo "SB is $SB";
            sd=$(($SB-1));
#           echo "SB-1=sd is $sd";
            echo $ID | awk '{print substr($1,1,ss)}' ss=$sd > /tmp/ID
            ID=`cat /tmp/ID`
#           echo WRIGHT ID $ID
            OTHER=$SYSTEM;SYSTEM=$ON;ON=$LOG;LOG=$TO;TO=$FAILED;FAILED=$IP;IP=$RAID;RAID=$USER;
            USER=$TIME;TIME=$DATE;DATE=$STAT;STAT=War;
#           echo WRIGH STAT IS $STAT
            echo -e "$ID\t\t $STAT\t $DATE\t $TIME\t $USER\t $RAID\t $IP\t $FAILED\t $TO\t $LOG\t $ON\t $SYSTEM\t $OTHER\t" >> /tmp/hpteventssorted2
            ;;
    esac
done < /tmp/hpteventssorted

#echo "#################### Identifyng number of the last Warn in the logs  ########################"

#Select string with last war to /tmp/hpterrors
tail -n 1 /tmp/hpteventssorted2 > /tmp/hpterrors

#Defining last war ID
number_of_last_warn_from_log=`cat /tmp/hpterrors | awk '{print $1}'`
#echo "LastID real is $number_of_last_warn_from_log"

#Define count of Warnings from log
count_of_last_warn_from_log=`grep -c "War" /tmp/hpteventssorted2`
#echo "count of Warnings from log is $count_of_last_warn_from_log"
#echo "count of lst existed Warning is $count_of_last_existed_warn"
#echo "s1 = $s1";
#echo "s2 = $s2";

if ([ "$s1" = "NORMAL" ] && [ "$s2" = "NORMAL" ])
    then
        ok="OK"
    else
        ok="ACHTUNG!!!"
fi

echo "$ok: Arrays status: $s1:$s2" > /tmp/statuss

#sleep 5;
#Write email with Warnings or status
if [ "$count_of_last_warn_from_log" -gt "0" ]
    then
#       if ($s1 == $s2 == NORMAL)
        if ([ "$s1" = "NORMAL" ] && [ "$s2" = "NORMAL" ])
            then
                if date | grep 21:50 > /dev/null
                    then /usr/local/sbin/hpt_raid_mon.sh;
                    else
                        if [ "$count_of_last_warn_from_log" -gt "$count_of_last_existed_warn" ]
                            then /usr/local/sbin/hpt_raid_mon.sh;
                        fi;
                fi;
            else /usr/local/sbin/hpt_raid_mon.sh
        fi
    else echo "Logs are null now. Necessarry to login to server and set correct variable count_of_last_existed_warn." | mail -s "Attention! NECESSARY TO LOGIN TO SERVER AND count_of_last_existed_wa
rn SET CORRECT VARIABLE!" vittrok@gmail.com
fi
