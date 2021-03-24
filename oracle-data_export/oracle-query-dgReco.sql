-- This file must end in a new line.
--DiskGroup Usage of DATA diskgroup
select round(avg(avg_value))
from sysman.gc${dollar}metric_values_daily
join sysman.mgmt${dollar}group_flat_memberships mgmt on mgmt.composite_target_name = SUBSTR(entity_name,6)
where metric_group_name = 'DiskGroup_Usage'
and upper(member_target_type) = 'HOST' 
and metric_column_label = 'Disk Group Used %'
and lower(mgmt.member_target_name) like '%${envhostname}%'
and upper(key_part_1) = 'RECO';
exit
