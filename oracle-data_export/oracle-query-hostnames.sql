select distinct lower(entity_name)
from sysman.gc$metric_values_daily
where entity_name LIKE 'u3%' ;
exit
