-- This file must end in a new line.
-- Total Percentage UP in the current month from the first day to your date
-- if value of blackout is null return 100
select NVL(round(100-(100*sum(round(60*60*24*(to_date(TO_CHAR(end_timestamp,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS') - to_date(TO_CHAR(start_timestamp,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS')))))/(TO_CHAR(LAST_DAY(SYSDATE),'DD')*24*60*60), 3), 100)
from sysman.MGMT${dollar}AVAILABILITY_HISTORY
where target_type = 'cluster'
and availability_status = 'Blackout'
and target_name like '%${envhostname}%'
and TO_CHAR(start_timestamp,'MM') = TO_CHAR(add_months(trunc(sysdate,'mm'),-1),'MM')
and TO_CHAR(end_timestamp,'MM') < TO_CHAR((sysdate),'MM');
exit
