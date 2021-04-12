-- This file must end in a new line.
--DiskGroup Usage of DATA diskgroup
--valeur la plus élevée
select MAX(MAX_VALUE)
from sysman.gc${dollar}metric_values_daily
where metric_group_name = 'DiskGroup_Usage'
and metric_column_label = 'Disk Group Used %'
and lower(SUBSTR(entity_name,6)) like '%${envhostname}%'
and upper(key_part_1) = 'RECO'
and collection_time between ADD_MONTHS((LAST_DAY(add_months(sysdate,-1))+1),-1) and ADD_MONTHS((LAST_DAY(sysdate)+1),-1);
exit
