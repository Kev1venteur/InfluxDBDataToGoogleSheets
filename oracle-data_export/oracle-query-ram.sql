-- This file must end in a new line.
--set heading off
select round(avg(avg_value)) as avg
from sysman.gc${dollar}metric_values_daily
where metric_group_name = 'Load'
and metric_column_name = 'usedLogicalMemoryPct'
and (lower(entity_name) like '%${envhostname}%' or lower(entity_name) like '%${envhostname}%')
-- entre le 1er jour du mois dernier et le 1er jour du mois en cours (00:00:00)
and collection_time between ADD_MONTHS((LAST_DAY(add_months(sysdate,-1))+1),-1) and ADD_MONTHS((LAST_DAY(sysdate)+1),-1);
exit
