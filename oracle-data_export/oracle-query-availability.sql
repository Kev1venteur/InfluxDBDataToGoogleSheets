-- This file must end in a new line.
-- Total Percentage UP in the current month
select round(100-(100*sum(round(60*60*24*(to_date(TO_CHAR(end_timestamp,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS') - to_date(TO_CHAR(start_timestamp,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS')))))/(TO_CHAR(LAST_DAY(SYSDATE),'DD')*24*60*60), 3)
from sysman.MGMT$AVAILABILITY_HISTORY
where target_type = 'host'
and availability_status = 'Blackout'
and target_name = '%${envhostname}%'
and TO_CHAR(start_timestamp,'MM') = TO_CHAR(LAST_DAY(SYSDATE),'MM');
exit
