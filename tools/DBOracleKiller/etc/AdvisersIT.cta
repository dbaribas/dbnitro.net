DECLARE
    CURSOR cur_BlockingLocks IS
        SELECT
            iw.inst_id AS waiting_instance_id
          , iw.instance_name AS waiting_instance
          , sw.status AS waiting_status
          , lw.sid AS waiting_sid
          , sw.serial# AS waiting_serial_num
          , sw.username AS waiting_oracle_username
          , sw.osuser AS waiting_os_username
          , sw.machine AS waiting_machine
          , pw.spid AS waiting_spid
          , SUBSTR(sw.terminal,0, 39) AS waiting_terminal
          , SUBSTR(sw.program,0, 39) AS waiting_program
          , ROUND(lw.ctime/60) AS waiting_lock_time_min
          , DECODE (lh.type, 'CF', 'Control File', 'DX', 'Distributed Transaction', 'FS', 'File Set', 'IR', 'Instance Recovery', 'IS', 'Instance State', 'IV', 'Libcache Invalidation', 'LS', 'Log Start or Log Switch', 'MR', 'Media Recovery', 'RT', 'Redo Thread', 'RW', 'Row Wait', 'SQ', 'Sequence Number', 'ST', 'Diskspace Transaction', 'TE', 'Extend Table', 'TT', 'Temp Table', 'TX', 'Transaction', 'TM', 'DML', 'UL', 'PLSQL User_lock', 'UN', 'User Name', 'Nothing-'  ) AS waiter_lock_type
	        , DECODE (lw.request, 0, 'None' /* Mon Lock equivalent */ , 1, 'NoLock' /* N */, 2, 'Row-Share (SS)' /* L */ , 3, 'Row-Exclusive (SX)' /* R */ , 4, 'Share-Table' /* S */ , 5, 'Share-Row-Exclusive (SSX)' /* C */ , 6, 'Exclusive' /* X */ , '[Nothing]' ) AS waiter_mode_request
	  , ih.inst_id AS locking_instance_id
          , ih.instance_name AS locking_instance
          , sh.status AS locking_status
          , lh.sid AS locking_sid
          , sh.serial# AS locking_serial_num
          , sh.username AS locking_oracle_username
          , sh.osuser AS locking_os_username
          , sh.machine AS locking_machine
          , ph.spid AS locking_spid
          , SUBSTR(sh.terminal,0, 39) AS locking_terminal
          , SUBSTR(sh.program,0, 39) AS locking_program
          , ROUND(lh.ctime/60) AS locking_lock_time_min
          , aw.sql_text AS waiting_sql_text
        FROM
            gv$lock     lw
          , gv$lock     lh
          , gv$instance iw
          , gv$instance ih
          , gv$session  sw
          , gv$session  sh
          , gv$process  pw
          , gv$process  ph
          , gv$sqlarea  aw
        WHERE
              iw.inst_id  = lw.inst_id
          AND ih.inst_id  = lh.inst_id
          AND sw.inst_id  = lw.inst_id
          AND sh.inst_id  = lh.inst_id
          AND pw.inst_id  = lw.inst_id
          AND ph.inst_id  = lh.inst_id
          AND aw.inst_id  = lw.inst_id
          AND sw.sid      = lw.sid
          AND sh.sid      = lh.sid
          AND lh.id1      = lw.id1
          AND lh.id2      = lw.id2
          AND lh.request  = 0
          AND lw.lmode    = 0
          AND (lh.id1, lh.id2) IN ( SELECT id1, id2 FROM gv$lock WHERE request = 0 INTERSECT SELECT id1, id2 FROM gv$lock WHERE  lmode = 0)
          AND sw.paddr  = pw.addr (+)
          AND sh.paddr  = ph.addr (+)
          AND sw.sql_address  = aw.address
        ORDER BY
            iw.instance_name
          , lw.sid;
    TYPE t_BlockingLockRecord IS RECORD (
          WaitingInstanceID         NUMBER
        , WaitingInstanceName       VARCHAR2(16)
        , WaitingStatus             VARCHAR2(8)
        , WaitingSid                NUMBER
        , WaitingSerialNum          NUMBER
        , WaitingOracleUsername     VARCHAR2(30)
        , WaitingOSUsername         VARCHAR2(30)
        , WaitingMachine            VARCHAR2(64)
        , WaitingSpid               VARCHAR2(12)
        , WaitingTerminal           VARCHAR2(30)
        , WaitingProgram            VARCHAR2(48)
        , WaitingLockTimeMinute     NUMBER
        , WaiterLockType            VARCHAR2(30)
        , WaiterModeRequest         VARCHAR2(30)
        , LockingInstanceID         NUMBER
        , LockingInstanceName       VARCHAR2(16)
        , LockingStatus             VARCHAR2(8)
        , LockingSid                NUMBER
        , LockingSerialNum          NUMBER
        , LockingOracleUsername     VARCHAR2(30)
        , LockingOSUsername         VARCHAR2(30)
        , LockingMachine            VARCHAR2(64)
        , LockingSpid               VARCHAR2(12)
        , LockingTerminal           VARCHAR2(30)
        , LockingProgram            VARCHAR2(48)
        , LockingLockTimeMinute     NUMBER
        , SQLText                   VARCHAR2(1000)
    );
    TYPE t_BlockingLockRecordTable IS TABLE OF t_BlockingLockRecord INDEX BY BINARY_INTEGER;
    v_BlockingLockArray             t_BlockingLockRecordTable;
    v_BlockingLockRec               cur_BlockingLocks%ROWTYPE;
    v_NumBlockingLocksIncidents     BINARY_INTEGER := 0;
