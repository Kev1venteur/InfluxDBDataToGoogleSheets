SELECT
     A.target_name DBNAME,
     LOWER(A.AVAILABILITY_STATUS) AVAI_STATUS,
     SUM(ROUND(least(nvl( MGMT_VIEW_UTIL.ADJUST_TZ(A.end_timestamp,B.TIMEZONE_REGION,'Europe/Paris'),(MGMT_VIEW_UTIL.ADJUST_TZ(sysdate,sessiontimezone,'Europe/Paris'))),to_date(:datefin, 'yyyymmdd') )-greatest( MGMT_VIEW_UTIL.ADJUST_TZ(A.start_timestamp,B.TIMEZONE_REGION,'Europe/Paris'), to_date(:datedeb, 'yyyymmdd')),8))*24*60 DURATION
 FROM
   mgmt$availability_history A,MGMT$TARGET B
 WHERE A.target_name like 'O%' and
 (A.target_type='rac_database') AND A.TARGET_GUID=B.TARGET_GUID
   and MGMT_VIEW_UTIL.ADJUST_TZ(start_timestamp,B.TIMEZONE_REGION,'Europe/Paris') < to_date(:datefin, 'yyyymmdd') and
   (MGMT_VIEW_UTIL.ADJUST_TZ(end_timestamp,B.TIMEZONE_REGION,'Europe/Paris')>= to_date(:datedeb, 'yyyymmdd') OR end_timestamp is NULL)
GROUP BY A.target_name,A.AVAILABILITY_STATUS ORDER BY A.target_name;


-- 1 requete � l'ann�e
-- 1 requ�te au mois


SELECT empno, deptno,
COUNT(*) OVER (PARTITION BY
deptno) DEPT_COUNT
FROM emp
WHERE deptno IN (20, 30);

-- - de 60% de up sur la totalit� => base non prise en compte
-- + indiquer les bases en �cart
