-- This file must end in a new line.
set heading off
select count(1) from (
select distinct host_name, target_name
from sysman.mgmt$db_users schema
inner join sysman.mgmt$group_flat_memberships member
on schema.target_name = member.MEMBER_TARGET_NAME
where composite_target_type = 'rac_database'
and target_name like '%1'
and host_name not like 'ed0_db0_%'
group by host_name, target_name
union
select host_name, target_name
from sysman.mgmt$db_users schema
where (host_name, target_name) not in (
select host_name, target_name
from sysman.mgmt$db_users schema
inner join sysman.mgmt$group_flat_memberships member
on schema.target_name = member.MEMBER_TARGET_NAME
where composite_target_type = 'rac_database'
and host_name not like 'ed0_db0_%'
group by host_name, target_name)
and host_name not like 'ed0_db0_%'
group by host_name, target_name);
exit
