-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 10/04/2024
-- DateModification.: 10/04/2024
-- EMAIL_1..........: dba.ribas@gmail.com
-- EMAIL_2..........: andre.ribas@icloud.com
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing off time off colsep '|' trim on trims on numformat 999999999999999 heading on feedback off
col "SIZE(GB)" FORMAT 9,999.990 HEADING 'SIZE(GB)'
col name for a40
select name
  , open_mode
  , restricted
  , to_char(creation_time, 'YYYY-MM-DD HH:MM:SS') as created
  , to_char(open_time, 'YYYY-MM-DD HH:MM:SS') as opened
  , to_char(total_size/1024/1024/1024, '999,999.990') AS "SIZE(GB)"
from v$containers 
where con_id not in (0,1,2)
order by 1;
