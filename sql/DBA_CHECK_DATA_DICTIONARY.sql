set serveroutput on size unlimited

DECLARE
--------------------------------------------------------------------------
-- Copyright (c) 2015, Oracle and/or its affiliates. All rights reserved.
--    NAME
--      hcheck.sql
--
--    DESCRIPTION:
--      Doc ID 136697.1
--      To provide a single plsql which looks for common data dictionary
--      problems.
--      This script is for use mainly under the guidance of Oracle Support.
--    NOTES:
--      Usage:
--        SQL> @hcheck
--
--      Must be executed in SYS schema
--      This script is intended for use in Oracle releases 10.2.0.5 onwards
--      This script will NOT work in 10.2.0.4 or earlier.
--      In all cases any output reporting "problems" should be
--      parsed by Oracle Support to confirm if any action is required.
--
--      About the Result Status:
--          CRITICAL:  Is of highest risk and require urgent fix.
--          FAIL:      Require resolution on priority.
--          WARN:      Good to resolve.
--          PASS:      No problem.
--------------------------------------------------------------------------
 -- Output options - change these to default as required
 -- Override them at run time if required.
 --
  TO_DBMS_OUTPUT boolean := TRUE;	-- Send output to DBMS_OUTPUT
  TO_USER_TRACE  boolean := TRUE;	-- Send output to user trace file
  IGNORE_ERRORS  boolean := TRUE;	-- Ignore DBMS_OUTPUT errors if
  DEBUG          boolean := FALSE;
--
  tmp varchar2(2001);
--
  APP_EXCEPTION EXCEPTION;
  pragma exception_init(APP_EXCEPTION, -20000);
  --
  Type RecFunc Is Record (FName Varchar2(32), FRelease Varchar2(32)) ;
  Type sFunc Is Table Of RecFunc Index By Binary_integer ;
--
  sF sFunc ;       -- Function Names
  Ver        Varchar2(10) := '07MAY18';
  Warn       Number       := 0;
  Fatal      Number       := 0;
  Critical   Number       := 0;
  CatV       Varchar2(10)     ; -- RDBMS Catalog Version from dba_registry
  nCatV      Number       := 0; -- RDBMS Catalog Version from dba_registry converted to Number
  Verbose    Boolean;

  procedure put_line(txt varchar2) is
  begin
    tmp:=txt;
    if TO_DBMS_OUTPUT then
      begin
	dbms_output.put_line(txt);
      exception
	when APP_EXCEPTION then
	  -- If DBMS_OUTPUT is full then carry on if we are writing to
	  -- the trace file and ignoring errors, otherwise error now
	  if TO_USER_TRACE and IGNORE_ERRORS then
	    begin
	      dbms_output.put_line('[TRUNCATED]');
            exception
	      when APP_EXCEPTION then
		  null;
	    end;
	  else
	    raise;
	  end if;
      end;
    end if;
    if TO_USER_TRACE then
	dbms_system.ksdwrt(1,tmp);
    end if;
  end;
 --
  procedure put(txt varchar2) is
  begin
    tmp:=txt;
    if TO_DBMS_OUTPUT then
      begin
	dbms_output.put(txt);
      exception
	when APP_EXCEPTION then
	  -- If DBMS_OUTPUT is full then carry on if we are writing to
	  -- the trace file and ignoring errors, otherwise error now
	  if TO_USER_TRACE and IGNORE_ERRORS then
	    begin
	      dbms_output.put('[TRUNCATED]');
            exception
	      when APP_EXCEPTION then
		  null;
	    end;
	  else
	    raise;
	  end if;
      end;
    end if;
    if TO_USER_TRACE then
	dbms_system.ksdwrt(1,tmp);
    end if;
  end;
 --
  procedure new_line is
  begin
    if TO_DBMS_OUTPUT then
      begin
	dbms_output.new_line;
      exception
	when APP_EXCEPTION then
	  if TO_USER_TRACE and IGNORE_ERRORS then
	    null;
	  else
	    raise;
	  end if;
      end;
    end if;
    if TO_USER_TRACE then
	dbms_system.ksdwrt(1,' ');
    end if;
  end;
 --
  procedure wrap(txt varchar2, linelen number default 78) is
    p   integer:=1;
    len integer;
    pos integer;
    chunk varchar2(2000);
    xchunk varchar2(2000);
    llen number:=linelen;
  BEGIN
    if (llen>2000) then
	llen:=2000;
    end if;
    if (llen<=1) then
	llen:=78;
    end if;
    len:=length(txt);
    while (p<=len) loop
      chunk:=substr(txt,p,llen);
      pos:=instr(chunk,chr(10),-1);
      if pos>0 then
       -- We have a CR in the text - use it
       put_line(substr(chunk,1,pos-1));
       p:=p+pos;
      else 
       -- No CR in the text so we will look for a split character
       xchunk:=translate(chunk,' ,()=',',,,,,');
       pos:=instr(xchunk,',',-1);
       if pos>0 and len>llen then
        put_line(substr(chunk,1,pos));
	p:=p+pos;
       else
        put(chunk);
	p:=p+llen;
       end if;
      end if;
    end loop;
    new_line;
  END;
 --
  procedure rule_off is
  begin
    put_line('=========================================================');
  end;

--
-- Main
--

--
  Procedure strtok (tok In Out Varchar2, s In Out Varchar2, ct In Varchar2) Is
    i           Pls_integer      ;
    p           Pls_integer      ;
    len         Pls_integer      ;
    token_start Pls_integer      ;
    intoken     Boolean := FALSE ;
  Begin
    If ( s Is Not NULL ) Then
      len := length( s ) ;
      i   := 1 ;
      While ( i <= len ) Loop
        p := instr( ct, substr(s,i,1) );
        If ( ( i = len ) Or ( p > 0 ) ) Then
          If ( intoken ) Then
            If ( p > 0 ) Then
              tok := substr( s, token_start, i - token_start ) ;
              s   := substr( s, i+1 ) ;
            Else
              tok := substr( s, token_start, i - token_start + 1 ) ;
              s   := '' ;
            End If ;
            Exit When TRUE ;
          End If ;
        Elsif ( Not intoken ) Then
            intoken := true ;
            token_start := i ;
        End If;
        tok := s ;
        i := i + 1 ;
      End Loop;
    End if;
  End;
--
  Function CatV2nCatV ( s In Varchar2, n in Number default 5 ) Return Number As
    type tok is table of Number index by binary_integer ;
    tk tok ;
    scp varchar2(16) ;
    i number := 1 ;
    scv Varchar2(16) := Null ;
  Begin
    scp := s ;
    for i in 1..n loop
      tk(i) := Null ;
      strtok( tk(i), scp, '.' );
      scv := scv || Lpad(tk(i),2,'0') ;
    end loop ;
    return To_Number(scv) ;
  end;
--
  Function InitsF (Fname In Varchar2 default Null, nvc In Number Default 5) Return sFunc Is
    AllReleases Varchar2(32) := '99.99.99.99.99' ;
  Begin
    Select version Into CatV From dba_registry Where comp_id='CATALOG' ;
    nCatV := CatV2nCatV ( CatV, nvc ) ;
    execute immediate 'alter session set tracefile_identifier=HCHECK' || Fname ;
--
-- Highest Relevant Release For Functions
-- If check against all releases, specify '99.99.99.99.99'
--
    sF (0).Fname := NULL                        ; sF (0).Frelease := AllReleases ;
    sF (1).Fname := 'SynLastDDLTim'             ; sF (1).Frelease := '10.1.0.2.0';
    sF (2).Fname := 'LobNotInObj'               ; sF (2).Frelease := AllReleases ;
    sF (3).Fname := 'MissingOIDOnObjCol'        ; sF (3).Frelease := AllReleases ;
    sF (4).Fname := 'SourceNotInObj'            ; sF (4).Frelease := AllReleases ;
    sF (5).Fname := 'IndIndparMismatch'         ; sF (5).Frelease := '11.2.0.1.0';
    sF (6).Fname := 'InvCorrAudit'              ; sF (6).Frelease := '11.2.0.1.0';
    sF (7).Fname := 'OversizedFiles'            ; sF (7).Frelease := AllReleases ;
    sF (8).Fname := 'TinyFiles'                 ; sF (8).Frelease :=  '9.0.1.0.0';
    sF (9).Fname := 'PoorDefaultStorage'        ; sF (9).Frelease := AllReleases ;
    sF(10).Fname := 'PoorStorage'               ; sF(10).Frelease := AllReleases ;
    sF(11).Fname := 'MissTabSubPart'            ; sF(11).Frelease :=  '9.0.1.0.0';
    sF(12).Fname := 'PartSubPartMismatch'       ; sF(12).Frelease := '11.2.0.1.0';
    sF(13).Fname := 'TabPartCountMismatch'      ; sF(13).Frelease := AllReleases ;
    sF(14).Fname := 'OrphanedTabComPart'        ; sF(14).Frelease := AllReleases ;
    sF(15).Fname := 'ZeroIndSubPart'            ; sF(15).Frelease :=  '9.2.0.1.0';
    sF(16).Fname := 'MissingSum$'               ; sF(16).Frelease := AllReleases ;
    sF(17).Fname := 'MissingDir$'               ; sF(17).Frelease := AllReleases ;
    sF(18).Fname := 'DuplicateDataobj'          ; sF(18).Frelease := AllReleases ;
    sF(19).Fname := 'ObjSynMissing'             ; sF(19).Frelease := AllReleases ;
    sF(20).Fname := 'ObjSeqMissing'             ; sF(20).Frelease := AllReleases ;
    sF(21).Fname := 'OrphanedUndo'              ; sF(21).Frelease := AllReleases ;
    sF(22).Fname := 'OrphanedIndex'             ; sF(22).Frelease := AllReleases ;
    sF(23).Fname := 'OrphanedIndexPartition'    ; sF(23).Frelease := AllReleases ;
    sF(24).Fname := 'OrphanedIndexSubPartition' ; sF(24).Frelease := AllReleases ;
    sF(25).Fname := 'OrphanedTable'             ; sF(25).Frelease := AllReleases ;
    sF(26).Fname := 'OrphanedTablePartition'    ; sF(26).Frelease := AllReleases ;
    sF(27).Fname := 'OrphanedTableSubPartition' ; sF(27).Frelease := AllReleases ;
    sF(28).Fname := 'MissingPartCol'            ; sF(28).Frelease := AllReleases ;
    sF(29).Fname := 'OrphanedSeg$'              ; sF(29).Frelease := AllReleases ;
    sF(30).Fname := 'OrphanedIndPartObj#'       ; sF(30).Frelease := AllReleases ;
    sF(31).Fname := 'DuplicateBlockUse'         ; sF(31).Frelease := AllReleases ;
    sF(32).Fname := 'FetUet'                    ; sF(32).Frelease := AllReleases ;
    sF(33).Fname := 'Uet0Check'                 ; sF(33).Frelease := AllReleases ;
    sF(34).Fname := 'ExtentlessSeg'             ; sF(34).Frelease := '11.2.0.1.0';
    sF(35).Fname := 'SeglessUET'                ; sF(35).Frelease := AllReleases;
    sF(36).Fname := 'BadInd$'                   ; sF(36).Frelease := AllReleases ;
    sF(37).Fname := 'BadTab$'                   ; sF(37).Frelease := AllReleases ;
    sF(38).Fname := 'BadIcolDepCnt'             ; sF(38).Frelease := AllReleases ;
    sF(39).Fname := 'WarnIcolDep'               ; sF(39).Frelease := '11.1.0.7.0';
    sF(40).Fname := 'ObjIndDobj'                ; sF(40).Frelease := AllReleases ;
    sF(41).Fname := 'DropForceType'             ; sF(41).Frelease := '10.1.0.2.0';
    sF(42).Fname := 'TrgAfterUpgrade'           ; sF(42).Frelease := AllReleases ;
    sF(43).Fname := 'ObjType0'                  ; sF(43).Frelease := AllReleases ;
    sF(44).Fname := 'ObjOidView'                ; sF(44).Frelease :=  '9.0.1.0.0';
    sF(45).Fname := 'Idgen1$TTS'                ; sF(45).Frelease :=  '9.0.1.0.0';
    sF(46).Fname := 'DroppedFuncIdx'            ; sF(46).Frelease :=  '9.2.0.1.0';
    sF(47).Fname := 'BadOwner'                  ; sF(47).Frelease := AllReleases ;
    sF(48).Fname := 'StmtAuditOnCommit'         ; sF(48).Frelease := AllReleases ;
    sF(49).Fname := 'BadPublicObjects'          ; sF(49).Frelease := AllReleases ;
    sF(50).Fname := 'BadSegFreelist'            ; sF(50).Frelease := AllReleases ;
    sF(51).Fname := 'BadCol#'                   ; sF(51).Frelease := '10.1.0.2.0';
    sF(52).Fname := 'BadDepends'                ; sF(52).Frelease := AllReleases ;
    sF(53).Fname := 'CheckDual'                 ; sF(53).Frelease := AllReleases ;
    sF(54).Fname := 'ObjectNames'               ; sF(54).Frelease := AllReleases ;
    sF(55).Fname := 'BadCboHiLo'                ; sF(55).Frelease := AllReleases ;
    sF(56).Fname := 'ChkIotTs'                  ; sF(56).Frelease := AllReleases ;
    sF(57).Fname := 'NoSegmentIndex'            ; sF(57).Frelease := AllReleases ;
    sF(58).Fname := 'BadNextObject'             ; sF(58).Frelease := AllReleases ;
    sF(59).Fname := 'OrphanIndopt'              ; sF(59).Frelease :=  '9.2.0.8.0';
    sF(60).Fname := 'UpgFlgBitTmp'              ; sF(60).Frelease := '10.1.0.1.0';
    sF(61).Fname := 'RenCharView'               ; sF(61).Frelease := '10.1.0.1.0';
    sF(62).Fname := 'Upg9iTab$'                 ; sF(62).Frelease :=  '9.2.0.4.0';
    sF(63).Fname := 'Upg9iTsInd'                ; sF(63).Frelease :=  '9.2.0.5.0';
    sF(64).Fname := 'Upg10gInd$'                ; sF(64).Frelease := '10.2.0.0.0';
    sF(65).Fname := 'DroppedROTS'               ; sF(65).Frelease := AllReleases ;
    sF(66).Fname := 'ChrLenSmtcs'               ; sF(66).Frelease := '11.1.0.6.0';
    sF(67).Fname := 'FilBlkZero'                ; sF(67).Frelease := AllReleases ;
    sF(68).Fname := 'DbmsSchemaCopy'            ; sF(68).Frelease := AllReleases ;
    sF(69).Fname := 'OrphanedIdnseqObj'         ; sF(69).Frelease := '12.1.0.0.0';
    sF(70).Fname := 'OrphanedIdnseqSeq'         ; sF(70).Frelease := '12.1.0.0.0';
    sF(71).Fname := 'OrphanedObjError'          ; sF(71).Frelease := '11.2.0.0.0';
    sF(72).Fname := 'ObjNotLob'                 ; sF(72).Frelease := AllReleases ;
    sF(73).Fname := 'MaxControlfSeq'            ; sF(73).Frelease := AllReleases ;
    sF(74).Fname := 'SegNotInDeferredStg'       ; sF(74).Frelease := '11.2.0.0.0';
    sF(75).Fname := 'SystemNotRfile1'           ; sF(75).Frelease := '9.2.0.0.0' ;
    sF(76).Fname := 'DictOwnNonDefaultSYSTEM'   ; sF(76).Frelease := AllReleases ;
    sF(77).Fname := 'OrphanTrigger'             ; sF(77).Frelease := AllReleases ;
    sF(78).Fname := 'ObjNotTrigger'             ; sF(78).Frelease := AllReleases ;
