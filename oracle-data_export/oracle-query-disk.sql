-- This file must end in a new line.
--Disk Usage
select round(avg(avg_value)) as avg
from sysman.gc$metric_values_daily
where metric_group_name = 'TotalDiskUsage'
and metric_column_name = 'totpercntused'
and (lower(entity_name) like '%'$hostname'%'
     or lower(entity_name) like '%'$hostname'%'
	)
-- entre le 1er jour du mois dernier et le 1er jour du mois en cours (00:00:00)
and collection_time between ADD_MONTHS((LAST_DAY(add_months(sysdate,-1))+1),-1) and ADD_MONTHS((LAST_DAY(sysdate)+1),-1);
exit