BEGIN
    DBMS_OUTPUT.ENABLE(1000000);
    OPEN cur_BlockingLocks;
    LOOP
        FETCH cur_BlockingLocks INTO v_BlockingLockRec;
        EXIT WHEN cur_BlockingLocks%NOTFOUND;
        v_NumBlockingLocksIncidents := v_NumBlockingLocksIncidents + 1;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).WaitingInstanceID        := v_BlockingLockRec.waiting_instance_id;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).WaitingInstanceName      := v_BlockingLockRec.waiting_instance;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).WaitingStatus            := v_BlockingLockRec.waiting_status;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).WaitingSid               := v_BlockingLockRec.waiting_sid;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).WaitingSerialNum         := v_BlockingLockRec.waiting_serial_num;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).WaitingOracleUsername    := v_BlockingLockRec.waiting_oracle_username;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).WaitingOSUsername        := v_BlockingLockRec.waiting_os_username;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).WaitingMachine           := v_BlockingLockRec.waiting_machine;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).WaitingSpid              := v_BlockingLockRec.waiting_spid;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).WaitingTerminal          := v_BlockingLockRec.waiting_terminal;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).WaitingProgram           := v_BlockingLockRec.waiting_program;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).WaitingLockTimeMinute    := v_BlockingLockRec.waiting_lock_time_min;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).WaiterLockType           := v_BlockingLockRec.waiter_lock_type;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).WaiterModeRequest        := v_BlockingLockRec.waiter_mode_request;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).LockingInstanceID        := v_BlockingLockRec.locking_instance_id;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).LockingInstanceName      := v_BlockingLockRec.locking_instance;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).LockingStatus            := v_BlockingLockRec.locking_status;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).LockingSid               := v_BlockingLockRec.locking_sid;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).LockingSerialNum         := v_BlockingLockRec.locking_serial_num;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).LockingOracleUsername    := v_BlockingLockRec.locking_oracle_username;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).LockingOSUsername        := v_BlockingLockRec.locking_os_username;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).LockingMachine           := v_BlockingLockRec.locking_machine;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).LockingSpid              := v_BlockingLockRec.locking_spid;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).LockingTerminal          := v_BlockingLockRec.locking_terminal;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).LockingProgram           := v_BlockingLockRec.locking_program;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).LockingLockTimeMinute    := v_BlockingLockRec.locking_lock_time_min;
        v_BlockingLockArray(v_NumBlockingLocksIncidents).SQLText                  := v_BlockingLockRec.waiting_sql_text;
    END LOOP;
    CLOSE cur_BlockingLocks;
    FOR RowIndex IN 1 .. v_BlockingLockArray.COUNT
    LOOP
        DBMS_OUTPUT.PUT_LINE('Instance ID|' || v_BlockingLockArray(RowIndex).WaitingInstanceID 			|| '|' || v_BlockingLockArray(RowIndex).LockingInstanceID);
        DBMS_OUTPUT.PUT_LINE('Instance Name|' || v_BlockingLockArray(RowIndex).WaitingInstanceName 		|| '|' || v_BlockingLockArray(RowIndex).LockingInstanceName);
        DBMS_OUTPUT.PUT_LINE('Oracle SID|' || v_BlockingLockArray(RowIndex).WaitingSid  			|| '|' || v_BlockingLockArray(RowIndex).LockingSid);
        DBMS_OUTPUT.PUT_LINE('Serial#|' || v_BlockingLockArray(RowIndex).WaitingSerialNum      			|| '|' || v_BlockingLockArray(RowIndex).LockingSerialNum);
        DBMS_OUTPUT.PUT_LINE('Oracle User|' || v_BlockingLockArray(RowIndex).WaitingOracleUsername 		|| '|' || v_BlockingLockArray(RowIndex).LockingOracleUsername);
        DBMS_OUTPUT.PUT_LINE('O/S User|' || v_BlockingLockArray(RowIndex).WaitingOSUsername     		|| '|' || v_BlockingLockArray(RowIndex).LockingOSUsername);
        DBMS_OUTPUT.PUT_LINE('Machine|' || v_BlockingLockArray(RowIndex).WaitingMachine        			|| '|' || v_BlockingLockArray(RowIndex).LockingMachine);
        DBMS_OUTPUT.PUT_LINE('O/S PID|' || v_BlockingLockArray(RowIndex).WaitingSpid           			|| '|' || v_BlockingLockArray(RowIndex).LockingSpid);
        DBMS_OUTPUT.PUT_LINE('Terminal|' || v_BlockingLockArray(RowIndex).WaitingTerminal       		|| '|' || v_BlockingLockArray(RowIndex).LockingTerminal);
        DBMS_OUTPUT.PUT_LINE('Lock Time|' || v_BlockingLockArray(RowIndex).WaitingLockTimeMinute || ' minutes'  || '|' || v_BlockingLockArray(RowIndex).LockingLockTimeMinute ||' minutes');
        DBMS_OUTPUT.PUT_LINE('Status|' || v_BlockingLockArray(RowIndex).WaitingStatus         			|| '|' || v_BlockingLockArray(RowIndex).LockingStatus);
        DBMS_OUTPUT.PUT_LINE('Program|' || v_BlockingLockArray(RowIndex).WaitingProgram        			|| '|' || v_BlockingLockArray(RowIndex).LockingProgram);
        DBMS_OUTPUT.PUT_LINE('Waiter Lock Type|' || v_BlockingLockArray(RowIndex).WaiterLockType);
        DBMS_OUTPUT.PUT_LINE('Waiter Mode Request|' || v_BlockingLockArray(RowIndex).WaiterModeRequest);
        DBMS_OUTPUT.PUT_LINE('Waiting SQL|' || v_BlockingLockArray(RowIndex).SQLText);
        DBMS_OUTPUT.PUT_LINE('-');
    END LOOP;
END;