--
    Return sF;
  end;
--
  Function FindFname (Fname Varchar2 Default Null) return number is
  Begin
    sF := InitsF (Fname);
    For FnIdx in 1..sf.LAST Loop
        If upper(sF(FnIdx).Fname) = upper(Fname) Then
           Return FnIdx;
        End If;
    End Loop;
  End;
--
  Function Owner (uid Number) Return Varchar2 Is
    r Varchar2(30) := Null;
  Begin
    Select name Into r
    From   user$
    Where  user# = uid ;

    Return r;
  Exception
    When NO_DATA_FOUND Then
      Return ( '*NonexistentOwnerId='||uid||'*' ) ;
  End ;
--
  Function ObjType (typeid Number) Return Varchar2 Is
  Begin
    Case typeid
     When 1  Then Return 'INDEX';
     When 2  Then Return 'TABLE';
     When 3  Then Return 'CLUSTER';
     When 4  Then Return 'VIEW';
     When 5  Then Return 'SYNONYM';
     When 6  Then Return 'SEQUENCE';
     When 7  Then Return 'PROCEDURE';
     When 8  Then Return 'FUNCTION';
     When 9  Then Return 'PACKAGE';
     When 10 Then Return 'NON-EXISTENT';
     When 11 Then Return 'PACKAGE BODY';
     When 12 Then Return 'TRIGGER';
     When 13 Then Return 'TYPE';
     When 14 Then Return 'TYPE BODY';
     When 19 Then Return 'TABLE PARTITION';
     When 20 Then Return 'INDEX PARTITION';
     When 21 Then Return 'LOB';
     When 34 Then Return 'TABLE SUBPARTITION';
     When 35 Then Return 'INDEX SUBPARTITION';
     When 40 Then Return 'LOB PARTITION';
     When 41 Then Return 'LOB SUBPARTITION';
     Else Return Null;
    End Case;
  End;
--
  Function SegType (segtypeid Number) Return Varchar2 Is
  Begin
    Case segtypeid
     When 1  Then Return 'UNDO';
     When 2  Then Return 'SAVE UNDO';
     When 3  Then Return 'TEMPORARY';
     When 4  Then Return 'CACHE';
     When 5  Then Return 'DATA';
     When 6  Then Return 'INDEX';
     When 7  Then Return 'SORT';
     When 8  Then Return 'LOB';
     When 9  Then Return 'Space Header';
     When 10 Then Return 'System Managed Undo';
     When 11 Then Return 'Stats';
     Else Return Null;
    End Case;
  End;
--
  Function TSName (tsn Number) Return Varchar2 Is
    r Varchar2(30) := Null;
  Begin
    If tsn=0 Then 
       Return Null; 
    End If;
    Select 'TABLESPACE_NAME='||name 
      Into r
    From   ts$ 
    Where  ts# = tsn;
    
    Return r;
  Exception
    When NO_DATA_FOUND Then
      Return Null;
  End ;
--
  Function IsIOT (objid Number) Return Boolean Is
    iotproperty Number;
  Begin
    Select Bitand(property, 64) 
    Into   iotproperty
    From   tab$
    Where  obj# = objid;
    If iotproperty = 64 Then
       Return True;
    Else 
       Return False;
    End If;
  Exception
    When no_data_found Then Return False;
  End;
--
  Function ObjName (objid Number, includetype boolean default false, 
             subnameonly boolean default false) Return Varchar2 Is
    r         Varchar2(1000) := Null;
    sub_name  obj$.subname%Type := Null;
    own       obj$.owner#%Type := Null;
    own_name  user$.name%Type := Null;
    type_name Varchar2(128);
    typeid obj$.type#%Type;
  Begin
    Select name, owner#, subname, type#
      Into r, own, sub_name, typeid
    From   obj$
    Where  obj# = objid;
    begin
      Select name 
        Into own_name
      From   user$
      Where  user# = own;
      If subnameonly Then
         r := sub_name;
      Else
         r := own_name||'.'||r; 
      End If;
    Exception
      when no_data_found then null;
    End;
    If includetype Then
       type_name := ObjType(typeid);
       If type_name Is Not Null Then
          r := type_name||'='||r;
       End If;
    End If;
    Return r;
  Exception
    When NO_DATA_FOUND Then
      Return ( '*UnknownObjID='||objid||'*' ) ;
  End;
--
  Function IsLastPartition( o number ) Return Boolean Is
    n Number := 0 ;
  Begin
    Select partcnt Into n From partobj$ where obj#=o ;
    If ( n>1 ) Then
      Return(FALSE) ;
    Else
      Return(TRUE) ;
    End If ;
  End;
--
  Procedure report_failure(impact in varchar2, herror in varchar2, hdesc in varchar2, 
                          docid in varchar2, printed out boolean)
  Is
  Begin
    put_line(impact);
    put_line (chr(10)||herror||': '||hdesc||' '||docid) ;
    printed := True;
  End;
