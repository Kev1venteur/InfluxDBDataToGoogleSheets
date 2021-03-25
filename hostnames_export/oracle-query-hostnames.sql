select distinct entity_name
from sysman.gc$metric_values_daily
where entity_type='host'
order by entity_name;
exit