-- This file must end in a new line.
--DiskGroup Usage of DATA diskgroup
--Moyenne de valeur sur les 2 derniers jours
select round(avg(avg_value))
from sysman.gc${dollar}metric_values_daily
where metric_group_name = 'DiskGroup_Usage'
and metric_column_label = 'Disk Group Used %'
and lower(SUBSTR(entity_name,6)) like '%${envhostname}%'
and upper(key_part_1) = 'DATA'
and collection_time between SYSDATE - 2 and SYSDATE;
exit
