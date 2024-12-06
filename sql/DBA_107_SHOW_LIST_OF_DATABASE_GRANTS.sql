-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
set feedback off serverout on wrap off
prompt ##############################################################
prompt # SHOW LIST OF DATABASE GRANTS
prompt ##############################################################
COL USERNAME FOR A15
COL PRIVILEGE FOR A25
COL OWNER FOR A15
COL TABLENAME FOR A30
COL COLUMN_NAME FOR A25
COL ADMIN_OPTION FOR A15
SELECT A.* 
FROM (SELECT GRANTEE USERNAME
        , GRANTED_ROLE     PRIVILEGE
        , '--'             OWNER
        , '--'             TABLENAME
        , '--'             COLUMN_NAME
        , ADMIN_OPTION     ADMIN_OPTION
        , 'ROLE'           ACCESS_TYPE
      FROM DBA_ROLE_PRIVS RP 
      JOIN DBA_ROLES R ON RP.GRANTED_ROLE = R.ROLE
      WHERE GRANTEE IN (SELECT USERNAME FROM DBA_USERS)
UNION
SELECT GRANTEE          USERNAME
  , PRIVILEGE        PRIVILEGE
  , '--'             OWNER
  , '--'             TABLENAME
  , '--'             COLUMN_NAME
  , ADMIN_OPTION     ADMIN_OPTION
  , 'SYSTEM'         ACCESS_TYPE
FROM DBA_SYS_PRIVS
WHERE GRANTEE IN (SELECT USERNAME FROM DBA_USERS)
UNION
SELECT GRANTEE        USERNAME
  , PRIVILEGE      PRIVILEGE
  , OWNER          OWNER
  , TABLE_NAME     TABLENAME
  , '--'           COLUMN_NAME
  , GRANTABLE      ADMIN_OPTION
  , 'TABLE'        ACCESS_TYPE
FROM DBA_TAB_PRIVS
WHERE GRANTEE IN (SELECT USERNAME FROM DBA_USERS)
UNION
SELECT DP.GRANTEE   USERNAME
  , PRIVILEGE       PRIVILEGE
  , OWNER           OWNER
  , TABLE_NAME      TABLENAME
  , COLUMN_NAME     COLUMN_NAME
  , '--'            ADMIN_OPTION
  , 'ROLE'          ACCESS_TYPE
FROM ROLE_TAB_PRIVS RP, DBA_ROLE_PRIVS DP
WHERE     RP.ROLE = DP.GRANTED_ROLE
AND DP.GRANTEE IN (SELECT USERNAME FROM DBA_USERS)
UNION
SELECT GRANTEE      USERNAME
  , PRIVILEGE       PRIVILEGE
  , GRANTABLE       ADMIN_OPTION
  , OWNER           OWNER
  , TABLE_NAME      TABLENAME
  , COLUMN_NAME     COLUMN_NAME
  , 'COLUMN'        ACCESS_TYPE
FROM DBA_COL_PRIVS
WHERE GRANTEE IN (SELECT USERNAME FROM DBA_USERS)) A
ORDER BY USERNAME
  , A.TABLENAME
  , CASE
      WHEN A.ACCESS_TYPE = 'SYSTEM' THEN 1
      WHEN A.ACCESS_TYPE = 'TABLE'  THEN 2
      WHEN A.ACCESS_TYPE = 'COLUMN' THEN 3
      WHEN A.ACCESS_TYPE = 'ROLE'   THEN 4
    ELSE 5
    END
  , CASE
      WHEN A.PRIVILEGE IN ('EXECUTE') THEN 1
      WHEN A.PRIVILEGE IN ('SELECT', 'INSERT', 'DELETE') THEN 3
    ELSE 2
    END
  , A.COLUMN_NAME
  , A.PRIVILEGE;