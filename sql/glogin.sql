set pages 700 lines 700 timing on time on colsep '|' trim on trims on numformat 999999999999999 heading on feedback on
COLUMN NAME FORMAT A20
COLUMN VALUE FORMAT A40
COLUMN USERNAME FORMAT A30
COLUMN PROFILE FORMAT A20
COLUMN FILE_NAME FORMAT A80
-- select 'Welcome, you are connected to ' || name || ' database' as Message from v$database;
SET SQLPROMPT '&_user@&_connect_identifier> '
DEFINE _EDITOR=vi