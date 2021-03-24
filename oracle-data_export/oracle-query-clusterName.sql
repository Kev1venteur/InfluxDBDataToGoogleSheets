-- This file must end in a new line.
-- Return cluster name from hostname
select SUBSTR(entity_name,6)
from sysman.gc${dollar}metric_values_daily
join sysman.mgmt${dollar}group_flat_memberships mgmt on mgmt.composite_target_name = SUBSTR(entity_name,6)
where metric_group_name = 'DiskGroup_Usage'
and upper(member_target_type) = 'HOST' 
and metric_column_label = 'Disk Group Used %'
and (lower(mgmt.member_target_name)) like '%${envhostname}%'
group by entity_name
order by entity_name;