--
  Procedure report_segtype(segtype# In Number)
  Is
  Begin
    put_line('^- Entry in SEG$ but for different SEG$.TYPE#='
             ||segtype#||'('||SegType(segtype#)||')'
             || '. Check for HCKE-0023 error');
  End;
--
  Procedure DictAt( ts number, fi number, bl number ) is
   Cursor cDictAt is
     select typ, ts#,file#,block#,count('x') CNT
      from (
    select 'UNDO$' typ, u.ts#, u.file#, u.block# from undo$ u
         where decode(u.status$,1,null,u.status$) is not null
    UNION ALL
    select 'TAB$'        typ, a.ts#,a.file#,a.block# from tab$        a
    UNION ALL
    select 'CLU$'        typ, b.ts#,b.file#,b.block# from clu$        b
    UNION ALL
    select 'TABPART$'    typ, c.ts#,c.file#,c.block# from tabpart$    c
    UNION ALL
    select 'TABSUBPART$' typ, d.ts#,d.file#,d.block# from tabsubpart$ d
    UNION ALL
    select 'IND$'        typ, e.ts#,e.file#,e.block# from ind$        e
    UNION ALL
    select 'INDPART$'    typ, f.ts#,f.file#,f.block# from indpart$    f
    UNION ALL
    select 'INDSUBPART$' typ, g.ts#,g.file#,g.block# from indsubpart$ g
    UNION ALL
    select 'LOB$'        typ, h.ts#,h.file#,h.block# from lob$        h
    UNION ALL
    select 'LOBFRAG$'    typ, i.ts#,i.file#,i.block# from lobfrag$    i
--  UNION ALL
--  select 'RECYCLEBIN$' typ, j.ts#,j.file#,j.block# from recyclebin$ j
       )
       where ts#= TS and file# = FI and block#= BL
       group by typ, ts#,file#,block#;
  Begin
   For R in cDictAt
   Loop
     put_line('^  '||R.typ||' has '||R.cnt||' rows');
   End Loop;
  End;
--
  function IndexIsNosegment( o number ) return boolean is
   Cursor cX is
    select bitand(flags,4096) noseg from ind$ where obj#=o;
   ret boolean:=null;
  begin
   For C in cX
   loop
     if C.noseg=4096 then
    ret:=true;
     else
    ret:=false;
     end if;
   end loop;
   return ret;  /* true/false or NULL if not found */
  end;
--
   Procedure CheckIndPart( o number ) is
    Cursor Cchk is
    select  i.obj#, i.dataobj#, i.ts#, i.file#, i.block#
          from indpart$ i
     where i.bo#=o
       and (i.file#!=0 OR i.block#!=0);
   begin
    For R in Cchk Loop
     put_line(' ^- PROBLEM: Child INDPART$ with FILE/BLK (bug 4683380)');
     put_line(' ^- ( OBJ='||R.obj#|| ' DOBJ='||r.dataobj#||
        ' TS='||r.TS#||
        ' RFILE/BLOCK='||r.file#||'/'||r.block#||')' );
     Fatal:=Fatal+1;
    end loop;
   end;
--
  Function ChecknCatVnFR ( nCatV In Number,
                           nF in Number,
                           VerChk Number,
                           min_version In Boolean default FALSE
                            ) Return Boolean Is
  /* To verify if the Check can be run in the Version by nCatV */
    str1 Varchar2(10) := To_Char(nCatV) ;
    str2 Varchar2(10) ;
    nFr  Number ;
    stime varchar2(30);
  Begin
    nFr := CatV2nCatV ( sF(nF).Frelease, VerChk );
    
    if nCatV = 0 Then
       str1 := '*Any Rel*' ;
    end if;

    if nFR = 9999999999 Then
       str2 := '*All Rel*' ;
    else
       str2 := To_Char(nFr);
    end if;

    select to_char(sysdate, 'MM/DD HH24:MI:SS')
    into stime
    from dual;

    If nCatV > nFR Then
      if min_version = TRUE Then
      /* The Check is only run in a version greater or equal to nFR */
         put(Rpad('.- '||sF(nF).Fname, 30, ' ')||' ... ' ||Rpad(str1,10,' ')||' > '||Lpad(str2,11,' ')||' '||stime||' ') ;
         Return TRUE ;     
      Else 
        If (DEBUG) Then
           put_line(Rpad('.- '||sF(nF).Fname, 30, ' ')||' ... ' ||Rpad(nCatv,10,' ')||' > '||Lpad(nFR,11,' ')||' : n/a');
        End If;
        Return FALSE ;
      End If;
    ElsIf min_version = TRUE Then
    /* The Check is only run in a version greater or equal to nFR */
    If (DEBUG) Then
        put_line(Rpad('.- '||sF(nF).Fname, 30, ' ')||' ... ' ||Rpad(nCatv,10,' ')||' < '||Lpad(nFR,11,' ')||' : n/a');
    End If;
      Return FALSE ;
    Else
    /* The Check is run in versions lower than nFR */
      put(Rpad('.- '||sF(nF).Fname, 30, ' ')||' ... ' ||Rpad(str1,10,' ')||' <='||Lpad(str2,11,' ')||' '||stime||' ') ;
      Return TRUE ;
    End If ;
  End ;
--
  Procedure SynLastDDLTim
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select Distinct o.obj#, o.owner#, o.name
      From   obj$ o
      Where  type#  = 5
      And    ctime != mtime
      And    exists (select 'x' from idl_ub1$ i
                     where  i.obj# = o.obj#  )  /* Has IDL information */;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0001';
    ps1a Varchar2(65) := 'Synonym''s LAST_DDL_TIME != CREATED';
    ps1n Varchar2(20) := '(Doc ID 2367573.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      /* Check is being executed standalone */
      nFr := FindFname('SynLastDDLTim') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line(' OBJ#='||c1.OBJ#||' Name='||Owner(c1.owner#)||'.'||
                c1.name);
      Warn := Warn + 1;
    End Loop ;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End ;
--
  Procedure LobNotInObj
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select l.obj#, l.lobj#
      From   lob$ l, obj$ o
      Where  l.lobj# = o.obj#(+)
      And    o.obj# is null
      ;
    ps1  Varchar2(10) := 'HCKE-0001';
    ps1a Varchar2(65) := 'LOB$.LOBJ# not found in OBJ$';
    ps1n Varchar2(40) := '(Doc ID 1360208.1)';
    CursorRun Boolean := FALSE;
    
  Begin
    If ( nF = 0) Then
      nFr := FindFname('LobNotInObj') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 In sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line(' LOB$.LOBJ# has no OBJ$ entry for LOBJ#='||c1.lobj#||
                    ' (of '|| ObjName(c1.obj#,True) || ' OBJ#='||c1.obj#||')');
      Fatal := Fatal + 1 ;
    End Loop ;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End ;
--
  Procedure MissingOIDOnObjCol
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select o.obj# , o.type#, o.owner#, o.name, c.col#, c.intcol#,
               c.name cname, t.property
      From   obj$ o, col$ c, coltype$ ct, oid$ oi, tab$ t
      Where  o.obj#     = ct.obj#
      And    ct.obj#    = c.obj#
      And    ct.col#    = c.col#
      And    ct.intcol# = c.intcol#
      And    oi.oid$(+) = ct.toid
      And    o.obj#     = t.obj#(+)
      And    oi.oid$ is null;
    ps1  Varchar2(10) := 'HCKE-0002';
    ps1a Varchar2(65) := 'Object type column with missing OID$';
    ps1n Varchar2(40) := '(Doc ID 1360268.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('MissingOIDOnObjCol') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 In sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line(' OBJ#='||c1.obj#||' Name='||Owner(c1.owner#)||'.'
                ||c1.name||' IntCol#='||c1.intcol#||'='||c1.cname
                ||' TabProp='||c1.property);
      Fatal := Fatal + 1 ;
    End Loop ;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End ;
--
  Procedure SourceNotInObj
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
	Select Count('x') cnt, Count(Distinct s.obj#) nobj
	From   source$ s
	Where  not exists (select 'x' 
	                     from obj$ o 
	                    where o.obj# = s.obj#)
	having Count('x') > 0;
    ps1  Varchar2(10) := 'HCKE-0003';
    ps1a Varchar2(65) := 'SOURCE$ for OBJ# not in OBJ$';
    ps1n Varchar2(40) := '(Doc ID 1360233.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('SourceNotInObj') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 In sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('SOURCE$ has '||c1.cnt||
               ' rows for '||c1.nobj||' OBJ# values not in OBJ$');
      Fatal := Fatal + 1;
    End Loop;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If;
  End ;
--
  Procedure IndIndparMismatch
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select io.obj# io, io.name ionam, ipo.obj# ipo, ipo.name iponam
      From   obj$ io, indpart$ ip, obj$ ipo
      Where  ipo.type#         = 20  /* IND PART */
      And    ip.obj#           = ipo.obj#
      And    io.obj# (+)       = ip.bo#
      And    nvl(io.name,'"') != ipo.name;
    ps1  Varchar2(10) := 'HCKE-0004';
    ps1a Varchar2(65) := 'OBJ$.NAME mismatch for INDEX v INDEX PARTITION' ;
    ps1n Varchar2(40) := '(Doc ID 1360285.1)';
    CursorRun Boolean := FALSE ; 
  Begin
    If ( nF = 0) Then
      nFr := FindFname('IndIndparMismatch') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 In sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line(' Ind Part OBJ$.OBJ# '||c1.ipo||' '||c1.iponam||
              '!='||c1.ionam||' OBJ#='||c1.io);
      Fatal := Fatal + 1 ;
    End Loop ;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End ;
--
  Procedure InvCorrAudit
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select decode(aud.user#,
                      0, 'ANY CLIENT',
                      1, Null        ,
                      client.name)     username ,
             proxy.name                proxyname,
             prv.name                  privilege,
             decode(aud.success,
                      1, 'BY SESSION',
                      2, 'BY ACCESS' ,
                      'NOT SET')       success  ,
             decode(aud.failure,
                      1, 'BY SESSION',
                      2, 'BY ACCESS' ,
                      'NOT SET')       failure
      From   sys.user$                 client   ,
             sys.user$                 proxy    ,
             system_privilege_map      prv      ,
             sys.audit$                aud
      Where  aud.option# = -prv.privilege
      and aud.user#      = client.user#
      and aud.user#      = 0               /* SYS */
      and aud.proxy#     = proxy.user# (+)
      and aud.proxy# is null
    ;
    ps1  Varchar2(10) := 'HCKE-0005';
    ps1a Varchar2(65) := 'Invalid/Corrupted AUDIT$ entries';
    ps1n Varchar2(40) := '(Doc ID 1360489.1)';
    CursorRun Boolean := FALSE;
    variant Varchar2(30) := Null ;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('InvCorrAudit') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 In sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      If (c1.username = 'ANY CLIENT') Then
        variant := 'Corrupted -' ;
      Else
        variant := 'Invalid   -' ;
      End If;
      put_line(variant||' USER#='''||c1.username||''' OPTION='''||
               c1.privilege||''' SUCCESS='''||c1.success||''' FAILURE='''||
               c1.failure||'''');
      Fatal := Fatal + 1 ;
    End Loop;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure OversizedFiles
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select f.ts# TS, f.relfile# RFILE, f.file# AFILE, v.name NAME, f.blocks
      From   ts$ ts, file$ f, v$datafile v
      Where  ts.ts#                = f.ts#
      And    v.file#               = f.file#
      And    f.blocks              > 4194303 -- (4M -1 blocks)
      And    bitand(ts.flags,256) != 256
      Order  By f.ts#, f.relfile#
      ;
    ps1  Varchar2(10) := 'HCKE-0006';
    ps1a Varchar2(65) := 'Oversized datafile (blocks>4194303)';
    ps1n Varchar2(40) := '(Doc ID 1360490.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('OversizedFiles') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 In sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line(' OVERSIZED FILE ('||c1.blocks||' blocks) TS='||c1.TS||
            ' RFILE='||c1.RFILE||
            ' ABS='||c1.AFILE||' Name='||c1.NAME);
      Fatal := Fatal + 1 ;
    End Loop ;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End ;
--
  Procedure TinyFiles
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      select file#, ts#, blocks
      from   file$
      where  status$ = 2
      and blocks    <= 1;
    ps1  Varchar2(10) := 'HCKE-0007';
    ps1a Varchar2(65) := 'Tiny File size in FILE$';
    ps1n Varchar2(40) := '(Doc ID 1360492.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('TinyFiles') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 In sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line(' FILE$ FILE#='||c1.file#||' has BLOCKS='||c1.blocks);
      Fatal := Fatal + 1 ;
    End Loop ;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End ;
--
  Procedure PoorDefaultStorage
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      select tablespace_name, initial_extent, next_extent, min_extents,
             pct_increase, max_extents
      from   dba_tablespaces
      where (initial_extent < 1024*1024
             or
             contents='TEMPORARY')
       and   extent_management = 'DICTIONARY'
       and   next_extent    < 65536
       and   min_extlen     < 65536
       and   pct_increase   <     5
       and   max_extents    >  3000
       ;
    ps1  Varchar2(10) := 'HCKW-0002';
    ps1a Varchar2(65) := 'Poor Default Storage Clauses For Tablespace' ;
    ps1n Varchar2(40) := '(Doc ID 1360493.1)';
    CursorRun Boolean := FALSE; 
  Begin
    If ( nF = 0) Then
      nFr := FindFname('PoorDefaultStorage') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 In sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
          put_line('  '||rpad('Tablespace',30)||rpad('Init',10)||
               rpad('Next',10)||rpad('Min',10)||rpad('Pct',4)||
               'MaxExtents');
      End If;
      put_line('  '
          ||rpad(c1.tablespace_name,30)
          ||rpad(c1.initial_extent,10)
          ||rpad(c1.next_extent,10)
          ||rpad(c1.min_extents,10)
          ||rpad(c1.pct_increase,4)
          ||c1.max_extents );
      Warn := Warn + 1 ; 
    End Loop ;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End ;
--
  Procedure PoorStorage
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select s.owner       ,
             s.segment_name,
             s.segment_type,
             s.next_extent ,
             s.extents     ,
             s.pct_increase,
             s.max_extents
      From   dba_segments s, dba_tablespaces t
      Where s.owner != 'SYS'
        And s.tablespace_name = t.tablespace_name
        And t.extent_management = 'DICTIONARY'
        And ((s.initial_extent     < 65535
              And s.next_extent    < 65536
              And s.pct_increase   <     5
              And s.max_extents    >  3000
              And s.extents        >   500
              ) Or s.extents        >  3000
            );
    ps1  Varchar2(10) := 'HCKW-0003';
    ps1a Varchar2(65) := 'Poor Storage Clauses For Object(s)';
    ps1n Varchar2(40) := '(Doc ID 1360496.1)';
    CursorRun Boolean := FALSE; 
  Begin
    If ( nF = 0) Then
      nFr := FindFname('PoorStorage') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 In sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
          put_line('  '||rpad('Segment',50)||rpad('Next',10)||
                        rpad('Exts',7)||rpad('Pct',4)||
                        'MaxExtents' ) ;
      End If;
      put_line('  '|| rpad(c1.segment_type||' '
                   ||c1.owner||'.'
                   ||c1.segment_name,50)
                   ||rpad(c1.next_extent,10)
                   ||rpad(c1.extents,7)
                   ||rpad(c1.pct_increase,4)
                   ||c1.max_extents );
      Warn := Warn + 1 ;
    End Loop ;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End ;
--
  Procedure MissTabSubPart
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select o.obj#       part_obj# ,
             o.owner#               ,
             o.name                 ,
             o.subname              ,
             p.subpartcnt           ,
             p.bo#        table_obj#
      From   obj$         o         ,
             tabcompart$  p
      Where  o.type#      = 19      /* PARTITION                     */
      and    o.obj#       = p.obj#  /* Has subpartitions             */
      and    p.subpartcnt = 0       /* Has No entries in tabsubpart$ */
      ;
    Cursor sCur2 Is
      Select o.obj#       part_obj# ,
             o.owner#               ,
             o.name                 ,
             o.subname              ,
             p.subpartcnt           ,
             p.bo#        index_obj#
      from   obj$         o         ,
             indcompart$  p
      where  o.type#      = 20      /* INDEX PARTITION               */
      and    o.obj#       = p.obj#  /* Has subpartitions             */
      and    p.subpartcnt = 0       /* Has No entries in indsubpart$ */
    ;
    ps1  Varchar2(10) := 'HCKE-0008';
    ps1a Varchar2(65) := 'Missing TABSUBPART$ entry/entries';
    ps1n Varchar2(40) := '(Doc ID 1360500.1)';
    CursorRun Boolean := FALSE;
    sMsg Boolean      := FALSE;
    Begin
      If ( nF = 0) Then
        nFr := FindFname('MissTabSubPart') ; Else nFr := nF;
      End If ;
      
      If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
      For c1 In sCur1 Loop
        If (ps1 Is Not Null) Then
            put_line('FAIL');
            CursorRun := TRUE ;
            put_line (chr(10)||ps1||': '||ps1a||' '||ps1n) ;
            ps1:=null;
        End If;
        put_line(
          ' TABLE '||Owner(c1.owner#)||'.'||c1.name||
          ' Partition '||c1.subname||
          ' PartObj#='||c1.part_obj#||' TabObj#='||c1.table_obj#
        ) ;
        If ( IsLastPartition ( c1.table_obj# ) ) Then
          put_line(' ^^ PARTOBJ$.PARTCNT<=1 - non standard corruption') ;
        End If ;
        If ( CursorRun ) Then put(chr(10)) ; End If ;
        Fatal := Fatal + 1 ;
      End Loop ;

      For c2 In sCur2 Loop 
        If (ps1 Is Not Null) Then
            put_line('FAIL');
            CursorRun := TRUE ;
            put_line (chr(10)||ps1||': '||ps1a||' '||ps1n) ;
            ps1:=null;
        End If;
        put_line(
          ' INDEX '||Owner(c2.owner#)||'.'||c2.name||
          ' Partition '||c2.subname||
          ' PartObj#='||c2.part_obj#||' IndObj#='||c2.index_obj#);
        If ( IsLastPartition ( c2.index_obj# ) ) Then
          put_line(' ^^ PARTOBJ$.PARTCNT<=1 - non standard corruption') ;
       End If;
       Fatal := Fatal+1 ;
       sMsg  := TRUE ;
      End Loop ;
      If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
      If ( sMsg ) Then
        put_line('There are probably orphaned SEG$ entry/s with this') ;
      End If ;
    End ;
--
  Procedure PartSubPartMismatch
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
       Select po.obj#                              obj#   ,
              u.name owner,
              o.name name,
              Decode(o.type#, 1, 'INDEX', 'TABLE') type   ,
              Decode(po.parttype,
                     1, 'RANGE' ,
                     2, 'HASH'  ,
                     3, 'SYSTEM',
                     4, 'LIST'  ,
                     'Unknown')                    part   ,
              Decode(Mod(po.spare2, 256),
                     0, 'NONE'  ,
                     2, 'HASH'  ,
                     3, 'SYSTEM',
                     4, 'LIST'  ,
                     'Unknown')                    subpart
       From   partobj$                             po     ,
              obj$                                 o      ,
              user$                                u
       Where  po.obj#    = o.obj#
       And    o.owner#   = u.user#
       And    po.spare2 != 0
       And    o.type#    = 1                       -- Index
       And    Decode(po.parttype,
                     1, 'RANGE' ,
                     2, 'HASH'  ,
                     3, 'SYSTEM',
                     4, 'LIST'  ,
                     'Unknown') !=
              Decode(mod(po.spare2, 256),
                     0, 'NONE'  ,
                     2, 'HASH'  ,
                     3, 'SYSTEM',
                     4, 'LIST'  ,
                     'Unknown');
    ps1  Varchar2(10) := 'HCKW-0004';
    ps1a Varchar2(65) := 'TABPART/TABSUBPART method mismatch';
    ps1n Varchar2(40) := '(Doc ID 1360504.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0 ) Then
      nFr := FindFname('PartSubPartMismatch') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 In sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line(rpad(' INDEX '||c1.owner||'.'||c1.name,62,' ')||
               ' (OBJ '||c1.obj#||')') ;
      Warn := Warn + 1;
    End Loop;
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If ;
  End ;
--
  Procedure TabPartCountMismatch
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select o.obj#                   ,
             o.owner#                 ,
             o.name                   ,
             t.property               ,
             p.partcnt                ,
             Bitand(p.spare2,255) comp
      From   obj$   o,
             tab$   t,
             partobj$ p
      Where  o.type#               =  2                  /* table */
      And    Bitand(t.property,32) = 32      /* partitioned table */
      And    o.obj#                = t.obj#
      And    o.obj#                = p.obj#(+)
      And    o.dataobj# is null;
    Cursor sCur2 ( pobj In Number) Is 
      Select o.obj#    ,
             o.name    ,
             o.subname ,
             o.type#   ,
             o.owner#
      From   obj$ o    ,
             tabpart$ p
      Where  o.obj# = p.obj#
      And    p.bo#  = pobj;
    Cursor sCur3 ( obj In Number ) Is
      Select Count('x') Count 
        From tabcompart$ 
       Where bo#=obj;
    ps1  Varchar2(10) := 'HCKE-0009';
    ps1a Varchar2(65) := 'OBJ$-PARTOBJ$-TABPART$ mismatch';
    ps1n Varchar2(40) := '(Doc ID 1360514.1)';
    CursorRun Boolean := FALSE;
    nCnt Number       := Null;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('TabPartCountMismatch') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 In sCur1 Loop
      -- No Partitions
      If ( c1.partcnt Is Null ) Then
        If (ps1 Is Not Null) Then
            put_line('FAIL');
            CursorRun := TRUE ;
            put_line (chr(10)||ps1||': '||ps1a||' '||ps1n) ;
            ps1:=null;
        End If;
        put_line(
          ' OBJ$ has no PARTOBJ$ OBJ#='||c1.obj#||' NAME='||c1.name) ;
        Fatal := Fatal + 1 ;
      Else
        -- Not Composite
        If ( c1.comp=0 ) Then
          Select Count('x') Into nCnt From tabpart$ Where bo#=c1.obj# ;
          -- Interval Partitioned Tables have partcnt = 1048575
          If ( c1.partcnt != nCnt And c1.partcnt != 1048575 ) Then
            If (ps1 Is Not Null) Then
                put_line('FAIL');
                CursorRun := TRUE ;
                put_line (chr(10)||ps1||': '||ps1a||' '||ps1n) ;
                ps1:=null;
            End If;
            put_line(' PARTOBJ$ PARTCNT!=num TABPART$ rows OBJ#='||c1.obj#||
                ' NAME='||c1.name||' PARTCNT='||c1.partcnt||' CNT='||nCnt);
            Fatal := Fatal + 1 ;
          End If ;
          -- Check OBJ$ for the tabpart$ rows match up
          For c2 In sCur2 (c1.obj#) Loop
            If ( c2.name   != c1.name   Or
                 c2.owner# != c1.owner# Or
                 c2.type#  != 19 ) Then
              If (ps1 Is Not Null) Then
                  put_line('FAIL');
                  CursorRun := TRUE ;
                  put_line (chr(10)||ps1||': '||ps1a||' '||ps1n) ;
                  ps1:=null;
              End If;
              put_line(' TABPART$-OBJ$ mismatch (Bug:1273906)'||
                  ' OBJ#='||c2.obj#||
                  ' #'||c2.owner#||'.'||c2.name||' '||c2.subname);
              If ( c2.name != c1.name) Then
                 put_line(
                    '  - Table Name ('||c1.name||') != '||
                    ' Partition Name ('||c2.name||')' );
              End If ;
              If ( c2.owner# != c1.owner# ) Then
                  put_line('  - Table Owner# ('||c1.owner#||') != '||
                    ' Partition Onwer# ('||c2.owner#||')' );
              End If ;
              If ( c2.type# != 19 ) Then
                put_line('  - Partition Type# ('||c2.type#||')!=19' );
              End If ;
              Fatal := Fatal + 1 ;
            End If ;
          End Loop ;
        -- Hash Composite
        ElsIf ( c1.comp=2 ) Then
          For c3 in sCur3 ( c1.obj# ) Loop
            If ( c1.partcnt != c3.Count And c1.partcnt != 1048575 ) Then
              If (ps1 Is Not Null) Then 
                 put_line('FAIL');
                 put_line(ps1); 
                 ps1:=null; 
              End If;
              CursorRun := TRUE ;
              put_line(' PARTOBJ$ PARTCNT!=num TABCOMPART$ rows OBJ#='||
                  c1.OBJ#||
                  ' NAME='||c1.name||' PARTCNT='||c1.partcnt||' CNT='||
                  c3.Count);
               Fatal := Fatal + 1;
            End If;
          End Loop ;
        End If ;
      End If ;
    End Loop ;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End ;
--
  Procedure OrphanedTabComPart
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select t.obj# , t.bo#, b.name, p.name pname, p.subname, b.owner#
      From   tabcompart$ t, obj$ b, obj$ p
      Where  b.obj#(+) = t.bo#
      And    p.obj#(+) = t.obj#
      And    p.obj#+b.obj# Is Null;
    nFr  Number;
    ps1  Varchar2(10) := 'HCKE-0010';
    ps1a Varchar2(65) := 'Orphaned TABCOMPART$ from OBJ$';
    ps1n Varchar2(40) := '(Doc ID 1360515.1)';
    CursorRun Boolean := FALSE; 
  Begin
    If ( nF = 0) Then
      nFr := FindFname('OrphanedTabComPart') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line(' ORPHAN TABCOMPART$: OBJ='||c1.obj#||
            ' OBJ#Name='||c1.subname||' ('||c1.pname||')'||
            ' BO#='||c1.bo#||
            ' BO#name='||Owner(c1.owner#)||'.'||c1.name);
      Fatal := Fatal + 1;
    End Loop ; 
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If ;
  End;
--
  Procedure ZeroIndSubPart
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select sp.flags,sp.obj#, sp.ts#, sp.pobj#, b.name, b.subname, b.owner#
      From   indsubpart$ sp, obj$ b
      Where  sp.file#  = 0
      And    sp.block# = 0
      And    b.obj#(+) = sp.pobj#
      And    sp.dataobj# Is Not Null   /* A Physical object, Excludes IOT */
      And    bitand(sp.flags, 65536) != 65536 /* Exclude DEFERRED Segment */;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0011';
    ps1a Varchar2(65) := 'INDSUBPART$ has file# = 0' ;
    ps1n Varchar2(40) := '(Doc ID 1360516.1)';
    CursorRun Boolean := FALSE ; 
  Begin
    If ( nF = 0) Then
      nFr := FindFname('ZeroIndSubPart') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line(' ORPHAN INDSUBPART$: OBJ#='||c1.obj#||
              ' POBJ#='||c1.pobj#||
              ' Index='||Owner(c1.Owner#)||'.'||c1.name||
              ' Partn='||c1.subname);
      Fatal := Fatal + 1;
    End Loop ; 
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If ;
  End;
--
  Procedure MissingSum$
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select t.obj#,o.owner#,o.name
      From   tab$ t, obj$ o, sum$ s
      Where  bitand(t.flags,262144) = 262144    /* Container table */
      And    o.obj#                 = t.obj#
      And    s.containerobj#(+)     = t.obj#
      And    s.containerobj# Is Null;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0012';
    ps1a Varchar2(65) := 'SUM$ entry missing for container table';
    ps1n Varchar2(40) := '(Doc ID 1360517.1)';
    CursorRun Boolean := FALSE ;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('MissingSum$') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line(' TAB$ OBJ#='||c1.OBJ#||' '||Owner(c1.owner#)||'.'||c1.name);
      Fatal := Fatal + 1;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure MissingDir$
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select o.obj# o_obj, o.owner# o_owner, o.name o_name, d.obj# d_obj,
             oa.grantee# oa_grantee, oa.privilege# oa_priv, u.name u_name
      from   obj$ o, dir$ d, objauth$ oa, user$ u
      where  o.obj# = d.obj# (+)
      and    o.obj# = oa.obj# (+)
      and    o.owner# = u.user#
      and    o.type# = 23
      and    d.obj# is null
      and    decode(bitand(o.flags, 196608),
              65536, 'METADATA LINK', 131072, 'OBJECT LINK', 'NONE') = 'NONE';
    nFr  Number;
    ps1  Varchar2(10) := 'HCKE-0013';
    ps1a Varchar2(65) := 'DIR$ entry missing for directory objects';
    ps1n Varchar2(40) := '(Doc ID 1360518.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('MissingDir$') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line(' OBJ$ OBJ#='||c1.o_obj||' Owner='||c1.u_name||'.'||
             c1.o_name||' - Grantee('||c1.oa_grantee||') - Priv ('||
             c1.oa_priv||')');
      Fatal := Fatal + 1;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure DuplicateDataobj
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
    select s.segment_objd dataobj#, s.tablespace_name, s.owner, s.segment_name, s.segment_type
           ,s.partition_name
    from (select segment_objd, tablespace_name
          from   sys_dba_segs
          where  segment_objd > 0
            and  segment_objd is not null
            and  segment_type not in ('CLUSTER','ROLLBACK',
                                      'TYPE2 UNDO','DEFERRED ROLLBACK',
                                      'TEMPORARY','CACHE',
                                      'SPACE HEADER','UNDEFINED','HEATMAP')
          having count('x') > 1
          group by segment_objd, tablespace_name) many, sys_dba_segs s
    where s.segment_objd = many.segment_objd
      and s.tablespace_name = many.tablespace_name
    order by s.segment_objd;

    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0014';
    ps1n Varchar2(40) := '(Doc ID 1360519.1)';
    ps1a Varchar2(67) := 'Duplicate dataobj#';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('DuplicateDataobj') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('DATAOBJ#='||c1.dataobj#||' Tablespace='||c1.tablespace_name||
            ' Name='||c1.owner||'.'||c1.segment_name||
            ' Type='||c1.segment_type||' '||c1.partition_name) ;
      Fatal:=Fatal+1;
    End Loop ; 
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If ;
  End;
--
  Procedure ObjSynMissing
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select o.obj#, o.owner#, o.name
      From   obj$ o, syn$ s
      Where  o.type#    = 5
      And    o.obj#     = s.obj#(+)
      And    o.linkname Is Null      /* Not a remote object */
      And    s.obj#     Is Null
      And    decode(bitand(o.flags, 196608),
              65536, 'METADATA LINK', 131072, 'OBJECT LINK', 'NONE') = 'NONE';
    nFr  Number;
    ps1  Varchar2(10) := 'HCKW-0005';
    ps1a Varchar2(65) := 'SYN$ entry missing for OBJ$ type#=5';
    ps1n Varchar2(40) := '(Doc ID 1360520.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('ObjSynMissing') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('OBJ#='||c1.OBJ#||' Name='||Owner(c1.owner#)||'.'||
            c1.name);
      Warn := Warn + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure ObjSeqMissing
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select o.obj#, o.owner#, o.name
      From   obj$ o, seq$ s
      Where o.type#    = 6
      And   o.obj#     = s.obj#(+)
      And   o.linkname is null       /* Not remote */
      And   s.obj#     is null;
    nFr  Number;
    ps1  Varchar2(10) := 'HCKW-0006';
    ps1a Varchar2(65) := 'SEQ$ entry missing for OBJ$ type#=6' ;
    ps1n Varchar2(40) := '(Doc ID 1360524.1)';
    CursorRun Boolean := FALSE ;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('ObjSeqMissing') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('OBJ#='||c1.OBJ#||' Name='||Owner(c1.owner#)||'.'||
            c1.name);
      Warn := Warn + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure OrphanedUndo
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
     select u.us#,
            u.name,
            u.ts#,
            u.file#,
            u.block#,
            u.status$    
       from undo$ u, seg$ s
      where u.ts# = s.ts#    (+)
        and u.file# = s.file#  (+)
        and u.block# = s.block# (+)
        and u.status$ > 1
        and s.ts# is null;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0015';
    ps1a Varchar2(65) := 'Orphaned Undo$ (no SEG$)';
    ps1n Varchar2(40) := '(Doc ID 1360527.1)';
    CursorRun Boolean := FALSE ;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('OrphanedUndo') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('CRITICAL',ps1,ps1a,ps1n,CursorRun);
          critical := critical + 1;
      End If;
      put_line('ORPHAN UNDO$: US#='||c1.us#||
          ' NAME='||c1.name||
          ' RFILE/BLOCK='||c1.file#||'/'||c1.block#||
          ' STATUS$='||c1.status$);
      Fatal := Fatal + 1;
    End Loop ; 
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If;
  End;
--
  Procedure OrphanedIndex
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select i.obj#, i.dataobj#, i.ts#, i.file#, i.block#, i.bo#, s.type#
      From   seg$ s, ind$ i, obj$ o
      Where  i.ts#                 = s.ts#(+)
      And    i.file#               = s.file#(+)
      And    i.block#              = s.block#(+)
      And    Bitand(i.flags,4096)   != 4096   /* Exclude NOSEGMENT index */
      And    Bitand(i.flags,67108864) != 67108864 /* Exclude DEFERRED index */
      And    Bitand(i.property,64)  != 64     /* Exclude session-specific temp */
      And    Bitand(i.property,32)  != 32     /* Exclude temporay table index */
      And    Nvl(s.type#,0)         != 6
      And    i.dataobj# Is Not Null           /* ie: A Physical object */
      And    i.bo#=o.obj#
      And    Bitand(nvl(o.flags,0), 2) != 2   /* Exclude Index of TEMPORARY Object */;  

    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0016';
    ps1a Varchar2(65) := 'Orphaned IND$ (no SEG$)';
    ps1n Varchar2(40) := '(Doc ID 1360531.1)';
    CursorRun Boolean := FALSE;
    bo_temp Number;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('OrphanedIndex') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;

    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;

      put_line('ORPHAN IND$: OBJ='||c1.obj#||
           ' DOBJ='||c1.dataobj#||
           ' TS='||c1.TS#||
           ' RFILE/BLOCK='||c1.file#||'/'||c1.block#||
           ' INDEX='||ObjName(c1.obj#)||
           ' OF '||ObjName(c1.bo#,True)||
           ' BO#='||c1.bo#);
      If (c1.type# Is Not Null) Then
         report_segtype(c1.type#);
      End If;
      If (c1.TS#=0 and c1.file#=0 and c1.block#=0) Then
          put_line('^- May be OK. Needs manual check');
      End If ;
      Fatal := Fatal + 1;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure OrphanedIndexPartition
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select i.obj#, i.ts#, i.file#, i.block#, i.bo#, s.type#
      from   seg$ s, indpart$ i, ind$ p
      where  i.ts#=s.ts#(+)
      and    i.file#=s.file#(+)
      and    i.block#=s.block#(+)
      and    i.dataobj# is not null  /* A Physical object */
      and    i.bo# = p.obj#
      and    nvl(s.type#,0)!=6
      and    bitand(p.flags,4096)   != 4096  /* Exclude NOSEGMENT / Fake Index */
      and    bitand(i.flags, 65536) != 65536 /* Exclude DEFERRED Segment */;
    nFr  Number;
    ps1  Varchar2(10) := 'HCKE-0017';
    ps1a Varchar2(65) := 'Orphaned INDPART$ (no SEG$)';
    ps1n Varchar2(40) := '(Doc ID 1360535.1)';
    CursorRun Boolean := FALSE; 
  Begin
   If ( nF = 0) Then
       nFr := FindFname('OrphanedIndexPartition'); Else nFr := nF;
     End If ;
      
     If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
   For c1 in sCur1 Loop
      If (not CursorRun) Then
         report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('ORPHAN INDPART$: OBJ='||c1.obj#||
           ' TS='||c1.ts#||
           ' RFILE/BLOCK='||c1.file#||'/'||c1.block#||' '||
           ObjName(c1.obj#,True,True)||' '||
           ObjName(c1.bo#,True)||' BO#='||
           c1.bo#);
      If (c1.type# Is Not Null) Then
         report_segtype(c1.type#);
      End If;
      Fatal := Fatal + 1 ;
   End Loop ; 
     If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure OrphanedIndexSubPartition
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
    select i.obj#, i.ts#, i.file#, i.block#, i.pobj#, i.flags, s.type#
          from seg$ s, indsubpart$ i
         where i.ts#=s.ts#(+)
           and i.file#=s.file#(+)
           and i.block#=s.block#(+)
           and nvl(s.type#,0)!=6
           and bitand(i.flags, 65536) != 65536 /* Exclude DEFERRED Segment */;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0018';
    ps1a Varchar2(65) := 'Orphaned INDSUBPART$ (no SEG$)' ;
    ps1n Varchar2(40) := '(Doc ID 1360536.1)';
    CursorRun Boolean := FALSE ; 
  Begin
    If ( nF = 0) Then
      nFr := FindFname('OrphanedIndexSubPartition') ; Else nFr := nF;
    End If ;
    
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (ps1 Is Not Null) Then
          put_line('FAIL');
          CursorRun := TRUE ;
          put_line (chr(10)||ps1||': '||ps1a||' '||ps1n) ;
          ps1:=null;
      End If;

      put_line('ORPHAN INDSUBPART$: OBJ='||c1.obj#||
              ' TS='||c1.TS#||
              ' RFILE/BLOCK='||c1.file#||'/'||c1.block#||
              ' POBJ#='||c1.pobj#);
      If (c1.type# Is Not Null) Then
         report_segtype(c1.type#);
      End If;
      Fatal := Fatal + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure OrphanedTable
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select t.obj#, t.dataobj#, t.ts#, t.file#, t.block#, t.bobj#
             , s.type#
      From   seg$ s, tab$ t, obj$ o
      Where  t.ts#                  = s.ts#(+)
      And    t.file#                = s.file#(+)
      And    t.block#               = s.block#(+)
      And    Nvl(s.type#,0)        != 5
      And    Bitand(t.property,64) != 64    /* Exclude IOT) */
      And    Bitand(t.property,17179869184) != 17179869184 /* Exclude DEFERRED Segment */
      And    t.dataobj# is not null         /* A Physical object */
      And    t.obj#=o.obj#
      And    Bitand(nvl(o.flags,0), 2) != 2 /* Exclude TEMPORARY Segment */
      And    Bitand(t.property,2147483648) != 2147483648 /* Exclude External Tables */
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0019';
    ps1a Varchar2(65) := 'Orphaned TAB$ (no SEG$)';
    ps1n Varchar2(40) := '(Doc ID 1360889.1)';
    CursorRun Boolean := FALSE; 
  Begin
    If ( nF = 0) Then
      nFr := FindFname('OrphanedTable') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('ORPHAN TAB$: OBJ#='||c1.obj#||
          ' DOBJ#='||c1.dataobj#||
          ' TS='||c1.TS#||
          ' RFILE/BLOCK='||c1.file#||'/'||c1.block#||
          ' TABLE='||ObjName(c1.obj#) ||
          ' BOBJ#='||c1.bobj#);
      If (c1.type# Is Not Null) Then
         report_segtype(c1.type#);
      End If;
      If (c1.TS#=0 and c1.file#=0 and c1.block#=0) Then
        put_line('^- May be OK. Needs manual check');
      End If ;
      Fatal := Fatal + 1;
    End Loop; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure OrphanedTablePartition
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
        Select t.obj#, t.dataobj#, t.ts#, t.file#, t.block#, t.bo#, s.type#
          From sys.seg$ s, sys.tabpart$ t 
         Where t.ts#=s.ts#(+)
           And t.file#=s.file#(+)
           And t.block#=s.block#(+)
           And t.dataobj# > 0 /* A Physical Object. Exclude IOT (null) and Truncated IOT (0) */
           And Nvl(s.type#,0)!=5
           And Bitand(t.flags, 65536) != 65536 /* Exclude DEFERRED Segment */;
    nFr  Number;
    ps1  Varchar2(10) := 'HCKE-0020';
    ps1a Varchar2(65) := 'Orphaned TABPART$ (no SEG$)';
    ps1n Varchar2(40) := '(Doc ID 1360890.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('OrphanedTablePartition') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (Not IsIOT(c1.bo#)) Then
         If (not CursorRun) Then
             report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
         End If;
          put_line('ORPHAN TABPART$: OBJ='||c1.obj#||
                ' DOBJ='||c1.dataobj#||
                ' TS='||c1.ts#||
                ' RFILE/BLOCK='||c1.file#||'/'||c1.block#||' '||
                ObjName(c1.obj#,True,True)||' '||
                ObjName(c1.bo#,True)||' BO#='||c1.bo#);
          If (c1.type# Is Not Null) Then
             report_segtype(c1.type#);
          End If;
          If (c1.TS#=0 and c1.file#=0 and c1.block#=0) Then
              put_line('^- May be OK. Needs manual check');
          End If ;
          Fatal:=Fatal+1;
      End If;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure OrphanedTableSubPartition
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
       select tsp.obj#, tsp.ts#, tsp.file#, tsp.block#, tsp.pobj#
          from tabsubpart$ tsp, seg$ s
         where tsp.ts#    = s.ts#     (+)
           and tsp.file#  = s.file#   (+)
           and tsp.block# = s.block#  (+)
           and s.file# is null
           and tsp.dataobj# is not null          /* A Physical object */
           and bitand(tsp.flags, 65536) != 65536 /* Exclude DEFERRED Segment */
       ;

    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0021';
    ps1a Varchar2(65) := 'Orphaned TABSUBPART$ (no SEG$)';
    ps1n Varchar2(40) := '(Doc ID 1360891.1)';
    CursorRun Boolean := FALSE; 
  Begin
    If ( nF = 0) Then
      nFr := FindFname('OrphanedTableSubPartition') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('ORPHAN TABSUBPART$: OBJ='||c1.obj#||
              ' TS='||c1.TS#||
              ' RFILE/BLOCK='||c1.file#||'/'||c1.block#||
              ' POBJ#='||c1.pobj#);
      Fatal := Fatal + 1;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure MissingPartCol
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select tp.bo#, tp.obj#, tp.ts#, tp.file#, tp.block#, o.type#
      From   tabpart$ tp, partcol$ pc, obj$ o, partobj$ po 
      Where  tp.bo#   = pc.obj# (+)
      And    tp.bo#   = po.obj#
      And    po.partkeycols > 0
      And    tp.obj#  = o.obj#
      And    pc.obj# Is Null
    ;

    nFr  Number;
    ps1  Varchar2(10) := 'HCKE-0022';
    ps1a Varchar2(65) := 'Missing TabPart Column (no PARTCOL$ info)';
    ps1n Varchar2(40) := '(Doc ID 1360892.1)';
    CursorRun Boolean := FALSE; 
    Begin
      If ( nF = 0) Then
        nFr := FindFname('MissingPartCol') ; Else nFr := nF;
      End If ;
      
      If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            put_line('FAIL');
            CursorRun := TRUE ;
            put_line (chr(10)||ps1||': '||ps1a||' '||ps1n) ;
            ps1:=null;
        End If;
        put_line('MISSING PARTCOL$: OBJ='||c1.bo#||
              ' DOBJ='||c1.obj#||
              ' TS='||c1.ts#||
              ' RFILE/BLOCK='||c1.file#||'/'||c1.block#||
              ' SegType='||c1.type#);
        Fatal := Fatal + 1 ;
      End Loop ; 
      If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
    End;
--
  Procedure OrphanedSeg$
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select 'TYPE2 UNDO' typ, s.ts#, s.file#, s.block#
      From   seg$ s, undo$ u
      Where  s.ts#    = u.ts#(+)
      And    s.file#  = u.file#(+)
      And    s.block# = u.block#(+)
      And    s.type#  = 10
      And    Decode(u.status$,1,null,u.status$) Is Null
      UNION ALL
      Select 'UNDO' typ, s.ts#, s.file#, s.block#
      From   seg$ s, undo$ i
      Where  s.ts#    = i.ts#(+)
      And    s.file#  = i.file#(+)
      And    s.block# = i.block#(+)
      And    s.type#  = 1
      And    Decode(i.status$,1,null,i.status$) Is Null
      UNION ALL
      Select 'DATA' typ, s.ts#, s.file#, s.block#
      From   seg$ s,
      ( Select a.ts#,a.file#,a.block# From tab$ a
        UNION ALL
        Select b.ts#,b.file#,b.block# From clu$ b
        UNION ALL
        Select c.ts#,c.file#,c.block# From tabpart$ c
        UNION ALL
        Select d.ts#,d.file#,d.block# From tabsubpart$ d
      ) i
      Where s.ts#    = i.ts#(+)
      And   s.file#  = i.file#(+)
      And   s.block# = i.block#(+)
      And   s.type#  = 5
      And   i.file# Is Null
      UNION ALL
      Select 'INDEX' typ, s.ts#, s.file#, s.block#
      From seg$ s,
      ( Select a.ts#,a.file#,a.block# From ind$ a
        UNION ALL
        Select b.ts#,b.file#,b.block# From indpart$ b
        UNION ALL
        Select d.ts#,d.file#,d.block# From indsubpart$ d
      ) i
      Where  s.ts#    = i.ts#(+)
      And    s.file#  = i.file#(+)
      And    s.block# = i.block#(+)
      And    s.type#  = 6
      And    i.file# Is Null
      UNION ALL
      Select 'LOB' typ, s.ts#, s.file#, s.block#
      From   seg$ s, 
      ( Select a.ts#,a.file#,a.block# From lob$ a
        UNION ALL
        Select b.ts#,b.file#,b.block# From lobfrag$ b
       ) i
      Where  s.ts#    = i.ts#(+)
      And    s.file#  = i.file#(+)
      And    s.block# = i.block#(+)
      And    s.type#  = 8
      And    i.file# Is Null
    ;
    nFr  Number;
    ps1  Varchar2(10) := 'HCKE-0023';
    ps1a Varchar2(65) := 'Orphaned SEG$ Entry';
    ps1n Varchar2(40) := '(Doc ID 1360934.1)';
    CursorRun Boolean := FALSE;
    so_type Number ;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('OrphanedSeg$') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('ORPHAN SEG$: SegType='||c1.typ||
         ' TS='||c1.TS#||' RFILE/BLOCK='||c1.file#||'/'||c1.block#);
      Fatal := Fatal + 1;
    End Loop;
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If ;
  End;
--
  Procedure OrphanedIndPartObj#
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select i.obj#, i.ts#, i.file#, i.block#, i.bo#
      From   obj$ o, indpart$ i
      Where  o.obj#(+) = i.obj#
      And    o.obj# Is Null
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0024';
    ps1a Varchar2(65) := 'Orphaned Index Partition Obj# (no OBJ$)';
    ps1n Varchar2(40) := '(Doc ID 1360935.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('OrphanedIndPartObj#') ; Else nFr := nF;
    End If;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('ORPHAN INDPART$: OBJ#='||c1.obj#||' BO#='||c1.bo#||' - no OBJ$ row');
      Fatal := Fatal + 1;
    End Loop ; 
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If ;
  End;
--
  Procedure DuplicateBlockUse
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select ts#,file#,block#,count('x') CNT, min(typ) mintyp
      From
      (
        Select 'UNDO$' typ, u.ts#, u.file#, u.block# from undo$ u
        Where Decode(u.status$,1,null,u.status$) Is Not Null
        UNION ALL
        Select 'TAB$', a.ts#,a.file#,a.block# From tab$ a
        UNION ALL
        Select 'CLU$', b.ts#,b.file#,b.block# From clu$ b
        UNION ALL
        Select 'TABPART$', c.ts#,c.file#,c.block# From tabpart$ c
        UNION ALL
        Select 'TABSUBPART$', d.ts#,d.file#,d.block# From tabsubpart$ d
        UNION ALL
        Select 'IND$', a.ts#,a.file#,a.block# From ind$ a
        UNION ALL
        Select 'INDPART$', b.ts#,b.file#,b.block# From indpart$ b
        UNION ALL
        Select 'INDSUBPART$', d.ts#,d.file#,d.block# From indsubpart$ d
        UNION ALL
        Select 'LOB$' , i.ts#, i.file#, i.block# From lob$ i
        UNION ALL
        Select 'LOBFRAG$' , i.ts#, i.file#, i.block# From lobfrag$ i
        --  UNION ALL
        --  select 'RECYCLEBIN$' , i.ts#, i.file#, i.block# From recyclebin$ i
      )
      Where  block#    != 0
      Group  By ts#, file#, block#
      Having Count('x') > 1
      And    Min(typ)  != 'CLU$'  /* CLUSTER can have multiple entries */
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0025';
    ps1a Varchar2(65) := 'Block has multiple dictionary entries';
    ps1n Varchar2(40) := '(Doc ID 1360880.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('DuplicateBlockUse') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('MULTI DICT REF: TS='||c1.TS#||
            ' RFILE/BLOCK='||c1.file#||'/'||c1.block#||
            ' cnt='||c1.cnt);
      DictAt(c1.ts#, c1.file#, c1.block#);
      Fatal := Fatal + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure FetUet
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select ts#
      From   ts$
      Where  online$   != 3   /* Not INVALID        */
      And    bitmapped  = 0   /* Dictionary Managed */
    ;
    Cursor sCur2 (ts In Number) Is
               Select relfile#, blocks
               From   file$
               Where  ts#      = ts
               And    status$ != 1 
               ;
    Cursor sCur3 (ts In Number, fil In Number, len In Number) Is
               Select block#, length, 'FET$' typ
               From   fet$
               Where  ts#   = ts
               And    file# = fil
               UNION  ALL
               select block#, length, 'UET$' typ
               from   uet$
               where  ts#   = ts
               And    file# = fil
               Order  By 1 
               ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0028';
    ps1a Varchar2(65) := 'FET$ <-> UET$ Corruption';
    ps1n Varchar2(40) := '(Doc ID 1360882.1)';
    CursorRun Boolean := FALSE;
    BlkExpected Number       ;
    prev        sCur3%Rowtype;
    relfile     Number       ;
    blocks1     Number       ;
    blocks2     Number       ;
    len         Number       ; 
    typ         Varchar2(4)  ;
    Begin
      If ( nF = 0) Then
        nFr := FindFname('FetUet') ; Else nFr := nF;
      End If ;
      
      If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
      For c1 in sCur1 Loop
        For c2 in sCur2 (c1.ts#) Loop
          BlkExpected := 2 ;
          prev.typ := Null ; prev.block# := Null ; prev.length := Null ;
          For c3 in sCur3 (c1.ts#, c2.relfile#, c2.blocks) Loop
            If ( c3.block# != BlkExpected ) Then
              If (ps1 Is Not Null) Then
                  put_line('FAIL');
                  CursorRun := TRUE ;
                  put_line (chr(10)||ps1||': '||ps1a||' '||ps1n||' TS# = '||c1.ts#||
                      ' - rFil = '||c2.relfile#) ;
                  ps1:=null;
              End If;
            End If ;
            Case 
              When ( c3.block# = BlkExpected ) Then
                Null ;
              When ( c3.block# < BlkExpected ) Then
                put_line('OVERLAP: TS#='||c1.ts#||' RFILE='||c2.relfile#||
                    ' ('||prev.typ||' '||prev.block#||' '||prev.length||
                    ') overlaps ('||
                    c3.typ||' '||c3.block#||' '||c3.length||')');
                Fatal := Fatal + 1 ;
              When ( c3.block# > BlkExpected ) Then
                put_line('GAP    : TS#='||c1.ts#||' RFILE='||c2.relfile#||
                    ' ('||prev.typ||' '||prev.block#||' '||prev.length||
                    ') overlaps ('||
                    c3.typ||' '||c3.block#||' '||c3.length||')');
                Fatal := Fatal + 1 ;
            End Case ;
            prev := c3 ;
            BlkExpected := c3.block# + c3.length ;
          End Loop ;
          If ( BlkExpected-1 != c2.blocks ) Then
            If (ps1 Is Not Null) Then
                put_line('FAIL');
                CursorRun := TRUE ;
                put_line (chr(10)||ps1||': '||ps1a||' '||ps1n||' TS# = '||c1.ts#||
                    ' - rFil = '||c2.relfile#) ;
                ps1:=null;
            End If;
            If (BlkExpected-1>len) then
              put_line(' EXTENT past end of file: TS#='||c1.ts#||' RFILE='
                  ||c2.relfile#||' ('||prev.typ||' '||prev.block#||' '||
                  prev.length||') goes past end of file ('||c2.blocks||
                  ' blocks)');
            Else
              put_line(' EXTENT too short: TS#='||c1.ts#||' RFILE='||
              c2.relfile#||' ('||prev.typ||' '||prev.block#||' '||prev.length||
              ') does not reach end of file ('||c2.blocks||' blocks)');
            End If ;
          End If ;
        End Loop ;
      End Loop ; 
      If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
    End;
--
  Procedure Uet0Check
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select ts#, segfile#, segblock#, file#, block#
      From   uet$ 
      Where  ext# = 0
      And   (file# != segfile# Or block# != segblock#)
    ;
    nFr  Number;
    ps1  Varchar2(10) := 'HCKE-0029';
    ps1a Varchar2(65) := 'EXTENT 0 not at start of segment';
    ps1n Varchar2(40) := '(Doc ID 1360883.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('Uet0Check') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('TS#='||c1.ts#||
            ' '||c1.segfile#||','||c1.segblock#||' != '||
            c1.file#||','||c1.block#);
      Fatal := Fatal + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure ExtentlessSeg
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select s.ts#, s.file#, s.block#, s.type#
      From   seg$ s, uet$ u
      Where  s.ts#                      = u.ts#(+)
      And    s.file#                    = u.segfile#(+)
      And    s.block#                   = u.segblock#(+)
      And    bitand(NVL(s.spare1,0), 1) = 0 /* Not locally managed */
      And    u.ext#(+)                  = 0
      And    u.ts# Is Null                  /* no UET$ entry       */
      Order  By s.ts#, s.file#, s.block#;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0008';
    ps1a Varchar2(65) := 'SEG$ entry has no UET$ entries (Dictionary managed)';
    ps1n Varchar2(40) := '(Doc ID 1360944.1)';
    CursorRun Boolean := FALSE;
    tmp1 Varchar2(16) := Null;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('ExtentlessSeg') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      tmp1 := Null ;
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      If ( c1.type# = 9 ) Then
         tmp1 := ' (May Be Ok)' ;
      End If ;
      put_line('SEG$ has no UET$ entry: TS#='||c1.TS#||' RFILE#='||
            c1.file#||' BLK#='||c1.block#||' TYPE#='||c1.type#||tmp1);
      Warn := Warn + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure SeglessUET
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select u.ts#, u.segfile#, u.segblock#, Count('x') cnt, Min(ext#) minext#
      From   seg$ s, uet$ u
      Where  s.ts#(+)    = u.ts#
      And    s.file#(+)  = u.segfile#
      And    s.block#(+) = u.segblock#
      And    s.ts# Is Null              /* no SEG$ entry */
      Group  By u.ts#, u.segfile#, u.segblock#;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0009';
    ps1a Varchar2(65) := 'UET$ entry has no SEG$ entries (Dictionary managed)';
    ps1n Varchar2(40) := '(Doc ID 1360944.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('SeglessUET') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('UET$ has no SEG$ entry: TS#='||c1.TS#||' SegFILE#='||
            c1.segfile#||' SegBLK#='||c1.segblock#||' Count='||
            c1.cnt||' MinExt#='||c1.minext#);
      Warn := Warn + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure BadInd$
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select o.typ, o.obj#, o.name, o.owner#, decode(o.subname, null,null,' PARTITION='
             ||o.subname) subname
      From   (Select 'INDEX has no IND$' typ, b.obj#, b.name, b.owner#, b.subname 
                From ind$ a, obj$ b
                Where  b.type#=1 and b.obj#  = a.obj#(+) and a.obj# is null
              Union All
              Select 'INDEX PARTITION has no INDPART$' typ, b.obj#, b.name, b.owner#, 
                     b.subname 
                From indpart$ a, obj$ b
               Where b.type#=20 and b.dataobj# Is Not Null and b.obj#  = a.obj#(+) 
                 And a.obj# Is Null
              UNION ALL
              Select 'INDEX SUBPARTITION has no INDSUBPART$' typ, b.obj#, b.name, 
                     b.owner#, b.subname From indsubpart$ a, obj$ b
               Where b.type#=35 And b.obj#  = a.obj#(+) And a.obj# Is Null
              ) o;
    nFr  Number;
    ps1  Varchar2(10) := 'HCKE-0030';
    ps1a Varchar2(65) := 'OBJ$ INDEX entry has no IND$ or INDPART$/INDSUBPART$ entry';
    ps1n Varchar2(40) := '(Doc ID 1360528.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('BadInd$') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('OBJ$ '||c1.typ ||' entry: Obj#='||c1.obj#||' '||Owner(c1.owner#)||' Name='||c1.name
             ||c1.subname);
      Fatal := Fatal + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure BadTab$
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select o.obj#, o.name, o.owner#
      From   obj$ o, tab$ i
      Where  o.type# = 2     /* TABLE */
      And    o.obj#  = i.obj#(+)
      And    i.obj#     Is Null
      And    o.linkname Is Null;
    nFr  Number;
    ps1  Varchar2(10) := 'HCKE-0031';
    ps1a Varchar2(65) := 'OBJ$ TABLE entry has no TAB$ entry';
    ps1n Varchar2(40) := '(Doc ID 1360538.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('BadTab$') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('TABLE has no TAB$ entry: Obj='||c1.obj#||' '||
            Owner(c1.owner#)||'.'||c1.name);
      Fatal := Fatal + 1;
    End Loop ; 
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If ;
  End;
--
  Procedure BadIcolDepCnt
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select i.obj# , nvl(i.spare1,i.intcols) expect, ic.cnt got
      from ind$ i,
      (select obj#, count(*) cnt from icoldep$ group by obj# ) ic
      where ic.obj#=i.obj#
      and ic.cnt!=nvl(i.spare1,i.intcols)
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0032';
    ps1a Varchar2(65) := 'ICOLDEP$ count!=IND$ expected num dependencies';
    ps1n Varchar2(40) := '(Doc ID 1360938.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('BadIcolDepCnt') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('OBJ#='||c1.OBJ#||' '||ObjName(c1.obj#)||
            ' IND$ expects '||c1.expect||' ICOLDEP$ has '||c1.got);
      Fatal := Fatal + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure WarnIcolDep
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select adt.obj#,adt.icobj#, adt.intcol#,adt.name
      from
      ( select c.obj#, ic.obj# icobj#, c.intcol#, c.name
       from col$ c , icoldep$ ic
       where c.type#=121 /*index on ADT*/
        and c.obj#=ic.bo#
        and c.intcol#=ic.intcol#
      ) adt,
      (select c.obj#, c.intcol#, c.name , ic.obj# icobj#
        from col$ c , icoldep$ ic
        where bitand(c.property,33)=33        /* index on ADT attribute */
         and c.obj#=ic.bo#
         and c.intcol#=ic.intcol#
      ) adtattr
      where adt.obj#=adtattr.obj#             /* same table */
        and adt.icobj#=adtattr.icobj#         /* same index */
        and adt.intcol#+1 = adtattr.intcol#   /* likely same ADT/attr */
      order by 1,2
    ;
    nFr  Number;
    ps1  Varchar2(10) := 'HCKW-0010';
    ps1a Varchar2(65) := 'ICOLDEP$ may reference ADT and its attributes';
    ps1n Varchar2(40) := '(Doc ID 1360939.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('WarnIcolDep') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('Index OBJ#='||c1.ICOBJ#||' '||ObjName(c1.icobj#)||
            ' intcol#='||c1.intcol#||'='||c1.name);
      Warn := Warn + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure ObjIndDobj
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
-- Former name: ObjIndDobj
    Cursor sCur1 Is
      Select o.obj# OBJ#, u.name OWNER, o.name NAME,
             o.dataobj# O_ID, i.dataobj# I_ID
      From   user$ u, obj$ o, ind$ i
      Where  u.user#     = o.owner#
      And    o.type#     = 1             /* INDEX */
      And    o.obj#      = i.obj#
      And    o.dataobj# != i.dataobj#
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0033';
    ps1a Varchar2(65) := 'OBJ$.DATAOBJ# != IND.DATAOBJ#';
    ps1n Varchar2(40) := '(Doc ID 1360968.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('ObjIndDobj') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line(c1.owner||'.'||c1.name||' OBJ$.DATAOBJ#='||c1.o_id||
            'IND$.DATAOBJ#='||c1.i_id);
      Fatal := Fatal + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure DropForceType
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select u.name owner, o.name name , a.name attr
      From   user$ u, obj$ o, type$ t, attribute$ a, type$ att
      Where  u.user#                    = o.owner#
      And    o.oid$                     = t.toid
      And    o.type#                   != 10     -- must not be invalid
      And    Bitand(t.properties, 2048) = 0      -- not system-generated
      And    t.toid                     = a.toid
      And    t.version#                 = a.version#
      And    a.attr_toid                = att.toid(+)
      And    a.attr_version#            = att.version#(+)
      And    att.toid Is Null
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0034';
    ps1a Varchar2(65) := 'Bad ATTRIBUTE$.ATTR_TOID entries';
    ps1n Varchar2(40) := '(Doc ID 1360971.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('DropForceType') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line(c1.owner||'.'||c1.name||' ATTR_NAME='||c1.attr);
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure TrgAfterUpgrade
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select Count('x') cnt from trigger$
      where  sys_evts Is Null or nttrigcol Is Null
      Having Count('x') > 0;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0035';
    ps1a Varchar2(65) := 'TRIGGER$ has NULL entries - Count = ';
    ps1n Varchar2(40) := '(Doc ID 1361014.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('TrgAfterUpgrade') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a||c1.cnt,ps1n,CursorRun);
      End If;
      Fatal := Fatal + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure ObjType0
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select obj#, type#, name,namespace,linkname
      From   obj$
      Where  type#=0
      And    name!='_NEXT_OBJECT';
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0036';
    ps1a Varchar2(65) := 'Bad OBJ$ entry with TYPE#=0';
    ps1n Varchar2(40) := '(Doc ID 1361015.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('ObjType0') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('OBJ$ OBJ#='||c1.OBJ#||' TYPE#=0 NAME='||c1.name||' NAMESPACE='||c1.namespace
          ||' Dblink='||c1.linkname);
      Fatal := Fatal + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure ObjOidView
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
-- Former name: TypeReusedAfterDrop
    Cursor sCur1 Is
      Select o.obj#, owner#, name
      From   obj$ o, view$ v
      Where  o.type#              = 4
      And    v.obj#               = o.obj#
      And    Bitand(v.property,1) = 0
      And    o.oid$ Is Not Null;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0037';
    ps1a Varchar2(65) := 'OBJ$.OID$ set for a VIEW';
    ps1n Varchar2(40) := '(Doc ID 1361016.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('TypeReusedAfterDrop') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('OBJ$ OBJ#='||c1.OBJ#||' Owner='||Owner(c1.owner#)||
          ' NAME='||c1.name);
      Fatal := Fatal + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure Idgen1$TTS
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
     Select increment$ 
       From seq$ s , obj$ o
      Where o.name='IDGEN1$' 
        And owner#=0
        And s.obj#=o.obj#
        And increment$>50;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0011';
    ps1a Varchar2(65) := 'Sequence IDGEN1$ (INCREMENT_BY) too high' ;
    ps1n Varchar2(40) := '(Doc ID 1361017.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('Idgen1$TTS') ; Else nFr := nF;
    End If ;
    
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
    
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      Fatal := Fatal + 1;
    End Loop; 
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If ;
  End;
--
  Procedure DroppedFuncIdx
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select distinct u.name owner, o.name tab
      from   user$ u, obj$ o, col$ c
      where  o.type#                  = 2
      and    c.col#                   = 0
      and    Bitand(32768,c.property) = 32768
      and    o.obj#                   = c.obj#
      and    u.user#                  = o.owner#
      and    u.user#                 != 0
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0012';
    ps1a Varchar2(65) := 'Table with Dropped Func Index';
    ps1n Varchar2(40) := '(Doc ID 1361019.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('DroppedFuncIdx') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('Table='||c1.owner||'.'||c1.tab);
      Warn := Warn + 1 ;
    End Loop; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure BadOwner
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select obj#, type#, owner#, name
      From   obj$
      Where  owner# not in (Select user# From user$)
      And    type# != 10;

    nFr  Number;
    ps1  Varchar2(10) := 'HCKE-0038';
    ps1a Varchar2(65) := 'OBJ$.OWNER# not in USER$';
    ps1n Varchar2(40) := '(Doc ID 1361020.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('BadOwner') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('OBJ$ OBJ#='||c1.OBJ#||' TYPE='||nvl(ObjType(c1.type#), c1.type#)
               ||' NAME='
               || c1.name||' Owner#='||c1.OWNER#);
      Fatal := Fatal + 1 ;
    End Loop; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure StmtAuditOnCommit
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
-- Former Name UpgCheckc0801070
    Cursor sCur1 Is
      Select option#, Count('x')
      From   STMT_AUDIT_OPTION_MAP
      Where  option# = 229
      And    name    = 'ON COMMIT REFRESH'
      Group  By option#
      Having Count('x') > 0;
    nFr  Number;
    ps1  Varchar2(10) := 'HCKW-0013';
    ps1a Varchar2(65) := 'option# in STMT_AUDIT_OPTION_MAP(ON COMMIT REFRESH)';
    ps1n Varchar2(40) := '(Doc ID 1361021.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('StmtAuditOnCommit') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('-- Please run the following:') ;
      put_line('SQL> update STMT_AUDIT_OPTION_MAP set option#=234') ;
      put_line('     where name =''ON COMMIT REFRESH'';') ;
      put_line('SQL> commit;') ;
      Warn := Warn + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure BadPublicObjects
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select obj#,name,type#
      From   obj$
      Where  owner#=1
      And    type# not in (5,10,111,148);
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0014';
    ps1a Varchar2(65) := 'Objects owned by PUBLIC' ;
    ps1n Varchar2(40) := '(Doc ID 1361022.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('BadPublicObjects') ; Else nFr := nF;
    End If ;
    
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('OBJ$ OBJ#='||c1.OBJ#||' TYPE='||c1.type#||
               ' NAME='||c1.name);
      Warn := Warn + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure BadSegFreelist
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select s.ts#, s.file#, s.block#, type#, s.lists, s.groups,
             bitand(l.property, 2048) bitp2048
      From   seg$ s, lob$ l
      Where  s.ts#    = l.ts#(+)
      And    s.file#  = l.file#(+)
      And    s.block# = l.block#(+)
      And    (s.lists = 1 Or s.groups = 1);

    nFr  Number;
    ps1  Varchar2(10) := 'HCKW-0015';
    ps1a Varchar2(65) := 'SEG$ bad LISTS/GROUPS (==1)';
    ps1b Varchar2(80) := 'May be Ok for LOBSEGMENT/SECUREFILE';
    ps1n Varchar2(40) := '(Doc ID 1361023.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('BadSegFreelist') ; Else nFr := nF;
    End If ;
    
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
    
    For c1 in sCur1 Loop
      If ( c1.bitp2048 != 2048 ) Then
        If (not CursorRun) Then
            report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
            if ( nCatV > 1100000000 ) Then
              put_line (ps1b) ;
            End If ;
        End If;
        put_line('Bad SEG$ lists/groups : TS#='||c1.TS#||' RFILE#='||
            c1.file#||' BLK#='||c1.block#||' TYPE#='||c1.type#||
            ' Lists='||c1.lists||' Groups='||c1.groups) ;
        Warn := Warn + 1 ;
      End If ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure BadCol#
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select o.obj# , Max(intcol#) maxi, Max(col#) maxc
      From   sys.col$ o
      Group  By o.obj#
      Having Max(intcol#)>1000 Or max(col#)>999
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0039';
    ps1a Varchar2(65) := 'COL$ (INTCOL#/COL#) too high';
    ps1n Varchar2(40) := '(Doc ID 1361044.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('BadCol#') ; Else nFr := nF;
    End If ;
    
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
    
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('OBJ#='||c1.obj#||' max(intcol#)'||c1.maxi||
          ' max(col#)='||c1.maxc);
      Fatal := Fatal + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If ;
  End;
--
--------------------------------------------------------------------------------
--
  Procedure BadDepends
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select o.obj#          dobj        ,
             p.obj#          pobj        ,
             d.p_timestamp   p_timestamp ,
             p.stime         p_stime     ,
             o.type#         o_type      ,
             p.type#         p_type
      From   sys.obj$        o           ,
             sys.dependency$ d           ,
             sys.obj$        p
      Where  p_obj#   = p.obj# (+)
      And    d_obj#   = o.obj#
      And    o.status = 1                    /*dependent is valid*/
      And    o.subname is null                /*!Old TYPE version*/
      And    bitand(d.property, 1) = 1          /*Hard dependency*/
      And    p.status = 1                       /*parent is valid*/
      And    p.stime !=d.p_timestamp /*parent timestamp not match*/
      Order  By 2,1;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0016';
    ps1a Varchar2(65) := 'Dependency$ p_timestamp mismatch for VALID objects';
    ps1n Varchar2(40) := '(Doc ID 1361045.1)';
    CursorRun Boolean := FALSE;
    to_chk Varchar2 (4) ;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('BadDepends') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      If ( (c1.o_type = 5) and (c1.p_type = 29) ) Then
        to_chk := '[W]'  ;
      Else
        to_chk := '[E]' ;
      End If ;
      put_line(to_chk||' - P_OBJ#='||c1.pobj||' D_OBJ#='||c1.dobj);
      Warn := Warn + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure CheckDual
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select dummy From dual
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0017';
    ps1a Varchar2(65) := 'DUAL has more than one row' ;
    ps1b Varchar2(80) := 'DUAL does not contain ''X''' ;
    ps1n Varchar2(40) := '(Doc ID 1361046.1)';
    CursorRun Boolean := FALSE;
    n    Number       := 0 ;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('CheckDual') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      n := n + 1 ;
      If ( n > 1 ) Then
        If (ps1a Is Not Null) Then
           if (not CursorRun) then
              put_line('WARN');
           end if;
           CursorRun := TRUE ;
           put_line (chr(10)||ps1||': '||ps1a||' '||ps1n) ;
           ps1a:=null;
        End If;
        Warn := Warn + 1 ;
      End If ;
      If ( Nvl(c1.dummy,'Z') != 'X' ) Then
        If (ps1b Is Not Null) Then
           if (not CursorRun) then
              put_line('WARN');
           end if;
           CursorRun := TRUE ;
           put_line (chr(10)||ps1||': '||ps1b||' '||ps1n) ;
           ps1b:=null;
        End If;
        Warn := Warn + 1 ;
      End If ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure ObjectNames
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
    select username, object_type,
           Substr(owner||'.'||object_name,1,62) Name
    from   dba_objects, dba_users
    where  object_name = username
    and   (owner=username Or owner='PUBLIC');
    nFr  Number;
    ps1  Varchar2(10) := 'HCKW-0018';
    ps1a Varchar2(65) := 'OBJECT name clashes with SCHEMA name';
    ps1n Varchar2(20) := '(Doc ID 2363142.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('ObjectNames') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('Schema='||c1.username||' '||c1.object_type||'='||c1.name);
      Warn := Warn + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure BadCboHiLo
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select obj#,intcol#,lowval,hival from hist_head$ where lowval>hival
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0019';
    ps1a Varchar2(65) := 'HIST_HEAD$.LOWVAL > HIVAL' ;
    ps1n Varchar2(40) := '(Doc ID 1361047.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('BadCboHiLo') ; Else nFr := nF;
    End If ;
    
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('OBJ# '||c1.obj#||' INTCOL#='||c1.intcol#);
      Warn := Warn + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure ChkIotTs
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select o.owner#, o.obj# , o.name , t.ts#, t.file#, t.block#
      From   sys.obj$ o, sys.tab$ t
      Where  Bitand(t.property,64) = 64 /* Marked as an IOT */
      And    ts#                  != 0
      And    o.obj#                = t.obj#
    ;
    nFr  Number;
    ps1  Varchar2(10) := 'HCKW-0020';
    ps1a Varchar2(65) := 'IOT Tab$ has TS#!=0';
    ps1n Varchar2(40) := '(Doc ID 1361048.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('ChkIotTs') ; Else nFr := nF;
    End If ;
    
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('OBJ#='||c1.obj#||' ('||Owner(c1.owner#)||'.'||
          c1.name||') '||' TS#='||c1.ts#||' f='||c1.file#||' b='||c1.block#) ;
      Warn := Warn + 1 ;
    End Loop ; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure NoSegmentIndex
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select i.obj#, i.dataobj#, i.ts#, i.file#, i.block#, i.bo#, s.type#
      from   seg$ s, ind$ i
      where  i.ts#                = s.ts#(+)
      and    i.file#              = s.file#(+)
      and    i.block#             = s.block#(+)
      and    Bitand(i.flags,4096) = 4096  /* NOSEGMENT Fake index */
    ;
    nFr  Number;
    ps1  Varchar2(10) := 'HCKW-0021';
    ps1a Varchar2(65) := 'NOSEGMENT IND$ exists' ;
    ps1n Varchar2(40) := '(Doc ID 1361049.1)' ;
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('NoSegmentIndex') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('NOSEGMENT IND$: OBJ='||c1.obj#||
            ' DOBJ='||c1.dataobj#||
            ' TS='||c1.TS#||
            ' RFILE/BLOCK='||c1.file#||'/'||c1.block#||' '||
            ObjName(c1.obj#,True) ||' OF '||ObjName(c1.bo#,True)||
            ' BO#='||c1.bo#);
      If (c1.type# Is Not Null) Then
          put_line('^- PROBLEM: NOSEGMENT Index has a segment attached SegType='
                  || c1.type#);
      End If ;
      Warn := Warn + 1 ;
      if (c1.file#!=0 or c1.block#!=0) then
          put_line('^- Index has ts#/file#/block# set') ;
      end if;
      CheckIndPart (c1.obj#) ;
    End Loop; 
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure BadNextObject
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select case when dataobj# < maxobj then
                       '_NEXT_OBJECT dataobj#='||dataobj#||' LOWER than max(obj#)='||maxobj
                  when dataobj# < maxdataobj then
                       '_NEXT_OBJECT dataobj#='||dataobj#||' LOWER than max(dataobj#)='||maxdataobj
             end Check_Result
        from sys.obj$, (select max(obj#) maxobj, max(dataobj#) maxdataobj
                        from obj$) maxo
       where name = '_NEXT_OBJECT' 
         and type# = 0 
         and owner# = 0
         and dataobj# < greatest(maxobj,maxdataobj); 
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0040';
    ps1a Varchar2(65) := 'OBJ$ _NEXT_OBJECT entry too low' ;
    ps1n Varchar2(20) := '(Doc ID 2124772.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('BadNextObject') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line(c1.Check_Result);
      Fatal := Fatal + 1 ;
    End Loop ;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure OrphanIndopt
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select i.obj#, i.bind#, Count(*) cnt
      From   sys.indop$ i
      Where  i.property != 4
      Group  By i.obj#, i.bind#
      Having Count(*) > 1;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0041';
    ps1a Varchar2(65) := 'Binding w/ multiple dictionary entries';
    ps1n Varchar2(20) := '(Doc ID 2124773.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('OrphanIndopt') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('OBJ# '||c1.obj#||' - BIND# '||c1.bind#||
               '('||c1.cnt||')');
      Fatal := Fatal + 1;
    End Loop;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure UpgFlgBitTmp
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select s.user#, s.ts#, s.file#, s.block#
      From seg$ s
      Where Bitand(s.spare1,513) = 513;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKE-0042';
    ps1a Varchar2(80) := 'Segment Known != Temporary after upgrade';
    ps1n Varchar2(20) := '(Doc ID 2124780.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('UpgFlgBitTmp') ; Else nFr := nF;
    End If ;
     
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
     
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('USER#: '||c1.user#||' - TS# '||c1.ts#||' ('||c1.file#||
               '/'||c1.block#||')');
      Fatal := Fatal + 1;
    End Loop;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure RenCharView
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select u.name uname, o.name oname
      From   obj$ o, user$ u
      Where  o.type#= 4 
      And    o.spare1 = 0
      And    o.owner# = u.user#;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKW-0022';
    ps1a Varchar2(80) := 'Renamed VIEW w/ CHAR columns' ;
    ps1n Varchar2(20) := Null;
    bug1 Varchar2(80) := 
         'Ref    : Bug:2909084';
    aff1 Varchar2(80) := 'Affects: Vers >=8 and BELOW 10.1 - '||
         'Specifically: 8.1.7.4 9.2.0.3';
    fix1 Varchar2(80) := 
         'Fixed: 8.1.7.5 9.2.0.4 10.1.0.2';
    tag1 Varchar2(80) := 'CORR/DIC HCHECK '||ps1;
    not1 Varchar2(80) := 
         'Note: 2909084.8 - RENAME of a VIEW with CHAR column / wrong results' ;
    CursorRun Boolean := FALSE;
   Begin
     If ( nF = 0) Then
        nFr := FindFname('RenCharView') ; Else nFr := nF;
     End If ;
      
     If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
     For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('VIEW: '||c1.uname||'.'||c1.oname);
      Warn := Warn + 1; 
     End Loop;
     If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
   End;
--
  Procedure Upg9iTab$
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select To_char(spare6), Count('x') nTot
      From   tab$
      Where  To_char(spare6) = '00-000-00'
      Group  By To_char(spare6)
    ;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKW-0023';
    ps1a Varchar2(80) := 'TAB$ contains corrupt data after upgrade to 9i';
    ps1n Varchar2(20) := Null;
    bug1 Varchar2(80) := 
         'Ref    : Bug:3091612' ;
    aff1 Varchar2(80) := 'Affects: Vers >=9.0 and BELOW 10.1 - '||
         'Specifically: 9.2.0.4' ;
    fix1 Varchar2(80) := 
         'Fixed: 9.2.0.5 10.1.0.2' ;
    tag1 Varchar2(80) := 'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note: 3091612.8 - TAB$.SPARE6: corrupt data after upgrade to 9i';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('Upg9iTab$') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('Total number of entries wrong: '||c1.nTot);
      Warn := Warn + 1 ; 
    End Loop ;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure Upg9iTsInd
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select i.obj#, i.ts#, i.file#, i.block#, i.bo#
      From   ind$ i
      Where  ts# != 0
      And    bo# In (Select obj#
                     From   tab$
                     Where  Bitand(property, 12582912) != 0)
                     -- global           temporary table (0x00400000)
                     -- session-specific temporary table (0x00800000)
    ;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKW-0024';
    ps1a Varchar2(80) := 'Corrupt IND$ data for Global Temp Table Idx' ;
    ps1n Varchar2(20) := Null;
    bug1 Varchar2(80) := 'Ref    : Bug:3238525' ;
    aff1 Varchar2(80) := 'Affects: Vers >=9.2 and BELOW 10.1'||
         'Specifically: 9.2.0.3 9.2.0.5' ;
    fix1 Varchar2(80) := 'Fixed: 9.2.0.6 10.1.0.2';
    tag1 Varchar2(80) := 'CORR/DIC HCHECK '||ps1;
    not1 Varchar2(80) := 'Note: 3238525.8 - Corrupt IND$ data after upgrade';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
        nFr := FindFname('Upg9iTsInd') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('OBJ#='||c1.obj#||' TS#='||c1.ts#||' '||c1.file#||' '||c1.block#);
      Warn := Warn + 1 ; 
    End Loop ;
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If;
  End;
--
  Procedure Upg10gInd$
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select To_char(spare6), Count('x') nTot
      From   ind$
      Where  To_char(spare6) = '00-000-00'
      Group  By To_char(spare6)
    ;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKW-0025';
    ps1a Varchar2(80) := 'IND$ contains corrupt data after upgrade to 10g' ;
    ps1n Varchar2(20) := Null;
    bug1 Varchar2(80) := 'Ref    : Bug:4134141' ;
    aff1 Varchar2(80) := 'Affects: Vers >=10.1 and BELOW 10.2'||
         'Specifically: 10.1.0.4' ;
    fix1 Varchar2(80) := 
         'Fixed: 10.1.0.5 10.2.0.1' ;
    tag1 Varchar2(80) := 'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 'Note: 842957.1 - EXPDP Fails With ORA-1801 During Schema Export' ;
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('Upg10gInd$') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
     If (not CursorRun) Then
         report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
     End If;
     put_line('Total number of entries wrong: '||c1.nTot);
     Warn  := Warn  + 1 ; 
    End Loop ;
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If;
  End;
--
  Procedure DroppedROTS
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select t.ts#, t.name, f.file#
      From   ts$ t, file$ f
      Where  t.ts# = f.ts# (+)
      And    t.online$ = 4
      And    f.file# Is Null;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKE-0043';
    ps1a Varchar2(80) := 'Dictionary inconsistency for dropped RO tablespace';
    ps1n Varchar2(20) := '(Doc ID 2124774.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('DroppedROTS'); Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
         report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('TS='||c1.ts#||'('||c1.name||')');
      Fatal := Fatal + 1;
    End Loop ;
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If;
  End;
--
  Procedure ChrLenSmtcs
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select obj#, name, property, spare3, length
      From   col$
      Where  Bitand(property,8388608)!=0
      And    type#=23;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKW-0026';
    ps1a Varchar2(80) := 'NLS_LENGTH_SEMANTICS / RAW after upgrade' ;
    ps1n Varchar2(20) := Null;
    bug1 Varchar2(80) := 
         'Ref    : Bug:4638550' ;
    aff1 Varchar2(80) := 'Affects: Vers BELOW 11.1 - '||
         'Specifically: 10.2.0.2' ;
    fix1 Varchar2(80) := 
         'Fixed: 10.2.0.3 11.1.0.6' ;
    tag1 Varchar2(80) := 'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note: 4638550.8 - OERI[dmlsrvColLenChk_2:dty] on upgrade from 9.2' ;
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('ChrLenSmtcs') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
         report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('OBJ#='||c1.obj#);
      Warn := Warn + 1 ; 
    End Loop ;
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If;
  End;
--
  Procedure FilBlkZero
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
     Select t_i.typ, t_i.ts#, t_i.file#, t_i.block#, t_i.obj#
      From
      (
        Select 'TABLE' typ, t.ts#, t.file#, t.block#, t.obj# from tab$ t
        Where  bitand(t.property,64) != 64    /* Exclude IOT) */
	  And  bitand(t.property,17179869184) != 17179869184    /* Exclude DEFERRED Segment */
	  And  t.dataobj# is not null         /* A Physical object */
        Union All
        Select 'INDEX' typ, i.ts#, i.file#, i.block#, i.obj# from ind$ i
        Where  Bitand(i.flags,4096) != 4096         /* Exclude NOSEGMENT index */
	And    Bitand(i.flags,67108864) != 67108864 /* Exclude DEFERRED index */
	And    i.dataobj# Is Not Null               /* A Physical object   */
      ) t_i   ,
        ts$ t ,
        obj$ o
        Where t_i.ts#=t.ts#
        And   t.name not in ('SYSTEM','SYSAUX')
        And   t_i.file#  = 0
        And   t_i.block# = 0
        And   t_i.obj#   = o.obj#
        And   o.flags   != 2  /* Exclude TEMP segment */;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKE-0044';
    ps1a Varchar2(80) := 'Object has zeroed file/block Information';
    ps1n Varchar2(20) := '(Doc ID 2124783.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('FilBlkZero') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
         report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line(c1.typ||'='||ObjName(c1.obj#)||' OBJ#='||c1.obj#||
               ' TS#='||c1.ts#||' '||TSName(c1.ts#));
      Fatal := Fatal + 1 ; 
    End Loop ;
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If;
  End;
--
  Procedure DbmsSchemaCopy
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select o.obj#, u.name owner, o.name object
      from   obj$ o, user$ u
      where  o.owner# = u.user#
      and    o.type# in (4,5,6,7,8,9,11)
      and    o.subname='CLONE_USE';
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKE-0045';
    ps1a Varchar2(80) := '"DBMS_SCHEMA_COPY" - Failed Execution';
    ps1n Varchar2(20) := '(Doc ID 2124795.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('DbmsSchemaCopy') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
         report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('OBJ#='||c1.obj#||' - '||c1.owner||'.'||c1.object);
      Fatal := Fatal + 1;
     End Loop ;
     If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If;
  End;
--
  Procedure OrphanedIdnseqObj
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0046';
    ps1a Varchar2(65) := 'Orphaned Idnseq$ Obj# (no OBJ$)' ;
    ps1n Varchar2(20) := '(Doc ID 2124805.1)';

    Type genericcurtyp Is Ref Cursor;
    c1 genericcurtyp;
    objn number;
    tabobjn number;

    CursorRun Boolean := FALSE; 

  Begin
    If ( nF = 0) Then
      nFr := FindFname('OrphanedIdnseqObj') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk, TRUE) = FALSE Then Return; End If;
      
    Open c1 for
             'Select i.seqobj#, i.obj#
              From   obj$ o, idnseq$ i
              Where  o.obj#(+) = i.seqobj#
              And    o.obj# Is Null';
    Loop
      Fetch c1 Into objn, tabobjn;
      Exit When c1%Notfound;
      If (not CursorRun) Then
         report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('ORPHAN IDNSEQ$: SEQOBJ#='||objn||' - no OBJ$, TABLE='||ObjName(tabobjn)
               ||' (OBJ#='||tabobjn||')');
      Fatal := Fatal + 1 ;
    End Loop ;
    Close c1;
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If;
  End;
--
  Procedure OrphanedIdnseqSeq
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0047';
    ps1a Varchar2(65) := 'Orphaned Idnseq$ Obj# (no SEQ$)' ;
    ps1n Varchar2(20) := '(Doc ID 2124787.1)';
    CursorRun Boolean := FALSE ;

    Type genericcurtyp IS Ref Cursor;
    c1 genericcurtyp;
    objn number;
    tabobjn number;

  Begin
    If ( nF = 0) Then
      nFr := FindFname('OrphanedIdnseqSeq') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk, TRUE) = FALSE Then Return; End If;
      
    Open c1 For
     'Select i.seqobj#, i.obj#
      From   seq$ s, idnseq$ i
      Where  s.obj#(+) = i.seqobj#
      And    s.obj# Is Null';

    Loop
      Fetch c1 Into objn, tabobjn;
      Exit When c1%Notfound;
      If (not CursorRun) Then
         report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('ORPHAN IDNSEQ$: SEQOBJ#='||objn||' - no SEQ$, TABLE='||ObjName(tabobjn)
               ||' (OBJ#='||tabobjn||')');
      Fatal := Fatal + 1;
    End Loop ;
    Close c1;
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If;
  End;
--
  Procedure OrphanedObjError
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0048';
    ps1a Varchar2(65) := 'ORPHAN OBJ$ not in OBJERROR$';
    ps1n Varchar2(20) := '(Doc ID 2124788.1)';
    CursorRun Boolean := FALSE; 

    Type genericcurtyp Is Ref Cursor;
    c1 genericcurtyp; 
    objn Number;
    objectname obj$.name%Type;
    ownerid Number;
    typeid Number;

  Begin
    If ( nF = 0) Then
      nFr := FindFname('OrphanedObjError') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk, TRUE) = FALSE Then Return; End If;
      
      
    Open c1 For
      'Select o.obj#, o.name, o.owner#, o.type#
       From   obj$ o, objerror$ e
       Where  bitand(o.flags,32768) = 32768
       And    o.obj# = e.obj#(+)
       And    o.linkname Is Null
       And    e.obj# Is Null';

    Loop
      Fetch c1 Into objn,objectname,ownerid,typeid;
      Exit When c1%Notfound;
      If (not CursorRun) Then
         report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('ORPHAN OBJ$: OBJ='||objn
            ||' '||ObjType(typeid)||'='
            || Owner(ownerid)||'.'||objectname
            ||' NOT in OBJERROR$') ;
      Fatal := Fatal + 1 ;
    End Loop ;
    Close c1;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End ;
--
  Procedure ObjNotLob
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select o.obj#,
             Decode(o.type#, 21, 'LOB',
                             40, 'LOB PARTITION',
                             41, 'LOB SUBPARTITION') typ,
             Decode(o.type#, 21, 'LOB$', 'LOBFRAG$') whichtab,
             o.name,decode(o.SUBNAME,NULL,NULL,'Partition: '||o.subname) subname, u.name owner
      From   obj$ o,  user$ u,
               ( Select a.lobj# obj# From lob$ a
                  UNION ALL
                 Select b.FRAGOBJ# obj# From lobfrag$ b -- for partition and subpartition
                  UNION ALL
                 Select c.PARENTOBJ# obj# From lobfrag$ c -- for partition with subpartition
               ) l
      Where o.type# in (21,40,41)
        And o.obj# = l.obj#(+)
        And l.obj# Is Null
        And o.owner#=u.user#
        And o.linkname Is Null;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0049';
    ps1a Varchar2(65) := 'OBJ$ LOB entry has no LOB$ or LOBFRAG$ entry';
    ps1n Varchar2(40) := '(Doc ID 2125104.1)' ;
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('ObjNotLob') ; Else nFr := nF;
    End If ;
      
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
      
    For c1 in sCur1 Loop
      If (not CursorRun) Then
         report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('OBJ$ '||c1.typ||' has no '||c1.whichtab|| ' entry: Obj='||c1.obj#||
             ' Owner: '|| c1.owner||' LOB Name: '||c1.name||' '||c1.subname);
      Fatal := Fatal + 1 ;
    End Loop ;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure MaxControlfSeq
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
    Select cseq
    From (Select Max(FHCSQ) cseq
          From   x$kcvfh) a
    Where Trunc(cseq/4294967295,1) = 0.9;

    nFr  Number;
    ps1  Varchar2(10) := 'HCKE-0050';
    ps1a Varchar2(65) := 'Control Seq is near to limit 4294967295';
    ps1n Varchar2(40) := '(Doc ID 2128446.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('MaxControlfSeq') ; Else nFr := nF;
    End If ;

    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;

    For c1 in sCur1 Loop
      If (not CursorRun) Then
         report_failure('CRITICAL',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line('Max Control Seq in Datafile Headers: '||c1.cseq
               ||' Hex: 0x'||ltrim(to_char(c1.cseq,'xxxxxxxx')));
      Critical := Critical + 1;
      Fatal := Fatal + 1 ;
    End Loop ;
    If (CursorRun) Then put(chr(10)) ; else put_line('PASS'); End If ;
  End;
--
  Procedure SegNotInDeferredStg
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0051';
    ps1a Varchar2(65) := 'Deferred Segment not in DEFERRED_STG$' ;
    ps1n Varchar2(20) := '(Doc ID 2298947.1)';
    CursorRun Boolean := FALSE ;

    objn Number;
    bobjn Number;
    objt Varchar2(60);
    message Varchar2(4000);

    TYPE genericcurtyp IS REF CURSOR;
    C1 genericcurtyp;

  Begin
    If ( nF = 0) Then
      nFr := FindFname('OrphanedDeferredStg') ; Else nFr := nF;
    End If ;

    If ChecknCatVnFR (nCatV, nFr, VerChk, TRUE) = FALSE Then Return; End If;

    Open C1 for
     'Select ''INDEX'', i.obj#, i.bo# 
      From deferred_stg$ d, ind$ i 
      Where  bitand(i.flags, 67108864) = 67108864
        And  d.obj#(+) = i.obj#
        And  d.obj# is null
      UNION ALL
      Select ''TABLE'', t.obj#, null bo#
      From deferred_stg$ d, tab$ t 
      Where  bitand(t.property, 17179869184) = 17179869184
        And  bitand(t.property, 64) != 64
        And  d.obj#(+) = t.obj#
        And  d.obj# is null
      UNION ALL
      Select ''TABLE PARTITION'', t.obj#, t.bo# 
      From deferred_stg$ d, tabpart$ t 
      Where  bitand(t.flags, 65536) = 65536
        And  d.obj#(+) = t.obj#
        And  d.obj# is null
      UNION ALL  
      Select ''LOB'', l.lobj#, l.obj# bo#
      From deferred_stg$ d, lob$ l
      Where  bitand(l.property, 4096) = 4096
        And  d.obj#(+) = l.lobj#
        And  d.obj# is null';

    Loop
      Fetch c1 Into objt,objn,bobjn;
      Exit When c1%Notfound;
      If (not CursorRun) Then
         report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
        
      If (objt = 'TABLE PARTITION') Then
          message := ObjName(objn,True,True);
      Else
         message := ObjName(objn,True);
      End If;
      If (objt != 'TABLE') Then
         message := message  
           || ' OF '
           ||ObjName(bobjn,True);
      End If;
      put_line('OBJ#='||objn||' '||message||
            ' - no DEFERRED_STG$ row');
      Fatal := Fatal + 1;
    End Loop ;
    Close c1;
    If (CursorRun) Then put(chr(10)); Else put_line('PASS'); End If;
  End;
--
  Procedure SystemNotRfile1
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
        Select Count('x')
          From dba_data_files
          Where tablespace_name = 'SYSTEM'
            And relative_fno=1
         Having count('x') = 0;
    nFr  Number;
    ps1  Varchar2(10) := 'HCKW-0027';
    ps1a Varchar2(65) := 'System Tablespace does not have relative file number of 1';
    ps1n Varchar2(40) := '(Doc ID 2364065.1)' ;
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('SystemNotRfile1'); Else nFr := nF;
    End If ;
    If ChecknCatVnFR (nCatV, nFr, VerChk, TRUE) = FALSE Then Return; End If;

    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      Warn := Warn + 1 ;
    End Loop ;
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If ;
  End;
--
  Procedure DictOwnNonDefaultSYSTEM
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
        Select username, default_tablespace
          From dba_users
         Where username in ('SYS', 'SYSTEM')
           And default_tablespace != 'SYSTEM';
    nFr  Number;
    ps1  Varchar2(10) := 'HCKW-0028';
    ps1a Varchar2(65) := 'Dictionary owner has not default tablespace SYSTEM';
    ps1n Varchar2(40) := '(Doc ID 2377270.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('DictOwnNonDefaultSYSTEM'); Else nFr := nF;
    End If ;
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('WARN',ps1,ps1a,ps1n,CursorRun);
      End If;
      put_line(c1.username ||' user has Default Tablespace '||c1.default_tablespace);
      put_line('-- Please run the following:') ;
      put_line('-- SQL> alter user ' ||c1.username||' default tablespace SYSTEM;') ;
      Warn := Warn + 1 ;
    End Loop ;
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If ;
  End;
--
  Procedure OrphanTrigger
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
        Select obj#, baseobject,'Schema' ttype, 'no USER$' orphandesc, 'USER#' tcolumn
          From sys.trigger$ t, sys.user$ u
         Where bitand(t.property,16) = 16
           And t.baseobject = u.user#(+)
           And u.user# Is Null;
    nFr  Number;
    ps1  Varchar2(10) := 'HCKE-0052';
    ps1a Varchar2(65) := 'Orphan Trigger';
    ps1n Varchar2(40) := '(Doc ID 2384373.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('OrphanTrigger'); Else nFr := nF;
    End If ;
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      Fatal := Fatal + 1;
      put_line('ORPHAN '|| c1.ttype||' Trigger ('
              || c1.orphandesc|| ') OBJ#='||c1.obj#
              ||' '||ObjName(c1.obj#)|| ' ' ||c1.tcolumn||'='||c1.baseobject
              ||'(non-existent)');
    End Loop;
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If ;
  End;
--
  Procedure ObjNotTrigger
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
        Select o.obj#, owner#, name
          From sys.obj$ o, sys.trigger$ t
         Where o.type# = 12 
           And o.obj# = t.obj#(+) 
           And t.obj# Is Null;
    nFr  Number;
    ps1  Varchar2(10) := 'HCKE-0053';
    ps1a Varchar2(65) := 'OBJ$ has no TRIGGER$ entry';
    ps1n Varchar2(40) := '(Doc ID 2384392.1)';
    CursorRun Boolean := FALSE;
  Begin
    If ( nF = 0) Then
      nFr := FindFname('ObjNotTrigger'); Else nFr := nF;
    End If;
    If ChecknCatVnFR (nCatV, nFr, VerChk) = FALSE Then Return; End If;
    For c1 in sCur1 Loop
      If (not CursorRun) Then
          report_failure('FAIL',ps1,ps1a,ps1n,CursorRun);
      End If;
      Fatal := Fatal + 1;
      put_line('OBJ$ has no TRIGGER$ entry: OBJ#='||c1.obj#||' Owner='
              || Owner(c1.owner#)|| ' Trigger='||c1.name
              );
    End Loop;
    If (CursorRun) Then put(chr(10)); else put_line('PASS'); End If ;
  End;
--
-- Main
--
  Procedure Full (Verbose In Boolean Default FALSE,
                  VerChk  In Number  Default 5) Is
    FnIdx        Number := 0 ;
    nvc          Number ;
    stmt         Varchar2(80) := Null ;
    sV           Varchar2 (6) := 'FALSE' ;
    dbname       Varchar2(32);
    STimeStamp   Date;
    ETimeStamp   Date;
    iscdb        Varchar2(3);
    conid        Number;
    cdbname      Varchar2(32);
    
  Begin
    Fatal  := 0 ;                    /* Number Of Fatal Errors */
    Warn   := 0 ;                    /* Number Of Warnings     */
--
--  number of fields in the release to check against
--  can never be > 5 or < 1
--
    nvc := VerChk ;

    If ( VerChk > 5 Or VerChk < 1 ) Then
      nvc := 5 ; 
    End If ;
    sF    := InitsF(null,nvc) ;
--
-- Get Catalog Version (Both String and Number)
--
    Select sysdate, name 
    Into   STimeStamp, dbname
    From   v$database;

    put_line('HCheck Version '||Ver||' on '||to_char(STimeStamp, 'DD-MON-YYYY HH24:MI:SS'));
    put_line('----------------------------------------------') ;
    put_line('Catalog Version '||Lpad(CatV,10,' ')||' '||
        Lpad( '('||To_char(nCatV)||')', 12, ' '));
    put_line('db_name: '||dbname);

    /* Is Multitenant configured? */
    If nCatV > 1201000000 Then
       execute immediate 'Select  decode(Sys_Context(''Userenv'', ''CDB_NAME'')
                                         ,null,''NO'',''YES''), 
                                  Sys_Context(''Userenv'', ''CON_ID''), 
                                  Sys_Context(''Userenv'', ''CON_NAME'') 
                          From dual' 
                          Into iscdb, conid, cdbname;
       if iscdb = 'YES' Then
          put_line('Is CDB?: '||iscdb||' CON_ID: '||conid||' Container: '||cdbname);
       Else
          put_line('Is CDB?: '||iscdb);
       End If;
    End If;

     If ( Verbose ) Then
      put_line('Running in Verbose mode ...') ;
      sV := 'TRUE' ;
    End If ;
    put(chr(10));
    put_line('                                   Catalog   '||
        '    Fixed           ') ;
    put_line('Procedure Name                     Version   '||
        ' Vs Release    Timestamp      Result') ;
    put_line('------------------------------ ... ----------'||
        ' -- ---------- -------------- ------') ;
--
-- Call All Defined Procedures
--
   SynLastDDLTim             (1);
   LobNotInObj               (2);
   MissingOIDOnObjCol        (3);
   SourceNotInObj            (4);
   IndIndparMismatch         (5);
   InvCorrAudit              (6);
   OversizedFiles            (7);
   TinyFiles                 (8);
   PoorDefaultStorage        (9);
   PoorStorage              (10);
   MissTabSubPart           (11);
   PartSubPartMismatch      (12);
   TabPartCountMismatch     (13);
   OrphanedTabComPart       (14);
   ZeroIndSubPart           (15);
   MissingSum$              (16);
   MissingDir$              (17);
   DuplicateDataobj         (18);
   ObjSynMissing            (19);
   ObjSeqMissing            (20);
   OrphanedUndo             (21);
   OrphanedIndex            (22);
   OrphanedIndexPartition   (23);
   OrphanedIndexSubPartition(24);
   OrphanedTable            (25);
   OrphanedTablePartition   (26);
   OrphanedTableSubPartition(27);
   MissingPartCol           (28);
   OrphanedSeg$             (29);
   OrphanedIndPartObj#      (30);
   DuplicateBlockUse        (31);
   FetUet                   (32);
   Uet0Check                (33);
   ExtentlessSeg            (34);
   SeglessUET               (35);
   BadInd$                  (36);
   BadTab$                  (37);
   BadIcolDepCnt            (38);
   WarnIcolDep              (39);
   ObjIndDobj               (40);
   DropForceType            (41);
   TrgAfterUpgrade          (42);
   ObjType0                 (43);
   ObjOidView               (44);
   Idgen1$TTS               (45);
   DroppedFuncIdx           (46);
   BadOwner                 (47);
   StmtAuditOnCommit        (48);
   BadPublicObjects         (49);
   BadSegFreelist           (50);
   BadCol#                  (51);
   BadDepends               (52);
   CheckDual                (53);
   ObjectNames              (54);
   BadCboHiLo               (55);
   ChkIotTs                 (56);
   NoSegmentIndex           (57);
   BadNextObject            (58);
   OrphanIndopt             (59);
   UpgFlgBitTmp             (60);
   RenCharView              (61);
   Upg9iTab$                (62);
   Upg9iTsInd               (63);
   Upg10gInd$               (64);
   DroppedROTS              (65);
   ChrLenSmtcs              (66);
   FilBlkZero               (67);
   DbmsSchemaCopy           (68);
   OrphanedIdnseqObj        (69);
   OrphanedIdnseqSeq        (70);
   OrphanedObjError         (71);
   ObjNotLob                (72);
   MaxControlfSeq           (73);
   SegNotInDeferredStg      (74);
   SystemNotRfile1          (75);
   DictOwnNonDefaultSYSTEM  (76);
   OrphanTrigger            (77);
   ObjNotTrigger            (78);
--
   put_line('---------------------------------------') ;
   Select sysdate
   Into   ETimeStamp
   from  dual;
   put_line(to_char(ETimeStamp, 'DD-MON-YYYY HH24:MI:SS') || '  Elapsed: '
            || to_char(round((ETimeStamp-STimeStamp)*24*60*60)) || ' secs');
   put_line('---------------------------------------') ;
  
--
    put_line('Found '||Fatal||' potential problem(s) and '||warn||' warning(s)');
    new_line;
    If (Critical > 0) Then
       put_line('Found '||Critical||' CRITICAL problem(s) needing attention'); 
       new_line;
    End If;

    If (Fatal > 0 Or Warn > 0) Then
      put_line('Contact Oracle Support with the output and trace file');
      put_line('to check if the above needs attention or not');
    Elsif iscdb = 'YES' And cdbname = 'CDB$ROOT' Then
      new_line;
      put_line('Note that hcheck has been run on CDB$ROOT, consider to run it in each PDB');
    End If;
  End ; 
begin
  dbms_output.enable(100000);
-- Execute all checks:
  Full;
End hcheck ;
/

REM Trace file:
oradebug setmypid
prompt
prompt Complete output is in trace file:
oradebug tracefile_name
prompt