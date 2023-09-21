SELECT
    i.instance_name              instance_name
  , s.inst_id                    instance_id
  , l.sid || ',' || s.serial#    sid_serial
  , s.username                   locking_oracle_user
  , DECODE(   l.lmode
            , 1, NULL
            , 2, 'Row Share'
            , 3, 'Row Exclusive'
            , 4, 'Share'
            , 5, 'Share Row Exclusive'
            , 6, 'Exclusive'
            ,    'None')         mode_held
  , DECODE(   l.request
            , 1, NULL
            , 2, 'Row Share'
            , 3, 'Row Exclusive'
            , 4, 'Share'
            , 5, 'Share Row Exclusive'
            , 6, 'Exclusive'
            ,    'None')         mode_requested
  , DECODE (   l.type
             , 'CF', 'Control File'
             , 'DX', 'Distributed Transaction'
             , 'FS', 'File Set'
             , 'IR', 'Instance Recovery'
             , 'IS', 'Instance State'
             , 'IV', 'Libcache Invalidation'
             , 'LS', 'Log Start or Log Switch'
             , 'MR', 'Media Recovery'
             , 'RT', 'Redo Thread'
             , 'RW', 'Row Wait'
             , 'SQ', 'Sequence Number'
             , 'ST', 'Diskspace Transaction'
             , 'TE', 'Extend Table'
             , 'TT', 'Temp Table'
             , 'TX', 'Transaction'
             , 'TM', 'DML'
             , 'UL', 'PLSQL User_lock'
             , 'UN', 'User Name'
             ,       'Nothing'
           )                     lock_type
  , o.owner || '.' || o.object_name    object
  , ROUND(l.ctime/60, 2)               lock_time_min
FROM v$instance    i
  , gv$session     s
  , v$lock        l
  , dba_objects   o
  , dba_tables    t
WHERE
      l.id1            =  o.object_id
  AND s.sid            =  l.sid
  AND o.owner          =  t.owner
  AND o.object_name    =  t.table_name
  AND o.owner          <> 'SYS'
  AND l.type           =  'TM'
ORDER BY i.instance_name, l.sid
