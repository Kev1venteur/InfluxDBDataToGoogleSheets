-- This file must end in a new line.
--DiskGroup Usage of clusters
select SUBSTR(entity_name,6), key_part_1, round(avg(avg_value)), mgmt.member_target_name
from sysman.gc$metric_values_daily
join sysman.mgmt$group_flat_memberships mgmt on mgmt.composite_target_name = SUBSTR(entity_name,6)
where metric_group_name = 'DiskGroup_Usage'
and upper(member_target_type) = 'HOST' 
and metric_column_label = 'Disk Group Used %'
group by entity_name, key_part_1, mgmt.member_target_name
order by entity_name;