-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL_1..........: dba.ribas@gmail.com
-- EMAIL_2..........: andre.ribas@icloud.com
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='yyyy-mm-dd';
set pages 700 lines 1000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFY GRANTS AND PERMISSIONS BY OWNER
prompt ##############################################################
col PRIVILEGE for a40
col OBJ_OWNER for a20
col OBJ_NAME for a40
col USERNAME for a20
col GRANT_SOURCES for a40
SELECT PRIVILEGE
  , OBJ_OWNER
  , OBJ_NAME
  , USERNAME
  , LISTAGG(GRANT_TARGET, ',') WITHIN GROUP (ORDER BY GRANT_TARGET) AS GRANT_SOURCES
  , MAX(ADMIN_OR_GRANT_OPT) AS ADMIN_OR_GRANT_OPT
  , MAX(HIERARCHY_OPT) AS HIERARCHY_OPT
FROM (WITH ALL_ROLES_FOR_USER AS (SELECT DISTINCT CONNECT_BY_ROOT GRANTEE AS GRANTED_USER, GRANTED_ROLE FROM DBA_ROLE_PRIVS CONNECT BY GRANTEE = PRIOR GRANTED_ROLE)
    SELECT PRIVILEGE
      , OBJ_OWNER
      , OBJ_NAME
      , USERNAME
      , REPLACE(GRANT_TARGET, USERNAME, 'Direct to user') AS GRANT_TARGET
      , ADMIN_OR_GRANT_OPT
      , HIERARCHY_OPT
    FROM (SELECT PRIVILEGE, NULL AS OBJ_OWNER, NULL AS OBJ_NAME, GRANTEE AS USERNAME, GRANTEE AS GRANT_TARGET, ADMIN_OPTION AS ADMIN_OR_GRANT_OPT, NULL AS HIERARCHY_OPT FROM DBA_SYS_PRIVS WHERE GRANTEE IN (SELECT USERNAME FROM DBA_USERS)
        UNION ALL
        SELECT PRIVILEGE, NULL AS OBJ_OWNER, NULL AS OBJ_NAME, ALL_ROLES_FOR_USER.GRANTED_USER AS USERNAME, GRANTEE AS GRANT_TARGET, ADMIN_OPTION AS ADMIN_OR_GRANT_OPT, NULL AS HIERARCHY_OPT FROM DBA_SYS_PRIVS
        JOIN ALL_ROLES_FOR_USER ON ALL_ROLES_FOR_USER.GRANTED_ROLE = DBA_SYS_PRIVS.GRANTEE
        UNION ALL
        SELECT PRIVILEGE, OWNER AS OBJ_OWNER, TABLE_NAME AS OBJ_NAME, GRANTEE AS USERNAME, GRANTEE AS GRANT_TARGET, GRANTABLE, HIERARCHY FROM DBA_TAB_PRIVS WHERE GRANTEE IN (SELECT USERNAME FROM DBA_USERS)
        UNION ALL
        SELECT PRIVILEGE, OWNER AS OBJ_OWNER, TABLE_NAME AS OBJ_NAME, GRANTEE AS USERNAME, ALL_ROLES_FOR_USER.GRANTED_ROLE AS GRANT_TARGET, GRANTABLE, HIERARCHY FROM DBA_TAB_PRIVS
        JOIN ALL_ROLES_FOR_USER ON ALL_ROLES_FOR_USER.GRANTED_ROLE = DBA_TAB_PRIVS.GRANTEE
    ) ALL_USER_PRIVS
      -- WHERE USERNAME in ('')
	) DISTINCT_USER_PRIVS
GROUP BY PRIVILEGE, OBJ_OWNER, OBJ_NAME, USERNAME;