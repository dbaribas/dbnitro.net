-- executing user must have select ANY TABLE privilege, best use with SYSTEM user
---------------Output into a html-file-------------------------------------------------------------------------------
-- exlude SQL text
set feedback off echo off numwidth 20
var hide_sql varchar2(3);
--- exec select decode('&1', 'nosql', 'Y', 'N') into :hide_sql from dual;
exec select decode('1', 'nosql', 'YES', 'NO') into :hide_sql from dual;
---SQL*Plus Settings -----------------------------------------------------------------------------------------
set timing off trimspool on feedback off echo off heading off linesize 1000 long 800 verify off define off serveroutput on size unlimited numwidth 20
---Parameter Settings ----------------------------------------------------------------------------------------
-- how many days in the past
var days_back number;
-- needs to replaced by cmd line parameter later on
exec :days_back := 7;
-- keep Starttime -----------------------------------------------------------------------------------------
var starttime varchar2(30)
exec :starttime := to_char(sysdate,'dd/mm/yyyy hh24:mi:ss');
exec dbms_application_info.set_module('DBACheck DB Report', 'Start');
--- Settings for queries-----------------------------------------------------------------------------------------
-- number of Logswitches (warning)
var redo_warn number
-- number of Logswitches (critical)
var redo_critical number
-- MB Redolog (warning)
var redo_warn_mb number
-- MB Redolog (critical)
var redo_critical_mb number
-- % MB Redolog (waring)
var redo_warn_mb_pct number
-- % MB Redolog (waring)
var redo_critical_mb_pct number
exec :redo_warn := 10;
exec :redo_critical := 20;
exec :redo_warn_mb_pct := 30;
exec :redo_critical_mb_pct := 80;
--exec :redo_warn_mb := 1000;
--exec :redo_critical_mb :=3000;
-- Get limits from DB size
var dbsize_mb number
exec select sum(bytes/1024/1024) into :dbsize_mb from dba_segments;
exec :redo_warn_mb := round((:dbsize_mb/100* :redo_warn_mb_pct)/24);
exec :redo_critical_mb := round((:dbsize_mb/100* :redo_critical_mb_pct)/24);
-- tablespace free space in PCT (warning)
var ts_pct_free_warn number
exec :ts_pct_free_warn := 15;
-- tablespace free space in PCT (critical)
var ts_pct_free_critical number
exec :ts_pct_free_critical := 5;
-- Management Pack Access
var is_diag_licensed number
begin
  :is_diag_licensed := 0;
  select 1 into :is_diag_licensed from v$version where banner like '%Enterprise Edition%' and dbms_db_version.version < 11 -- before 11 there was no init param
  union all
  select 1 from (select 1 from v$version v, v$parameter p where v.banner like '%Enterprise Edition%' and dbms_db_version.version >= 11 and p.name = 'control_management_pack_access' and p.value like '%DIAGNOSTIC%');
  exception
  when no_data_found then null;
end;
/
-- Username
var whoami varchar2(30)
exec :whoami := user;
-- Version
var myversion number
begin
  select substr(version, 1, instr(version, '.')-1) into :myversion from dba_registry where comp_id = 'CATALOG';
end;
/
---------------Date format---------------------------------------------------------------------------------------
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
alter session set nls_numeric_characters=',.';
---------------spooling------------------------------------------------------------------------------------------
set define on
col spoolname new_value spoolname_var
select to_char(sysdate, 'YYYYMMDD_HHSS') || '_dbinfo_' || instance_name || '_' || host_name || '.html' spoolname from v$instance;
DEFINE LOGFILE=&&spoolname_var
spool /opt/dbnitro/reports/&LOGFILE
set define off
---------------HTML-Head-----------------------------------------------------------------------------------------
prompt <HTML>
prompt <HEAD>
prompt <meta charset="UTF-8">
prompt <TITLE>Ribas - Oracle Database Report</TITLE>
prompt <script language="JavaScript" type="text/javascript"> -
function switchdiv(myElement) { -
 if (document.getElementById(myElement).style.display=="block") { -
  document.getElementById(myElement).style.display="none"; -
  document.getElementById("b_" + myElement.substr(2)).innerHTML="(+)"; -
 } else { -
  document.getElementById(myElement).style.display="block"; -
  document.getElementById("b_" + myElement.substr(2)).innerHTML="(-)"; -
 } -
}
prompt
prompt /*
prompt SortTable
prompt version 2
prompt 7th April 2007
prompt Stuart Langridge, http://www.kryogenix.org/code/browser/sorttable/
prompt Thanks to many, many people for contributions and suggestions.
prompt Licenced as X11: http://www.kryogenix.org/code/browser/licence.html
prompt This basically means: do what you want with it.
prompt */
prompt
prompt var stIsIE = /*@cc_on!@*/false;
prompt
prompt sorttable = {
prompt init: function() {
prompt // quit if this function has already been called
prompt if (arguments.callee.done) return;
prompt // flag this function so we do not do the same thing twice
prompt arguments.callee.done = true;
prompt // kill the timer
prompt if (_timer) clearInterval(_timer);
prompt if (!document.createElement || !document.getElementsByTagName) return;
prompt sorttable.DATE_RE = /^(\d\d?)[\/\.-](\d\d?)[\/\.-]((\d\d)?\d\d)$/;
prompt forEach(document.getElementsByTagName('table'), function(table) {
prompt if (table.className.search(/\bsortable\b/) != -1) {
prompt sorttable.makeSortable(table);
prompt }
prompt });
prompt },
prompt
prompt makeSortable: function(table) {
prompt if (table.getElementsByTagName('thead').length == 0) {
prompt // table does not have a tHead. Since it should have, create one and
prompt // put the first table row in it.
prompt the = document.createElement('thead');
prompt the.appendChild(table.rows[0]);
prompt table.insertBefore(the,table.firstChild);
prompt }
prompt // Safari does not support table.tHead, sigh
prompt if (table.tHead == null) table.tHead = table.getElementsByTagName('thead')[0];
prompt
prompt if (table.tHead.rows.length != 1) return; // can not cope with two header rows
prompt
prompt // Sorttable v1 put rows with a class of "sortbottom" at the bottom (as
prompt // "total" rows, for example). This is B&R, since what you are supposed
prompt // to do is put them in a tfoot. So, if there are sortbottom rows,
prompt // for backwards compatibility, move them to tfoot (creating it if needed).
prompt sortbottomrows = [];
prompt for (var i=0; i<table.rows.length; i++) {
prompt if (table.rows[i].className.search(/\bsortbottom\b/) != -1) {
prompt sortbottomrows[sortbottomrows.length] = table.rows[i];
prompt }
prompt }
prompt if (sortbottomrows) {
prompt if (table.tFoot == null) {
prompt // table does not have a tfoot. Create one.
prompt tfo = document.createElement('tfoot');
prompt table.appendChild(tfo);
prompt }
prompt for (var i=0; i<sortbottomrows.length; i++) {
prompt tfo.appendChild(sortbottomrows[i]);
prompt }
prompt delete sortbottomrows;
prompt }
prompt
prompt // work through each column and calculate its type
prompt headrow = table.tHead.rows[0].cells;
prompt for (var i=0; i<headrow.length; i++) {
prompt // manually override the type with a sorttable_type attribute
prompt if (!headrow[i].className.match(/\bsorttable_nosort\b/)) { // skip this col
prompt mtch = headrow[i].className.match(/\bsorttable_([a-z0-9]+)\b/);
prompt if (mtch) { override = mtch[1]; }
prompt if (mtch && typeof sorttable["sort_"+override] == 'function') {
prompt headrow[i].sorttable_sortfunction = sorttable["sort_"+override];
prompt } else {
prompt headrow[i].sorttable_sortfunction = sorttable.guessType(table,i);
prompt }
prompt // make it clickable to sort
prompt headrow[i].sorttable_columnindex = i;
prompt headrow[i].sorttable_tbody = table.tBodies[0];
prompt dean_addEvent(headrow[i],"click", function(e) {
prompt
prompt if (this.className.search(/\bsorttable_sorted\b/) != -1) {
prompt // if we are already sorted by this column, just
prompt // reverse the table, which is quicker
prompt sorttable.reverse(this.sorttable_tbody);
prompt this.className = this.className.replace('sorttable_sorted','sorttable_sorted_reverse');
prompt this.removeChild(document.getElementById('sorttable_sortfwdind'));
prompt sortrevind = document.createElement('span');
prompt sortrevind.id = "sorttable_sortrevind";
prompt sortrevind.innerHTML = stIsIE ? '&nbsp<font face="webdings">5</font>' : '&nbsp;&#x25B4;';
prompt this.appendChild(sortrevind);
prompt return;
prompt }
prompt if (this.className.search(/\bsorttable_sorted_reverse\b/) != -1) {
prompt // if we are already sorted by this column in reverse, just
prompt // re-reverse the table, which is quicker
prompt sorttable.reverse(this.sorttable_tbody);
prompt this.className = this.className.replace('sorttable_sorted_reverse','sorttable_sorted');
prompt this.removeChild(document.getElementById('sorttable_sortrevind'));
prompt sortfwdind = document.createElement('span');
prompt sortfwdind.id = "sorttable_sortfwdind";
prompt sortfwdind.innerHTML = stIsIE ? '&nbsp<font face="webdings">6</font>' : '&nbsp;&#x25BE;';
prompt this.appendChild(sortfwdind);
prompt return;
prompt }
prompt
prompt // remove sorttable_sorted classes
prompt theadrow = this.parentNode;
prompt forEach(theadrow.childNodes, function(cell) {
prompt if (cell.nodeType == 1) { // an element
prompt cell.className = cell.className.replace('sorttable_sorted_reverse','');
prompt cell.className = cell.className.replace('sorttable_sorted','');
prompt }
prompt });
prompt sortfwdind = document.getElementById('sorttable_sortfwdind');
prompt if (sortfwdind) { sortfwdind.parentNode.removeChild(sortfwdind); }
prompt sortrevind = document.getElementById('sorttable_sortrevind');
prompt if (sortrevind) { sortrevind.parentNode.removeChild(sortrevind); }
prompt
prompt this.className += ' sorttable_sorted';
prompt sortfwdind = document.createElement('span');
prompt sortfwdind.id = "sorttable_sortfwdind";
prompt sortfwdind.innerHTML = stIsIE ? '&nbsp<font face="webdings">6</font>' : '&nbsp;&#x25BE;';
prompt this.appendChild(sortfwdind);
prompt
prompt // build an array to sort. This is a Schwartzian transform thing,
prompt // i.e., we "decorate" each row with the actual sort key,
prompt // sort based on the sort keys, and then put the rows back in order
prompt // which is a lot faster because you only do getInnerText once per row
prompt row_array = [];
prompt col = this.sorttable_columnindex;
prompt rows = this.sorttable_tbody.rows;
prompt for (var j=0; j<rows.length; j++) {
prompt row_array[row_array.length] = [sorttable.getInnerText(rows[j].cells[col]), rows[j]];
prompt }
prompt /* If you want a stable sort, uncomment the following line */
prompt //sorttable.shaker_sort(row_array, this.sorttable_sortfunction);
prompt /* and comment out this one */
prompt row_array.sort(this.sorttable_sortfunction);
prompt
prompt tb = this.sorttable_tbody;
prompt for (var j=0; j<row_array.length; j++) {
prompt tb.appendChild(row_array[j][1]);
prompt }
prompt
prompt delete row_array;
prompt });
prompt }
prompt }
prompt },
prompt
prompt guessType: function(table, column) {
prompt // guess the type of a column based on its first non-blank row
prompt sortfn = sorttable.sort_alpha;
prompt for (var i=0; i<table.tBodies[0].rows.length; i++) {
prompt text = sorttable.getInnerText(table.tBodies[0].rows[i].cells[column]);
prompt if (text != '') {
prompt if (text.match(/^-?[£$¤]?[\d,.]+%?$/)) {
prompt return sorttable.sort_numeric;
prompt }
prompt // check for a date: dd/mm/yyyy or dd/mm/yy
prompt // can have / or . or - as separator
prompt // can be mm/dd as well
prompt possdate = text.match(sorttable.DATE_RE)
prompt if (possdate) {
prompt // looks like a date
prompt first = parseInt(possdate[1]);
prompt second = parseInt(possdate[2]);
prompt if (first > 12) {
prompt // definitely dd/mm
prompt return sorttable.sort_ddmm;
prompt } else if (second > 12) {
prompt return sorttable.sort_mmdd;
prompt } else {
prompt // looks like a date, but we can not tell which, so assume
prompt // that it is dd/mm (English imperialism!) and keep looking
prompt sortfn = sorttable.sort_ddmm;
prompt }
prompt }
prompt }
prompt }
prompt return sortfn;
prompt },
prompt
prompt getInnerText: function(node) {
prompt // gets the text we want to use for sorting for a cell.
prompt // strips leading and trailing whitespace.
prompt // this is *not* a generic getInnerText function; it is special to sorttable.
prompt // for example, you can override the cell text with a customkey attribute.
prompt // it also gets .value for <input> fields.
prompt
prompt hasInputs = (typeof node.getElementsByTagName == 'function') &&
prompt node.getElementsByTagName('input').length;
prompt
prompt if (node.getAttribute("sorttable_customkey") != null) {
prompt return node.getAttribute("sorttable_customkey");
prompt }
prompt else if (typeof node.textContent != 'undefined' && !hasInputs) {
prompt return node.textContent.replace(/^\s+|\s+$/g, '');
prompt }
prompt else if (typeof node.innerText != 'undefined' && !hasInputs) {
prompt return node.innerText.replace(/^\s+|\s+$/g, '');
prompt }
prompt else if (typeof node.text != 'undefined' && !hasInputs) {
prompt return node.text.replace(/^\s+|\s+$/g, '');
prompt }
prompt else {
prompt switch (node.nodeType) {
prompt case 3:
prompt if (node.nodeName.toLowerCase() == 'input') {
prompt return node.value.replace(/^\s+|\s+$/g, '');
prompt }
prompt case 4:
prompt return node.nodeValue.replace(/^\s+|\s+$/g, '');
prompt break;
prompt case 1:
prompt case 11:
prompt var innerText = '';
prompt for (var i = 0; i < node.childNodes.length; i++) {
prompt innerText += sorttable.getInnerText(node.childNodes[i]);
prompt }
prompt return innerText.replace(/^\s+|\s+$/g, '');
prompt break;
prompt default:
prompt return '';
prompt }
prompt }
prompt },
prompt
prompt reverse: function(tbody) {
prompt // reverse the rows in a tbody
prompt newrows = [];
prompt for (var i=0; i<tbody.rows.length; i++) {
prompt newrows[newrows.length] = tbody.rows[i];
prompt }
prompt for (var i=newrows.length-1; i>=0; i--) {
prompt tbody.appendChild(newrows[i]);
prompt }
prompt delete newrows;
prompt },
prompt
prompt /* sort functions
prompt each sort function takes two parameters, a and b
prompt you are comparing a[0] and b[0] 
prompt */
prompt sort_numeric: function(a,b) {
prompt aa = parseFloat(a[0].replace(/[^0-9.-]/g,''));
prompt if (isNaN(aa)) aa = 0;
prompt bb = parseFloat(b[0].replace(/[^0-9.-]/g,''));
prompt if (isNaN(bb)) bb = 0;
prompt return aa-bb;
prompt },
prompt sort_alpha: function(a,b) {
prompt if (a[0]==b[0]) return 0;
prompt if (a[0]<b[0]) return -1;
prompt return 1;
prompt },
prompt sort_ddmm: function(a,b) {
prompt mtch = a[0].match(sorttable.DATE_RE);
prompt y = mtch[3]; m = mtch[2]; d = mtch[1];
prompt if (m.length == 1) m = '0'+m;
prompt if (d.length == 1) d = '0'+d;
prompt dt1 = y+m+d;
prompt mtch = b[0].match(sorttable.DATE_RE);
prompt y = mtch[3]; m = mtch[2]; d = mtch[1];
prompt if (m.length == 1) m = '0'+m;
prompt if (d.length == 1) d = '0'+d;
prompt dt2 = y+m+d;
prompt if (dt1==dt2) return 0;
prompt if (dt1<dt2) return -1;
prompt return 1;
prompt },
prompt sort_mmdd: function(a,b) {
prompt mtch = a[0].match(sorttable.DATE_RE);
prompt y = mtch[3]; d = mtch[2]; m = mtch[1];
prompt if (m.length == 1) m = '0'+m;
prompt if (d.length == 1) d = '0'+d;
prompt dt1 = y+m+d;
prompt mtch = b[0].match(sorttable.DATE_RE);
prompt y = mtch[3]; d = mtch[2]; m = mtch[1];
prompt if (m.length == 1) m = '0'+m;
prompt if (d.length == 1) d = '0'+d;
prompt dt2 = y+m+d;
prompt if (dt1==dt2) return 0;
prompt if (dt1<dt2) return -1;
prompt return 1;
prompt },
prompt
prompt shaker_sort: function(list, comp_func) {
prompt // A stable sort function to allow multi-level sorting of data
prompt // see: http://en.wikipedia.org/wiki/Cocktail_sort
prompt // thanks to Joseph Nahmias
prompt var b = 0;
prompt var t = list.length - 1;
prompt var swap = true;
prompt
prompt while(swap) {
prompt swap = false;
prompt for(var i = b; i < t; ++i) {
prompt if ( comp_func(list[i], list[i+1]) > 0 ) {
prompt var q = list[i]; list[i] = list[i+1]; list[i+1] = q;
prompt swap = true;
prompt }
prompt } // for
prompt t--;
prompt
prompt if (!swap) break;
prompt
prompt for(var i = t; i > b; --i) {
prompt if ( comp_func(list[i], list[i-1]) < 0 ) {
prompt var q = list[i]; list[i] = list[i-1]; list[i-1] = q;
prompt swap = true;
prompt }
prompt } // for
prompt b++;
prompt
prompt } // while(swap)
prompt }
prompt }
prompt
prompt /* 
prompt ******************************************************************
prompt Supporting functions: bundled here to avoid depending on a library
prompt ****************************************************************** 
prompt */
prompt
prompt // Dean Edwards/Matthias Miller/John Resig
prompt
prompt /* 
prompt for Mozilla/Opera9 
prompt */
prompt if (document.addEventListener) {
prompt document.addEventListener("DOMContentLoaded", sorttable.init, false);
prompt }
prompt
prompt /* for Internet Explorer */
prompt /*@cc_on @*/
prompt /*@if (@_win32)
prompt document.write("<script id=__ie_onload defer src=javascript:void(0)><\/script>");
prompt var script = document.getElementById("__ie_onload");
prompt script.onreadystatechange = function() {
prompt if (this.readyState == "complete") {
prompt sorttable.init(); // call the onload handler
prompt }
prompt };
prompt /*@end @*/
prompt
prompt /* for Safari */
prompt if (/WebKit/i.test(navigator.userAgent)) { // sniff
prompt var _timer = setInterval(function() {
prompt if (/loaded|complete/.test(document.readyState)) {
prompt sorttable.init(); // call the onload handler
prompt }
prompt }, 10);
prompt }
prompt
prompt /* for other browsers */
prompt window.onload = sorttable.init;
prompt
prompt // written by Dean Edwards, 2005
prompt // with input from Tino Zijdel, Matthias Miller, Diego Perini
prompt
prompt // http://dean.edwards.name/weblog/2005/10/add-event/
prompt
prompt function dean_addEvent(element, type, handler) {
prompt if (element.addEventListener) {
prompt element.addEventListener(type, handler, false);
prompt } else {
prompt // assign each event handler a unique ID
prompt if (!handler.$$guid) handler.$$guid = dean_addEvent.guid++;
prompt // create a hash table of event types for the element
prompt if (!element.events) element.events = {};
prompt // create a hash table of event handlers for each element/event pair
prompt var handlers = element.events[type];
prompt if (!handlers) {
prompt handlers = element.events[type] = {};
prompt // store the existing event handler (if there is one)
prompt if (element["on" + type]) {
prompt handlers[0] = element["on" + type];
prompt }
prompt }
prompt // store the event handler in the hash table
prompt handlers[handler.$$guid] = handler;
prompt // assign a global event handler to do all the work
prompt element["on" + type] = handleEvent;
prompt }
prompt };
prompt // a counter used to create unique IDs
prompt dean_addEvent.guid = 1;
prompt
prompt function removeEvent(element, type, handler) {
prompt if (element.removeEventListener) {
prompt element.removeEventListener(type, handler, false);
prompt } else {
prompt // delete the event handler from the hash table
prompt if (element.events && element.events[type]) {
prompt delete element.events[type][handler.$$guid];
prompt }
prompt }
prompt };
prompt
prompt function handleEvent(event) {
prompt var returnValue = true;
prompt // grab the event object (IE uses a global event object)
prompt event = event || fixEvent(((this.ownerDocument || this.document || this).parentWindow || window).event);
prompt // get a reference to the hash table of event handlers
prompt var handlers = this.events[event.type];
prompt // execute each event handler
prompt for (var i in handlers) {
prompt this.$$handleEvent = handlers[i];
prompt if (this.$$handleEvent(event) === false) {
prompt returnValue = false;
prompt }
prompt }
prompt return returnValue;
prompt };
prompt
prompt function fixEvent(event) {
prompt // add W3C standard event methods
prompt event.preventDefault = fixEvent.preventDefault;
prompt event.stopPropagation = fixEvent.stopPropagation;
prompt return event;
prompt };
prompt fixEvent.preventDefault = function() {
prompt this.returnValue = false;
prompt };
prompt fixEvent.stopPropagation = function() {
prompt this.cancelBubble = true;
prompt }
prompt
prompt // Dean forEach: http://dean.edwards.name/base/forEach.js
prompt /*
prompt forEach, version 1.0
prompt Copyright 2006, Dean Edwards
prompt License: http://www.opensource.org/licenses/mit-license.php
prompt */
prompt
prompt // array-like enumeration
prompt if (!Array.forEach) { // mozilla already supports this
prompt Array.forEach = function(array, block, context) {
prompt for (var i = 0; i < array.length; i++) {
prompt block.call(context, array[i], i, array);
prompt }
prompt };
prompt }
prompt
prompt // generic enumeration
prompt Function.prototype.forEach = function(object, block, context) {
prompt for (var key in object) {
prompt if (typeof this.prototype[key] == "undefined") {
prompt block.call(context, object[key], key, object);
prompt }
prompt }
prompt };
prompt
prompt // character enumeration
prompt String.forEach = function(string, block, context) {
prompt Array.forEach(string.split(""), function(chr, index) {
prompt block.call(context, chr, index, string);
prompt });
prompt };
prompt
prompt // globally resolve forEach enumeration
prompt var forEach = function(object, block, context) {
prompt if (object) {
prompt var resolve = Object; // default
prompt if (object instanceof Function) {
prompt // functions have a "length" property
prompt resolve = Function;
prompt } else if (object.forEach instanceof Function) {
prompt // the object implements a custom forEach method so use that
prompt object.forEach(block, context);
prompt return;
prompt } else if (typeof object == "string") {
prompt // the object is a string
prompt resolve = String;
prompt } else if (typeof object.length == "number") {
prompt // the object is array-like
prompt resolve = Array;
prompt }
prompt resolve.forEach(object, block, context);
prompt }
prompt };
prompt
prompt </script>
prompt
prompt <style type="text/css">
prompt <!---
prompt /* ... define Formats... */ -
    body                 {font:9pt Arial,Helvetica,sans-serif; color:black; background:white;} -
    p                    {font:9pt Arial,Helvetica,sans-serif; color:black; background:white;} -
    table                {font:9pt Arial,Helvetica,sans-serif; color:Black; background:#FFFFDD; ;border-spacing:0px;border-collapse:collapse;} -
    tr                   {font:9pt Arial,Helvetica,sans-serif; color:Black; background:#FFFFDD;} -
    th                   {font:bold 9pt Arial,Helvetica,sans-serif; color:Black; background:#CCCCAA; padding:1px 1px 1px 1px; margin:0px 0px 0px 0px;border:1px solid #000000;} -
    td                   {font:9pt Arial,Helvetica,sans-serif; color:Black; background:#FFFFDD; padding:1px 1px 1px 1px; margin:0px 0px 0px 0px;border:1px solid #000000;} -
    td.number            {text-align:right; font:9pt Arial,Helvetica,sans-serif; color:Black; background:#FFFFDD; padding:1px 1px 1px 1px; margin:0px 0px 0px 0px;border:1px solid #000000;} -
    td.critical          {font:bold 9pt Arial,Helvetica,sans-serif; color:Black; background:#FF5050; padding:1px 1px 1px 1px; margin:0px 0px 0px 0px;border:1px solid #000000;} -
    td.warning           {font:9pt Arial,Helvetica,sans-serif; color:Black; background:#FF9933; padding:1px 1px 1px 1px; margin:0px 0px 0px 0px;border:1px solid #000000;} -
    td.good              {font:9pt Arial,Helvetica,sans-serif; color:Black; background:#339900; padding:1px 1px 1px 1px; margin:0px 0px 0px 0px;border:1px solid #000000;} -
    td.numbercritical    {text-align:right; font:bold 9pt Arial,Helvetica,sans-serif; color:Black; background:#FF5050; padding:1px 1px 1px 1px; margin:0px 0px 0px 0px;border:1px solid #000000;}
prompt td.numberwarning  {text-align:right; font:9pt Arial,Helvetica,sans-serif; color:Black; background:#FF9933; padding:1px 1px 1px 1px; margin:0px 0px 0px 0px;border:1px solid #000000;} -
    td.numbergood        {text-align:right; font:9pt Arial,Helvetica,sans-serif; color:Black; background:#339900; padding:1px 1px 1px 1px; margin:0px 0px 0px 0px;border:1px solid #000000;} -
    h1                   {font:bold 12pt Arial,Helvetica,Geneva,sans-serif; color:#336699; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;} -
    h2                   {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; margin-top:4pt; margin-bottom:0pt;} -
    h3                   {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:Black; margin-top:4pt; margin-bottom:0pt;} -
    a                    {font:9pt Arial,Helvetica,sans-serif; color:#663300; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.link               {font:9pt Arial,Helvetica,sans-serif; color:#663300; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLink             {font:9pt Arial,Helvetica,sans-serif; color:#663300; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkBlue         {font:9pt Arial,Helvetica,sans-serif; color:#0000ff; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkBlue     {font:9pt Arial,Helvetica,sans-serif; color:#000099; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt a.noLinkRed       {font:9pt Arial,Helvetica,sans-serif; color:#ff0000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkRed      {font:9pt Arial,Helvetica,sans-serif; color:#990000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkGreen        {font:9pt Arial,Helvetica,sans-serif; color:#00ff00; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkGreen    {font:9pt Arial,Helvetica,sans-serif; color:#009900; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}

-- Styles for Bargraph-Tables
prompt table.BarGraph, table.BarGraph td.EmptyRight  { -
    background-color:#E0E0E0; -
    color:#000000; -
} -
table.BarGraph td.EmptyRight, table.BarGraph td.Full { -
    padding-left:1; -
    padding-top:1; -
    padding-right:1; -
    padding-bottom:1; -
    border-width:0; -
    border-style:solid; -
} -
table.BarGraph { -
    border-color:#80A080; -
    border-width:1px; -
    border-style:solid; -
} -
table.BarGraph td.EmptyRight { -
    text-align:right; -
} -
table.BarGraph td.FullGreen { -
   background-color:#60A060; -
   text-align:center; -
} -
table.BarGraph td.FullWarning { -
   background-color:#FF9933; -
   text-align:center; -
} -
table.BarGraph td.FullCritical { -
   background-color:#FF5050; -
   text-align:center; -
}
prompt -->
prompt </style>
prompt </HEAD>
prompt <BODY>
prompt <!-- CUSTOMERID = ######## -->
---------------Content------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
select '<h1>Ribas - Database Maintenance Report</h1><br>' FROM dual;
select '<a name="options"><h3>DB Options</h3></a><br>' FROM dual;
select '<table><tr><th>Instance</th><th>DB Name</th><th>DB Uniq Name</th><th>Service Names</th><th>Host</th><th>Start Time</th><th>Uptime</th><th>Open mode</th><th>DB Role</th><th>LogMode</th><th>Cluster</th><th>Guard Status</th><th>DataGuard</th><th>Protection Level</th><th>Force Logging</th><th>Flashback ON</th><th>Hide SQL</th><th>Diagnostic Pack</th></tr>' FROM dual;
select '<tr><td>' || i.instance_name 
   || '</td><td>' || d.NAME
   || '</td><td>' || (select value from v$parameter where name = 'db_unique_name')
   || '</td><td>' || (select value from v$parameter where name = 'service_names')
   || '</td><td>' || i.HOST_NAME 
   || '</td><td>' || startup_time 
   || '</td><td>' || to_char(round(sysdate-startup_time,1), '99990d0') || ' d' 
   || '</td><td>' || open_mode 
   || '</td><td>' || DATABASE_ROLE 
   || '</td><td>' || log_mode 
   || '</td><td>' || (select case when value = 'TRUE' then 'YES' else 'NO' end from v$parameter where name = 'cluster_database')
   || '</td><td>' || GUARD_STATUS 
   || '</td><td>' || (select case when value = 'TRUE' then 'YES' else 'NO' end from v$parameter where name = 'dg_broker_start')
   || '</td><td>' || PROTECTION_LEVEL 
   || '</td><td>' || FORCE_LOGGING 
   || '</td><td>' || d.FLASHBACK_ON
   || '</td><td>' || (select :hide_sql FROM dual)
   || '</td><td>' || (select decode(:is_diag_licensed, 1, 'YES', 0, 'NO') FROM dual)
   || '</td></tr>' 
FROM gv$instance i, v$database d 
order by instance_name;
select '</table><br>' FROM dual;
select '<table><tr><th>Instance</th><th>System Sessions</th><th>User Sessions</th></tr>' FROM dual;
---------------DB Sessions------------------------------------------------------------------------------------------
select '<a name="sessions"><h3>DB Sessions</h3></a><br>' FROM dual;
select '<tr><td>' || i.instance_name 
   || '</td><td>' || to_char(sum(nvl2(username, 0, 1)), '999g999') 
   || '</td><td>' || to_char(sum(nvl2(username, 1, 0)), '999g999') 
   || '</td></tr>' 
FROM gv$session s, gv$instance i 
WHERE s.inst_id = i.inst_id 
group by i.instance_name 
order by i.instance_name;
select '</table><br>' FROM dual;
---------------Healthchecks------------------------------------------------------------------------------------------
select '<a name="health"><h3>Healthchecks</h3></a><br>' FROM dual;
select '<table><tr><th>Status</th><th>Message</th></tr>' FROM dual;
-- Database Uptime
select '<tr><td' || case when anzahl > 0 then ' class="warning"' else ' class="good"' end || '>Instance Uptime</td>' || '<td>' || to_char(anzahl) || ' Instances rebooted during the last ' || to_char(:days_back) || ' days.' || '</td></tr>' 
from (select count(*) as anzahl from gv$instance where sysdate-startup_time < :days_back);
-- Alert Log (use dynamic SQL to prevent ORA-942 errors during parse time)
declare
  dynsql varchar2(2000);
  ret    varchar2(1000);
  TYPE   cur_typ IS REF CURSOR;
  c cur_typ;
begin
  if :myversion < 11 then dbms_output.put_line('<tr><td class="warning">Alert Log</td><td>not executed since version is below 11g.</td></tr>');
  elsif :whoami <> 'SYS' then dbms_output.put_line('<tr><td class="warning">Alert Log</td><td>not executed since user is not SYS.</td></tr>');
  else
-- Alert Log general
  dynsql := 'select ''<tr><td'' || case when anzahl_ora+anzahl_cnc > 0 then '' class="warning"'' else '' class="good"'' end ||''>Altert Log</td>'' || ''<td><a href="#alert_log">'' || to_char(anzahl_ora) || '' ORA- messages, '' || to_char(anzahl_cnc) || '' "checkpoint not complete" messages  in last '' || to_char(:days_back) || '' days.'' || ''<a></td></tr>'' as msgtext from (select sum( case when lower(message_text) like ''ora-%'' then 1 else 0 end ) as anzahl_ora, sum( case when lower(message_text) like ''%checkpoint not complete%'' then 1 else 0 end ) as anzahl_cnc from sys.X$DBGALERTEXT where ORIGINATING_TIMESTAMP>sysdate-:days_back)';
    OPEN c FOR dynsql USING :days_back, :days_back;
    LOOP
      FETCH c INTO ret;
      EXIT WHEN c%NOTFOUND;
      dbms_output.put_line(ret);
    END LOOP;
    CLOSE c;
-- Alert Log ORA-600, ORA-7445
    dynsql := 'select ''<tr><td'' || case when anzahl_ora > 0 then '' class="warning"'' else '' class="good"'' end ||''>Altert Log ORA-600/7445</td>'' || ''<td><a href="#alert_log">'' || to_char(anzahl_ora) || '' ORA-600/7445 messages in last '' || to_char(:days_back) || '' days.'' || ''</a></td></tr>'' as msgtext from (select count(*) as anzahl_ora from sys.X$DBGALERTEXT where ORIGINATING_TIMESTAMP>sysdate-:days_back and (lower(message_text) like ''%ora-%600%'' or lower(message_text) like ''%ora-%7445%'' ))';
    OPEN c FOR dynsql USING :days_back, :days_back;
    LOOP
      FETCH c INTO ret;
      EXIT WHEN c%NOTFOUND;
      dbms_output.put_line(ret);
    END LOOP;
    CLOSE c;
  end if;
end;
/
-- current processes utilization
-- with clause is neccessary because predicate pushing leads to division by zero....
with reslimit as (select /*+ MATERIALIZE */ s.anz_sess/p.value*100 pctused, s.inst_id
from (select inst_id, max_utilization anz_sess from gv$resource_limit where resource_name='processes') s, (select inst_id, value from gv$parameter where name ='processes' ) p
where s.inst_id = p.inst_id)
select '<tr><td' || case when anzahl > 0 then ' class="warning"' else ' class="good"' end 
   || '>processes parameter</td>' 
   || '<td><a href="res_limit">' 
   || to_char(anzahl) 
   || ' Instances have more than 80% of max processes used.</a></td></tr>' 
from (select count(inst_id) as anzahl from reslimit where pctused >= 80);
-- PGA overallocation
select '<tr><td' || case when anzahl > 0 then ' class="warning"' else ' class="good"' end 
   || '>PGA overallocation</td>' 
   || '<td><a href="#pga_advice">' 
   || to_char(anz_inst) 
   || ' instances had ' 
   || to_char(anzahl) 
   || ' PGA memory overallocations.</a></td></tr>' 
from (select sum(case when p.value > 0 then 1 else 0 end) as anz_inst, sum(p.value) as anzahl 
from gv$pgastat p, gv$instance i where p.name = 'over allocation count' and p.inst_id = i.inst_id);
-- session_cached_cursors
select '<tr><td' || case when amount/s.sess# >= 0.2 then ' class="critical"' when amount/s.sess# >= 0.1 then ' class="warning"' else ' class="good"' end 
  || '>session_cached_cursors</td>' 
  || '<td><a href="#session_cached_cursors">' 
  || to_char( round(amount/s.sess#*100)) 
  || '% sessions outrun session_cached_cursors (' 
  || to_char(p.value) 
  || ')</a></td></tr>'
from (select trunc(value) SESSION_CACHED_CURSORS, count(*) Amount 
from gv$sesstat seval, v$statname sname, gv$session se where name = 'session cursor cache count' and seval.statistic# = sname.statistic# and seval.sid = se.sid and seval.inst_id = se.inst_id and se.username is not null	group by trunc(value) order by 1) c,
    (select to_number(value) value from v$parameter where name='session_cached_cursors') p,
    (select count(*) sess# from v$session where username is not null) s where SESSION_CACHED_CURSORS = (select to_number(value) value from v$parameter where name='session_cached_cursors');
-- open_cursors
select '<tr><td' || case when sum_critical > 0 then ' class="critical"' when sum_warning > 0 then ' class="warning"' else ' class="good"' end 
   || '>open_cursors</td>' 
   || '<td><a href="#open_cursors">' 
   || to_char(sum_critical) 
   || ' sessions use 90%, ' 
   || to_char(sum_warning) 
   || ' session use 80%</a></td></tr>'
from (select sum(case when a.value > p.value*0.8 then 1 else 0 end) sum_warning, sum(case when a.value > p.value*0.9 then 1 else 0 end) sum_critical from gv$sesstat a, v$statname b, gv$session s,
	(select to_number(value) value from v$parameter where name='open_cursors') p
where a.statistic# = b.statistic# and s.sid=a.sid and s.inst_id = a.inst_id and b.name = 'opened cursors current');
-- Tablespace usage
select '<tr><td' 
   || case when nvl(pct_free_crit,0) > 0 then ' class="critical"' when pct_free_warn > 0 then ' class="warning"' else ' class="good"' end 
   || '>Tablespace usage</td>' 
   || '<td>' 
   || '<a href="#tablespaces">' 
   || to_char(nvl(pct_free_crit,0)) 
   || ' Tablespaces with <' 
   || to_char(:ts_pct_free_critical) 
   || '% free, ' 
   || to_char(pct_free_warn) 
   || ' Tablespaces with <' 
   || to_char(:ts_pct_free_warn) 
   || '% free. ' 
   || '</a></td></tr>'
from (select sum(case when pct_free < 5 then 1 else 0 end) pct_free_crit, count(pct_free) pct_free_warn from 
     (select round((mb_free+mb_autoalloc)/mb_gesamt*100, 1) pct_free from dba_tablespaces t, 
     (select sum(greatest(BYTES,MAXBYTES))/1024/1024 mb_gesamt, sum(greatest(BYTES,MAXBYTES)-BYTES)/1024/1024 mb_autoalloc, TABLESPACE_NAME from dba_data_files group by TABLESPACE_NAME) f,
     (select sum(BYTES)/1024/1024 mb_free, TABLESPACE_NAME from dba_free_space group by TABLESPACE_NAME) fs where t.tablespace_name = f.tablespace_name and t.tablespace_name = fs.tablespace_name and t.contents = 'PERMANENT')
where pct_free <= :ts_pct_free_warn);
-- Quota usage
select '<tr><td' 
   || case when nvl(pct_free_5,0) > 0 then ' class="critical"' when pct_free_25 > 0 then ' class="warning"' else ' class="good"' end 
   || '>Quota usage</td>' 
   || '<td>' 
   || '<a href="#quotas">' 
   || to_char(nvl(pct_free_5,0)) 
   || ' Quotas with <5% free, ' 
   || to_char(pct_free_25) 
   || ' Quotas with <25% free. ' 
   || '</a></td></tr>'
from (select sum(case when pct_free < 5 then 1 else 0 end) pct_free_5, count(pct_free) pct_free_25 from
     (select /*+RULE*/ USERNAME -- RULE hint as fix for Bug 6613821
		, TABLESPACE_NAME
		, BYTES/1024/1024 MB 
		, MAX_BYTES/1024/1024 MB_MAX
		, 100-BYTES/MAX_BYTES*100 pct_free
		, row_number() over (order by BYTES/MAX_BYTES desc) rn
		from dba_ts_quotas
		where max_bytes > 1 ) -- unlimited Quota = -1; no Quota = 0)
	where pct_free < 25);
-- unable to extend issues
select '<tr><td' 
   || case when anzahl > 0 then ' class="critical"' else ' class="good"' end 
   || '>unable to extend issues</td>' 
   || '<td>' 
   || '<a href="#extend_issues">' 
   || to_char(anzahl) 
   || ' tablespaces might have segments which are unable to extend.' 
   || '</a></td></tr>'
from (select /* extent check DMTs, LMTs  */ count(tablespace_name) as anzahl
	FROM (select t.tablespace_name, mb_gesamt, mb_free+mb_autoalloc mb_free	from dba_tablespaces t,
         (select sum(greatest(BYTES,MAXBYTES)) / 1024/1024 mb_gesamt, sum(greatest(BYTES,MAXBYTES)-BYTES)/1024/1024 mb_autoalloc, TABLESPACE_NAME from dba_data_files group by TABLESPACE_NAME) f,
		 (select sum(BYTES) / 1024/1024 mb_free, TABLESPACE_NAME from dba_free_space group by TABLESPACE_NAME) fs
	where t.tablespace_name = f.tablespace_name
	and   t.tablespace_name = fs.tablespace_name
	and   t.contents = 'PERMANENT')
	where (mb_free <= 64 /* 64MB */ 
	and mb_gesamt >= 640) or (mb_free < (mb_gesamt/10) and mb_gesamt < 640));
-- Tablespace organization
select '<tr><td' 
   || case when anzahl_dmt > 0 or anzahl_noassm > 0 then ' class="warning"' else ' class="good"' end 
   || '>Extent/Segment Management (non-SYSTEM)</td>' 
   || '<td>' 
   || '<a href="#space_management">' 
   || to_char(anzahl_dmt) 
   || ' dictionary managed tablespaces, ' 
   || to_char(anzahl_noassm) 
   || ' tablespaces without ASSM. ' 
   || '</a></td></tr>' 
from (select nvl(sum(decode(extent_management, 'LOCAL', 0, 1)), 0) anzahl_dmt, nvl(sum(decode(segment_space_management, 'AUTO', 0, 1)), 0) anzahl_noassm 
from dba_tablespaces 
where tablespace_name <> 'SYSTEM' 
and contents = 'PERMANENT' 
and (extent_management <> 'LOCAL' 
or segment_space_management <> 'AUTO'));
-- Invalid objects
select '<tr><td' 
   || case when objects > 10 then ' class="critical"' when objects > 0 then ' class="warning"' else ' class="good"' end 
   || '>Objects</td>' 
   || '<td>' 
   || '<a href="#inv_obj">' 
   || to_char(objects) 
   || ' invalid objects in ' 
   || to_char(owners) 
   || ' schemas. ' 
   || '</a></td></tr>' 
from (select count(distinct owner) owners, count(object_name) objects 
from dba_objects 
where object_type <> 'SYNONYM' 
and status <> 'VALID' 
and object_name not like 'BIN$%');
-- Invalid indexes
select '<tr><td' 
   || case when indexes > 0 then ' class="critical"' else ' class="good"' end 
   || '>Indexes</td>' 
   || '<td>' 
   || '<a href="#inv_index">' 
   || to_char(indexes) 
   || ' invalid indexes in ' 
   || to_char(owners) 
   || ' schemas. ' 
   || '</a></td></tr>'
from (select count(distinct owner) owners, count(index_name) indexes 
from (select index_name, owner, status from dba_indexes where status not in ('VALID', 'N/A')
union all
select index_name, index_owner, status from dba_ind_partitions where status not in ('USABLE', 'N/A')
union all
select index_name, index_owner, status from dba_ind_subpartitions where status <> 'USABLE'));
-- FRA usage
select '<tr><td' 
   || case when pct_used > 90 then ' class="critical"' when pct_used > 75 then ' class="warning"' else ' class="good"' end 
   || '>FRA</td>' 
   || '<td>' 
   || '<a href="#fra">' 
   || to_char(pct_used) 
   || '% used in Flash Recovery Area.' 
   || '</a></td></tr>' 
from (select sum(PERCENT_SPACE_USED) pct_used from v$flash_recovery_area_usage);
-- Failed Jobs
select '<tr><td' 
   || case when status_failed > 2 then ' class="critical"' when status_failed > 1 then ' class="warning"' else ' class="good"' end 
   || '>Scheduler Jobs</td>' 
   || '<td>' 
   || '<a href="#scheduler_job_runs">' 
   || to_char(status_failed) 
   || ' failed Scheduler Jobs.' 
   || '</a></td></tr>' 
from (select count(status) status_failed 
from dba_scheduler_job_run_details 
where status <> 'SUCCEEDED' 
and log_date > systimestamp - :days_back);
-- Redolog Members
select '<tr><td' 
   || case when anzahl > 1 then ' class="warning"' else ' class="good"' end 
   || '>Members per Loggroup</td>' 
   || '<td>' 
   || '<a href="#all_files">' 
   || to_char(anzahl) 
   || ' Redolog groups with only 1 member.' 
   || '</a></td></tr>'
from (select count(*) as anzahl 
from gv$log where members < 2);
-- Redolog Sizes
select '<tr><td' 
   || case when anzahl > 1 then ' class="warning"' else ' class="good"' end 
   || '>Redologs same size</td>' 
   || '<td>' || '<a href="#all_files">' 
   || to_char(anzahl) 
   || ' distinct Redolog sizes in database.' 
   || '</a></td></tr>' 
from (select count(distinct bytes) as anzahl 
from gv$log);
-- Controlfile Mirroring
select '<tr><td' 
   || case when anz_mount = 1 then ' class="warning"' else ' class="good"' end 
   || '>Controlfile Redundancy</td>' 
   || '<td>' 
   || '<a href="#all_files">' 
   || to_char(anzahl) 
   || ' Control files in ' 
   || to_char(anz_mount) 
   || ' distinct Mountpoints.' 
   || '</a></td></tr>' 
from (select * 
from (select count(distinct directory) anz_mount 
from (select SUBSTR(name, 1,INSTR(REPLACE(name, '/', ''), '', -1)-1) directory from gv$controlfile)), (select count(*) as anzahl from gv$controlfile));
-- Controlfile Autobackup
select '<tr><td' 
   || case  when anz < 1 then ' class="warning"' else ' class="good"' end 
   || '>Controlfile Autobackup</td>' 
   || '<td>' 
   || '<a href="#rman_conf">' 
   || 'Controlfile Autobackup is ' 
   || mytext 
   || '.' 
   || '</a></td></tr>'
from (select decode(anz, 0, 'OFF', 'ON') mytext, anz 
from (select count(*) as anz 
from v$rman_configuration 
where name = 'CONTROLFILE AUTOBACKUP' 
and value = 'ON'));
-- Datafile Backups
select '<tr><td' 
   || case when anzahl > 0 then ' class="warning"' else ' class="good"' end 
   || '>Datafile Backups</td>' 
   || '<td>' 
   || '<a href="#backups">' 
   || to_char(anzahl) 
   || ' datafile backups corrupt or older than ' 
   || to_char(:days_back) 
   || ' days.' 
   || '</a></td></tr>' 
from (select count(*) as anzahl 
from (select i.instance_name
        , f.file#
		, f.name fname
		, bd.completion_time
		, bd.MARKED_CORRUPT corrupt_blocks
		, bd.LOGICALLY_CORRUPT
		, row_number() over (partition by f.file# order by bd.completion_time desc) rn 
	  from gv$instance i, gv$datafile f, gv$backup_datafile bd 
	  where i.inst_id = f.inst_id 
	  and i.inst_id = bd.inst_id 
	  and f.inst_id = bd.inst_id 
	  and f.file# = bd.file# 
	  order by i.instance_name, f.name)
where rn = 1 
and ( corrupt_blocks > 0 
or LOGICALLY_CORRUPT > 0 
or completion_time < sysdate - :days_back));
-- missing Datafile Backups
select '<tr><td'
   || case when anzahl > 0 then ' class="warning"' else ' class="good"' end 
   || '>Datafile without backup</td>' 
   || '<td>' 
   || '<a href="#missing_backups">' 
   || to_char(anzahl) 
   || ' datafile(s) never backed up.' 
   || '</a></td></tr>'
from (with bdf as (select --+MATERIALIZE
	  bd.inst_id
	  , bd.file# 
	from gv$backup_datafile bd 
	where bd.completion_time > sysdate- :days_back)
select count(*) as anzahl from 
(select i.instance_name
  , f.file#
  , f.name fname 
from gv$instance i
  , gv$datafile f
where i.inst_id = f.inst_id 
and (f.inst_id, f.file#) 
not in (select bd.inst_id
          , bd.file# 
		from bdf bd 
		where f.file# = bd.file# 
		and f.inst_id = bd.inst_id) 
order by i.instance_name, f.name));
-- missing Datafile Backups
with vd as (select /*+MATERIALIZE*/ * from v$datafile),
     bd as (select /*+MATERIALIZE*/ * from v$BACKUP_DATAFILE)
select '<tr><td' 
   || case when anzahl > 0 then ' class="warning"' else ' class="good"' end 
   || '>Datafiles with unrecoverable operations</td>' 
   || '<td>' 
   || '<a href="#unrecoverable">' 
   || to_char(anzahl) 
   || ' datafile(s) have unrecoverable operations (nologging).' 
   || '</a></td></tr>' 
from (select count(*) as anzahl 
from (select * 
from VD, (select BD.CREATION_CHANGE#, MAX(BD.COMPLETION_TIME) COMPLETION_TIME 
from BD GROUP BY BD.CREATION_CHANGE#) VBD
WHERE VBD.CREATION_CHANGE# = VD.CREATION_CHANGE#
AND VD.UNRECOVERABLE_TIME > VBD.COMPLETION_TIME
order by vd.name));
-- Paramter control_file_record_keep_time
select '<tr><td' 
   || case when value < 8 then ' class="warning"' else ' class="good"' end 
   || '>control_file_record_keep_time</td>' 
   || '<td>' 
   || '<a href="#parameter">' 
   || 'control_file_record_keep_time = ' 
   || to_char(value) 
   || '. Should be increased.' 
   || '</a></td></tr>' 
from (select value 
from v$parameter 
where name='control_file_record_keep_time');
-- Standby File Management
select '<tr><td' 
   || case when upper(value) <> 'AUTO' then ' class="warning"' else ' class="good"' end 
   || '>Standby File Management</td>' 
   || '<td><a href="#parameter">Standby Configurations should use STANDBY_FILE_MANAGEMENT=AUTO. Current Setting: ' 
   || p.value 
   || '</a></td></tr>' 
from (select value 
from v$parameter 
where name='standby_file_management') p,
--	(select protection_level from v$database where protection_level <> 'UNPROTECTED') d
(select value as broker_state 
from v$parameter 
where name= 'dg_broker_start' 
and value = 'TRUE') d;
-- Standby LOGGING Mode
select '<tr><td' 
   || case when force_logging <> 'YES' then ' class="warning"' else ' class="good"' end 
   || '>Standby Logging Mode</td>' 
   || '<td>Standby Configurations should use FORCE LOGGING. Current Setting: ' 
   || force_logging 
   || '</td></tr>' 
from (select force_logging 
from v$database 
where protection_level <> 'UNPROTECTED') d,
(select value as broker_state 
from v$parameter 
where name= 'dg_broker_start' 
and value = 'TRUE') p;
-- Segments in SYSTEM Tablespace
select '<tr><td' 
   || case when anzahl > 0 then ' class="warning"' else ' class="good"' end 
   || '>Segments in SYSTEM Tablespace</td>' 
   || '<td>' 
   || '<a href="#system_segments">' 
   || to_char(owners) 
   || ' owners have ' 
   || to_char(anzahl) 
   || ' segments in SYSTEM tablespace.' 
   || '</a></td></tr>' 
from (select count(distinct owner) as owners, count(*) as anzahl 
FROM DBA_SEGMENTS
WHERE TABLESPACE_NAME IN ('SYS','SYSAUX')
AND OWNER NOT IN ('SYS','SYSTEM','SYSMAN','TSMSYS','DBSNMP','XDB','CTXSYS','EXFSYS','WMSYS','ORDSYS','MDSYS','OLAPSYS','WKSYS', 'DMSYS','WK_TEST', 'ORDDATA', 'AUDSYS', 'GSMADMIN_INTERNAL', 'APPQOSSYS')
AND OWNER not like 'FLOWS_%'
AND OWNER not like 'APEX%');
-- Segments without statistics
select '<tr><td' 
   || case when anzahl > 0 then ' class="warning"' else ' class="good"' end 
   || '>Segments without statistics</td>' 
   || '<td>' 
   || '<a href="#stale_statistics">' 
   || to_char(owners) 
   || ' owners have ' 
   || to_char(anzahl) 
   || ' segments without statistics.' 
   || '</a></td></tr>' 
from (select count(distinct owner) as owners, count(*) as anzahl
from (select owner, 'TABLE' segment_type, count(*) anzahl from dba_tables where last_analyzed is null and owner not in ('SYS','SYSTEM') group by owner
union all
select table_owner, 'TABLE PARTITION' segment_type, count(*) anzahl from dba_tab_partitions where last_analyzed is null and table_owner not in ('SYS','SYSTEM') group by table_owner
union all
select table_owner, 'TABLE SUBPARTITION' segment_type, count(*) anzahl from dba_tab_subpartitions where last_analyzed is null and table_owner not in ('SYS','SYSTEM') group by table_owner
union all
select owner, 'INDEX' segment_type, count(*) anzahl from dba_indexes where last_analyzed is null and owner not in ('SYS','SYSTEM') group by owner
union all
select index_owner, 'INDEX PARTITION' segment_type, count(*) anzahl from dba_ind_partitions where last_analyzed is null and index_owner not in ('SYS','SYSTEM') group by index_owner
union all
select index_owner, 'INDEX SUBPARTITION' segment_type, count(*) anzahl from dba_ind_subpartitions where last_analyzed is null and index_owner not in ('SYS','SYSTEM') group by index_owner));
-- Segments with stale statistics
select '<tr><td' 
   || case when anzahl > 0 then ' class="warning"' else ' class="good"' end 
   || '>Segments with stale statistics</td>' 
   || '<td>' 
   || '<a href="#stale_statistics">' 
   || to_char(owners) 
   || ' owners have ' 
   || to_char(anzahl) 
   || ' segments with stale statistics.' 
   || '</a></td></tr>'
from (select count(distinct owner) as owners, count(*) as anzahl
from (select u.TIMESTAMP
	    , d.last_analyzed
		, d.owner
		, u.table_name
		, u.inserts
		, u.updates
		, u.deletes
		, d.num_rows
		, ((U.inserts+u.deletes+u.updates)/decode(d.num_rows, 0, 1, d.num_rows)) * 100 percent
	  from ALL_TAB_MODIFICATIONS u,dba_tables d
	  where u.table_name = d.table_name
	  and   u.table_owner = d.owner
	  and (u.inserts > 10000 
	  or u.updates > 10000 
	  or u.deletes > 10000)));
-- Segments which need Reorg
select '<tr><td' 
   || case when anzahl > 0 then ' class="warning"' else ' class="good"' end 
   || '>Segments which need reorganization</td>' 
   || '<td>' 
   || '<a href="#reorg_tab">' 
   || to_char(owners) 
   || ' owners have ' 
   || to_char(anzahl) 
   || ' segments which may be reorganized. Could save ' 
   || to_char(GB) 
   || 'GB' 
   || '</a></td></tr>'
from (select count(distinct owner) as owners
        , count(*) as anzahl
		, round(sum(blocks*block_size/1024/1024/1024-num_rows*avg_row_len/1024/1024/1024)) GB
      FROM (select * FROM dba_tables WHERE BLOCKS > 0 and TEMPORARY='N') dt, dba_tablespaces dts
      WHERE dt.tablespace_name=dts.tablespace_name
      AND (num_rows*avg_row_len/block_size/blocks < 0.7	OR blocks*block_size-num_rows*avg_row_len > 40*1024*1024)
      AND blocks*block_size-num_rows*avg_row_len > 1*1024*1024
      AND owner not in ('SYS','SYSTEM','WMSYS')
      AND table_name not in (select distinct table_name from dba_tab_columns where DATA_TYPE in ('BLOB','CLOB','LONG','LONG RAW','NCLOB')));
-- Statistics Autotask Job
declare
  dynsql varchar2(2000);
  ret    varchar2(1000);
  TYPE cur_typ IS REF CURSOR;
  c cur_typ;
begin
  if :myversion < 11 then
    dbms_output.put_line('<tr><td class="warning">Automatic Statistics Job<td>Not executed since version is below 11g.</td></tr>');
  else
    -- Alert Log general
	dynsql := 'select ''<tr><td'' || case when status <> ''ENABLED'' then '' class="warning"'' else '' class="good"'' end ||''>Automatic Statistics Job</td>'' || ''<td>'' || ''<a href="#autotask">'' || ''Automatic statistic gathering should be enabled. Current status: '' || status || ''</a></td></tr>''	from (select status from dba_autotask_task where client_name=''auto optimizer stats collection'')';
    OPEN c FOR dynsql;
    LOOP
        FETCH c INTO ret;
        EXIT WHEN c%NOTFOUND;
        dbms_output.put_line(ret);
    END LOOP;
    CLOSE c;
  end if;
end;
/
-- Unindexed Keys
select '<tr><td' 
   || case when anzahl > 0 then ' class="warning"' else ' class="good"' end 
   || '>Unindexed Foreign Keys</td>' 
   || '<td>' 
   || '<a href="#unindexed_keys">' 
   || to_char(owners) 
   || ' owners have ' 
   || to_char(anzahl) 
   || ' unindexed foreign keys.' 
   || '</a></td></tr>'
from (select count(distinct owner) as owners, count(constraint_name) as anzahl
	 from (select b.owner,
				   b.table_name,
				   b.constraint_name,
				   max(decode(position, 1, column_name, null)) cname1,
				   max(decode(position, 2, column_name, null)) cname2,
				   max(decode(position, 3, column_name, null)) cname3,
				   max(decode(position, 4, column_name, null)) cname4,
				   max(decode(position, 5, column_name, null)) cname5,
				   max(decode(position, 6, column_name, null)) cname6,
				   max(decode(position, 7, column_name, null)) cname7,
				   max(decode(position, 8, column_name, null)) cname8,
				   count(*) col_cnt
			  from (select substr(owner,1,30) owner,
						   substr(table_name,1,30) table_name,
						   substr(constraint_name,1,30) constraint_name,
						   substr(column_name,1,30) column_name,
						   position
					  from dba_cons_columns ) a,
				   dba_constraints b
			 where a.constraint_name = b.constraint_name
			 and a.owner = b.owner
			 and b.constraint_type = 'R'
             and a.owner not in ('SYS','SYSTEM','SYSMAN','EXFSYS','DBSNMP')
			 group by b.table_name, b.constraint_name, b.owner) cons
	where col_cnt > ALL
			(select count(*)
				from dba_ind_columns i
			   where i.table_name = cons.table_name
				 and i.table_owner = cons.owner
				 and i.column_name in (cname1, cname2, cname3, cname4, cname5, cname6, cname7, cname8 )
				 and i.column_position <= cons.col_cnt
			   group by i.index_name, i.table_owner));
-- Sequence running out of values
select '<tr><td' 
   || case when anzahl > 0 then ' class="warning"' else ' class="good"' end 
   || '>Sequences running out of values</td>' 
   || '<td>' 
   || '<a href="#sequences">' 
   || to_char(owners) 
   || ' owner have ' 
   || to_char(anzahl) 
   || ' sequences with more than 80% values used.' 
   || '</a></td></tr>'
from (select count(sequence_name) as anzahl, count(distinct sequence_owner) as owners
from (select SEQUENCE_OWNER, SEQUENCE_NAME, CYCLE_FLAG, LAST_NUMBER, INCREMENT_BY, CACHE_SIZE, decode(MAX_VALUE, -1, 9999999999999999999999999999, MAX_VALUE) MAX_VALUE 
from dba_sequences) where last_number/max_value>=0.8 and cycle_flag='N');
-- Redolog Switches per Hour
select '<tr><td' || case when anz_critical > 0 or anz_critical_mb > 0 then ' class="critical"' when anz_warn > 0 or anz_warn_mb > 0 then ' class="warning"' else ' class="good"' end 
   ||'>Redo per Hour</td>' 
   || '<td>' 
   || '<a href="#redolog_switches">' 
   || '#' 
   || to_char(anz_critical) 
   || '/ #' 
   || to_char(anz_critical_mb) 
   || '(in MB) critical switches, ' 
   || '#' 
   || to_char(anz_warn) 
   || '/ #' 
   || to_char(anz_warn_mb) 
   || '(in MB) suspicious switches, ' 
   || '</a></td></tr>'
from (select sum(case when anz >= :redo_warn then 1 else 0 end) anz_warn
  , sum(case when anz >= :redo_critical      then 1 else 0 end) anz_critical
  , sum(case when  MB >= :redo_warn_mb       then 1 else 0 end) anz_warn_mb
  , sum(case when  MB >= :redo_critical_mb   then 1 else 0 end) anz_critical_mb
from (select l.thread# thread
  , trunc(l.first_time,'hh') stunde
  , count(l.sequence#) anz
  , sum(al.block_size * al.blocks)/1024/1024 MB
from gv$log_history l, (select distinct inst_id, thread#, sequence#, blocks, block_size 
from gv$archived_log) al, gv$instance i
where i.inst_id = l.inst_id(+)
and l.inst_id = al.inst_id(+)
and l.thread# = al.thread#(+)
and l.sequence# = al.sequence#(+)
and sysdate-31 < l.first_time(+)
group by l.thread#, trunc(l.first_time,'hh')));
-- Redolog Switches per Day
select '<tr><td' 
   || case when anz_critical > 0 or anz_critical_mb > 0 then ' class="critical"' when anz_warn > 0 or anz_warn_mb > 0 then ' class="warning"' else ' class="good"' end 
   || '>Redo per Day</td>' 
   || '<td>' 
   || '<a href="#redolog_switches">' 
   || '#' 
   || to_char(anz_critical) 
   || '/ #' || to_char(anz_critical_mb) 
   || '(in MB) critical switches, ' 
   || '#' 
   || to_char(anz_warn) 
   || '/ #' 
   || to_char(anz_warn_mb) 
   || '(in MB) suspicious switches, ' 
   || '</a></td></tr>'
from (select sum(case when anz >= :redo_warn*24 then 1 else 0 end ) anz_warn
  , sum(case when anz >= :redo_critical*24      then 1 else 0 end ) anz_critical
  , sum(case when MB >= :redo_warn_mb*24        then 1 else 0 end ) anz_warn_mb
  , sum(case when MB >= :redo_critical_mb*24    then 1 else 0 end ) anz_critical_mb
from (select l.thread# thread
  , trunc(l.first_time) tag
  , count(l.sequence#) anz
  , sum(al.block_size * al.blocks)/1024/1024 MB
from gv$log_history l, (select distinct inst_id, thread#, sequence#, blocks, block_size 
from gv$archived_log) al, gv$instance i
where i.inst_id = l.inst_id(+)
and l.inst_id = al.inst_id(+)
and l.thread# = al.thread#(+)
and l.sequence# = al.sequence#(+)
and sysdate-31 < l.first_time(+)
group by l.thread#, trunc(l.first_time)));
-- Audit Table History
select '<tr><td' 
   || case when to_number(cast(systimestamp as date) - cast(min_ts as date)) > 365 then ' class="critical"' when to_number(cast(systimestamp as date) - cast(min_ts as date)) > 180 then ' class="warning"' else ' class="good"' end 
   || '>Old Audit Records</td>' 
   || '<td>Oldest Audit Record created ' 
   || round(nvl( cast(systimestamp as date) - cast(min_ts as date), 0)) 
   || ' days ago. Oldest TS: ' 
   || nvl( to_char(min_ts, 'dd/mm/yyyy hh24:mi:ss'), 'null') 
   || ', youngest TS: ' 
   || nvl( to_char(max_ts, 'dd/mm/yyyy hh24:mi:ss'), 'null') 
   || '</td></tr>'
from (select min_ts, max_ts 
from (select min(timestamp) min_ts 
from dba_audit_trail) minaud, (select max(timestamp) max_ts 
from dba_audit_trail) maxaud);
-- Audit Table SIZE
select '<tr><td' 
  || case when MB > 500 then ' class="critical"' when MB > 200 then ' class="warning"' else ' class="good"' end 
  || '>Audit Table Size</td>' 
  || '<td>AUD$ size ' 
  || round(to_number(mb)) 
  || ' MB. Records: ' 
  || nvl( to_char(anz), 'null') 
  || '.</td></tr>'
from (select mb, anz 
from (select sum(bytes)/1024/1024 MB 
from dba_segments 
where segment_name = 'AUD$' 
and owner = 'SYS' 
and segment_type='TABLE') audsize, (select count(*) anz 
from dba_audit_trail) audcnt);
select '</table><br>' from dual;
---------------DB Size------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('abriss');
select '<a name="dbsize"><h3>DB Size</h3></a><br>' FROM dual;
select '<table><tr><th>GB allocated</th><th>GB used</th><th>GB free</th></tr>' FROM dual;
select '<tr><td class="number">' 
   || to_char(gb_files, '999g999g999g990d9') 
   || '</td><td class="number">' 
   || to_char(gb_alloc, '999g999g999g990d9') 
   || '</td><td class="number">' 
   || to_char(gb_files-gb_alloc, '999g999g999g990d9') 
   || '</td></tr>' 
from (select round(sum(s.bytes/1024/1024/1024),1) GB_alloc, avg((select round(sum(d.bytes)/1024/1024/1024,1) 
from v$datafile d)) GB_files from dba_segments s);
select '</table><br>' FROM dual;
--------------Linklist-------------------------------------------------------------------------------------------
prompt <hr><ul><li><h2>Overview</h2></li>
prompt <ul> -
       <li><a href="#banner">Components</a></li> -
       <li><a href="#database_properties">DB Properties</a></li> -
       <li><a href="#alert_log">Alert Log</a></li> -
       <li><a href="#alert_queue">Outstanding Alerts</a></li> -
       <li><a href="#alert_history">Alert History</a></li> -
       <li><a href="#parameter">Parameter</a></li> -
       <li><a href="#hparameter">Underscore Parameter</a></li> -
       <li><a href="#res_limit">Resource Limits</a></li> -
       <li><a href="#timemodel">Time Model</a></li> -
       </ul>
prompt <li><h2>Maintenance Report</h2></li>
prompt <ul> -
       <li><a href="#sgastat">SGA</a></li> -
       <li><a href="#dynamic_sga">SGA Dynamic Components</a></li> -
       <li><a href="#sgahistory">SGA History</a></li> -
       <li><a href="#hitratios">Hit Ratios</a></li> -
       <li><a href="#libcache">Library Cache</a></li> -
       <li><a href="#wait_event">Wait Events</a></li> -
       <li><a href="#space_management">Tablespace Space Management</a></li> -
       <li><a href="#tablespaces">Tablespaces</a></li> -
       <li><a href="#extend_issues">unable to extend issues</a></li> -
       <li><a href="#quotas">User Quotas</a></li> -
       <li><a href="#sga_advice">SGA Advice</a></li>
prompt <li><a href="#pga_advice">PGA Advice</a></li> -
       <li><a href="#pga_stat">PGA statistics</a></li> -
       <li><a href="#mem_advice">Memory Advice</a></li> -
       <li><a href="#session_cached_cursors">Session Cached Cursors</a></li> -
       <li><a href="#open_cursors">Open Cursors</a></li> -
       <li><a href="#undo">Undo Stats</a></li> -
       <li><a href="#flashback_db">Flashback Database</a></li> -
       <li><a href="#redolog_switches">Redolog Switches</a></li> -
       <li><a href="#file_io_stats">File I/O Statistics</a></li> -
       <li><a href="#file_io_timing">File I/O Timings</a></li> -
       <li><a href="#users">Users</a></li> -
       <li><a href="#users_def_pwd">Users with Default Password</a></li>
prompt <li><a href="#fra">Flash Recovery Area</a></li> -
       <li><a href="#rman_conf">RMAN Configuration</a></li> -
       <li><a href="#backups">Backups</a></li> -
       <li><a href="#all_backups">All Backups</a></li> -
       <li><a href="#missing_backups">Datafiles not backed up</a></li> -
       <li><a href="#unrecoverable">Unrecoverable Datafiles</a></li> -
       <li><a href="#arch_dest">Archive Destinations</a></li> -
       <li><a href="#reorg_tab">Reorg. Tables</a></li> -
       <li><a href="#top_segments">Top 30 Segments by size</a></li> -
       <li><a href="#system_segments">Segments in SYSTEM/SYSAUX not owned by SYS[TEM|MAN]</a></li> -
       <li><a href="#stale_statistics">Segments with stale or missing statistics</a></li> -
       <li><a href="#unindexed_keys">Unindexed Foreign Keys</a></li>
prompt <li><a href="#sequences">Sequences</a></li> -
       <li><a href="#jobs">Jobs</a></li> -
       <li><a href="#scheduler_job_runs">Scheduler Job History</a></li> -
       <li><a href="#autotask">Autotask Jobs</a></li> -
       <li><a href="#inv_obj">Invalid Objects</a></li> -
       <li><a href="#inv_index">Unusable Indexes</a></li> -
       <li><a href="#auditing">Auditing</a></li> -
       <li><a href="#top_sessions">Top Sessions</a></li> -
       <li><a href="#top_sql">Top SQL statements</a></li> -
       <li><a href="#top_sql_awr">Top SQL statements from AWR</a></li> -
       <li><a href="#awr_summary">AWR Summary</a></li> -
       <li><a href="#segs_logical">Top 10 Segments by logical reads</a></li> -
       <li><a href="#segs_physical">Top 10 Segments by physical reads</a></li> -
       <li><a href="#segs_writes">Top 10 Segments by physical writes</a></li> -
       <li><a href="#segs_changes">Top 10 Segments by block changes</a></li> -
       <li><a href="#segs_busy">Top 10 Segments by buffer busy waits</a></li> -
       <li><a href="#latches">Latch Hit Ratios</a></li> -
       <li><a href="#dataguard">Dataguard</a></li> -
       <li><a href="#rac_interconnect">RAC</a></li> -
       <li><a href="#asm">ASM</a></li> -
       </ul>
prompt <li><h2>Database Report</h2></li> -
       <ul> -
       <li><a href="#options">DB Options</a></li> -
       <li><a href="#sessions">DB Sessions</a></li> -
	   <li><a href="#health">Healthchecks</a></li> -
	   <li><a href="#dbsize">DB Size</a></li> -
       <li><a href="#dba_registry">DB-Registry</a></li> -
       <li><a href="#registry_history">Registry History</a></li> -
       <li><a href="#feature_usage">Feature Usage</a></li> -
       <li><a href="#db_growth">DB growth</a></li> -
       <li><a href="#schema_sizes">Schema Sizes</a></li> -
       <li><a href="#size_summary">Size Summary</a></li> -
       <li><a href="#all_files">All Files</a></li> -
       <li><a href="#db_links">Database Links</a></li> -
       <li><a href="#directories">Directories</a></li> -
       <li><a href="#roles">Roles</a></li> -
       <li><a href="#net-acls">Network ACLs</a></li> -
       </ul> -
       </ul>
---------------Components------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('banner');
prompt <hr /><a name="banner"><h3>Components</h3></a>
select '<table><tr><th><b>Components</b></th></tr>' FROM dual;
select '<tr><td>' || banner || '</td></tr>' FROM v$version;
select '</table><br>' FROM dual;
---------------Database Properties-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('database_properties');
prompt <a name="database_properties"><h3>Database Properties</h3></a>
select '<table><tr><th><b>Name</b></th><th><b>Value</b></th></tr>' FROM dual;
select '<tr><td>' 
  || property_name 
  || '</td><td>'
  || property_value 
  || '</td></tr>'
FROM database_properties 
order by property_name;
select '</table><br>' FROM dual;
---------------Alert Log-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('alert_log');
prompt <a name="alert_log"><h3>Alert Log</h3></a>
select '<table class="sortable"><tr><th><b>Timestamp</b></th><th><b>Host</b></th><th><b>IP</b></th><th><b>Message</b></th></tr>' FROM dual;
select '<tr><td>' 
  || to_char(ORIGINATING_TIMESTAMP, 'dd/mm/yyyy hh24:mi:ss') 
  || '</td><td>' 
  || host_id 
  || '</td><td>' 
  || host_address 
  || '</td><td>' 
  || MESSAGE_TEXT 
  || '</td></tr>' 
from sys.X$DBGALERTEXT
where (lower(MESSAGE_TEXT) like '%ora-%' or lower(MESSAGE_TEXT) like '%checkpoint not complete%') 
and ORIGINATING_TIMESTAMP > sysdate-:days_back 
order by ORIGINATING_TIMESTAMP desc;
select '</table><br>' FROM dual;
---------------Alert Queue-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('alert_queue');
prompt <a name="alert_queue"><h3>Outstanding Alerts</h3></a>
select '<table class="sortable"><tr><th><b>Severity</b></th><th><b>Target Name</b></th><th><b>Target Type</b></th><th><b>Category</b></th><th><b>Name</b></th><th><b>Message</b></th><th><b>Alert Timestamp</b></th></tr>' FROM dual;
select '<tr><td' 
  || DECODE(alert_state, 'Critical', ' class="critical">', '>') 
  || alert_state 
  || '</td><td>' 
  || target_name 
  || '</td><td>' 
  || (CASE target_type
  WHEN 'oracle_listener' THEN 'Oracle Listener'
  WHEN 'rac_database'    THEN 'Cluster Database'
  WHEN 'cluster'         THEN 'Clusterware'
  WHEN 'host'            THEN 'Host'
  WHEN 'osm_instance'    THEN 'OSM Instance'
  WHEN 'oracle_database' THEN 'Database Instance'
  WHEN 'oracle_emd'      THEN 'Oracle EMD'
  WHEN 'oracle_emrep'    THEN 'Oracle EMREP' ELSE target_type END) 
  || '</td><td>' 
  || metric_label 
  || '</td><td>' 
  || column_label 
  || '</td><td>' 
  || message 
  || '</td><td>' 
  || collection_timestamp 
  || '</td></tr>' 
FROM mgmt$alert_current
ORDER BY alert_state, collection_timestamp desc;
select '</table><br>' FROM dual;
---------------DBA_ALERT_HISTORY-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('alert_history');
prompt <a name="alert_history"><h3>Alert History</h3></a><a id="b_alert_history" href="javascript:switchdiv('d_alert_history')">(+)</a><div id="d_alert_history" style="display:none;">
select '<table class="sortable"><tr><th><b>Type</b></th><th><b>Object</b></th><th><b>Reason</b></th><th><b>Group</b></th><th><b>Instance</b></th><th><b>Timestamp</b></th><th><b>Resolution</b></th></tr>' from dual;
select '<tr><td' 
  || DECODE(MESSAGE_TYPE, 'Critical', ' class="critical">', '>') 
  || MESSAGE_TYPE 
  || '</td><td>' 
  || object_name 
  || '</td><td>' 
  || REASON 
  || '</td><td>' 
  || MESSAGE_GROUP 
  || '</td><td>' 
  || INSTANCE_NAME 
  || '</td><td>' 
  || to_char(CREATION_TIME,'dd/mm/yyyy hh24:mi:ss') 
  || '</td><td>' 
  || RESOLUTION 
  || '</td></tr>' 
FROM dba_alert_history 
ORDER BY MESSAGE_TYPE, CREATION_TIME desc;
select '</table><br>' FROM dual;
prompt </div>
---------------Parameter----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('parameter');
select '<a name="parameter"><h3>Parameter (not default)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Name</th><th>Instance</th><th>Value</th><th>Modified</th><th>Adjusted</th><th>Deprecated</th><th>Comment</th></tr>' FROM dual;
select '<tr><td>' 
  || name 
  || '</td><td>' 
  || instance_name 
  || '</td><td>'
  || display_value 
  || '</td><td>' 
  || ISMODIFIED 
  || '</td><td>' 
  || ISADJUSTED 
  || '</td><td>' 
  || decode(ISDEPRECATED, 'TRUE', ' class="warning"') 
  || ISDEPRECATED 
  || '</td><td>' 
  || UPDATE_COMMENT 
  ||'</td></tr>'
FROM gv$parameter p, gv$instance i
where p.inst_id = i.inst_id
and (isdefault = 'FALSE' or ismodified <> 'FALSE') -- catch parameters from init-file as well as system-modified ones
order by name, instance_name;
select '</table><br>' FROM dual;
--------------- Underscore Parameter------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('hidden parameter');
select '<a name="hparameter"><h3>Underscore Parameter</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Name</th><th>Value</th><th>Is Default</th><th>Type</th><th>Description</th></tr>' FROM dual;
select '<tr><td>' 
  || name 
  || '</td><td>' 
  || display_value 
  || '</td><td>' 
  || is_default 
  || '</td><td>' 
  || type 
  || '</td><td>' 
  || description 
  || '</td></tr>' 
FROM (select a.ksppinm name
        , b.ksppstvl display_value
		, b.ksppstdf is_default
		, decode (a.ksppity, 1,'boolean', 2,'string', 3,'number', 4,'file', a.ksppity) type
		, a.ksppdesc description 
	  from sys.x$ksppi a, sys.x$ksppcv b 
      where a.indx = b.indx and a.ksppinm like '\_%' escape '\' and b.ksppstdf <> 'TRUE')
order by name;
select '</table><br>' FROM dual;
--------------- Resource Limits------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('resource limits');
select '<a name="res_limit"><h3>Resource Limits</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Resource</th><th>Current</th><th>Max</th><th>Initial</th><th>Limit</th></tr>' FROM dual;
select '<tr><td>' 
  || instance_name 
  || '</td><td>' 
  || resource_name 
  || '</td><td class="number">' 
  || current_utilization 
  || '</td><td class="number">' 
  || max_utilization 
  || '</td><td class="number">' 
  || initial_allocation 
  || '</td><td class="number">' 
  || limit_value 
  || '</td></tr>' 
FROM gv$instance i, gv$resource_limit r
where i.inst_id = r.inst_id
order by i.inst_id, r.resource_name;
select '</table><br>' FROM dual;
--------------- Time Model------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('timemodel');
begin
  dbms_output.put_line('<a name="timemodel"><h3>Time Model (since instance startup)</h3></a>');
  dbms_output.put_line('<table>');
for rec in (select inst_id, instance_name from gv$instance order by 1) 
loop
  dbms_output.put_line('<tr><th>Instance</th><th>Value (s)</th><th>Pct of parent</th><th>Statistic</th></tr>');
  for tm in 
    (select '<tr><td>' 
	   || rec.instance_name 
	   || '</td><td class="number">' 
	   || to_char(round(tm.value/1000000, 1), '999g999g999g990d0') 
	   || '</td><td class="number">' 
	   || round(value/(prior value)*100) 
	   || '</td><td>' 
	   || lpad(' ', 2*(level-1), '-') 
	   || tm.stat_name 
	   || '</td></tr>' txt 
	 from (select 0 id, null parent, 'DB time' stat_name from dual
      union all
      select 1, 0, 'DB CPU' from dual
      union all
      select 2, null, 'background elapsed time' from dual
      union all
      select 3, 2, 'background cpu time' from dual
      union all
      select 4, 0, 'sequence load elapsed time' from dual
      union all
      select 5, 7, 'parse time elapsed' from dual
      union all
      select 6, 5, 'hard parse elapsed time' from dual
      union all
      select 7, 0, 'sql execute elapsed time' from dual
      union all
      select 8, 0, 'connection management call elapsed time' from dual
      union all
      select 9, 5, 'failed parse elapsed time' from dual
      union all
      select 10, 9, 'failed parse (out of shared memory) elapsed time' from dual
      union all
      select 11, 6, 'hard parse (sharing criteria) elapsed time' from dual
      union all
      select 12, 11,'hard parse (bind mismatch) elapsed time' from dual
      union all
      select 13, 0, 'PL/SQL execution elapsed time' from dual
      union all
      select 14, 0, 'inbound PL/SQL rpc elapsed time' from dual
      union all
      select 15, 0, 'PL/SQL compilation elapsed time' from dual
      union all
      select 16, 0, 'Java execution elapsed time' from dual
      union all
      select 17, 0, 'repeated bind elapsed time' from dual
      union all
      select 18, 3, 'RMAN cpu time (backup/restore)' from dual) lev,
      (select tm1.stat_name
	     , tm1.value 
	   from gv$sys_time_model tm1 
	   where tm1.inst_id = rec.inst_id) tm 
	where lev.stat_name = tm.stat_name
connect by prior id=parent
start with parent is null)
loop
  dbms_output.put_line(tm.txt);
end loop;
  dbms_output.put_line('<!-- Instance ' || rec.instance_name || ' finished. -->');
end loop;
  dbms_output.put_line('</table><br>');
end;
/
--------------- Time Model AWR------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('timemodel');
declare
  begin_snap number;
  end_snap number;
begin
  dbms_output.put_line('<a name="timemodel_awr"><h3>AWR Time Model (last ' || to_char(:days_back) || ' days)</h3></a>');
  if :is_diag_licensed = 1 
  then
    dbms_output.put_line('<table>');
    for rec in (select inst_id, instance_name from gv$instance order by 1) loop
-- get first and last snap_id for given instance
    select max(snap_id) into begin_snap
    from  dba_hist_snapshot
    where begin_interval_time <= sysdate - :days_back
    and (dbid, instance_number) = (select dbid, rec.inst_id from v$database);
  if begin_snap is null 
  then
    select min(snap_id) into begin_snap
    from dba_hist_snapshot
    where (dbid, instance_number) = (select dbid, rec.inst_id from v$database);
  end if;
  select max(snap_id) into end_snap
  from dba_hist_snapshot
  where (dbid, instance_number) = (select dbid, rec.inst_id from v$database);
dbms_output.put_line('<!-- Instance ' || rec.instance_name || ' starting, snaps from ' || to_char(begin_snap) || ' till ' || to_char(end_snap) || '. -->');
dbms_output.put_line('<tr><th>Instance</th><th>Value (s)</th><th>Pct of parent</th><th>Statistic</th></tr>');
  for tm in 
  (select '<tr><td>' 
     || rec.instance_name 
	 || '</td><td class="number">' 
	 || to_char(round(tm.value/1000000, 1), '999g999g999g990d0') 
	 || '</td><td class="number">' 
	 || round(case when value = 0 then null else value end / (prior value)*100) 
	 || '</td><td>' 
	 || lpad(' ', 2*(level-1), '-') 
	 || tm.stat_name 
	 ||'</td></tr>' txt 
   from (select 0 id, null parent, 'DB time' stat_name from dual
  union all
  select 1, 0, 'DB CPU' from dual
  union all
  select 2, null, 'background elapsed time' from dual
  union all
  select 3, 2, 'background cpu time' from dual
  union all
  select 4, 0, 'sequence load elapsed time' from dual
  union all
  select 5, 7, 'parse time elapsed' from dual
  union all
  select 6, 5, 'hard parse elapsed time' from dual
  union all
  select 7, 0, 'sql execute elapsed time' from dual
  union all
  select 8, 0, 'connection management call elapsed time' from dual
  union all
  select 9, 5, 'failed parse elapsed time' from dual
  union all
  select 10, 9, 'failed parse (out of shared memory) elapsed time' from dual
  union all
  select 11, 6, 'hard parse (sharing criteria) elapsed time' from dual
  union all
  select 12, 11, 'hard parse (bind mismatch) elapsed time' from dual
  union all
  select 13, 0, 'PL/SQL execution elapsed time' from dual
  union all
  select 14, 0, 'inbound PL/SQL rpc elapsed time' from dual
  union all
  select 15, 0, 'PL/SQL compilation elapsed time' from dual
  union all
  select 16, 0, 'Java execution elapsed time' from dual
  union all
  select 17, 0, 'repeated bind elapsed time' from dual
  union all
  select 18, 3, 'RMAN cpu time (backup/restore)' from dual) lev, 
  (select tm1.stat_name
     , tm2.value - tm1.value value 
   from dba_hist_sys_time_model tm1, dba_hist_sys_time_model tm2 
   where tm1.stat_name = tm2.stat_name 
   and tm1.snap_id = begin_snap 
   and tm1.INSTANCE_NUMBER = rec.inst_id 
   and tm2.snap_id = end_snap 
   and tm2.INSTANCE_NUMBER = rec.inst_id) tm 
where lev.stat_name = tm.stat_name 
connect by prior id=parent 
start with parent is null)
  loop
    dbms_output.put_line(tm.txt);
  end loop;
    dbms_output.put_line('<!-- Instance ' || rec.instance_name || ' finished. -->');
  end loop;
    dbms_output.put_line('</table><br>');
  end if;
end;
/
---------------SGA------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('sgastat');
prompt <hr>
select '<a name="sgastat"><h3>SGA</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Pool</th><th>Area</th><th>MB</th></tr>' FROM dual;
select '<tr><td>' 
  || instance_name 
  || '</td><td>' 
  || pool 
  || '</td><td>' 
  || decode(name,'free memory', 'free', 'used') 
  || '</td><td class="number">' 
  || to_char(sum(bytes/1024/1024), '999g999g999g990d999') 
  || '</td></tr>' 
from gv$sgastat sa, gv$instance i
where sa.inst_id = i.inst_id
group by instance_name, pool, decode(name,'free memory', 'free', 'used')
order by instance_name, pool, decode(name,'free memory', 'free', 'used');
select '</table><br>' FROM dual;
---------------dynamic SGA components------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('dynamic_sga');
prompt <hr>
select '<a name="dynamic_sga"><h3>SGA Dynamic Components</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Component</th><th>Current MB</th><th>Min MB</th><th>Max MB</th><th>User-Specified MB</th><th>Operations #</th><th>Last Operation Type</th><th>Last Operation Mode</th><th>Last Operation Time</th></tr>' FROM dual;
select '<tr><td>' 
  || instance_name 
  || '</td><td>' 
  || COMPONENT 
  || '</td><td class="number">' 
  || to_char(CURRENT_SIZE/1024/1024, '999g999g999g990d999') 
  || '</td><td class="number">' 
  || to_char(MIN_SIZE/1024/1024, '999g999g999g990d999') 
  || '</td><td class="number">' 
  || to_char(MAX_SIZE/1024/1024, '999g999g999g990d999') 
  || '</td><td class="number">' 
  || to_char(USER_SPECIFIED_SIZE/1024/1024, '999g999g999g990d999') 
  || '</td><td class="number">' 
  || oper_count 
  || '</td><td>' 
  || last_oper_type 
  || '</td><td>'
  || last_oper_mode 
  || '</td><td>' 
  || last_oper_time 
  || '</td></tr>' 
from gv$sga_dynamic_components sa, gv$instance i
where sa.inst_id = i.inst_id
order by instance_name, COMPONENT;
select '</table><br>' FROM dual;
---------------Hit ratios--------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('hitratios');
select '<a name="hitratios"><h3>Hit Ratios</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Statistic</th><th>Value %</th></tr>' FROM dual;
select '<tr><td>Buffercache hit ratio</td>' 
  || '<td class="number' 
  || case when 1-p.value/(c.value+cn.value) < 0.80 then 'critical' when 1-p.value/(c.value+cn.value) < 0.95 then 'warning' else 'good' end 
  || '">' 
  || to_char(ROUND((1-p.value/(c.value+cn.value))*100,3),'990.000') 
  || '</td></tr>' 
FROM v$sysstat p, v$sysstat c, v$sysstat cn
WHERE c.name='db block gets'
AND cn.name='consistent gets'
AND p.name='physical reads';
select '<tr><td>Dictionary hit ratio</td>' 
  || '<td class="number' 
  || case when hitratio < 80 then 'critical' when hitratio < 95 then 'warning' else 'good' end 
  || '">' 
  || to_char(hitratio, '990.000') 
  || '</td></tr>'
FROM (select sum(GETS) as Gets, sum(GETMISSES) as Misses, round((1 - (sum(GETMISSES) / sum(GETS))) * 100, 3) as hitratio from gv$rowcache);
select '<tr><td>SQL hit ratio</td>' 
  || '<td class="number' 
  || case when hitratio < 80 then 'critical' when hitratio < 95 then 'warning' else 'good' end 
  || '">' 
  || TO_CHAR(hitratio, '990.000') 
  || '</td></tr>'
FROM (select sum(PINS) Pins, sum(RELOADS) Reloads, round((sum(PINS) - sum(RELOADS)) / sum(PINS) * 100, 3) as  hitratio from gv$librarycache);
select '<tr><td>Library miss ratio</td>' 
  || '<td class="number' 
  || case when missratio > 20 then 'critical' when missratio > 5 then 'warning' else 'good' end 
  || '">' 
  || TO_CHAR(missratio, '990.000') 
  || '</td></tr>'
FROM (select sum(PINS) Executions, sum(RELOADS) cache_misses, round(sum(RELOADS) / sum(PINS) * 100, 3) as missratio from gv$librarycache);
select '<tr><td>Sorts (disk/memory)</td>' 
  || '<td class="number' 
  || case when c.value/cn.value > 0.10 then 'critical' when c.value/cn.value > 0.05 then 'warning' else 'good' end 
  || '">' 
  || TO_CHAR(ROUND(c.value/cn.value*100,3),'990.000') 
  || '</td></tr>'
FROM v$sysstat c, v$sysstat cn
WHERE c.name='sorts (disk)'
AND cn.name='sorts (memory)';
select '</table><br>' FROM dual;
---------------LibraryCache hit ratios-------------------------------------------------------------------------
set colsep ''
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('libcache');
select '<a name="libcache"><h3>Hit- / Pin-Stats LibraryCache</h3></a>' FROM dual;
select '<table class="sortable"><thead><tr><th>Area</th><th>Gets</th><th>GetHits</th><th>Quote</th><th>Pins</th><th>PinHits</th><th>Ratio</th><th>Reloads</th><th>Reloadrate</th><th>Invalidations</th></tr></thead><tbody>' FROM dual;
select '<tr><td>' 
  || namespace, '</td><td class="number">' 
  || gets, '</td><td class="number">' 
  || gethits, '</td><td class="number' 
  || case when gets = 0 then 'good' when gethits*100/gets > 95 then 'good' when gethits*100/gets > 80 then 'warning' else 'critical' end 
  || '">' 
  || case when gets = 0 then '-' else TO_CHAR(ROUND(gethits*100/gets,3),'990.000') ||'%' end 
  || '</td><td class="number">' 
  || pins, '</td><td class="number">' 
  || pinhits, '</td><td class="number">' 
  || DECODE(pins,0,'-',CONCAT(TO_CHAR(ROUND(pinhits*100/pins,3),'990.000'),'%')), '</td><td class="number">' 
  || reloads, '</td><td class="number' 
  || case when pins = 0 then 'good' when reloads*100/pins < 0.5 then 'good' when reloads*100/pins < 1 then 'warning' else 'critical' end 
  || '">' 
  || case when pins = 0 then '-' else TO_CHAR(ROUND(reloads*100/pins,3),'990.000') 
  || '%' end 
  || '</td><td class="number">' 
  || invalidations 
  || '</td></tr>'
FROM v$librarycache
ORDER BY namespace;
select '</tbody><tfoot>' FROM dual;
select '<tr><td><b>Sum'
  , '</td><td class="number"><b>' 
  || SUM(gets), '</td><td class="number"><b>' 
  || SUM(gethits), '</td><td class="number' 
  || case when sum(gets) = 0 then 'good' when sum(gethits)*100/sum(gets) > 95 then 'good' when sum(gethits)*100/sum(gets) > 80 then 'warning' else 'critical' end 
  || '"><b>' 
  || CONCAT(TO_CHAR(ROUND(SUM(gethits)*100/SUM(gets),3),'990.000'),'%'), '</td><td class="number"><b>' 
  || SUM(pins)
  , '</td><td class="number"><b>' 
  || SUM(pinhits)
  , '</td><td class="number"><b>' 
  || CONCAT(TO_CHAR(ROUND(SUM(pinhits)*100/SUM(pins),3),'990.000'),'%'), '</td><td class="number"><b>' 
  || SUM(reloads), '</td><td class="number' 
  || case when sum(pins) = 0 then 'good' when sum(reloads)*100/sum(pins) < 0.5 then 'good' when sum(reloads)*100/sum(pins) < 1 then 'warning' else 'critical' end 
  || '"><b>' 
  || CONCAT(TO_CHAR(ROUND(SUM(reloads)*100/SUM(pins),3),'990.000'),'%'), '</td><td class="number"><b>' 
  || SUM(invalidations) 
  || '</td></tr>'
FROM v$librarycache;
select '</tfoot></table><br>' FROM dual;
---------------Wait Events-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('wait_event');
select '<a name="wait_event"><h3>Waits (since instance startup)</h3></a><h3>Top 10 Wait Events</h3>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Event</th><th>Waits #</th><th>Wait Time (s)</th><th>Quota %</th><th>Avg Wait (ms)</th><th>Class</th></tr>' FROM dual;
select '<tr><td>' 
  || instance_name 
  || '</td><td>' 
  || event 
  || '</td><td class="number">' 
  || TOTAL_WAITS 
  || '</td><td class="number">' 
  || round(TIME_WAITED) 
  || '</td><td class="number' 
  || case when pct_waited >= 0.5 then 'critical' when pct_waited >= 0.2 then 'warning' end 
  || '">' 
  || to_char(round(pct_waited*100,1), '999D0') 
  || '</td><td class="number">' 
  || round(AVERAGE_WAIT*10,2)
  || '</td><td>' 
  || WAIT_CLASS 
  || '</td></tr>'
from (select instance_name
        , event
		, total_waits
		, time_waited
		, TIME_WAITED/sum(time_waited) over () pct_waited
		, average_wait
		, wait_class 
	  from (select inst_id
	          , event
			  , TOTAL_WAITS
			  , TIME_WAITED/100 time_waited
			  , AVERAGE_WAIT
			  , WAIT_CLASS 
			from (select * from gv$system_event where lower(wait_class) != 'idle' 
    and event != 'Null event' 
    and event != 'rdbms ipc message' 
    and event != 'pipe get' 
    and event != 'virtual circuit status' 
    and event not like '%timer%' 
    and event not like 'SQL*Net message from %' 
    and event not like 'SQL*Net vector data from %') e
    where time_waited > 0
    UNION ALL
    select inst_id, 'server CPU' event, null total_waits, SUM (VALUE / 1000000) waited, null average_wait, 'CPU' wait_class FROM gv$sys_time_model WHERE stat_name IN ('background cpu time', 'DB CPU') GROUP BY inst_id) e, gv$instance i where e.inst_id = i.inst_id order by 5 desc)
   where rownum <= 10;
select '</table><br>' FROM dual;
select '<h3>Top 5 System Wait Classes</h3>' FROM dual;
select '<table class="sortable"><tr><th>Event</th><th>Waits #</th><th>Wait Time (s)</th><th>Quota %</th></tr>' FROM dual;
select '<tr><td>' 
  || WAIT_CLASS 
  || '</td><td>' 
  || TOTAL_WAITS 
  || '</td><td class="number">' 
  || TIME_WAITED 
  || '</td><td class="number' 
  || case when pct_waited >= 0.5 then 'critical' when pct_waited >= 0.2 then 'warning' end 
  || '">' 
  || to_char(round(pct_waited*100,1), '999D0') 
  || '</td></tr>' 
from (select WAIT_CLASS, TOTAL_WAITS, TIME_WAITED, TIME_WAITED / sum(time_waited) over () pct_waited
from (select WAIT_CLASS, sum(TOTAL_WAITS) TOTAL_WAITS, round(sum(TIME_WAITED)/100) AS TIME_WAITED 
from GV$SYSTEM_WAIT_CLASS 
group by WAIT_CLASS) order by 3 desc)
where rownum <=5;
select '</table><br>' FROM dual;
select '<h3>Top 5 DB-CPU Activity</h3>' FROM dual;
select '<table class="sortable"><tr><th>Event</th><th>Wait Time (s)</th><th>Quota %</th></tr>' FROM dual;
select '<tr><td>' 
  || STAT_NAME 
  || '</td><td class="number">' 
  || TIME_WAITED 
  || '</td><td class="number' 
  || case when pct_waited >= 0.5 then 'critical' when pct_waited >= 0.2 then 'warning' end 
  || '">' 
  || to_char(round(pct_waited*100,1), '999D0') 
  || '</td></tr>'
from (select STAT_NAME
        , time_waited
		, TIME_WAITED/sum(time_waited) over () pct_waited 
	  from (select STAT_NAME
	          , round(sum(VALUE)/(1000*1000)) AS time_waited 
			from GV$SYS_TIME_MODEL 
			group by STAT_NAME) 
			order by 2 desc)
where rownum <= 5;
select '</table><br>' FROM dual;
select '<h3>DB-Time ratios</h3>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Interval (s)</th><th>Metric</th><th>Value</th><th>Unit</th></tr>' FROM dual;
select '<tr><td>' 
  || instance_name 
  || '</td><td>' 
  || intsize 
  || '</td><td>' 
  || METRIC_NAME 
  || '</td><td class="number">' 
  || to_char(round(VALUE, 2), '999D0') 
  || '</td><td>' 
  || METRIC_UNIT 
  || '</td></tr>' 
from (select inst_id
        , round(INTSIZE_CSEC/100) AS intsize
		, METRIC_NAME
		, VALUE
		, METRIC_UNIT 
	  from gv$sysmetric
	  where METRIC_NAME = 'Database Wait Time Ratio' and round(INTSIZE_CSEC/100) = 60
	  union all
	  select inst_id
	    , round(INTSIZE_CSEC/100) AS "Interval (s)"
		, METRIC_NAME
		, VALUE
		, METRIC_UNIT 
	  from gv$sysmetric
	  where METRIC_NAME = 'Database CPU Time Ratio' 
	  and round(INTSIZE_CSEC/100) = 60) m, gv$instance i 
	  where i.inst_id = m.inst_id;
select '</table><br>' FROM dual;
---------------Tablespace Space Management------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('tablespace space management');
select '<a name="space_management"><h3>Tablespace Space Management (dictionary managed, no ASSM)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Tablespace</th><th>Extent Mgmt</th><th>Allocation</th><th>Segment Space Mgmt</th></tr>' FROM dual;
select '<tr><td>' 
  || tablespace_name 
  || '</td><td>' 
  || extent_management 
  || '</td><td>' 
  || allocation_type 
  || '</td><td>' 
  || segment_space_management 
  || '</td></tr>' 
from dba_tablespaces
where (extent_management <> 'LOCAL' or segment_space_management <> 'AUTO')
order by tablespace_name;
select '</table><br>' FROM dual;
---------------Tablespaces------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('tablespaces');
select '<a name="tablespaces"><h3>Tablespaces (>50% full OR Top 30)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Tablespace</th><th width="100px">Graph</th><th>% full</th><th>MB total</th><th>MB Files</th><th>MB free in Files</th><th>MB free</th><th>% free in Files</th><th># Files</th><th>Extent Mgmt</th><th>Allocation</th><th>Segment Space Mgmt</th></tr>' FROM dual;
select '<tr><td>' 
  || tablespace_name 
  || '</td><td><table class="BarGraph"><tr height="10px"><td class="' 
  || case when pct_free <= :ts_pct_free_critical then 'FullCritical' when pct_free <= :ts_pct_free_warn then 'FullWarning' else 'FullGreen' end 
  || '" width="' 
  || round(100-pct_free) 
  || 'px"></td><td class="EmptyRight" width="' 
  || round(pct_free) 
  || 'px"></td></tr></table>' 
  || '</td><td class="number">' 
  || to_char(100-pct_free) 
  || '</td><td class="number">' 
  || to_char(round(mb_gesamt), '999g999g999g999') 
  || '</td><td class="number">' 
  || to_char(round(mb_file), '999g999g999g999') 
  || '</td><td class="number">' 
  || to_char(round(mb_free), '999g999g999g999') 
  || '</td><td class="number">' 
  || to_char(round(mb_free+mb_autoalloc), '999g999g999g999') 
  || '</td><td class="number">' 
  || to_char(pct_free_file) 
  || '</td><td class="number">' 
  || to_char(cnt_files) 
  || '</td><td>' 
  || extent_management 
  || '</td><td>' 
  || allocation_type 
  || '</td><td>' 
  || segment_space_management 
  || '</td></tr>'
from (select mb_file
        , mb_free
		, mb_autoalloc
		, mb_gesamt
		, cnt_files
		, t.tablespace_name
		, t.extent_management
		, t.allocation_type
		, t.segment_space_management
		, round(mb_free/mb_file*100, 1) pct_free_file
		, round((mb_free+mb_autoalloc)/mb_gesamt*100, 1) pct_free
		, row_number() over (order by mb_free/mb_file*100) rn 
      from dba_tablespaces t, (select sum(greatest(BYTES,MAXBYTES))/1024/1024 mb_gesamt
	                             , sum(bytes)/1024/1024 mb_file
								 , sum(greatest(BYTES,MAXBYTES)-BYTES)/1024/1024 mb_autoalloc
								 , count(file_name) cnt_files
								 , TABLESPACE_NAME 
							  from dba_data_files 
                              group by TABLESPACE_NAME) f, (select sum(BYTES)/1024/1024 mb_free, TABLESPACE_NAME from dba_free_space group by TABLESPACE_NAME) fs
where t.tablespace_name = f.tablespace_name
and   t.tablespace_name = fs.tablespace_name
and   t.contents = 'PERMANENT')
where pct_free < 50 or rn < 30
order by pct_free;
select '</table><br>' FROM dual;
---------------User Quotas------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('quotas');
select '<a name="quotas"><h3>User Quotas (>50% full OR Top 30)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>User</th><th>Tablespace</th><th width="100px">Graph</th><th>% free</th><th>MB allocated</th><th>MB allowed</th></tr>' FROM dual;
select '<tr><td>' 
  || username 
  || '</td><td>' 
  || tablespace_name 
  || '</td><td><table class="BarGraph"><tr height="10px"><td class="' 
  || case when pct_free <= 5 then 'FullCritical' when pct_free <= 15 then 'FullWarning' else 'FullGreen' end 
  || '" width="' 
  || round(100-pct_free) 
  || 'px"></td><td class="EmptyRight" width="' 
  || round(pct_free) 
  || 'px"></td></tr></table>' 
  || '</td><td class="number">' 
  || to_char(round(pct_free, 1)) 
  || '</td><td class="number">' 
  || to_char(round(mb), '999g999g999g999') 
  || '</td><td class="number">' 
  || to_char(round(mb_max), '999g999g999g999') 
  || '</td></tr>'
from (select /*+RULE*/ USERNAME                   -- RULE hint as fix for Bug 6613821
        , TABLESPACE_NAME
        , BYTES/1024/1024 MB 
        , MAX_BYTES/1024/1024 MB_MAX
        , 100-BYTES/MAX_BYTES*100 pct_free
        , row_number() over (order by BYTES/MAX_BYTES desc) rn
      from dba_ts_quotas
      where max_bytes > 1)                        -- unlimited Quota = -1; no Quota = 0
where pct_free < 50 or rn < 30
order by pct_free;
select '</table><br>' FROM dual;
---------------unable to extend issues----------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('extend issues');
select '<a name="extend_issues"><h3>Unable to Extend Issues (TS>640MB: 1x 64MB must fit, TS<640MB: min 10% space left)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Tablespace</th><th>MB total</th><th>MB free</th></tr>' FROM dual;
select /* extent check DMTs, LMTs  */
   '<tr><td>' 
   || tablespace_name 
   || '</td><td>' 
   || mb_gesamt 
   || '</td><td>' 
   || round(mb_free, 1) 
   || '</td></tr>' 
FROM (select t.tablespace_name
        , mb_gesamt
		, mb_free+mb_autoalloc mb_free 
      from dba_tablespaces t, (select sum(greatest(BYTES,MAXBYTES))/1024/1024 mb_gesamt
	                             , sum(greatest(BYTES,MAXBYTES)-BYTES)/1024/1024 mb_autoalloc
								 , TABLESPACE_NAME 
							   from dba_data_files 
							   group by TABLESPACE_NAME) f, (select sum(BYTES)/1024/1024 mb_free, TABLESPACE_NAME from dba_free_space group by TABLESPACE_NAME) fs
where t.tablespace_name = f.tablespace_name
and   t.tablespace_name = fs.tablespace_name
and   t.contents = 'PERMANENT')
where (mb_free <= 64 /* 64MB */ 
and mb_gesamt >= 640) or (mb_free < (mb_gesamt/10) 
and mb_gesamt < 640)
order by tablespace_name;
select '</table><br>' FROM dual;
---------------SGA Advice------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('sga_advice');
select '<a name="sga_advice"><h3>SGA Advice</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>SGA Size MB</th><th>Size Factor</th><th>Time Factor</th><th>Est. DB-Time</th><th>Diff next size</th></tr>' FROM dual;
select '<tr><td>' 
  || instance_name 
  || '</td><td class="number">' 
  || to_char(sga_size, '999g999g999') 
  || '</td><td class="number">' 
  || round(sga_size_factor*100) 
  || '%' 
  || '</td><td class="number">' 
  || round(ESTD_DB_TIME_FACTOR*100) 
  || '%' 
  || '</td><td class="number">' 
  || ESTD_DB_TIME 
  || '</td><td' 
  || case when (diff_next_time) < 0.06 then ' class="good">' when (diff_next_time) is null then ' class="good">' else '>' end 
  || round( diff_next_time*100, 1) 
  || '%' 
  || '</td></tr>'
from (select instance_name
        , sga_size
		, sga_size_factor
		, ESTD_DB_TIME_FACTOR
		, ESTD_DB_TIME
		, (ESTD_DB_TIME -lead(ESTD_DB_TIME) over (partition by sa.inst_id 
	  order by SGA_SIZE_FACTOR))/ESTD_DB_TIME diff_next_time 
	  from gv$sga_target_advice sa, gv$instance i
      where sa.inst_id = i.inst_id) sga
order by instance_name, sga_size;
select '</table><br>' FROM dual;
---------------PGA advise------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('pga_advice');
select '<a name="pga_advice"><h3>PGA Advice</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>PGA Target MB</th><th>Size Factor</th><th>Status</th><th>Cache Hit %</th><th># Overallocations</th></tr>' FROM dual;
select '<tr><td>' 
  || instance_name 
  || '</td><td class="number">' 
  || to_char(PGA_TARGET_FOR_ESTIMATE/1024/1024, '999g999g999') 
  || '</td><td class="number">' 
  || round(PGA_TARGET_FACTOR*100) 
  || '%'
  || '</td><td class="number">' 
  || ADVICE_STATUS 
  || '</td><td' 
  || case when (ESTD_PGA_CACHE_HIT_PERCENTAGE) > 98 then ' class="good">' else '>' end 
  || ESTD_PGA_CACHE_HIT_PERCENTAGE 
  || '</td><td' 
  || case when (ESTD_OVERALLOC_COUNT) = 0 then ' class="good">' else '>' end 
  || ESTD_OVERALLOC_COUNT 
  || '</td></tr>'
from gv$pga_target_advice pa, gv$instance i
where pa.inst_id = i.inst_id
order by instance_name, PGA_TARGET_FOR_ESTIMATE;
select '</table><br>' FROM dual;
---------------PGA stat------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('pga_stat');
select '<a name="pga_stat"><h3>Top 10 PGA usage per instance</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Username</th><th>OS User</th><th>Program</th><th>machine</th><th>PGA allocated (MB)</th><th>max PGA (MB)</th></tr>' FROM dual;
select '<tr><td>' 
  || instance_name 
  || '</td><td>' 
  || username 
  || '</td><td>' 
  || osuser 
  || '</td><td>' 
  || program 
  || '</td><td>' 
  || machine 
  || '</td><td class="number">' 
  || to_char(pga_alloc_mb, '999g999g999') 
  || '</td><td class="number">' 
  || to_char(pga_max_mb, '999g999g999') 
  || '</td></tr>'
from (select i.instance_name
        , s.username
        , s.osuser
        , s.program
        , s.machine
        , p.pga_alloc_mem/1024/1024 pga_alloc_mb
        , p.pga_max_mem/1024/1024 pga_max_mb
        , row_number() over (partition by i.instance_name order by pga_alloc_mem desc) ranking
      from gv$instance i, gv$session s, gv$process p
      where p.inst_id = i.inst_id
      and i.inst_id = s.inst_id
      and s.username is not null)
where ranking <= 10
order by instance_name, ranking;
select '</table><br>' FROM dual;
---------------MEM Advice------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('pga_stat');
select '<a name="mem_advice"><h3>Memory Advice</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>SGA Size MB</th><th>Size Factor</th><th>Time Factor</th><th>Est. DB-Time</th><th>Diff next size</th></tr>' FROM dual;
SELECT '<tr><td>' 
  || instance_name 
  || '</td><td class="number">' 
  || to_char(memory_size, '999g999g999') 
  || '</td><td class="number">' 
  || round(memory_size_factor*100) 
  || '%' 
  || '</td><td class="number">' 
  || round(ESTD_DB_TIME_FACTOR*100) 
  || '%' 
  || '</td><td class="number">' 
  || ESTD_DB_TIME 
  || '</td><td' 
  || case when (diff_next_time) < 0.06 then ' class="good">' when (diff_next_time) is null then ' class="good">' else '>' end 
  || round( diff_next_time*100, 1) 
  || '%' 
  || '</td></tr>'
from (select instance_name
        , memory_size
	    , memory_size_factor
	    , ESTD_DB_TIME_FACTOR
	    , ESTD_DB_TIME
	    , (ESTD_DB_TIME -lead(ESTD_DB_TIME) over (partition by sa.inst_id order by MEMORY_SIZE_FACTOR))/ESTD_DB_TIME diff_next_time
      from gv$memory_target_advice sa, gv$instance i 
	  where sa.inst_id = i.inst_id) sga
order by instance_name, memory_size;
select '</table><br>' FROM dual;
---------------Session Cached Cursors-----------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('session_cached_cursors');
select '<a name="session_cached_cursors"><h3>Session Cached Cursors</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Sessions#</th><th>Sessions %</th><th>Cached Cursors#</th></tr>' FROM dual;
select '<tr><td class="number">' 
  || to_char(amount, '999g999') 
  || '</td><td class="number">' 
  || to_char(sess_pct, '990d0') 
  || '%' 
  || '</td><td class="number">' 
  || to_char(cursors_cached, '999g999') 
  || '</td></tr>' 
from (select sum(amount) amount
        , sum(amount)/s.sess#*100 sess_pct
		, trunc(SESSION_CACHED_CURSORS/(p.value/10)) * (p.value/10) cursors_cached 
      from (select trunc(value) SESSION_CACHED_CURSORS
	          , count(*) Amount 
			from gv$sesstat seval, gv$session se, v$statname sname 
			where name = 'session cursor cache count' 
			and seval.statistic# = sname.statistic#
            and seval.sid = se.sid
            and seval.inst_id = se.inst_id
            and se.username is not null
            group by trunc(value)
            order by 1) c,
(select to_number(value) value from v$parameter where name='session_cached_cursors') p,
(select count(*) sess# from v$session where username is not null) s
group by  trunc(SESSION_CACHED_CURSORS / (p.value/10) ) * (p.value/10), s.sess#
order by trunc(SESSION_CACHED_CURSORS / (p.value/10) ) * (p.value/10));
select '</table><br>' FROM dual;
---------------Open Cursors-----------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('open_cursors');
select '<a name="open_cursors"><h3>Top 10 Session by Open Cursors</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Username</th><th>Program</th><th>Machine</th><th>Open Cursors#</th></tr>' FROM dual;
select '<tr><td>'
  || instance_name 
  || '</td><td>' 
  || username 
  || '</td><td>' 
  || program 
  || '</td><td>' 
  || machine 
  || '</td><td class="number' 
  || case when (total_cur/max_cur) > 0.9 then 'critical' when (total_cur/max_cur) > 0.8 then 'warning' else '>' end 
  || '">' 
  || to_char(trunc(total_cur), '999g999') 
  || ' / ' 
  || to_char(trunc(max_cur), '999g999') 
  || '</td></tr>' 
from (select i.instance_name
        , s.username
		, s.program
		, s.machine
		, a.value total_cur
		, p.value max_cur
		, row_number() over (partition by i.inst_id order by a.value desc) rn
	  from gv$sesstat a, v$statname b, gv$session s, gv$instance i, (select to_number(value) value from v$parameter where name='open_cursors') p
	  where a.statistic# = b.statistic#
	  and s.sid=a.sid
	  and s.inst_id = a.inst_id
	  and s.inst_id = i.inst_id
	  and b.name = 'opened cursors current'
	order by i.instance_name asc, a.value desc)
where rn <= 10;
select '</table><br>' FROM dual;
---------------Undo Stats------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('undo');
select '<a name="undo"><h3>Undo Stats</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Actual UNDO-Tbs Size [MB]</th><th>Undo Retention (min)</th><th>Undo MB per min</th><th>Req. UNDO Space [MB]</th><th>Optimal Undo Retention (min)</th></tr>' FROM dual;
select '<tr><td>' 
  || d.instance_name, '</td><td class="number">' 
  || d.undo_size/(1024*1024)
  || '</td><td class="number">'
  || SUBSTR(ur.value/60,1,25) 
  || '</td><td class="number">' 
  || ROUND(us.undo_block_per_sec*bs.value/1024/1024*60) 
  || '</td><td class="number">' 
  || ROUND((us.undo_block_per_sec*bs.value/1024/1024) * ur.value) 
  || '</td><td class="number">' 
  || ROUND((d.undo_size/(to_number(bs.value) * us.undo_block_per_sec))/60) 
  || '</tr></td>'
FROM (select SUM(a.bytes) undo_size
    , i.instance_name
    , i.inst_id
    FROM gv$instance i, gv$datafile a, gv$tablespace b, dba_tablespaces c
    WHERE c.contents = 'UNDO'
    AND c.status = 'ONLINE'
    AND b.name = c.tablespace_name
    AND a.ts# = b.ts#
    and i.inst_id = a.inst_id
    and i.inst_id = b.inst_id
    GROUP BY i.instance_name, i.inst_id) d,
    (select value, i.inst_id from gv$parameter p, gv$instance i where p.inst_id = i.inst_id and p.name = 'undo_retention') ur,
    (select value, i.inst_id from gv$parameter p, gv$instance i where p.inst_id = i.inst_id and p.name = 'db_block_size') bs,
    (select MAX(undoblks/((end_time-begin_time)*3600*24)) undo_block_per_sec, i.inst_id FROM gv$undostat g, gv$instance i WHERE g.inst_id = i.inst_id GROUP BY i.inst_id) us
WHERE d.inst_id = ur.inst_id
AND d.inst_id = bs.inst_id
AND d.inst_id = us.inst_id
order by d.instance_name;
select '</table><br>' FROM dual;
---------------Flashback Database------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('flashback_db');
select '<a name="flashback_db"><h3>Flashback Database</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Oldest Flashback Time</th><th>Retention Target (min)</th><th>Current Flashback Size (MB)</th><th>Estimated Flashback Size (MB)</th></tr>' FROM dual;
select '<tr><td>'
  || instance_name || '</td><td>'
  || OLDEST_FLASHBACK_TIME || '</td><td class="number">'
  || RETENTION_TARGET || '</td><td class="number">'
  || round(FLASHBACK_SIZE/1024/1024) || '</td><td class="number">'
  || round(ESTIMATED_FLASHBACK_SIZE/1024/1024) || '</td></tr>'
from gv$flashback_database_log fd, gv$instance i
where fd.inst_id = i.inst_id
order by instance_name;
select '</table><br>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Begin Time</th><th>End Time</th><th>Flashback Data written (MB)</th><th>DB Data read/written (MB)</th><th>Redo Data written (MB)</th><th>Estimated Flashback Size (MB)</th></tr>' FROM dual;
select '<tr><td>' || instance_name || '</td><td>'
  || begin_time || '</td><td>'
  || end_time || '</td><td class="number">'
  || round(FLASHBACK_DATA/1024/1024) || '</td><td class="number">'
  || round(DB_DATA/1024/1024) || '</td><td class="number">'
  || round(REDO_DATA/1024/1024) || '</td><td class="number">'
  || round(ESTIMATED_FLASHBACK_SIZE/1024/1024) || '</td></tr>'
from gv$flashback_database_stat fs, gv$instance i
where fs.inst_id = i.inst_id
order by instance_name, fs.begin_time;
select '</table><br>' FROM dual;
---------------Redolog Switches------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('redolog_switches');
prompt <a name="redolog_switches"><h3>Redolog Switches</h3></a><a id="b_redolog_switches" href="javascript:switchdiv('d_redolog_switches')">(+)</a><div id="d_redolog_switches" style="display:none;">
select '<p>Gelb = more than ' || :redo_warn || ' Switches OR more than ' || :redo_warn_mb || 'MB/h (' || :redo_warn_mb_pct || '% of DB size within 24h)</p>' || '<p>Rot = more than ' || :redo_critical || ' Switches OR more than ' || :redo_critical_mb || 'MB/h (' || :redo_critical_mb_pct || '% of DB size within 24h)</p>' FROM dual;
select '<table><tr><th>Thread#</th><th>Date</th><th>#/MB total</th><th>#</th><th>#/MB 00:00</th><th>#/MB 01:00</th><th>#/MB 02:00</th><th>#/MB 03:00</th><th>#/MB 04:00</th><th>#/MB 05:00</th><th>#/MB 06:00</th><th>#/MB 07:00</th><th>#/MB 08:00</th><th>#/MB 09:00</th><th>#/MB 10:00</th><th>#/MB 11:00</th><th>#/MB 12:00</th><th>#/MB 13:00</th><th>#/MB 14:00</th><th>#/MB 15:00</th><th>#/MB 16:00</th><th>#/MB 17:00</th><th>#/MB 18:00</th><th>#/MB 19:00</th><th>#/MB 20:00</th><th>#/MB 21:00</th><th>#/MB 22:00</th><th>#/MB 23:00</th></tr>' FROM dual;
select '<tr><td>' || thread || '</td><td>' || to_char(tag, 'dd/mm/yyyy') || '</td><td' || 
  case
	when ( AA ) > :redo_critical*24 or (MA > :redo_critical_mb*24) then ' class="critical">'
	when ( AA ) > :redo_warn*24 or (MA > :redo_warn_mb*24 ) then ' class="warning">'
	else '>' end || AA || ' / ' || MA || '</td><td/><td' ||
	case
	when ( A00 ) > :redo_critical or (M00 > :redo_critical_mb) then ' class="critical">'
	when ( A00 ) > :redo_warn or (M00 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A00 || ' / ' || M00 || '</td><td' ||
	case
	when ( A01 ) > :redo_critical or (M01 > :redo_critical_mb) then ' class="critical">'
	when ( A01 ) > :redo_warn or (M01 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A01 || ' / ' || M01 || '</td><td' ||
	case
	when ( A02 ) > :redo_critical or (M02 > :redo_critical_mb) then ' class="critical">'
	when ( A02 ) > :redo_warn or (M02 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A02 || ' / ' || M02 || '</td><td' ||
	case
	when ( A03 ) > :redo_critical or (M03 > :redo_critical_mb) then ' class="critical">'
	when ( A03 ) > :redo_warn or (M03 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A03 || ' / ' || M03 || '</td><td' ||
	case
	when ( A04 ) > :redo_critical or (M04 > :redo_critical_mb) then ' class="critical">'
	when ( A04 ) > :redo_warn or (M04 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A04 || ' / ' || M04 || '</td><td' ||
	case
	when ( A05 ) > :redo_critical or (M05 > :redo_critical_mb) then ' class="critical">'
	when ( A05 ) > :redo_warn or (M05 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A05 || ' / ' || M05 || '</td><td' ||
	case
	when ( A06 ) > :redo_critical or (M06 > :redo_critical_mb) then ' class="critical">'
	when ( A06 ) > :redo_warn or (M06 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A06 || ' / ' || M06 || '</td><td' ||
	case
	when ( A07 ) > :redo_critical or (M07 > :redo_critical_mb) then ' class="critical">'
	when ( A07 ) > :redo_warn or (M07 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A07 || ' / ' || M07 || '</td><td' ||
	case
	when ( A08 ) > :redo_critical or (M08 > :redo_critical_mb) then ' class="critical">'
	when ( A08 ) > :redo_warn or (M08 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A08 || ' / ' || M08 || '</td><td' ||
	case
	when ( A09 ) > :redo_critical or (M09 > :redo_critical_mb) then ' class="critical">'
	when ( A09 ) > :redo_warn or (M09 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A09 || ' / ' || M09 || '</td><td' ||
	case
	when ( A10 ) > :redo_critical or (M10 > :redo_critical_mb) then ' class="critical">'
	when ( A10 ) > :redo_warn or (M10 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A10 || ' / ' || M10 || '</td><td' ||
	case
	when ( A11 ) > :redo_critical or (M11 > :redo_critical_mb) then ' class="critical">'
	when ( A11 ) > :redo_warn or (M11 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A11 || ' / ' || M11 || '</td><td' ||
	case
	when ( A12 ) > :redo_critical or (M12 > :redo_critical_mb) then ' class="critical">'
	when ( A12 ) > :redo_warn or (M12 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A12 || ' / ' || M12 || '</td><td' ||
	case
	when ( A13 ) > :redo_critical or (M13 > :redo_critical_mb) then ' class="critical">'
	when ( A13 ) > :redo_warn or (M13 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A13 || ' / ' || M13 || '</td><td' ||
	case
	when ( A14 ) > :redo_critical or (M14 > :redo_critical_mb) then ' class="critical">'
	when ( A14 ) > :redo_warn or (M14 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A14 || ' / ' || M14 || '</td><td' ||
	case
	when ( A15 ) > :redo_critical or (M15 > :redo_critical_mb) then ' class="critical">'
	when ( A15 ) > :redo_warn or (M15 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A15 || ' / ' || M15 || '</td><td' ||
	case
	when ( A16 ) > :redo_critical or (M16 > :redo_critical_mb) then ' class="critical">'
	when ( A16 ) > :redo_warn or (M16 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A16 || ' / ' || M16 || '</td><td' ||
	case
	when ( A17 ) > :redo_critical or (M17 > :redo_critical_mb) then ' class="critical">'
	when ( A17 ) > :redo_warn or (M17 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A17 || ' / ' || M17 || '</td><td' ||
	case
	when ( A18 ) > :redo_critical or (M18 > :redo_critical_mb) then ' class="critical">'
	when ( A18 ) > :redo_warn or (M18 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A18 || ' / ' || M18 || '</td><td' ||
	case
	when ( A19 ) > :redo_critical or (M19 > :redo_critical_mb) then ' class="critical">'
	when ( A19 ) > :redo_warn or (M19 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A19 || ' / ' || M19 || '</td><td' ||
	case
	when ( A20 ) > :redo_critical or (M20 > :redo_critical_mb) then ' class="critical">'
	when ( A20 ) > :redo_warn or (M20 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A20 || ' / ' || M20 || '</td><td' ||
	case
	when ( A21 ) > :redo_critical or (M21 > :redo_critical_mb) then ' class="critical">'
	when ( A21 ) > :redo_warn or (M21 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A21 || ' / ' || M21 || '</td><td' ||
	case
	when ( A22 ) > :redo_critical or (M22 > :redo_critical_mb) then ' class="critical">'
	when ( A22 ) > :redo_warn or (M22 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A22 || ' / ' || M22 || '</td><td' ||
	case
	when ( A23 ) > :redo_critical or (M23 > :redo_critical_mb) then ' class="critical">'
	when ( A23 ) > :redo_warn or (M23 > :redo_warn_mb) then ' class="warning">'
	else '>' end || A23 || ' / ' || M23 || '</td></tr>'
from (select thread, tag,
	max(decode(stunde, '00', anz, null)) A00,
	max(decode(stunde, '01', anz, null)) A01,
	max(decode(stunde, '02', anz, null)) A02,
	max(decode(stunde, '03', anz, null)) A03,
	max(decode(stunde, '04', anz, null)) A04,
	max(decode(stunde, '05', anz, null)) A05,
	max(decode(stunde, '06', anz, null)) A06,
	max(decode(stunde, '07', anz, null)) A07,
	max(decode(stunde, '08', anz, null)) A08,
	max(decode(stunde, '09', anz, null)) A09,
	max(decode(stunde, '10', anz, null)) A10,
	max(decode(stunde, '11', anz, null)) A11,
	max(decode(stunde, '12', anz, null)) A12,
	max(decode(stunde, '13', anz, null)) A13,
	max(decode(stunde, '14', anz, null)) A14,
	max(decode(stunde, '15', anz, null)) A15,
	max(decode(stunde, '16', anz, null)) A16,
	max(decode(stunde, '17', anz, null)) A17,
	max(decode(stunde, '18', anz, null)) A18,
	max(decode(stunde, '19', anz, null)) A19,
	max(decode(stunde, '20', anz, null)) A20,
	max(decode(stunde, '21', anz, null)) A21,
	max(decode(stunde, '22', anz, null)) A22,
	max(decode(stunde, '23', anz, null)) A23,
	round(sum(anz)) AA,
	round(max(decode(stunde, '00', MB, null))) M00,
	round(max(decode(stunde, '01', MB, null))) M01,
	round(max(decode(stunde, '02', MB, null))) M02,
	round(max(decode(stunde, '03', MB, null))) M03,
	round(max(decode(stunde, '04', MB, null))) M04,
	round(max(decode(stunde, '05', MB, null))) M05,
	round(max(decode(stunde, '06', MB, null))) M06,
	round(max(decode(stunde, '07', MB, null))) M07,
	round(max(decode(stunde, '08', MB, null))) M08,
	round(max(decode(stunde, '09', MB, null))) M09,
	round(max(decode(stunde, '10', MB, null))) M10,
	round(max(decode(stunde, '11', MB, null))) M11,
	round(max(decode(stunde, '12', MB, null))) M12,
	round(max(decode(stunde, '13', MB, null))) M13,
	round(max(decode(stunde, '14', MB, null))) M14,
	round(max(decode(stunde, '15', MB, null))) M15,
	round(max(decode(stunde, '16', MB, null))) M16,
	round(max(decode(stunde, '17', MB, null))) M17,
	round(max(decode(stunde, '18', MB, null))) M18,
	round(max(decode(stunde, '19', MB, null))) M19,
	round(max(decode(stunde, '20', MB, null))) M20,
	round(max(decode(stunde, '21', MB, null))) M21,
	round(max(decode(stunde, '22', MB, null))) M22,
	round(max(decode(stunde, '23', MB, null))) M23,
	round(sum(MB)) MA
    from (select l.thread# thread
            , to_char(trunc(l.first_time,'hh')
            , 'hh24') stunde
            , trunc(l.first_time) tag
            , count(l.sequence#) anz
            , sum(al.block_size * al.blocks)/1024/1024 MB 
         from gv$log_history l,
         (select distinct inst_id
            , thread#
            , sequence#
            , blocks
            , block_size from 
          gv$archived_log) al, gv$instance i
	    where i.inst_id = l.inst_id(+)
	    and l.inst_id = al.inst_id(+)
	    and l.thread# = al.thread#(+)
	    and l.sequence# = al.sequence#(+)
	    and sysdate-31 < l.first_time(+)
	group by l.thread#, to_char(trunc(l.first_time,'hh'), 'hh24'), trunc(l.first_time))
	group by thread, tag
	order by thread, tag);
select '</table></div><br>' FROM dual;
---------------File I/O Statistics------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('file_io_stats');
select '<a name="file_io_stats"><h3>File I/O Statistics (Top 30 Reads)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Tablesapce</th><th>File</th><th>Reads</th><th>Reads %</th><th>Writes</th><th>Writes %</th><th>Toal I/O</th></tr>' FROM dual;
select '<tr><td>' || instance_name || '</td><td>' 
  || tablespace_name || '</td><td>' 
  || file_name || '</td><td class="number">' 
  || to_char(phyrds, '999g999g999') || '</td><td class="number">' 
  || round(read_pct) || '%' ||	'</td><td class="number">' 
  || to_char(phywrts, '999g999g999') ||	'</td><td class="number">' 
  || round(write_pct) || '%' || '</td><td class="number">' 
  || to_char(total_io, '999g999g999') || '</td></tr>'
from (select i.instance_name
	  , df.tablespace_name
	  , df.file_name
	  , fs.phyrds
	  , ROUND((fs.phyrds * 100) / (fst.pr + tst.pr), 2) read_pct
	  , fs.phywrts phywrts
	  , ROUND((fs.phywrts * 100) / (fst.pw + tst.pw), 2) write_pct
	  , (fs.phyrds + fs.phywrts) total_io
	FROM sys.dba_data_files df, gv$filestat fs, gv$instance i
	  , (select sum(f.phyrds) pr, sum(f.phywrts) pw from v$filestat f) fst
	  , (select sum(t.phyrds) pr, sum(t.phywrts) pw from v$tempstat t) tst
	WHERE df.file_id = fs.file#
	  AND fs.inst_id = i.inst_id
	UNION ALL
	select i.instance_name
	  , tf.tablespace_name
	  , tf.file_name
	  , ts.phyrds
	  , ROUND((ts.phyrds * 100) / (fst.pr + tst.pr), 2)
	  , ts.phywrts phywrts
	  , ROUND((ts.phywrts * 100) / (fst.pw + tst.pw), 2)
	  , (ts.phyrds + ts.phywrts) total_io
	FROM sys.dba_temp_files  tf
	  , gv$tempstat ts
	  , gv$instance i
	  , (select sum(f.phyrds) pr, sum(f.phywrts) pw from v$filestat f) fst
	  , (select sum(t.phyrds) pr, sum(t.phywrts) pw from v$tempstat t) tst
	WHERE tf.file_id = ts.file#
	  AND ts.inst_id = i.inst_id
	ORDER BY phyrds DESC)
where rownum<=30;
select '</table><br>' FROM dual;
---------------File I/O Timings------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('file_io_timing');
select '<a name="file_io_timing"><h3>File I/O Timings (Top 30 Readtime)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>File</th><th>Reads</th><th>Read Time per I/O</th><th>Writes</th><th>Write Time per I/O</th></tr>' FROM dual;
select '<tr><td>' || instance_name || '</td><td>'
  || fname || '</td><td class="number">'
  || to_char(phyrds, '999g999g999') || '</td><td class="number' 
  || case when read_rate > 4 then 'warning' when read_rate > 10 then 'critical' end || '">' 
  || to_char(round(read_rate, 1), '999g999g990d0') || 'ms' || '</td><td class="number">'
  || to_char(phywrts, '999g999g999') || '</td><td class="number'
  || case when write_rate > 4 then 'warning' when write_rate > 10 then 'critical' end || '">' 
  || to_char(round(write_rate, 1), '999g999g990d0') || 'ms' || '</td></tr>'
from (select instance_name
	  , d.name fname
	  , s.phyrds
	  , ROUND((s.readtim/GREATEST(s.phyrds,1)), 2)   read_rate
	  , s.phywrts
	  , ROUND((s.writetim/GREATEST(s.phywrts,1)),2)  write_rate
	FROM gv$filestat s, gv$datafile d, gv$instance  i
	WHERE s.file# = d.file#
	  AND s.inst_id = i.inst_id
	  AND s.inst_id = d.inst_id
	UNION ALL
	SELECT instance_name
	  , t.name fname
	  , s.phyrds
	  , ROUND((s.readtim/GREATEST(s.phyrds,1)), 2) read_rate
	  , s.phywrts
	  , ROUND((s.writetim/GREATEST(s.phywrts,1)),2) write_rate
	FROM gv$tempstat s, gv$tempfile  t, gv$instance i
	WHERE s.file# = t.file#
	  AND s.inst_id = i.inst_id
	  AND s.inst_id = t.inst_id
	ORDER BY 4 DESC)
where rownum <= 30;
select '</table><br>' FROM dual;
---------------Users------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('users');
prompt <a name="users"><h3>Users</h3></a><a id="b_users" href="javascript:switchdiv('d_users')">(+)</a><div id="d_users" style="display:none;">
select '<table class="sortable"><tr><th>User</th><th>Status</th><th>Lock Date</th><th>Expiry Date</th></tr>' FROM dual;
select '<tr><td>' || Username || '</td><td>' 
  || Account_Status || '</td><td>' 
  || lock_date || '</td><td' 
  || case when expiry_date < sysdate+30 and expiry_date > sysdate-30 then ' class="critical"' when expiry_date < sysdate+60 then ' class="warning"'	end || '>' 
  || expiry_date || '</td></tr>'
FROM dba_users
ORDER BY USERNAME;
select '</table></div><br>' FROM dual;
---------------Users with default PWD--------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('users_def_pwd');
select '<a name="users_def_pwd"><h3>Users with default Password</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>User</th><th>Status</th><th>Lock Date</th><th>Expiry Date</th></tr>' FROM dual;
select '<tr><td>' || u.Username || '</td><td' 
  || case when account_status='OPEN' then ' class="critical"' end || '>' 
  || Account_Status || '</td><td>' || lock_date || '</td><td' 
  || case when expiry_date < sysdate+30 and expiry_date > sysdate-30 then ' class="critical"' when expiry_date < sysdate+60 then ' class="warning"' end || '>' 
  || expiry_date || '</td></tr>'
FROM dba_users u, dba_users_with_defpwd du
WHERE u.username = du.username
ORDER BY u.USERNAME;
select '</table><br>' FROM dual;
--------------FRA--------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('fra');
select '<a name="fra"><h3>Flash Recovery Area</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Type</th><th>% used</th><th>% reclaimable</th><th># Files</th></tr>' FROM dual;
select '<tr><td>' || FILE_TYPE || '</td><td class="number' 
  || case when PERCENT_SPACE_USED > 90 then 'critical' when PERCENT_SPACE_USED > 70 then 'warning' end || '">' 
  || PERCENT_SPACE_USED || '</td><td class="number">'
  || to_char(PERCENT_SPACE_RECLAIMABLE, '990d0') || '</td><td class="number">'
  || to_char(NUMBER_OF_FILES, '990d0') || '</td></tr>'
FROM v$flash_recovery_area_usage;
select '</table><br>' FROM dual;
--------------RMAN Settings--------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('RMAN Settings');
select '<a name="rman_conf"><h3>non-default RMAN Settings</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Name</th><th>Value</th></tr>' FROM dual;
select '<tr><td>' || Name || '</td><td>' || Value || '</td></tr>'
FROM v$rman_configuration
order by name;
select '</table><br>' FROM dual;
---------------Backups------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('backups');
select '<a name="backups"><h3>Datafile Backups (Top 30 OR corrupt OR older than ' || to_char(:days_back) || ' days)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>File</th><th>Last Backup</th><th>Phys. Corrupt</th><th>Log. Corrupt</th></tr>' from dual;
select '<tr><td>' || instance_name || '</td><td>' 
  || fname || '</td><td' 
  || case when completion_time < sysdate-:days_back then ' class="critical"' when completion_time < sysdate-:days_back/2 then ' class="warning"' end || '>' 
  || completion_time ||'</td><td' 
  || case when corrupt_blocks > 0 then ' class="critical"' end || '>' 
  || corrupt_blocks || '</td><td' 
  || case when LOGICALLY_CORRUPT > 0 then ' class="critical"' end || '>' 
  || LOGICALLY_CORRUPT || '</td></tr>'
from (select i.instance_name
    , f.file#
	, f.name fname
	, bd.completion_time
	, bd.MARKED_CORRUPT corrupt_blocks
	, bd.LOGICALLY_CORRUPT
	, row_number() over (partition by f.file# order by bd.completion_time desc) rn
      from gv$instance i, gv$datafile f, gv$backup_datafile bd
      where i.inst_id = f.inst_id
      and i.inst_id = bd.inst_id
      and f.inst_id = bd.inst_id
      and f.file# = bd.file#
      order by i.instance_name, f.name)
where rn=1
and (rownum <=30 or corrupt_blocks > 0 or LOGICALLY_CORRUPT >0 or completion_time < sysdate - :days_back);
select '</table><br>' FROM dual;
---------------All Backups------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('all_backups');
prompt <a name="all_backups"><h3>All Backups</h3></a><a id="b_all_backups" href="javascript:switchdiv('d_all_backups')">(+)</a><div id="d_all_backups" style="display:none;">
select '<table class="sortable"><tr><th>Backup Type</th><th>File Type</th><th>Status</th><th>Backupset Status</th><th>Device Type</th><th>Backup Filename</th><th>Filename</th><th>Completion Time</th></tr>' from dual;
select '<tr><td>' ||  bd.backup_type || '</td><td>'
  || bd.file_type || '</td><td>'
  || bd.status || '</td><td>'
  || bd.bs_status || '</td><td>'
  || bd.bs_device_type ||'</td><td>'
  || bd.fname || '</td><td>'
  || f.name || '</td><td' 
  || case when bd.completion_time < sysdate-:days_back then ' class="critical"' when bd.completion_time < sysdate-:days_back/2 then ' class="warning"' end || '>' 
  || bd.completion_time || '</td></tr>'
from v$backup_files bd, v$datafile f
where f.file# (+) = bd.df_file#
order by bd.fname;
select '</table><br></div>' FROM dual;
--------------Missing Backups------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('missing_backups');
select '<a name="missing_backups"><h3>Files not backuped up (last '||to_char(:days_back)||' days)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>File</th></tr>' from dual;
with bdf as (select --+MATERIALIZE
    bd.inst_id, bd.file#
    from gv$backup_datafile bd
	where bd.completion_time > sysdate-:days_back)
select '<tr><td>' || instance_name || '</td><td>' || fname || '</td></tr>'
from (select i.instance_name
    , f.file#
	, f.name fname 
  from gv$instance i, gv$datafile f 
  where i.inst_id = f.inst_id 
  and (f.inst_id, f.file#) not in (select bd.inst_id, bd.file# from bdf bd where f.file# = bd.file# and f.inst_id = bd.inst_id) order by i.instance_name, f.name);
select '</table><br>' FROM dual;
--------------Backups------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('unrecoverable');
select '<a name="unrecoverable"><h3>Unrecoverable Files</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>File</th><th>Last Backup Time</th><th>Unrecoverable Operation Time</th></tr>' from dual;
with vd as (select /*+MATERIALIZE*/ * from v$datafile),
     bd as (select /*+MATERIALIZE*/ * from v$BACKUP_DATAFILE)
select '<tr><td>' || VD.Name || '</td><td>'
  || VBD.COMPLETION_TIME || '</td><td>'
  || VD.UNRECOVERABLE_TIME || '</td></tr>'
FROM VD, (select BD.CREATION_CHANGE#, MAX(BD.COMPLETION_TIME) COMPLETION_TIME FROM BD GROUP BY BD.CREATION_CHANGE#) VBD
WHERE VBD.CREATION_CHANGE# = VD.CREATION_CHANGE#
AND VD.UNRECOVERABLE_TIME > VBD.COMPLETION_TIME
order by vd.name;
select '</table><br>' FROM dual;
---------------Archive Destinations------------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('arch_dest');
select '<a name="arch_dest"><h3>Archive Destinations</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Name</th><th>Status</th><th>Target</th><th>Destination</th><th>Archiver</th><th>Error</th></tr>' from dual;
select '<tr><td>' || i.instance_name ||	'</td><td>'
  || a.dest_name || '</td><td' 
  || case when a.status <> 'VALID' then ' class="critical"'	end || '>' 
  || a.status || '</td><td>'
  || a.target || '</td><td>'
  || a.destination || '</td><td>'
  || a.archiver || '</td><td>'
  || a.error || '</td></tr>'
from gv$instance i, gv$archive_dest a
where i.inst_id = a.inst_id
and a.status <> 'INACTIVE'
order by i.inst_id, a.dest_id;
select '</table><br>' FROM dual;
------------------------------Reorg-Tables-----------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('reorg_tab');
prompt <a name="reorg_tab"><h3>Reorg-Tables</h3></a><a id="b_reorg_tab" href="javascript:switchdiv('d_reorg_tab')">(+)</a><div id="d_reorg_tab" style="display:none;">
select 'Tables with >40MB free space below HWM, and/or free space >30%. Segment statistics need to be current for this.</br>' FROM dual;
select '<table class="sortable"><tr><th>Owner</th><th>Tablename</th><th>last analyzed</th><th>Rows</th><th>Data</th><th>HWM</th><th>Wasted</th><th>Quota</th></tr>' FROM dual;
select '<tr><td>' || owner, '</td><td>'
  || table_name, '</td><td>'
  || NVL(TO_CHAR(LAST_ANALYZED,'DD/MM/YYYY'),'no Stats'), '</td><td class="number">' 
  || num_rows, '</td><td class="number">'
  || to_char(round(num_rows*avg_row_len/1024/1024,2),'999999990.00') || 'MB', '</td><td class="number">'
  || to_char(round(blocks*block_size/1024/1024,2),'999999990.00') || 'MB', '</td><td class="number">'
  || to_char(round(blocks*block_size/1024/1024-num_rows*avg_row_len/1024/1024,2),'999999990.00') || 'MB', '</td><td class="number">'
  || to_char(round(100*(1-num_rows*avg_row_len/block_size/blocks),2),'999999990.00') || '%</td></tr>'
FROM (select * FROM dba_tables WHERE BLOCKS > 0 and TEMPORARY='N') dt, dba_tablespaces dts
WHERE dt.tablespace_name=dts.tablespace_name
AND	(num_rows*avg_row_len/block_size/blocks<0.7	OR	blocks*block_size-num_rows*avg_row_len>40*1024*1024)
AND	blocks*block_size-num_rows*avg_row_len>1*1024*1024
AND	owner not in ('SYS','SYSTEM','WMSYS')
AND	table_name not in (select distinct table_name from dba_tab_columns where DATA_TYPE in ('BLOB','CLOB','LONG','LONG RAW','NCLOB')) 
ORDER BY round(blocks*block_size/1024/1024-num_rows*avg_row_len/1024/1024,2) desc;
select '</table><br>' FROM dual;
select '<table class="sortable"><tr><th>Owner</th><th>Tablename</th><th>Partition name</th><th>last analyzed</th><th>Rows</th><th>Data</th><th>HWM</th><th>Wasted</th><th>Quota</th></tr>' FROM dual;
SELECT '<tr><td>' || table_owner, '</td><td>'
  || table_name, '</td><td>'
  || partition_name, '</td><td>'
  || NVL(TO_CHAR(LAST_ANALYZED,'DD/MM/YYYY'),'no Stats'),'</td><td class="number">' 
  || num_rows, '</td><td class="number">'
  || to_char(round(num_rows*avg_row_len/1024/1024,2),'999999990.00') || 'MB', '</td><td class="number">'
  || to_char(round(blocks*block_size/1024/1024,2),'999999990.00') || 'MB', '</td><td class="number">'
  || to_char(round(blocks*block_size/1024/1024-num_rows*avg_row_len/1024/1024,2),'999999990.00') || 'MB', '</td><td class="number">'
  || to_char(round(100*(1-num_rows*avg_row_len/block_size/blocks),2),'999999990.00') || '%</td></tr>'
FROM (select * FROM dba_tab_partitions WHERE BLOCKS>0) dt, dba_tablespaces dts
WHERE dt.tablespace_name=dts.tablespace_name
AND (num_rows*avg_row_len/block_size/blocks<0.7	OR	blocks*block_size-num_rows*avg_row_len>40*1024*1024)
AND	blocks*block_size-num_rows*avg_row_len>1*1024*1024
AND	table_owner not in ('SYS','SYSTEM','WMSYS')
AND	table_name not in (select distinct table_name from dba_tab_columns where DATA_TYPE in ('BLOB','CLOB','LONG','LONG RAW','NCLOB')) 
ORDER BY round(blocks*block_size/1024/1024-num_rows*avg_row_len/1024/1024,2) desc;
select '</table><br>' FROM dual;
select '<table class="sortable"><tr><th>Owner</th><th>Tablename</th><th>Partition name</th><th>Subpartition name</th><th>Analyse</th><th>Rows</th><th>Data</th><th>HWM</th><th>Wasted</th><th>Quota</th></tr>' FROM dual;
select '<tr><td>' || table_owner, '</td><td>'
  || table_name, '</td><td>'
  || partition_name, '</td><td>'
  || subpartition_name, '</td><td>'
  || NVL(TO_CHAR(LAST_ANALYZED,'DD/MM/YYYY'),'no Stats'), '</td><td class="number">'
  || num_rows,'</td><td class="number">'
  || to_char(round(num_rows*avg_row_len/1024/1024,2),'999999990.00') || 'MB', '</td><td class="number">'
  || to_char(round(blocks*block_size/1024/1024,2),'999999990.00') || 'MB', '</td><td class="number">'
  || to_char(round(blocks*block_size/1024/1024-num_rows*avg_row_len/1024/1024,2),'999999990.00') || 'MB', '</td><td class="number">'
  || to_char(round(100*(1-num_rows*avg_row_len/block_size/blocks),2),'999999990.00') || '%</td></tr>'
FROM (select * FROM dba_tab_subpartitions WHERE BLOCKS>0) dt, dba_tablespaces dts
WHERE dt.tablespace_name=dts.tablespace_name
AND (num_rows*avg_row_len/block_size/blocks<0.7	OR	blocks*block_size-num_rows*avg_row_len>40*1024*1024)
AND	blocks*block_size-num_rows*avg_row_len>1*1024*1024
AND table_owner not in ('SYS','SYSTEM','WMSYS')
AND	table_name not in (select distinct table_name from dba_tab_columns where DATA_TYPE in ('BLOB','CLOB','LONG','LONG RAW','NCLOB')) ORDER BY round(blocks*block_size/1024/1024-num_rows*avg_row_len/1024/1024,2) desc;
select '</table></div><br>' FROM dual;
---------------Top Segments-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('top_segments');
select '<a name="top_segments"><h3>Top 30 Segments by Size</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Owner</th><th>Segment</th><th>Type</th><th>Tablespace</th><th>Size MB</th></tr>' FROM dual;
select '<tr><td>' || owner || '</td><td>'
  || segment_name || '</td><td>'
  || segment_type || '</td><td>'
  || tablespace_name || '</td><td class="number">'
  || to_char(round(bytes/1024/1024), '999g999g990') || '</td></tr>'
FROM (select * FROM DBA_SEGMENTS ORDER BY bytes desc)
WHERE ROWNUM < 31;
select '</table><br>' FROM dual;
---------------Segments in SYSTEM TS-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('system_segments');
prompt <a name="system_segments"><h3>Segments in SYSTEM / SYSAUX not owned by SYS / SYSTEM </h3></a><a id="b_system_segments" href="javascript:switchdiv('d_system_segments')">(+)</a><div id="d_system_segments" style="display:none;">
select '<table class="sortable"><tr><th>Owner</th><th>Segment</th><th>Type</th><th>Tablespace</th><th>Size MB</th></tr>' FROM dual;
select '<tr><td>' || owner || '</td><td>'
  || segment_name || '</td><td>'
  || segment_type || '</td><td>'
  || tablespace_name || '</td><td class="number">'
  || to_char(round(bytes/1024/1024), '999g999g990')
  || '</td></tr>'
FROM DBA_SEGMENTS
WHERE TABLESPACE_NAME IN ('SYS','SYSAUX')
AND   OWNER NOT IN ('SYS','SYSTEM','SYSMAN','TSMSYS','DBSNMP','XDB','CTXSYS','EXFSYS','WMSYS','ORDSYS','MDSYS','OLAPSYS','WKSYS','DMSYS','WK_TEST','ORDDATA','AUDSYS','GSMADMIN_INTERNAL','APPQOSSYS')
AND   OWNER not like 'FLOWS_%'
AND   OWNER not like 'APEX%'
order by owner, segment_name;
select '</table></div><br>' FROM dual;
---------------segments with stale or missing statistics-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('stale_statistics');
prompt <a name="stale_statistics"><h3>Segments with stale or missing statistics</h3></a><a id="b_stale_statistics" href="javascript:switchdiv('d_stale_statistics')">(+)</a><div id="d_stale_statistics" style="display:none;">
select '<h4>Segments without statistics</h4></a>' FROM dual;
select '<table class="sortable"><tr><th>Owner</th><th>Segment Type</th><th>Count</th></tr>' FROM dual;
select '<tr><td>' || owner || '</td><td>'
  || segment_type || '</td><td>'
  || anzahl || '</td></tr>'
FROM (select owner, 'TABLE' segment_type, count(*) anzahl from dba_tables where last_analyzed is null and owner not in ('SYS','SYSTEM') group by owner
  union all
  select table_owner, 'TABLE PARTITION' segment_type, count(*) anzahl from dba_tab_partitions where last_analyzed is null and table_owner not in ('SYS','SYSTEM') group by table_owner
  union all
  select table_owner, 'TABLE SUBPARTITION' segment_type, count(*) anzahl from dba_tab_subpartitions where last_analyzed is null and table_owner not in ('SYS','SYSTEM') group by table_owner
  union all
  select owner, 'INDEX' segment_type, count(*) anzahl from dba_indexes where last_analyzed is null and owner not in ('SYS','SYSTEM') group by owner
  union all
  select index_owner, 'INDEX PARTITION' segment_type, count(*) anzahl from dba_ind_partitions where last_analyzed is null and index_owner not in ('SYS','SYSTEM') group by index_owner
  union all
  select index_owner, 'INDEX SUBPARTITION' segment_type, count(*) anzahl from dba_ind_subpartitions where last_analyzed is null and index_owner not in ('SYS','SYSTEM') group by index_owner)
order by owner, segment_type;
select '</table><br>' FROM dual;
select '<h4>Segments with stale statistics</h4></a>' FROM dual;
select '<table class="sortable"><tr><th>Owner</th><th>Table Name</th><th>Pct changed</th><th>Last analyzed</th></tr>' FROM dual;
select '<tr><td>' || owner || '</td><td>' 
  || table_name || '</td><td class="number' 
  || case when percent >= 25 then 'critical' when percent >= 10 then 'warning' end || '">' 
  || TO_CHAR(percent,'999G999D99') || '</td><td>' 
  || to_char(last_analyzed, 'dd/mm/yyyy hh24:mi') || '</td></tr>'
FROM (select u.TIMESTAMP
        , d.last_analyzed
		, d.owner
		, u.table_name
		, u.inserts
		, u.updates
		, u.deletes
		, d.num_rows
		, ((U.inserts+u.deletes+u.updates)/ decode(d.num_rows, 0, 1, d.num_rows)) * 100 percent
      from ALL_TAB_MODIFICATIONS u,dba_tables d
      where u.table_name = d.table_name
	  and u.table_owner = d.owner
      and (u.inserts > 10000 or u.updates > 10000 or u.deletes > 10000))
order by percent desc;
select '</table></div><br>' FROM dual;
---------------Unindexed Foreign Keys-----------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('unindexed keys');
prompt <a name="unindexed_keys"><h3>Unindexed Foreign Keys</h3></a><a id="b_unindexed_keys" href="javascript:switchdiv('d_unindexed_keys')">(+)</a><div id="d_unindexed_keys" style="display:none;">
select '<table class="sortable"><tr><th>Owner</th><th>Table Name</th><th>Constraint Name</th><th>Column List</th></tr>' FROM dual;
select '<tr><td>' || owner || '</td><td>'
  || table_name || '</td><td>'
  || constraint_name || '</td><td>'
  || columns || '</td></tr>'
from (select owner
        , table_name
		, constraint_name
		, cname1 
		|| nvl2(cname2, ',' || cname2, null) 
		|| nvl2(cname3, ',' || cname3, null) 
		|| nvl2(cname4, ',' || cname4, null) 
		|| nvl2(cname5, ',' || cname5, null) 
		|| nvl2(cname6, ',' || cname6, null) 
		|| nvl2(cname7, ',' || cname7, null) 
		|| nvl2(cname8, ',' || cname8, null) columns
	 from (select b.owner
	         , b.table_name
			 , b.constraint_name
			 , max(decode(position, 1, column_name, null)) cname1
			 , max(decode(position, 2, column_name, null)) cname2
			 , max(decode(position, 3, column_name, null)) cname3
			 , max(decode(position, 4, column_name, null)) cname4
			 , max(decode(position, 5, column_name, null)) cname5
			 , max(decode(position, 6, column_name, null)) cname6
			 , max(decode(position, 7, column_name, null)) cname7
			 , max(decode(position, 8, column_name, null)) cname8
			 , count(*) col_cnt
			from (select substr(owner,1,30) owner
			        , substr(table_name,1,30) table_name
					, substr(constraint_name,1,30) constraint_name
					, substr(column_name,1,30) column_name
					, position
				  from dba_cons_columns) a,
				  dba_constraints b
			 where a.constraint_name = b.constraint_name
			 and a.owner = b.owner
			 and b.constraint_type = 'R'
             and a.owner not in ('SYS','SYSTEM','SYSMAN','EXFSYS','DBSNMP')
			 group by b.table_name, b.constraint_name, b.owner) cons
	where col_cnt > ALL
			(select count(*) from dba_ind_columns i
			 where i.table_name = cons.table_name
			 and i.table_owner = cons.owner
			 and i.column_name in (cname1, cname2, cname3, cname4, cname5, cname6, cname7, cname8 )
			 and i.column_position <= cons.col_cnt
			 group by i.index_name, i.table_owner))
order by owner,table_name, constraint_name;
select '</table></div><br>' FROM dual;
---------------Sequences-----------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('sequences');
prompt <a name="sequences"><h3>Sequences</h3></a><a id="b_sequences" href="javascript:switchdiv('d_sequences')">(+)</a><div id="d_sequences" style="display:none;">
select '<table class="sortable"><tr><th>Owner</th><th>Sequence</th><th>Max Value</th><th>Current Value</th><th>Increase by</th><th>Cache</th><th>Cycle</th></tr>' FROM dual;
SELECT '<tr><td>' || SEQUENCE_OWNER || '</td><td>'
  || SEQUENCE_NAME || '</td><td class="number">'
  || MAX_VALUE || '</td><td class="number' 
  || case when (CYCLE_FLAG='N' and LAST_NUMBER/MAX_VALUE > 0.9) then 'critical' when (CYCLE_FLAG='N' and LAST_NUMBER/MAX_VALUE > 0.8) then 'warning' else 'good' end || '">'
  || LAST_NUMBER || '</td><td class="number">'
  || INCREMENT_BY || '</td><td class="number">'
  || CACHE_SIZE || '</td><td>'
  || CYCLE_FLAG || '</td></tr>'
from (select SEQUENCE_OWNER
        , SEQUENCE_NAME
		, CYCLE_FLAG
		, LAST_NUMBER
		, INCREMENT_BY
		, CACHE_SIZE
		, decode(MAX_VALUE, -1, 9999999999999999999999999999, MAX_VALUE) MAX_VALUE
      from dba_sequences)
order by LAST_NUMBER/MAX_VALUE desc, SEQUENCE_OWNER,SEQUENCE_NAME;
select '</table></div><br>' FROM dual;
---------------Jobs-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('jobs');
select '<a name="jobs"><h3>DBA Jobs</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Job</th><th>Schema User</th><th>Priv User</th><th>Broken</th><th>Failures</th><th>Last Date</th><th>Next Date</th><th>Interval</th><th>What</th></tr>' FROM dual;
select '<tr><td>' || instance_name || '</td><td>'
  || job || '</td><td>'
  || schema_user || '</td><td>'
  || priv_user || '</td><td'
  || case when broken='Y' then ' class="critical"' else ' class="good"' end || '>' 
  || broken || '</td><td class="number' 
  || case when failures >= 5 then 'critical' when failures >= 1 then 'warning' end || '">' 
  || failures || '</td><td>'
  || last_date || '</td><td>'
  || next_date || '</td><td>'
  || interval || '</td><td>'
  || what || '</td></tr>'
from (select instance_name
        , job
		, schema_user
		, priv_user
		, broken
		, failures
		, last_date
		, next_date
		, interval
		, what
	  from (select i.instance_name, i.inst_id from gv$instance i
	  union all
	  select 'ANY', 0 from dual) i, dba_jobs j where i.inst_id = j.instance order by schema_user asc, next_date desc);
select '</table><br>' FROM dual;
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('scheduler jobs');
select '<h3>Scheduler Jobs</h3>' FROM dual;
select '<table class="sortable"><tr><th>Owner</th><th>Job</th><th>Job Type</th><th>Schedule Name</th><th>Schedule Type</th><th>Enabled</th><th>State</th><th>Run Count</th><th>Last Run Time (s)</th><th>Failures</th><th>Last Date</th><th>Next Date</th>  <th>Interval</th><th>Action</th></tr>' FROM dual;
select '<tr><td>' || owner || '</td><td>'
  || job_name || '</td><td>'
  || job_type || '</td><td>'
  || SCHEDULE_NAME || '</td><td>'
  || SCHEDULE_TYPE || '</td><td'
  || case when enabled='FALSE' then ' class="warning"' else ' class="good"' end || '>' 
  || enabled || '</td><td>'
  || state || '</td><td>'
  || run_count || '</td><td>'
  || last_run_duration || '</td><td class="number' 
  || case when failure_count >= 5 then 'critical' when failure_count >= 1 then 'warning' end || '">' 
  || failure_count || '</td><td>'
  || last_start_date || '</td><td>'
  || next_run_date || '</td><td>'
  || Repeat_interval || '</td><td>'
  || Job_Action || '</td></tr>'
from dba_scheduler_jobs
order by owner, job_name desc;
select '</table><br>' FROM dual;
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('scheduler job runs');
select '<a name="scheduler_job_runs"><h3>Scheduler Job History (max. 20 per Job)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Log Date</th><th>Owner</th><th>Job</th><th>Status</th><th>Message</th><th>Error Number</th><th>Error Msg</th><th>Start Date</th><th>Duration</th></tr>' FROM dual;
select '<tr><td>' || to_char(log_date, 'dd/mm/yyyy hh24:mi:ss') || '</td><td>' 
  || owner || '</td><td>' 
  || job_name || '</td><td' 
  || case when status='FAILED' then ' class="critical"' else ' class="good"' end || '>' 
  || status || '</td><td>' 
  || output || '</td><td class="number">' 
  || error# || '</td><td>' 
  || errors || '</td><td>' 
  || actual_start_date || '</td><td>' 
  || run_duration || '</td></tr>'
from (select log_date
        , owner
		, job_name
		, status
		, output
		, error#
		, errors
		, actual_start_date
		, run_duration
		, row_number() over (partition by job_name order by log_date desc) rn 
	  from dba_scheduler_job_run_details 
	  where log_date > systimestamp - :days_back)
where rn < 21
order by log_date desc;
select '</table><br>' FROM dual;
---------------Autotask Jobs--------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('autotask');
select '<a name="autotask"><h3>Autotask Jobs</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Job</th><th>Status</th><th>Last Try Date</th><th>Last Good Date</th><th>Next Try Date</th></tr>' FROM dual;
select '<tr><td>' || CLIENT_NAME || '</td><td>'
  || STATUS || '</td class="' 
  || case when LAST_TRY_DATE > LAST_TRY_DATE then 'warning' else 'good' end || '"><td>'
  || to_char(LAST_TRY_DATE, 'dd/mm/yyyy hh24:mi:ss') || '</td><td>'
  || to_char(LAST_TRY_DATE, 'dd/mm/yyyy hh24:mi:ss') || '</td><td>'
  || to_char(NEXT_TRY_DATE, 'dd/mm/yyyy hh24:mi:ss') || '</td></tr>'
from dba_autotask_task
order by CLIENT_NAME asc;
select '</table><br>' FROM dual;
---------------Invalid Objects----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('inv_obj');
select '<a name="inv_obj"><h3>Invalid Objects</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Owner</th><th>Synonym</th><th>Procedure</th><th>Function</th><th>Trigger</th><th>Package</th><th>Package Body</th><th>Other</th></tr>' FROM dual;
select '<tr><td>' || owner || '</td><td class="number">'
  || sum(case when object_type='SYNONYM' then 1 end) || '</td><td class="number">'
  || sum(case when object_type='PROCEDURE' then 1 end) || '</td><td class="number">'
  || sum(case when object_type='FUNCTION' then 1 end) || '</td><td class="number">'
  || sum(case when object_type='TRIGGER' then 1 end) || '</td><td class="number">'
  || sum(case when object_type='PACKAGE' then 1 end) || '</td><td class="number">'
  || sum(case when object_type='PACKAGE BODY' then 1 end) || '</td><td class="number">'
  || sum(case when object_type='SYNONYM' 
  then null when object_type='PROCEDURE' 
  then null when object_type='FUNCTION' 
  then null when object_type='TRIGGER' 
  then null when object_type='PACKAGE' 
  then null when object_type='PACKAGE BODY' 
  then null else 1 end) || '</td></tr>'
from dba_objects
where status<>'VALID'
and object_name not like 'BIN$%'
group by owner
order by owner;
select '</table><br>' FROM dual;
---------------Invalid Indexes----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') ||    's -->' from dual;
exec dbms_application_info.set_action('inv_index');
select '<a name="inv_index"><h3>Unusable Indexes</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Owner</th><th>Index</th><th>Partition</th><th>Subpartition</th><th>Status</th></tr>' FROM dual;
select '<tr><td>' || index_owner || '</td><td>'
  || index_name || '</td><td>'
  || partition_name || '</td><td>'
  || subpartition_name || '</td><td>'
  || status || '</td></tr>'
from (select index_owner
        , index_name
		, partition_name
		, subpartition_name
		, status
      from dba_ind_subpartitions
      where status <> 'USABLE'
      union all
      select index_owner
	    , index_name
		, partition_name
		, ''
		, status
      from dba_ind_partitions
      where status not in ('USABLE', 'N/A')
      union all
      select owner
	    , index_name
		, ''
		, ''
		, status
      from dba_indexes
      where status not in ('VALID', 'N/A'))
order by index_owner, index_name, partition_name, subpartition_name;
select '</table><br>' FROM dual;
---------------Auditing----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('auditing');
select '<a name="auditing"><h3>Auditing</h3></a><h3>Audited Objects</h3>' FROM dual;
select '<table class="sortable"><tr><th>Owner</th><th>Object</th><th>Type</th><th>Alter</th><th>Audit</th><th>Comment</th><th>Delete</th><th>Grant</th><th>Index</th><th>Insert</th><th>Lock</th><th>Rename</th><th>Select</th><th>Update</th><th>Execute</th><th>Create</th><th>Read</th><th>Write</th><th>Flashback</th></tr>' FROM dual;
select '<tr><td>' || owner || '</td><td>' 
  || object_name || '</td><td>' 
  || object_type || '</td><td>' 
  || ALT || '</td><td>' 
  || AUD || '</td><td>' 
  || COM || '</td><td>' 
  || DEL || '</td><td>' 
  || GRA || '</td><td>' 
  || IND || '</td><td>' 
  || INS || '</td><td>' 
  || LOC || '</td><td>' 
  || REN || '</td><td>' 
  || SEL || '</td><td>' 
  || UPD || '</td><td>' 
  || EXE || '</td><td>' 
  || CRE || '</td><td>' 
  || REA || '</td><td>' 
  || WRI || '</td><td>' 
  || FBK || '</td></tr>'
from dba_obj_audit_opts
order by owner, object_type, object_name;
select '</table><br>' FROM dual;
select '<h3>Audited Statements</h3>' FROM dual;
select '<table class="sortable"><tr><th>Username</th><th>Audit Option</th><th>Success</th><th>Failure</th></tr>' FROM dual;
select '<tr><td>' || user_name || '</td><td>' || audit_option || '</td><td>' || success || '</td><td>' || failure || '</td></tr>'
from dba_stmt_audit_opts
order by user_name, audit_option;
select '</table><br>' FROM dual;
--------------- Top Sessions--------------------------------------------------------------------------
DECLARE
  TYPE r_type IS RECORD (
    stat_name     VARCHAR2 (30),
    description   VARCHAR2 (30));
  TYPE tr_type IS TABLE OF r_type;
  l_rarray   tr_type  := tr_type();
  l_rec      r_type;
  mysql varchar2(2000);
  TYPE cur_typ IS REF CURSOR;
  c            cur_typ;
  inst_id      sys.gv_$session.inst_id%TYPE;
  sid          sys.gv_$session.sid%TYPE;
  username     sys.gv_$session.username%TYPE;
  program      sys.gv_$session.program%TYPE;
  machine      sys.gv_$session.machine%TYPE;
  module       sys.gv_$session.module%TYPE;
  action       sys.gv_$session.action%TYPE;
  logon_time   sys.gv_$session.logon_time%TYPE;
  statvalue    sys.gv_$sesstat.value%TYPE;
  pct          number;
  ranking      number;
BEGIN
  l_rarray.extend(4);
  l_rec.stat_name := '''session logical reads''';
  l_rec.description := 'buffer gets';
  l_rarray(1) := l_rec;
  l_rec.stat_name := '''physical reads''';
  l_rec.description := 'physical reads';
  l_rarray(2) := l_rec;
  l_rec.stat_name := '''db block changes''';
  l_rec.description := 'block changes';
  l_rarray(3) := l_rec;
  l_rec.stat_name := '''CPU used by this session''';
  l_rec.description := 'CPU (in 1/100s)';
  l_rarray(4) := l_rec;
  dbms_output.put_line('<a name="top_sessions"></a>');
  FOR col IN l_rarray.FIRST .. l_rarray.LAST
  LOOP
    dbms_application_info.set_action('SESSION_' || l_rarray(col).description );
	dbms_output.put_line('<h3>Top 10 Sessions with high ' || l_rarray(col).description || '</h3>');
	dbms_output.put_line('<table class="sortable"><tr><th>Percent</th><th>Inst-ID</th><th>SID</th><th>Username</th><th>Program</th><th>Machine</th><th>Module</th><th>Action</th><th>Logon Time</th><th>' || l_rarray(col).description || '</th></tr>');
	mysql := 'select * from (select inst_id,
				  sid,
				  username,
				  program,
				  machine,
				  module,
				  action,
				  logon_time,
				  value,
				  pct,
				  rank() over (partition by inst_id order by value desc)  ranking
				from (select
				  se.inst_id,
				  se.sid,
				  se.username,
				  se.program,
				  se.machine,
				  se.module,
				  se.action,
				  se.logon_time,
				  sum(st.value) value,
				  100 * ratio_to_report(sum(st.value)) over (partition by se.inst_id)  pct
				from sys.gv_$session  se
				  join sys.gv_$sesstat st on (se.inst_id = st.inst_id and se.sid = st.sid)
				  join sys.v_$statname sn on (st.statistic# = sn.statistic#)
				where sn.name in (' || l_rarray(col).stat_name || ')
				  and se.username is not null
				group by se.inst_id,
				  se.sid,
				  se.username,
				  se.program,
				  se.machine,
				  se.module,
				  se.action,
				  se.logon_time)) s
			where s.ranking <= 10
			order by s.inst_id, s.ranking';
    OPEN c FOR mysql;
    LOOP
        FETCH c INTO inst_id, sid, username, program, machine, module, action, logon_time, statvalue, pct, ranking;
        EXIT WHEN c%NOTFOUND;
    	dbms_output.put_line('<tr><td class="number">' || to_char(round(pct,1), '990D09') || '</td><td class="number">' || to_char(inst_id, '999') || '</td><td class="number">' || to_char(sid, '999999') || '</td><td>' || username || '</td><td>' || program || '</td><td>' || machine || '</td><td>' || module || '</td><td>' || action || '</td><td>' || to_char(logon_time, 'dd/mm/yyyy hh24:mi:ss') || '</td><td class="number">' || to_char(statvalue, '999g999g999g999g999g999') || '</td></tr>');
    END LOOP;
    CLOSE c;
	dbms_output.put_line('</table>');
  END LOOP;
END;
/
--------------- SQL-----------------------------------------------------------------------------------
DECLARE
  TYPE sqlids_type is table of number index by varchar2(13); -- all SQL-IDs that came along
  mysqlids sqlids_type;
  ids varchar2(13);
  TYPE r_type IS RECORD (
    column_name   VARCHAR2 (30),
    description   VARCHAR2 (30));
  TYPE tr_type IS TABLE OF r_type;
  l_rarray   tr_type  := tr_type();
  l_rec      r_type;
  mysql varchar2(1000);
  TYPE cur_typ IS REF CURSOR;
  c           cur_typ;
  sql_id       varchar2(13);
  inst_id      number;
  buffer_gets  number;
  disk_reads   number;
  executions   number;
  elapsed_time number;
  cpu_time     number;
  pct          number;
  ranking      number;
BEGIN
  l_rarray.extend(4);
  l_rec.column_name := 'buffer_gets';
  l_rec.description := 'buffer gets';
  l_rarray(1) := l_rec;
  l_rec.column_name := 'disk_reads';
  l_rec.description := 'disk reads';
  l_rarray(2) := l_rec;
  l_rec.column_name := 'cpu_time';
  l_rec.description := 'CPU Time';
  l_rarray(3) := l_rec;
  l_rec.column_name := 'elapsed_time';
  l_rec.description := 'Elapsed Time';
  l_rarray(4) := l_rec;
  l_rec.column_name := 'executions';
  l_rec.description := 'Executions';
  l_rarray(4) := l_rec;
  dbms_output.put_line('<a name="top_sql"></a>');
  FOR col IN l_rarray.FIRST .. l_rarray.LAST
  LOOP
    dbms_application_info.set_action('SQL_' || l_rarray(col).column_name );
	dbms_output.put_line('<h3>Top 10 SQL with high ' || l_rarray(col).description || '</h3>');
	dbms_output.put_line('<table class="sortable"><tr><th>Percent</th><th>Gets</th><th>Gets / Exec</th><th>Reads</th><th>Reads / Exec</th><th>CPU Time (s)</th><th>CPU Time (s) / Exec</th><th>Elapsed Time (s)</th><th>Elapsed Time (s) / Exec</th><th>Executions #</th><th>SQL-ID</th><th>Inst-ID</th></tr>');
	mysql := 'select * from (select inst_id,
				  sql_id,
				  buffer_gets,
				  disk_reads,
				  executions,
				  elapsed_time,
				  cpu_time,
				  pct,
				  rank() over (partition by inst_id order by ' || l_rarray(col).column_name || ' desc)  ranking
				from (select
				  inst_id,
				  sql_id,
				  buffer_gets,
				  disk_reads,
				  executions,
				  elapsed_time,
				  cpu_time,
				  100 * ratio_to_report(' || l_rarray(col).column_name || ') over (partition by inst_id)  pct
				from sys.gv_$sql
				where command_type != 47 and
				  executions > 0)) s
			where s.ranking <= 10
			order by inst_id, ranking';
    OPEN c FOR mysql;
    LOOP
        FETCH c INTO inst_id, sql_id, buffer_gets, disk_reads, executions, elapsed_time, cpu_time, pct, ranking;
        EXIT WHEN c%NOTFOUND;
    	dbms_output.put_line('<tr><td class="number">' || to_char(round(pct,1), '990D09') || '</td><td class="number">' || to_char(buffer_gets, '999g999g999g999') || '</td><td class="number">' || to_char(round(buffer_gets/executions), '999g999g999g999') || '</td><td class="number">' || to_char(disk_reads, '999g999g999g999') || '</td><td class="number">' || to_char(round(disk_reads/executions), '999g999g999g999') || '</td><td class="number">' || to_char(round(cpu_time/1000000, 3), '999g999g990D09') || '</td><td class="number">' || to_char(round(cpu_time/1000000/executions, 3), '999g999g990D09') || '</td><td class="number">' || to_char(round(elapsed_time/1000000, 3), '999g999g990D09') || '</td><td class="number">' || to_char(round(elapsed_time/1000000/executions, 3), '999g999g990D09') || '</td><td class="number">' || to_char(executions, '999g999g999g999') || '</td><td><a href="#' || sql_id || '">' || sql_id ||'</a></td><td class="number">' || to_char(inst_id, '999') || '</td></tr>');
		-- remember SQL-ID
		mysqlids(sql_id) := 1;
    END LOOP;
    CLOSE c;
	dbms_output.put_line('</table>');
  END LOOP;
  -- Full SQL Texts
	dbms_output.put_line('<h3>SQL List</h3><table><tr><th>SQL-ID</th><th>SQL Text</th></tr>');
	-- loop through all SQL-IDs
	ids := mysqlids.first;
	while ids is not null
	loop
    	dbms_output.put_line('<tr><td><a name="' || ids || '">' || ids || '</a></td><td><pre><code></code>');
		for rec in (select dbms_lob.substr(sql_fulltext, 4000) sql_text from sys.v_$sql where sql_id=ids and rownum=1)
		loop
		    if :hide_sql <> 'Y' then
		        dbms_output.put_line( replace( replace(rec.sql_text, '<', '&lt;'), '>', '&gt;') );
		    end if;
		end loop;
	    ids := mysqlids.next(ids);
	end loop;
	dbms_output.put_line('</table>');
END;
/
--------------- SQL from AWR--------------------------------------------------------------------------
DECLARE
  TYPE sqlids_type is table of number index by varchar2(13); -- all SQL-IDs that came along
  mysqlids sqlids_type;
  ids varchar2(13);
  TYPE r_type IS RECORD (
    column_name   VARCHAR2 (30),
    description   VARCHAR2 (30));
  TYPE tr_type IS TABLE OF r_type;
  l_rarray   tr_type  := tr_type();
  l_rec      r_type;
  mysql varchar2(2000);
  TYPE cur_typ IS REF CURSOR;
  c           cur_typ;
  sql_id       varchar2(13);
  inst_id      number;
  buffer_gets  number;
  disk_reads   number;
  executions   number;
  elapsed_time number;
  cpu_time     number;
  pct          number;
  ranking      number;
BEGIN
  l_rarray.extend(4);
  l_rec.column_name := 'buffer_gets_delta';
  l_rec.description := 'buffer gets';
  l_rarray(1) := l_rec;
  l_rec.column_name := 'disk_reads_delta';
  l_rec.description := 'disk reads';
  l_rarray(2) := l_rec;
  l_rec.column_name := 'cpu_time_delta';
  l_rec.description := 'CPU Time';
  l_rarray(3) := l_rec;
  l_rec.column_name := 'elapsed_time_delta';
  l_rec.description := 'Elapsed Time';
  l_rarray(4) := l_rec;
  l_rec.column_name := 'executions_delta';
  l_rec.description := 'Executions';
  l_rarray(4) := l_rec;
  dbms_output.put_line('<a name="top_sql_awr"></a>');
  if :is_diag_licensed <> 1 then
	dbms_output.put_line('<h3>Top 10 SQL from AWR</h3>');
	dbms_output.put_line('<p>No Diagnostic Pack Licence.</p>');
  else
  FOR col IN l_rarray.FIRST .. l_rarray.LAST
  LOOP
    dbms_application_info.set_action('SQL_' || l_rarray(col).column_name );
	dbms_output.put_line('<h3>Top 10 SQL from AWR with high ' || l_rarray(col).description || '</h3>');
	dbms_output.put_line('<table class="sortable"><tr><th>Percent</th><th>Gets</th><th>Gets / Exec</th><th>Reads</th><th>Reads / Exec</th><th>CPU Time (s)</th><th>CPU Time (s) / Exec</th><th>Elapsed Time (s)</th><th>Elapsed Time (s) / Exec</th>	<th>Executions #</th><th>SQL-ID</th><th>Inst-ID</th></tr>');
	mysql := 'select * from ( select instance_number inst_id,
				  sql_id,
				  buffer_gets_delta   buffer_gets,
				  disk_reads_delta    disk_reads,
				  executions_delta    executions,
				  elapsed_time_delta  elapsed_time,
				  cpu_time_delta      cpu_time,
				  pct,
				  rank() over (partition by instance_number order by ' || l_rarray(col).column_name || ' desc)  ranking
				from (select instance_number,
					  sql_id,
					  sum(buffer_gets_delta) buffer_gets_delta,
					  sum(disk_reads_delta) disk_reads_delta,
					  sum(executions_delta) executions_delta,
					  sum(elapsed_time_delta) elapsed_time_delta,
					  sum(cpu_time_delta) cpu_time_delta,
					  100 * ratio_to_report(sum(' || l_rarray(col).column_name || ')) over (partition by instance_number)  pct
					from dba_hist_sqlstat
					where executions_delta > 0
					  and snap_id between
					    (select min(snap_id) from dba_hist_snapshot where begin_interval_time > systimestamp - ' || to_char(:days_back) || ')
						and
					    (select max(snap_id) from dba_hist_snapshot)
				    group by instance_number, sql_id)) s
			where s.ranking <= 10
			order by inst_id, ranking';
    OPEN c FOR mysql;
    LOOP
        FETCH c INTO inst_id, sql_id, buffer_gets, disk_reads, executions, elapsed_time, cpu_time, pct, ranking;
        EXIT WHEN c%NOTFOUND;
    	dbms_output.put_line('<tr><td class="number">' || to_char(round(pct,1), '990D09') || '</td><td class="number">' || to_char(buffer_gets, '999g999g999g999') || '</td><td class="number">' || to_char(round(buffer_gets/executions), '999g999g999g999') || '</td><td class="number">' || to_char(disk_reads, '999g999g999g999') || '</td><td class="number">' || to_char(round(disk_reads/executions), '999g999g999g999') || '</td><td class="number">' || to_char(round(cpu_time/1000000, 3), '999g999g990D09') || '</td><td class="number">' || to_char(round(cpu_time/1000000/executions, 3), '999g999g990D09') || '</td><td class="number">' || to_char(round(elapsed_time/1000000, 3), '999g999g990D09') || '</td><td class="number">' || to_char(round(elapsed_time/1000000/executions, 3), '999g999g990D09') || '</td><td class="number">' || to_char(executions, '999g999g999g999') || '</td><td><a href="#awr' || sql_id || '">' || sql_id ||'</a></td><td class="number">' || to_char(inst_id, '999') || '</td></tr>');
		-- remember SQL-ID
		mysqlids(sql_id) := 1;
    END LOOP;
    CLOSE c;
	dbms_output.put_line('</table>');
  END LOOP;
  -- Full SQL Texts
	dbms_output.put_line('<h3>SQL List</h3><table><tr><th>SQL-ID</th><th>SQL Text</th></tr>');
	-- loop through all SQL-IDs
	ids := mysqlids.first;
	while ids is not null
	loop
    	dbms_output.put_line('<tr><td><a name="awr' || ids || '">' || ids || '</a></td><td><pre><code></code>');
		for rec in (select dbms_lob.substr(sql_text, 4000) sql_text from DBA_HIST_SQLTEXT where sql_id=ids)
		loop
		    if :hide_sql <> 'Y' then
		        dbms_output.put_line(replace(replace(rec.sql_text, '<', '&lt;'), '>', '&gt;') );
		    end if;
		end loop;
	    ids := mysqlids.next(ids);
	end loop;
	dbms_output.put_line('</table>');
  end if;
END;
/
---------------AWR Summary-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('awr_summary');
begin
  dbms_output.put_line('<a name="awr_summary"><h3>AWR Summary (last '||to_char(:days_back)||' days)</h3></a>');
  if :is_diag_licensed = 1 then
	dbms_output.put_line('<table class="sortable"><thead><tr><th>Begin</th><th>End</th><th>Phys. Reads MB/s</th><th>Phys. Writes MB/s</th><th>Redo MB/s</th><th>Phys. Reads IO/s</th><th>Phys. Writes IO/s</th><th>Phys. Redo IO/s</th><th>OS Load</th><th>DB CPU Usage /s</th><th>CPU Util %</th><th>network MB/s</th></tr></thead><tbody>');
    for	rec in
	  (select '<tr><td>' || begin_time ||
		  '</td><td>' || end_time ||
		  '</td><td class="number">' || to_char(Physical_Read_Total_Bps/1024/1024,'999g990D9') ||
		  '</td><td class="number">' || to_char(Physical_Write_Total_Bps/1024/1024,'999g990D9') ||
		  '</td><td class="number">' || to_char(Redo_Bytes_per_sec/1024/1024,'999g990D9') ||
		  '</td><td class="number">' || to_char(Physical_Read_IOPS,'999g990D9') ||
		  '</td><td class="number">' || to_char(Physical_write_IOPS,'999g990') ||
		  '</td><td class="number">' || to_char(Physical_redo_IOPS,'999g990') ||
		  '</td><td class="number">' || to_char(OS_LOad,'9g990D9') ||
		  '</td><td class="number">' || to_char(DB_CPU_Usage_per_sec,'990D99') ||
		  '</td><td class="number">' || to_char(Host_CPU_util,'990D99') ||
		  '</td><td class="number">' || to_char(Network_bytes_per_sec/1024/1024,'999g990D9') ||
		  '</td></tr>' print_col
		from (select min(begin_time) begin_time,
			  max(end_time) end_time,
			  sum(case metric_name when 'Physical Read Total Bytes Per Sec' then average end) Physical_Read_Total_Bps,
			  sum(case metric_name when 'Physical Write Total Bytes Per Sec' then average end) Physical_Write_Total_Bps,
			  sum(case metric_name when 'Redo Generated Per Sec' then average end) Redo_Bytes_per_sec,
			  sum(case metric_name when 'Physical Read Total IO Requests Per Sec' then average end) Physical_Read_IOPS,
			  sum(case metric_name when 'Physical Write Total IO Requests Per Sec' then average end) Physical_write_IOPS,
			  sum(case metric_name when 'Redo Writes Per Sec' then average end) Physical_redo_IOPS,
			  sum(case metric_name when 'Current OS Load' then average end) OS_LOad,
			  sum(case metric_name when 'CPU Usage Per Sec' then average end) DB_CPU_Usage_per_sec,
			  sum(case metric_name when 'Host CPU Utilization (%)' then average end) Host_CPU_util,
			  sum(case metric_name when 'Network Traffic Volume Per Sec' then average end) Network_bytes_per_sec,
			  snap_id
			from dba_hist_sysmetric_summary
			where begin_time >= sysdate-:days_back
			group by snap_id
			order by snap_id))
	loop
	  dbms_output.put_line(rec.print_col);
	end loop;
	dbms_output.put_line('</tbody><thead><tr><th>Summary</th><th></th><th>Phys. Reads MB/s</th><th>Phys. Writes MB/s</th><th>Redo MB/s</th><th>Phys. Reads IO/s</th><th>Phys. Writes IO/s</th><th>Phys. RedoIO/s</th><th>OS Load</th><th>DB CPU Usage /s</th><th>CPU Util %</th><th>network MB/s</th></tr></thead><tfoot>');
	-- print averages
    for	rec in
	  (select '<tr><td><b>AVG' || '</td><td>' ||
		  '</td><td class="number"><b>' ||to_char(Physical_Read_Total_Bps/1024/1024,'999g990D9') ||
		  '</td><td class="number"><b>' ||to_char(Physical_Write_Total_Bps/1024/1024,'999g990D9') ||
		  '</td><td class="number"><b>' ||to_char(Redo_Bytes_per_sec/1024/1024,'999g990D9') ||
		  '</td><td class="number"><b>' ||to_char(Physical_Read_IOPS,'999g990D9') ||
		  '</td><td class="number"><b>' ||to_char(Physical_write_IOPS,'999g990') ||
		  '</td><td class="number"><b>' ||to_char(Physical_redo_IOPS,'999g990') ||
		  '</td><td class="number"><b>' ||to_char(OS_LOad,'9g990D9') ||
		  '</td><td class="number"><b>' ||to_char(DB_CPU_Usage_per_sec,'990D99') ||
		  '</td><td class="number"><b>' ||to_char(Host_CPU_util,'990D99') ||
		  '</td><td class="number"><b>' ||to_char(Network_bytes_per_sec/1024/1024,'999g990D9') ||
		  '</td></tr>' print_col
		from (select avg(case metric_name when 'Physical Read Total Bytes Per Sec' then average end) Physical_Read_Total_Bps,
			  avg(case metric_name when 'Physical Write Total Bytes Per Sec' then average end) Physical_Write_Total_Bps,
			  avg(case metric_name when 'Redo Generated Per Sec' then average end) Redo_Bytes_per_sec,
			  avg(case metric_name when 'Physical Read Total IO Requests Per Sec' then average end) Physical_Read_IOPS,
			  avg(case metric_name when 'Physical Write Total IO Requests Per Sec' then average end) Physical_write_IOPS,
			  avg(case metric_name when 'Redo Writes Per Sec' then average end) Physical_redo_IOPS,
			  avg(case metric_name when 'Current OS Load' then average end) OS_LOad,
			  avg(case metric_name when 'CPU Usage Per Sec' then average end) DB_CPU_Usage_per_sec,
			  avg(case metric_name when 'Host CPU Utilization (%)' then average end) Host_CPU_util,
			  avg(case metric_name when 'Network Traffic Volume Per Sec' then average end) Network_bytes_per_sec
			from dba_hist_sysmetric_summary
			where begin_time >= sysdate-:days_back))
	loop
	  dbms_output.put_line(rec.print_col);
	end loop;
	-- print maximum
    for	rec in
	  (select '<tr><td><b>MAX' || '</td><td>' ||
		  '</td><td class="number"><b>'||to_char(Physical_Read_Total_Bps/1024/1024,'999g990D9') ||
		  '</td><td class="number"><b>'||to_char(Physical_Write_Total_Bps/1024/1024,'999g990D9') ||
		  '</td><td class="number"><b>'||to_char(Redo_Bytes_per_sec/1024/1024,'999g990D9') ||
		  '</td><td class="number"><b>'||to_char(Physical_Read_IOPS,'999g990D9') ||
		  '</td><td class="number"><b>'||to_char(Physical_write_IOPS,'999g990') ||
		  '</td><td class="number"><b>'||to_char(Physical_redo_IOPS,'999g990') ||
		  '</td><td class="number"><b>'||to_char(OS_LOad,'9g990D9') ||
		  '</td><td class="number"><b>'||to_char(DB_CPU_Usage_per_sec,'990D99') ||
		  '</td><td class="number"><b>'||to_char(Host_CPU_util,'990D99') ||
		  '</td><td class="number"><b>'||to_char(Network_bytes_per_sec/1024/1024,'999g990D9') ||
		  '</td></tr>' print_col
		from (select max(case metric_name when 'Physical Read Total Bytes Per Sec' then average end) Physical_Read_Total_Bps,
			  max(case metric_name when 'Physical Write Total Bytes Per Sec' then average end) Physical_Write_Total_Bps,
			  max(case metric_name when 'Redo Generated Per Sec' then average end) Redo_Bytes_per_sec,
			  max(case metric_name when 'Physical Read Total IO Requests Per Sec' then average end) Physical_Read_IOPS,
			  max(case metric_name when 'Physical Write Total IO Requests Per Sec' then average end) Physical_write_IOPS,
			  max(case metric_name when 'Redo Writes Per Sec' then average end) Physical_redo_IOPS,
			  max(case metric_name when 'Current OS Load' then average end) OS_LOad,
			  max(case metric_name when 'CPU Usage Per Sec' then average end) DB_CPU_Usage_per_sec,
			  max(case metric_name when 'Host CPU Utilization (%)' then average end) Host_CPU_util,
			  max(case metric_name when 'Network Traffic Volume Per Sec' then average end) Network_bytes_per_sec
			from dba_hist_sysmetric_summary
			where begin_time >= sysdate-:days_back))
	loop
	  dbms_output.put_line(rec.print_col);
	end loop;
	-- print minimum
    for	rec in
	  (select '<tr><td><b>MIN' ||
		  '</td><td>' ||
		  '</td><td class="number"><b>' || to_char(Physical_Read_Total_Bps/1024/1024,'999g990D9') ||
		  '</td><td class="number"><b>' || to_char(Physical_Write_Total_Bps/1024/1024,'999g990D9') ||
		  '</td><td class="number"><b>' || to_char(Redo_Bytes_per_sec/1024/1024,'999g990D9') ||
		  '</td><td class="number"><b>' || to_char(Physical_Read_IOPS,'999g990D9') ||
		  '</td><td class="number"><b>' || to_char(Physical_write_IOPS,'999g990') ||
		  '</td><td class="number"><b>' || to_char(Physical_redo_IOPS,'999g990') ||
		  '</td><td class="number"><b>' || to_char(OS_LOad,'9g990D9') ||
		  '</td><td class="number"><b>' || to_char(DB_CPU_Usage_per_sec,'990D99') ||
		  '</td><td class="number"><b>' || to_char(Host_CPU_util,'990D99') ||
		  '</td><td class="number"><b>' || to_char(Network_bytes_per_sec/1024/1024,'999g990D9') ||
		  '</td></tr>' print_col
		from (select 
		      min(case metric_name when 'Physical Read Total Bytes Per Sec' then average end) Physical_Read_Total_Bps,
			  min(case metric_name when 'Physical Write Total Bytes Per Sec' then average end) Physical_Write_Total_Bps,
			  min(case metric_name when 'Redo Generated Per Sec' then average end) Redo_Bytes_per_sec,
			  min(case metric_name when 'Physical Read Total IO Requests Per Sec' then average end) Physical_Read_IOPS,
			  min(case metric_name when 'Physical Write Total IO Requests Per Sec' then average end) Physical_write_IOPS,
			  min(case metric_name when 'Redo Writes Per Sec' then average end) Physical_redo_IOPS,
			  min(case metric_name when 'Current OS Load' then average end) OS_LOad,
			  min(case metric_name when 'CPU Usage Per Sec' then average end) DB_CPU_Usage_per_sec,
			  min(case metric_name when 'Host CPU Utilization (%)' then average end) Host_CPU_util,
			  min(case metric_name when 'Network Traffic Volume Per Sec' then average end) Network_bytes_per_sec
			from dba_hist_sysmetric_summary
			where begin_time >= sysdate-:days_back))
	loop
	  dbms_output.put_line(rec.print_col);
	end loop;
	dbms_output.put_line('</tfoot></table><br>');
  else
    dbms_output.put_line('<p>No Diagnostic Pack License.</p>');
  end if;
end;
/
---------------Segments by logical reads-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('segs_logical');
select '<hr /><a name="segs_logical"><h3>Top 10 Segments by logical reads (since startup)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Owner</th><th>Object Name</th><th>Tablespace</th><th>Reads / sec</th></tr>' FROM dual;
select '<tr><td>' || instance_name || '</td><td>'
  || owner || '</td><td>'
  || object_name || '</td><td>'
  || tablespace_name ||	'</td><td class="number">'
  || round(reads) || '</td></tr>'
from (select instance_name
        , owner
		, object_name
		, tablespace_name
		, value/((sysdate-startup_time)*86400) reads
      from gv$segment_statistics s, gv$instance i
      where s.inst_id = i.inst_id
      and s.statistic_name = 'logical reads'
      order by value desc)
where rownum <11;
select '</table><br>' FROM dual;
---------------Segments by physical reads-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('segs_physical');
select '<a name="segs_physical"><h3>Top 10 Segments by physical reads (since startup)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Owner</th><th>Object Name</th><th>Tablespace</th><th>Reads / sec</th></tr>' FROM dual;
select '<tr><td>' || instance_name || '</td><td>'
  || owner || '</td><td>'
  || object_name || '</td><td>'
  || tablespace_name || '</td><td class="number">' 
  || round(reads) ||'</td></tr>'
from (select instance_name
        , owner
		, object_name
		, tablespace_name
		, value/((sysdate-startup_time)*86400) reads
      from gv$segment_statistics s, gv$instance i
      where s.inst_id = i.inst_id
      and s.statistic_name = 'physical reads'
      order by value desc)
where rownum <11;
select '</table><br>' FROM dual;
---------------Segments by physical writes-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('segs_writes');
select '<a name="segs_writes"><h3>Top 10 Segments by physical writes (since startup)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Owner</th><th>Object Name</th><th>Tablespace</th><th>Writes / sec</th></tr>' FROM dual;
select '<tr><td>' || instance_name || '</td><td>'
  || owner || '</td><td>'
  || object_name || '</td><td>'
  || tablespace_name || '</td><td class="number">' 
  || round(reads) ||'</td></tr>'
from (select instance_name
        , owner
		, object_name
		, tablespace_name
		, value/((sysdate-startup_time)*86400) reads
      from gv$segment_statistics s, gv$instance i
      where s.inst_id = i.inst_id
      and s.statistic_name = 'physical writes'
      order by value desc)
where rownum <11;
select '</table><br>' FROM dual;
---------------Segments by block changes-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('segs_changes');
select '<a name="segs_changes"><h3>Top 10 Segments by block changes (since startup)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Owner</th><th>Object Name</th><th>Tablespace</th><th>Block Changes / sec</th></tr>' FROM dual;
select '<tr><td>' || instance_name || '</td><td>'
  || owner || '</td><td>' 
  || object_name || '</td><td>'
  || tablespace_name || '</td><td class="number">' 
  || round(reads) || '</td></tr>'
from (select instance_name
        , owner
		, object_name
		, tablespace_name
		, value/((sysdate-startup_time)*86400) reads
      from gv$segment_statistics s, gv$instance i
      where s.inst_id = i.inst_id
      and s.statistic_name = 'db block changes'
      order by value desc)
where rownum <11;
select '</table><br>' FROM dual;
---------------Segments by buffer busy waits----------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('segs_busy');
select '<a name="segs_busy"><h3>Top 10 Segments by buffer busy waits (since startup)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Owner</th><th>Object Name</th><th>Tablespace</th><th>buffer busy waits / sec</th></tr>' FROM dual;
select '<tr><td>' || instance_name || '</td><td>'
  || owner || '</td><td>'
  || object_name || '</td><td>'
  || tablespace_name || '</td><td class="number">' 
  || round(reads) ||'</td></tr>'
from (select instance_name
        , owner
		, object_name
		, tablespace_name
		, value/((sysdate-startup_time)*86400) reads
      from gv$segment_statistics s, gv$instance i
      where s.inst_id = i.inst_id
      and s.statistic_name = 'buffer busy waits'
      order by value desc)
where rownum <11;
select '</table><br>' FROM dual;
---------------Latch Hit ratio-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('latches');
select '<a name="latches"><h3>Latch Hit Ratios (<100%)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Latch Name</th><th>Hit Ratio %</th><th>Sleeps / Miss</th></tr>' FROM dual;
select '<tr><td>' || instance_name || '</td><td>' 
  || name || '</td><td class="number'
  || case when hit_ratio < 95 then 'critical' when hit_ratio < 99 then 'warning' end || '">' 
  || hit_ratio || '</td><td class="number">'
  || sleep_miss || '</td></tr>'
from (select i.instance_name
        , l.name
		, round((gets-misses)/decode(gets,0,1,gets),3)*100 hit_ratio
		, round(sleeps/decode(misses,0,1,misses),3) sleep_miss
      from gv$latch l, gv$instance i
      where l.gets != 0
      and l.inst_id = i.inst_id)
where hit_ratio < 100
order by hit_ratio;
select '</table><br>' FROM dual;
---------------Dataguard-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('dataguard');
prompt <hr /><a name="dataguard"><h3>Dataguard</h3></a><a id="b_dataguard" href="javascript:switchdiv('d_dataguard')">(+)</a><div id="d_dataguard" style="display:none;">
select '<h4>Processes</h4>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Process</th><th>Client</th><th>Sequence</th><th>Status</th></tr>' FROM dual;
select '<tr><td>' || i.instance_name || '</td><td>'
  || a.PROCESS || '</td><td>'
  || a.CLIENT_PROCESS || '</td><td>'
  || a.SEQUENCE# || '</td><td>' 
  || a.STATUS || '</td></tr>'
FROM gv$MANAGED_STANDBY a, gv$INSTANCE i
where a.inst_id = i.inst_id
order by i.instance_name, a.process;
select '</table><br>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Type</th><th>Status</th></tr>' FROM dual;
select '<tr><td>' || i.instance_name || '</td><td>'
  || a.TYPE || '</td><td>'
  || a.STATUS || '</td></tr>'
FROM gv$LOGSTDBY_PROCESS a, gv$INSTANCE i
where a.inst_id = i.inst_id
order by i.instance_name, a.type;
select '</table><br>' FROM dual;
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('dataguard - Archive Destinations');
select '<h4>Archive Destinations</h4>' FROM	dual;
select '<table class="sortable"><tr><th>Instance</th><th>ARCHIVED_THREAD#</th><th>ARCHIVED_SEQ#</th><th>APPLIED_THREAD#</th><th>APPLIED_SEQ#</th></tr>' FROM dual;
select '<tr><td>' || i.instance_name || '</td><td>'
  || a.ARCHIVED_THREAD# || '</td><td>'
  || a.ARCHIVED_SEQ# || '</td><td>'
  || a.APPLIED_THREAD# || '</td><td>'
  || a.APPLIED_SEQ# ||'</td></tr>'
FROM Gv$ARCHIVE_DEST_STATUS a, Gv$INSTANCE i
where a.inst_id = i.inst_id
order by i.instance_name, a.ARCHIVED_THREAD#;
select '</table><br>' FROM dual;
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('dataguard - Archive Log History');
select '<h4>Archive Log History (last '||to_char(:days_back)||' days)</h4>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Thread</th><th>Sequence</th><th>First Time</th><th>archived</th><th>applied</th><th>deleted</th></tr>' FROM dual;
select '<tr><td>' || i.Instance_name || ' @ ' 
  || i.host_name || '</td><td>'
  || a.THREAD# || '</td><td>'
  || a.SEQUENCE# || '</td><td>'
  || to_char(a.first_time, 'dd/mm/yyyy hh24:mi:ss') || '</td><td>'
  || a.archived || '</td><td>' 
  || a.APPLIED ||'</td><td>' 
  || a.deleted ||'</td></tr>'
FROM Gv$ARCHIVED_LOG a, gv$instance i
where a.inst_id = i.inst_id
and a.first_time > sysdate-:days_back
order by i.instance_name, a.thread#, a.sequence#;
select '</table><br>' FROM dual;
------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('dataguard - Archive Gap');
select '<h4>Archive Gap</h4>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Thread</th><th>Low Sequence</th><th>High Sequence</th></tr>' FROM dual;
select '<tr><td>' || i.Instance_name || '</td><td>'
  || a.THREAD# || '</td><td>'
  || a.LOW_SEQUENCE# || '</td><td>'
  || a.HIGH_SEQUENCE# || '</td></tr>'
FROM Gv$ARCHIVE_GAP a, gv$instance i
where a.inst_id = i.inst_id
order by i.instance_name, a.thread#, a.low_sequence#;
select '</table><br>' FROM dual;
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('dataguard - Logical Standby Status');
select '<h4>Logical Standby Status</h4>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Applied Time</th><th>Applied SCN</th><th>Mining Time</th><th>Minig SCN</th><th>Latest Time</th><th>Latest SCN</th><th>Apply Lag (s)</th></tr>' FROM dual;
select '<tr><td>' || i.Instance_name || '</td><td>' 
  || to_char(APPLIED_TIME, 'dd/mm/yyyy hh24:mi:ss') || '</td><td>' 
  || a.APPLIED_SCN || '</td><td>' 
  || to_char(MINING_TIME, 'dd/mm/yyyy hh24:mi:ss') || '</td><td>' 
  || a.MINING_SCN || '</td><td>' 
  || to_char(LATEST_TIME, 'dd/mm/yyyy hh24:mi:ss') || '</td><td>'
  || a.LATEST_SCN || '</td><td>'
  || to_char((latest_time - applied_time)*86400, '999g990d9') || '</td></tr>'
FROM Gv$LOGSTDBY_PROGRESS a, gv$instance i
where a.inst_id = i.inst_id
order by i.instance_name;
select '</table><br>' FROM dual;
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('dataguard - Logical Standby Events');
select '<h4>Logical Standby Events</h4>' FROM dual;
select '<table class="sortable"><tr><th>Event Time</th><th>Status</th><th>Event</th></tr>' FROM dual;
select '<tr><td>' || to_char(EVENT_TIME, 'dd/mm/yyyy hh24:mi:ss') || '</td><td>'
  || STATUS || '</td><td>'
  || dbms_lob.substr(EVENT,200,1) || '</td></tr>'
FROM DBA_LOGSTDBY_EVENTS
where event_time > sysdate-31
ORDER BY EVENT_TIMESTAMP, COMMIT_SCN;
select '</table></div><br>' FROM dual;
---------------RAC-----------------------------------------------------------------------------------
------------- several scripts taken from Note 135714.1-----------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('rac_interconnect');
prompt <hr /><a name="rac_interconnect"><h3>RAC</h3></a><a id="b_rac_interconnect" href="javascript:switchdiv('d_rac_interconnect')">(+)</a><div id="d_rac_interconnect" style="display:none;">
select '<h4>Current Block Transfer Time</h4> ' || '<p>This shows the average latency of a consistent block request. ' || 'AVG CR BLOCK RECEIVE TIME should typically be about 15 milliseconds depending ' || 'on your system configuration and volume, is the average latency of a  ' || 'consistent-read request round-trip from the requesting instance to the holding  ' || 'instance and back to the requesting instance. If your CPU has limited idle time  ' || 'and your system typically processes long-running queries, then the latency may  ' || 'be higher. However, it is possible to have an average latency of less than one  ' || 'millisecond with User-mode IPC. Latency can be influenced by a high value for  ' || 'the DB_MULTI_BLOCK_READ_COUNT parameter. This is because a requesting process  ' || 'can issue more than one request for a block depending on the setting of this  ' || 'parameter. Correspondingly, the requesting process may wait longer.  Also check ' || 'interconnect badwidth, OS tcp settings, and OS udp settings if ' || 'AVG CR BLOCK RECEIVE TIME is high.</p>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Received</th><th>Receive Time</th><th>Avg Receive Time (ms)</th></tr>' FROM dual;
select '<tr><td>' || instance_name || '</td><td class="number">'
  || GLOBAL_LOCK_GETS || '</td><td class="number">'
  || GLOBAL_LOCK_GET_TIME || '</td><td class="number' 
  || case when AVG_GLOBAL_LOCK_GET_TIME > 50 then 'critical' when AVG_GLOBAL_LOCK_GET_TIME > 30 then 'warning' end || '">' 
  || round(AVG_GLOBAL_LOCK_GET_TIME,1) || '</td></tr>'
from (select b1.inst_id
        , (case when b1.value = 0 then null else b1.value end + case when b2.value = 0 then null else b2.value end) GLOBAL_LOCK_GETS
		, b3.value GLOBAL_LOCK_GET_TIME
		, (case when b3.value = 0 then null else b3.value end / (case when b1.value = 0 then null else b1.value end + case when b2.value = 0 then null else b2.value end) * 10) AVG_GLOBAL_LOCK_GET_TIME
	  from gv$sysstat b1, gv$sysstat b2, gv$sysstat b3
	  where b1.name = 'global lock sync gets'
	  and   b2.name = 'global lock async gets'
	  and   b3.name = 'global lock get time'
	  and   b1.inst_id = b2.inst_id
	  and   b2.inst_id = b3.inst_id
	  or    b1.name = 'global enqueue gets sync'
	  and   b2.name = 'global enqueue gets async'
	  and   b3.name = 'global enqueue get time'
	  and   b1.inst_id = b2.inst_id
	  and   b2.inst_id = b3.inst_id) s, gv$instance i
where s.inst_id = i.inst_id
order by 1;
select '</table><br>' FROM dual;
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('rac_interconnect - Global Cache Lock');
select '<h4>Global Cache Lock Performance</h4>' || '<p>This shows the average global enqueue get time. ' || 'Typically AVG GLOBAL LOCK GET TIME should be 20-30 milliseconds. The elapsed ' || 'time for a get includes the allocation and initialization of a new global ' || 'enqueue. If the average global enqueue get (global cache get time) or average ' || 'global enqueue conversion times are excessive, then your system may be ' || 'experiencing timeouts.  See the ''WAITING SESSIONS'', ''GES LOCK BLOCKERS'', ' || '''GES LOCK WAITERS'', and ''TOP 10 WAIT EVENTS ON SYSTEM'' sections if the ' || 'AVG GLOBAL LOCK GET TIME is high.</p>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Gets</th><th>Get Time</th><th>Avg Get Time (ms)</th></tr>' FROM dual;
select '<tr><td>' || instance_name || '</td><td class="number">'
  || GLOBAL_LOCK_GETS || '</td><td class="number">'
  || GLOBAL_LOCK_GET_TIME || '</td><td class="number' 
  || case when AVG_GLOBAL_LOCK_GET_TIME > 50 then 'critical' when AVG_GLOBAL_LOCK_GET_TIME > 30 then 'warning' end || '">' 
  || round(AVG_GLOBAL_LOCK_GET_TIME,1) || '</td></tr>'
from (select b1.inst_id
        , (case when b1.value = 0 then null else b1.value end + case when b2.value = 0 then null else b2.value end) GLOBAL_LOCK_GETS
		, b3.value GLOBAL_LOCK_GET_TIME
		, (case when b3.value = 0 then null else b3.value end / (case when b1.value = 0 then null else b1.value end + case when b2.value = 0 then null else b2.value end) * 10) AVG_GLOBAL_LOCK_GET_TIME
	  from gv$sysstat b1, gv$sysstat b2, gv$sysstat b3
	  where b1.name = 'global lock sync gets'
	  and   b2.name = 'global lock async gets'
	  and   b3.name = 'global lock get time'
	  and   b1.inst_id = b2.inst_id
	  and   b2.inst_id = b3.inst_id
	  or    b1.name = 'global enqueue gets sync'
	  and   b2.name = 'global enqueue gets async'
	  and   b3.name = 'global enqueue get time'
	  and   b1.inst_id = b2.inst_id
	  and   b2.inst_id = b3.inst_id) s, gv$instance i
where s.inst_id = i.inst_id
order by 1;
select '</table><br>' FROM dual;
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('rac_interconnect - Resource Allocation');
select '<h4>Resource Allocation</h4>' FROM dual;
select '<table class="sortable"><tr><th>Instance</th><th>Resource</th><th>Current util.</th><th>Max util.</th><th>Initial allocation</th></tr>' FROM dual;
select '<tr><td>' || instance_name || '</td><td>'
  || resource_name || '</td><td class="number">'
  || current_utilization || '</td><td class="number">'
  || max_utilization || '</td><td class="number">'
  || initial_allocation || '</td></tr>'
from  gv$resource_limit l, gv$instance i
where l.max_utilization > 0
and   i.inst_id = l.inst_id
order by instance_name, resource_name;
select '</table></div><br>' FROM dual;
---------------ASM----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('asm');
select '<hr /><a name="asm"><h3>ASM</h3></a><h4>Disk Groups</h4>' FROM dual;
select '<table class="sortable"><tr><th>Name</th><th>Redundancy</th><th>Total MB</th><th>Free MB</th><th>Used Space %</th><th>Offline Disks</th></tr>' FROM dual;
select '<tr><td>' || name || '</td><td>'
  || type || '</td><td class="number">'
  || to_char(total_mb, '999g999g990d0') || '</td><td class="number">'
  || to_char(free_mb, '999g999g990d0') || '</td><td class="number'
  || case when 1-(free_mb/total_mb) > 0.95 then 'critical' when 1-(free_mb/total_mb) > 0.9 then 'warning' end || '">' 
  || to_char(round(100-free_mb/total_mb*100, 1), '990d0') || '</td><td class="number">'
  || offline_disks || '</td></tr>'
FROM v$asm_diskgroup
order by name;
select '</table><br>' FROM dual;
select '<h4>Disks</h4>' FROM dual;
select '<table class="sortable"><tr><th>Disk Name</th><th>Group Name</th><th>Failgroup</th><th>Path</th><th>Product</th><th>Mount Status</th><th>Header Status</th><th>Mode Status</th><th>State</th><th>Redundancy</th><th>Read Time (ms)</th><th>Write Time (ms)</th><th>Read Errors</th><th>Write Errors</th></tr>' FROM dual;
select '<tr><td>'
  || d.name || '</td><td>'
  || g.name || '</td><td>'
  || d.failgroup || '</td><td>'
  || d.path || '</td><td>'
  || d.product || '</td><td>'
  || d.mount_status || '</td><td>'
  || d.header_status || '</td><td>'
  || d.mode_status || '</td><td>'
  || d.state || '</td><td>' 
  || d.redundancy || '</td><td class="number">'
  || round(d.reads/d.read_time*10) || '</td><td class="number">'
  || round(d.writes/d.write_time*10) || '</td><td class="number'
  || case when d.read_errs > 0 then 'critical' end || '">' 
  || d.read_errs || '</td><td class="number'
  || case when d.write_errs > 0 then 'critical' end || '">' 
  || d.write_errs || '</td></tr>' 
from v$asm_diskgroup g, v$asm_disk d
where g.group_number = d.group_number
order by g.name, d.name;
select '</table><br>' FROM dual;
---------------v$option----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('options');
select '<table class="sortable"><tr><th>Option</th><th>Value</th></tr>' FROM dual;
select '<tr><td>' || parameter || '</td><td>' || value || '</td></tr>'
FROM v$option
order by value desc, parameter asc;
select '</table><br>' FROM dual;
---------------Registy-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('dba_registry');
select '<hr /><a name="dba_registry"><h3>DB-Registy</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Component</th><th>Name</th><th>Version</th><th>Status</th><th>modified</th></tr>' FROM dual;
select '<tr><td>' || comp_id || '</td><td>'
  || comp_name || '</td><td>'
  || version || '</td><td' 
  || decode(status, 'VALID', '>', 'INVALID', ' class="critical">', ' class="warning">') 
  || status || '</td><td>' 
  || modified || '</td></tr>'
FROM dba_registry;
select '</table><br>' FROM dual;
---------------Registy History-----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('registry_history');
select '<a name="registry_history"><h3>Registy History</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Timestamp</th><th>Action</th><th>namespace</th><th>Version</th><th>ID</th><th>Comments</th></tr>' FROM dual;
select '<tr><td>' || ACTION_TIME ||'</td><td>' 
  || ACTION || '</td><td>' 
  || NAMESPACE || '</td><td>' 
  || VERSION || '</td><td>' 
  || ID || '</td><td>' 
  || COMMENTS || '</td></tr>'
FROM sys.registry$history
order by ACTION_TIME desc;
select '</table><br>' FROM dual;
---------------Registy History 12.1c--------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('registry_history_121');
select '<a name="registry_history"><h3>SQL-Patch Registry (12.1c)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Timestamp</th><th>Action</th><th>Status</th><th>Patch ID</th><th>Bundle ID</th></tr>' FROM dual;
select '<tr><td>' || ACTION_TIME || '</td><td>' || ACTION || '</td><td>' || STATUS || '</td><td>' || PATCH_ID || '</td><td>' || DESCRIPTION || '</td></tr>' FROM dba_registry_sqlpatch order by ACTION_TIME desc;
select '</table><br>' FROM dual;
---------------Registy History 12.2c--------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('registry_history_122');
select '<a name="registry_history"><h3>SQL-Patch Registry (12.2c)</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Timestamp</th><th>Action</th><th>Status</th><th>Patch ID</th><th>Bundle ID</th></tr>' FROM dual;
select '<tr><td>' || ACTION_TIME || '</td><td>' || ACTION || '</td><td>' || STATUS || '</td><td>' || PATCH_ID || '</td><td>' || DESCRIPTION || '</td></tr>' FROM dba_registry_sqlpatch order by ACTION_TIME desc;
select '</table><br>' FROM dual;
---------------DBA_FEATURE_USAGE_STATISTICS----------------------------------------------------------------------------------
--------------MOS Note 1317265.1-------------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('feature_usage');
prompt <a name="feature_usage"><h3>Feature Usage</h3></a>
set define on
-- Prepare settings for pre 12c databases
define DFUS=DBA_
col DFUS_ new_val DFUS noprint
define DCOL1=CON_ID
col DCOL1_ new_val DCOL1 noprint
define DCID=-1
col DCID_ new_val DCID noprint
define DCOL2=CON_NAME
col DCOL2_ new_val DCOL2 noprint
define DCNA=to_char(NULL)
col DCNA_ new_val DCNA noprint
select 'CDB_' as DFUS_
  , 'CON_ID' as DCID_
  , '(select NAME from v$CONTAINERS xz where xz.CON_ID=xy.CON_ID)' as DCNA_
  , 'XXXXXX' as DCOL1_
  , 'XXXXXX' as DCOL2_ 
from CDB_FEATURE_USAGE_STATISTICS 
where exists (select 1 from v$DATABASE where CDB='YES')
and rownum=1;
select '<table class="sortable">
  <tr>
  <th>Container</th>
  <th>Feature</th>
  <th>Usage</th>
  <th>Last Sample Date</th>
  <th>First Usage Date</th>
  <th>Last Usage Date</th>
  </tr>'
FROM dual;
with
MAP as (
-- mapping between features tracked by DBA_FUS and their corresponding database products (options or packs)
select '' PRODUCT, '' feature, '' MVERSION, '' CONDITION from dual union all
select 'Active Data Guard'                                   , 'Active Data Guard - Real-Time Query on Physical Standby' , '11.2'       , ' '       from dual union all
select 'Active Data Guard'                                   , 'Active Data Guard - Real-Time Query on Physical Standby' , '12.1'       , ' '       from dual union all
select 'Active Data Guard'                                   , 'Global Data Services'                                    , '12.1'       , ' '       from dual union all
select 'Advanced Analytics'                                  , 'Data Mining'                                             , '11.2'       , ' '       from dual union all
select 'Advanced Analytics'                                  , 'Data Mining'                                             , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'ADVANCED Index Compression'                              , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Advanced Index Compression'                              , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Backup HIGH Compression'                                 , '11.2'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Backup HIGH Compression'                                 , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Backup LOW Compression'                                  , '11.2'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Backup LOW Compression'                                  , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Backup MEDIUM Compression'                               , '11.2'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Backup MEDIUM Compression'                               , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Backup ZLIB Compression'                                 , '11.2'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Backup ZLIB Compression'                                 , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Data Guard'                                              , '11.2'       , 'C001'    from dual union all
select 'Advanced Compression'                                , 'Data Guard'                                              , '12.1'       , 'C001'    from dual union all
select 'Advanced Compression'                                , 'Flashback Data Archive'                                  , '11.2'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Flashback Data Archive'                                  , '11.2.0.4'   , 'INVALID' from dual union all -- licensing required by Optimization for Flashback Data Archive
select 'Advanced Compression'                                , 'Flashback Data Archive'                                  , '12.1'       , 'INVALID' from dual union all -- licensing required by Optimization for Flashback Data Archive
select 'Advanced Compression'                                , 'HeapCompression'                                         , '11.2'       , ' '       from dual union all
select 'Advanced Compression'                                , 'HeapCompression'                                         , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Heat Map'                                                , '12.1'       , ' '       from dual union all --
select 'Advanced Compression'                                , 'Hybrid Columnar Compression Row Level Locking'           , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Information Lifecycle Management'                        , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Oracle Advanced Network Compression Service'             , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Oracle Utility Datapump (Export)'                        , '11.2'       , 'C001'    from dual union all
select 'Advanced Compression'                                , 'Oracle Utility Datapump (Export)'                        , '12.1'       , 'C001'    from dual union all
select 'Advanced Compression'                                , 'Oracle Utility Datapump (Import)'                        , '11.2'       , 'C001'    from dual union all
select 'Advanced Compression'                                , 'Oracle Utility Datapump (Import)'                        , '12.1'       , 'C001'    from dual union all
select 'Advanced Compression'                                , 'SecureFile Compression (user)'                           , '11.2'       , ' '       from dual union all
select 'Advanced Compression'                                , 'SecureFile Compression (user)'                           , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'SecureFile Deduplication (user)'                         , '11.2'       , ' '       from dual union all
select 'Advanced Compression'                                , 'SecureFile Deduplication (user)'                         , '12.1'       , ' '       from dual union all
select 'Advanced Security'                                   , 'Backup Encryption'                                       , '11.2'       , ' '       from dual union all
select 'Advanced Security'                                   , 'Backup Encryption'                                       , '12.1'       , 'INVALID' from dual union all -- licensing required only by encryption to disk
select 'Advanced Security'                                   , 'Data Redaction'                                          , '12.1'       , ' '       from dual union all
select 'Advanced Security'                                   , 'Encrypted Tablespaces'                                   , '11.2'       , ' '       from dual union all
select 'Advanced Security'                                   , 'Encrypted Tablespaces'                                   , '12.1'       , ' '       from dual union all
select 'Advanced Security'                                   , 'Oracle Utility Datapump (Export)'                        , '11.2'       , 'C002'    from dual union all
select 'Advanced Security'                                   , 'Oracle Utility Datapump (Export)'                        , '12.1'       , 'C002'    from dual union all
select 'Advanced Security'                                   , 'Oracle Utility Datapump (Import)'                        , '11.2'       , 'C002'    from dual union all
select 'Advanced Security'                                   , 'Oracle Utility Datapump (Import)'                        , '12.1'       , 'C002'    from dual union all
select 'Advanced Security'                                   , 'SecureFile Encryption (user)'                            , '11.2'       , ' '       from dual union all
select 'Advanced Security'                                   , 'SecureFile Encryption (user)'                            , '12.1'       , ' '       from dual union all
select 'Advanced Security'                                   , 'Transparent Data Encryption'                             , '11.2'       , ' '       from dual union all
select 'Advanced Security'                                   , 'Transparent Data Encryption'                             , '12.1'       , ' '       from dual union all
select 'Change Management Pack'                              , 'Change Management Pack'                                  , '11.2'       , ' '       from dual union all
select 'Configuration Management Pack for Oracle Database'   , 'EM Config Management Pack'                               , '11.2'       , ' '       from dual union all
select 'Data Masking Pack'                                   , 'Data Masking Pack'                                       , '11.2'       , ' '       from dual union all
select '.Database Gateway'                                   , 'Gateways'                                                , '12.1'       , ' '       from dual union all
select '.Database Gateway'                                   , 'Transparent Gateway'                                     , '12.1'       , ' '       from dual union all
select 'Database In-Memory'                                  , 'In-Memory Aggregation'                                   , '12.1'       , ' '       from dual union all
select 'Database In-Memory'                                  , 'In-Memory Column Store'                                  , '12.1.0.2'   , 'BUG'     from dual union all
select 'Database Vault'                                      , 'Oracle Database Vault'                                   , '11.2'       , ' '       from dual union all
select 'Database Vault'                                      , 'Oracle Database Vault'                                   , '12.1'       , ' '       from dual union all
select 'Database Vault'                                      , 'Privilege Capture'                                       , '12.1'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'ADDM'                                                    , '11.2'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'ADDM'                                                    , '12.1'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'AWR Baseline'                                            , '11.2'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'AWR Baseline'                                            , '12.1'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'AWR Baseline Template'                                   , '11.2'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'AWR Baseline Template'                                   , '12.1'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'AWR Report'                                              , '11.2'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'AWR Report'                                              , '12.1'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'Automatic Workload Repository'                           , '12.1'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'Baseline Adaptive Thresholds'                            , '11.2'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'Baseline Adaptive Thresholds'                            , '12.1'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'Baseline Static Computations'                            , '11.2'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'Baseline Static Computations'                            , '12.1'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'Diagnostic Pack'                                         , '11.2'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'EM Performance Page'                                     , '12.1'       , ' '       from dual union all
select '.Exadata'                                            , 'Exadata'                                                 , '11.2'       , ' '       from dual union all
select '.Exadata'                                            , 'Exadata'                                                 , '12.1'       , ' '       from dual union all
select '.GoldenGate'                                         , 'GoldenGate'                                              , '12.1'       , ' '       from dual union all
select '.HW'                                                 , 'Hybrid Columnar Compression'                             , '12.1'       , 'BUG'     from dual union all
select '.HW'                                                 , 'Hybrid Columnar Compression Row Level Locking'           , '12.1'       , ' '       from dual union all
select '.HW'                                                 , 'Sun ZFS with EHCC'                                       , '12.1'       , ' '       from dual union all
select '.HW'                                                 , 'ZFS Storage'                                             , '12.1'       , ' '       from dual union all
select '.HW'                                                 , 'Zone maps'                                               , '12.1'       , ' '       from dual union all
select 'Label Security'                                      , 'Label Security'                                          , '11.2'       , ' '       from dual union all
select 'Label Security'                                      , 'Label Security'                                          , '12.1'       , ' '       from dual union all
select 'Multitenant'                                         , 'Oracle Multitenant'                                      , '12.1'       , 'C003'    from dual union all -- licensing required only when more than one PDB containers are created
select 'Multitenant'                                         , 'Oracle Pluggable Databases'                              , '12.1'       , 'C003'    from dual union all -- licensing required only when more than one PDB containers are created
select 'OLAP'                                                , 'OLAP - Analytic Workspaces'                              , '11.2'       , ' '       from dual union all
select 'OLAP'                                                , 'OLAP - Analytic Workspaces'                              , '12.1'       , ' '       from dual union all
select 'OLAP'                                                , 'OLAP - Cubes'                                            , '12.1'       , ' '       from dual union all
select 'Partitioning'                                        , 'Partitioning (user)'                                     , '11.2'       , ' '       from dual union all
select 'Partitioning'                                        , 'Partitioning (user)'                                     , '12.1'       , ' '       from dual union all
select 'Partitioning'                                        , 'Zone maps'                                               , '12.1'       , ' '       from dual union all
select '.Pillar Storage'                                     , 'Pillar Storage'                                          , '12.1'       , ' '       from dual union all
select '.Pillar Storage'                                     , 'Pillar Storage with EHCC'                                , '12.1'       , ' '       from dual union all
select '.Provisioning and Patch Automation Pack'             , 'EM Standalone Provisioning and Patch Automation Pack'    , '11.2'       , ' '       from dual union all
select 'Provisioning and Patch Automation Pack for Database' , 'EM Database Provisioning and Patch Automation Pack'      , '11.2'       , ' '       from dual union all
select 'RAC or RAC One Node'                                 , 'Quality of Service Management'                           , '12.1'       , ' '       from dual union all
select 'Real Application Clusters'                           , 'Real Application Clusters (RAC)'                         , '11.2'       , ' '       from dual union all
select 'Real Application Clusters'                           , 'Real Application Clusters (RAC)'                         , '12.1'       , ' '       from dual union all
select 'Real Application Clusters One Node'                  , 'Real Application Cluster One Node'                       , '12.1'       , ' '       from dual union all
select 'Real Application Testing'                            , 'Database Replay: Workload Capture'                       , '11.2'       , ' '       from dual union all
select 'Real Application Testing'                            , 'Database Replay: Workload Capture'                       , '12.1'       , ' '       from dual union all
select 'Real Application Testing'                            , 'Database Replay: Workload Replay'                        , '11.2'       , ' '       from dual union all
select 'Real Application Testing'                            , 'Database Replay: Workload Replay'                        , '12.1'       , ' '       from dual union all
select 'Real Application Testing'                            , 'SQL Performance Analyzer'                                , '11.2'       , ' '       from dual union all
select 'Real Application Testing'                            , 'SQL Performance Analyzer'                                , '12.1'       , ' '       from dual union all
select '.Secure Backup'                                      , 'Oracle Secure Backup'                                    , '12.1'       , 'INVALID' from dual union all  -- does not differentiate usage of Oracle Secure Backup Express, which is free
select 'Spatial and Graph'                                   , 'Spatial'                                                 , '11.2'       , 'INVALID' from dual union all  -- does not differentiate usage of Locator, which is free
select 'Spatial and Graph'                                   , 'Spatial'                                                 , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'Automatic Maintenance - SQL Tuning Advisor'              , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'Automatic SQL Tuning Advisor'                            , '11.2'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'Automatic SQL Tuning Advisor'                            , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'Real-Time SQL Monitoring'                                , '11.2'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'Real-Time SQL Monitoring'                                , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'SQL Access Advisor'                                      , '11.2'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'SQL Access Advisor'                                      , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'SQL Monitoring and Tuning pages'                         , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'SQL Profile'                                             , '11.2'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'SQL Profile'                                             , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'SQL Tuning Advisor'                                      , '11.2'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'SQL Tuning Advisor'                                      , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'SQL Tuning Set (user)'                                   , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'Tuning Pack'                                             , '11.2'       , ' '       from dual union all
select '.WebLogic Server Management Pack Enterprise Edition' , 'EM AS Provisioning and Patch Automation Pack'            , '11.2'       , ' '       from dual union all
select '' PRODUCT, '' FEATURE, '' MVERSION, '' CONDITION from dual),
FUS as (
-- the current data set to be used: DBA_FEATURE_USAGE_STATISTICS or CDB_FEATURE_USAGE_STATISTICS for Container Databases(CDBs)
select
    &&DCID as CON_ID,
    &&DCNA as CON_NAME,
    -- Detect and mark with Y the current DBA_FUS data set = Most Recent Sample based on LAST_SAMPLE_DATE
      case when DBID || '#' || VERSION || '#' || to_char(LAST_SAMPLE_DATE, 'YYYYMMDDHH24MISS') =
                first_value (DBID    ) over (partition by &&DCID order by LAST_SAMPLE_DATE desc nulls last, DBID desc) || '#' ||
                first_value (VERSION ) over (partition by &&DCID order by LAST_SAMPLE_DATE desc nulls last, DBID desc) || '#' ||
                first_value (to_char(LAST_SAMPLE_DATE, 'YYYYMMDDHH24MISS')) over (partition by &&DCID order by LAST_SAMPLE_DATE desc nulls last, DBID desc)
           then 'Y'
           else 'N'
    end as CURRENT_ENTRY,
    NAME            ,
    LAST_SAMPLE_DATE,
    DBID            ,
    VERSION         ,
    DETECTED_USAGES ,
    TOTAL_SAMPLES   ,
    CURRENTLY_USED  ,
    FIRST_USAGE_DATE,
    LAST_USAGE_DATE ,
    AUX_COUNT       ,
    FEATURE_INFO
from &&DFUS.FEATURE_USAGE_STATISTICS xy),
PFUS as (
-- Product-Feature Usage Statitsics = DBA_FUS entries mapped to their corresponding database products
select CON_ID,
    CON_NAME,
    PRODUCT,
    NAME as FEATURE_BEING_USED,
    case  when CONDITION = 'BUG'
               --suppressed due to exceptions/defects
            then '3.SUPPRESSED_DUE_TO_BUG'
          when detected_usages > 0               -- some usage detection - current or past
           and(trim(CONDITION) is null
               -- if special conditions (coded on the MAP.CONDITION column) are required, check if entries satisfy the condition
               -- C001 = compression has been used
               or CONDITION = 'C001' and regexp_like(to_char(FEATURE_INFO), 'compression used: *TRUE', 'i')
               -- C002 = encryption has been used
               or CONDITION = 'C002' and regexp_like(to_char(FEATURE_INFO), 'encryption used: *TRUE', 'i')
               -- C003 = more than one PDB are created
               or CONDITION = 'C003' and CON_ID=1 and AUX_COUNT > 1
              )
            then decode(CURRENT_ENTRY || '#' || CURRENTLY_USED, 'Y#TRUE', '6.CURRENT_USAGE', '4.PAST_USAGE')
          when detected_usages > 0               -- some usage detection - current or past
           and(
               -- if special counter conditions (coded on the MAP.CONDITION column) are required, check if the counter value is not 0
               -- C001 = compression has been used at least once
                  CONDITION = 'C001' and regexp_like(to_char(FEATURE_INFO), 'compression used:[ 0-9]*[1-9][ 0-9]*time', 'i')
               -- C002 = encryption has been used at least once
               or CONDITION = 'C002' and regexp_like(to_char(FEATURE_INFO), 'encryption used:[ 0-9]*[1-9][ 0-9]*time', 'i')
              )
            then decode(CURRENT_ENTRY || '#' || CURRENTLY_USED, 'Y#TRUE', '5.PAST_OR_CURRENT_USAGE', '4.PAST_USAGE') -- FEATURE_INFO counters indicate current or past usage
          when CURRENT_ENTRY = 'Y' then '2.NO_CURRENT_USAGE'   -- detectable feature shows no current usage
          else '1.NO_PAST_USAGE'
    end as USAGE,
    LAST_SAMPLE_DATE,
    DBID            ,
    VERSION         ,
    DETECTED_USAGES ,
    TOTAL_SAMPLES   ,
    CURRENTLY_USED  ,
    FIRST_USAGE_DATE,
    LAST_USAGE_DATE
from (select m.PRODUCT, m.CONDITION, m.MVERSION, first_value (m.MVERSION) over (partition by f.CON_ID, f.NAME, f.VERSION order by m.MVERSION desc nulls last) as MMVERSION, f.*
  from MAP m
  join FUS f on m.FEATURE = f.NAME and m.MVERSION = substr(f.VERSION, 1, length(m.MVERSION))
  where nvl(f.TOTAL_SAMPLES, 0) > 0                        -- ignore features that have never been sampled
)
  where MVERSION = MMVERSION                               -- retain only the MAP entry that mathces the most to the DBA_FUS version = the "most matching version"
  and nvl(CONDITION, '-') != 'INVALID'                   -- ignore entries that are invalidated by bugs or known issues or correspond to features which became free of charge
  and not (CONDITION = 'C003' and CON_ID not in (0, 1))  -- multiple PDBs are visible only in CDB$ROOT
)
select '<tr><td>' || CON_NAME || '</td><td>' 
  || PRODUCT || '</td><td' 
  || DECODE(usage, 'CURRENT_USAGE', ' class="critical">', 'PAST_OR_CURRENT_USAGE', ' class="warning">', '>') 
  || usage || '</td><td>' 
  || LAST_SAMPLE_DATE || '</td><td>' 
  || FIRST_USAGE_DATE || '</td><td>' 
  || LAST_USAGE_DATE || '</td></tr>'
from (select grouping_id(CON_ID) as gid,
    CON_ID   ,
    decode(grouping_id(CON_ID), 1, '--ALL--', max(CON_NAME)) as CON_NAME,
    PRODUCT  ,
    decode(max(USAGE),
          '1.NO_PAST_USAGE'        , 'NO_USAGE'             ,
          '2.NO_CURRENT_USAGE'     , 'NO_USAGE'             ,
          '3.SUPPRESSED_DUE_TO_BUG', 'SUPPRESSED_DUE_TO_BUG',
          '4.PAST_USAGE'           , 'PAST_USAGE'           ,
          '5.PAST_OR_CURRENT_USAGE', 'PAST_OR_CURRENT_USAGE',
          '6.CURRENT_USAGE'        , 'CURRENT_USAGE'        ,
          'UNKNOWN') as USAGE,
    max(LAST_SAMPLE_DATE) as LAST_SAMPLE_DATE,
    min(FIRST_USAGE_DATE) as FIRST_USAGE_DATE,
    max(LAST_USAGE_DATE)  as LAST_USAGE_DATE
  from PFUS
  where USAGE in ('2.NO_CURRENT_USAGE', '4.PAST_USAGE', '5.PAST_OR_CURRENT_USAGE', '6.CURRENT_USAGE')   -- ignore '1.NO_PAST_USAGE', '3.SUPPRESSED_DUE_TO_BUG'
  group by rollup(CON_ID), PRODUCT
  having not (max(CON_ID) in (-1, 0) and grouping_id(CON_ID) = 1)            -- aggregation not needed for non-container databases
order by GID desc, CON_ID, decode(substr(PRODUCT, 1, 1), '.', 2, 1), PRODUCT);
select '</table></div><br>' FROM dual;
---------------Feature Usage Details----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('feature_usage_details');
select '<a name="feature_usage_details"><h3>Featue Usage Details</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Container</th><th>Product</th><th>Feature</th><th>Last Sample Date</th><th>Version</th><th>Detected Usages</th><th>currently used</th><th>First Usage Date</th><th>Last Usage Date</th><th>Extra Info</th></tr>' FROM dual;
with
MAP as (
-- mapping between features tracked by DBA_FUS and their corresponding database products (options or packs)
select '' PRODUCT, '' feature, '' MVERSION, '' CONDITION from dual union all
select 'Active Data Guard'                                   , 'Active Data Guard - Real-Time Query on Physical Standby' , '11.2'       , ' '       from dual union all
select 'Active Data Guard'                                   , 'Active Data Guard - Real-Time Query on Physical Standby' , '12.1'       , ' '       from dual union all
select 'Active Data Guard'                                   , 'Global Data Services'                                    , '12.1'       , ' '       from dual union all
select 'Advanced Analytics'                                  , 'Data Mining'                                             , '11.2'       , ' '       from dual union all
select 'Advanced Analytics'                                  , 'Data Mining'                                             , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'ADVANCED Index Compression'                              , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Advanced Index Compression'                              , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Backup HIGH Compression'                                 , '11.2'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Backup HIGH Compression'                                 , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Backup LOW Compression'                                  , '11.2'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Backup LOW Compression'                                  , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Backup MEDIUM Compression'                               , '11.2'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Backup MEDIUM Compression'                               , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Backup ZLIB Compression'                                 , '11.2'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Backup ZLIB Compression'                                 , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Data Guard'                                              , '11.2'       , 'C001'    from dual union all
select 'Advanced Compression'                                , 'Data Guard'                                              , '12.1'       , 'C001'    from dual union all
select 'Advanced Compression'                                , 'Flashback Data Archive'                                  , '11.2'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Flashback Data Archive'                                  , '11.2.0.4'   , 'INVALID' from dual union all -- licensing required by Optimization for Flashback Data Archive
select 'Advanced Compression'                                , 'Flashback Data Archive'                                  , '12.1'       , 'INVALID' from dual union all -- licensing required by Optimization for Flashback Data Archive
select 'Advanced Compression'                                , 'HeapCompression'                                         , '11.2'       , ' '       from dual union all
select 'Advanced Compression'                                , 'HeapCompression'                                         , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Heat Map'                                                , '12.1'       , ' '       from dual union all --
select 'Advanced Compression'                                , 'Hybrid Columnar Compression Row Level Locking'           , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Information Lifecycle Management'                        , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Oracle Advanced Network Compression Service'             , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'Oracle Utility Datapump (Export)'                        , '11.2'       , 'C001'    from dual union all
select 'Advanced Compression'                                , 'Oracle Utility Datapump (Export)'                        , '12.1'       , 'C001'    from dual union all
select 'Advanced Compression'                                , 'Oracle Utility Datapump (Import)'                        , '11.2'       , 'C001'    from dual union all
select 'Advanced Compression'                                , 'Oracle Utility Datapump (Import)'                        , '12.1'       , 'C001'    from dual union all
select 'Advanced Compression'                                , 'SecureFile Compression (user)'                           , '11.2'       , ' '       from dual union all
select 'Advanced Compression'                                , 'SecureFile Compression (user)'                           , '12.1'       , ' '       from dual union all
select 'Advanced Compression'                                , 'SecureFile Deduplication (user)'                         , '11.2'       , ' '       from dual union all
select 'Advanced Compression'                                , 'SecureFile Deduplication (user)'                         , '12.1'       , ' '       from dual union all
select 'Advanced Security'                                   , 'Backup Encryption'                                       , '11.2'       , ' '       from dual union all
select 'Advanced Security'                                   , 'Backup Encryption'                                       , '12.1'       , 'INVALID' from dual union all -- licensing required only by encryption to disk
select 'Advanced Security'                                   , 'Data Redaction'                                          , '12.1'       , ' '       from dual union all
select 'Advanced Security'                                   , 'Encrypted Tablespaces'                                   , '11.2'       , ' '       from dual union all
select 'Advanced Security'                                   , 'Encrypted Tablespaces'                                   , '12.1'       , ' '       from dual union all
select 'Advanced Security'                                   , 'Oracle Utility Datapump (Export)'                        , '11.2'       , 'C002'    from dual union all
select 'Advanced Security'                                   , 'Oracle Utility Datapump (Export)'                        , '12.1'       , 'C002'    from dual union all
select 'Advanced Security'                                   , 'Oracle Utility Datapump (Import)'                        , '11.2'       , 'C002'    from dual union all
select 'Advanced Security'                                   , 'Oracle Utility Datapump (Import)'                        , '12.1'       , 'C002'    from dual union all
select 'Advanced Security'                                   , 'SecureFile Encryption (user)'                            , '11.2'       , ' '       from dual union all
select 'Advanced Security'                                   , 'SecureFile Encryption (user)'                            , '12.1'       , ' '       from dual union all
select 'Advanced Security'                                   , 'Transparent Data Encryption'                             , '11.2'       , ' '       from dual union all
select 'Advanced Security'                                   , 'Transparent Data Encryption'                             , '12.1'       , ' '       from dual union all
select 'Change Management Pack'                              , 'Change Management Pack'                                  , '11.2'       , ' '       from dual union all
select 'Configuration Management Pack for Oracle Database'   , 'EM Config Management Pack'                               , '11.2'       , ' '       from dual union all
select 'Data Masking Pack'                                   , 'Data Masking Pack'                                       , '11.2'       , ' '       from dual union all
select '.Database Gateway'                                   , 'Gateways'                                                , '12.1'       , ' '       from dual union all
select '.Database Gateway'                                   , 'Transparent Gateway'                                     , '12.1'       , ' '       from dual union all
select 'Database In-Memory'                                  , 'In-Memory Aggregation'                                   , '12.1'       , ' '       from dual union all
select 'Database In-Memory'                                  , 'In-Memory Column Store'                                  , '12.1.0.2'   , 'BUG'     from dual union all
select 'Database Vault'                                      , 'Oracle Database Vault'                                   , '11.2'       , ' '       from dual union all
select 'Database Vault'                                      , 'Oracle Database Vault'                                   , '12.1'       , ' '       from dual union all
select 'Database Vault'                                      , 'Privilege Capture'                                       , '12.1'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'ADDM'                                                    , '11.2'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'ADDM'                                                    , '12.1'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'AWR Baseline'                                            , '11.2'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'AWR Baseline'                                            , '12.1'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'AWR Baseline Template'                                   , '11.2'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'AWR Baseline Template'                                   , '12.1'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'AWR Report'                                              , '11.2'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'AWR Report'                                              , '12.1'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'Automatic Workload Repository'                           , '12.1'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'Baseline Adaptive Thresholds'                            , '11.2'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'Baseline Adaptive Thresholds'                            , '12.1'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'Baseline Static Computations'                            , '11.2'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'Baseline Static Computations'                            , '12.1'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'Diagnostic Pack'                                         , '11.2'       , ' '       from dual union all
select 'Diagnostics Pack'                                    , 'EM Performance Page'                                     , '12.1'       , ' '       from dual union all
select '.Exadata'                                            , 'Exadata'                                                 , '11.2'       , ' '       from dual union all
select '.Exadata'                                            , 'Exadata'                                                 , '12.1'       , ' '       from dual union all
select '.GoldenGate'                                         , 'GoldenGate'                                              , '12.1'       , ' '       from dual union all
select '.HW'                                                 , 'Hybrid Columnar Compression'                             , '12.1'       , 'BUG'     from dual union all
select '.HW'                                                 , 'Hybrid Columnar Compression Row Level Locking'           , '12.1'       , ' '       from dual union all
select '.HW'                                                 , 'Sun ZFS with EHCC'                                       , '12.1'       , ' '       from dual union all
select '.HW'                                                 , 'ZFS Storage'                                             , '12.1'       , ' '       from dual union all
select '.HW'                                                 , 'Zone maps'                                               , '12.1'       , ' '       from dual union all
select 'Label Security'                                      , 'Label Security'                                          , '11.2'       , ' '       from dual union all
select 'Label Security'                                      , 'Label Security'                                          , '12.1'       , ' '       from dual union all
select 'Multitenant'                                         , 'Oracle Multitenant'                                      , '12.1'       , 'C003'    from dual union all -- licensing required only when more than one PDB containers are created
select 'Multitenant'                                         , 'Oracle Pluggable Databases'                              , '12.1'       , 'C003'    from dual union all -- licensing required only when more than one PDB containers are created
select 'OLAP'                                                , 'OLAP - Analytic Workspaces'                              , '11.2'       , ' '       from dual union all
select 'OLAP'                                                , 'OLAP - Analytic Workspaces'                              , '12.1'       , ' '       from dual union all
select 'OLAP'                                                , 'OLAP - Cubes'                                            , '12.1'       , ' '       from dual union all
select 'Partitioning'                                        , 'Partitioning (user)'                                     , '11.2'       , ' '       from dual union all
select 'Partitioning'                                        , 'Partitioning (user)'                                     , '12.1'       , ' '       from dual union all
select 'Partitioning'                                        , 'Zone maps'                                               , '12.1'       , ' '       from dual union all
select '.Pillar Storage'                                     , 'Pillar Storage'                                          , '12.1'       , ' '       from dual union all
select '.Pillar Storage'                                     , 'Pillar Storage with EHCC'                                , '12.1'       , ' '       from dual union all
select '.Provisioning and Patch Automation Pack'             , 'EM Standalone Provisioning and Patch Automation Pack'    , '11.2'       , ' '       from dual union all
select 'Provisioning and Patch Automation Pack for Database' , 'EM Database Provisioning and Patch Automation Pack'      , '11.2'       , ' '       from dual union all
select 'RAC or RAC One Node'                                 , 'Quality of Service Management'                           , '12.1'       , ' '       from dual union all
select 'Real Application Clusters'                           , 'Real Application Clusters (RAC)'                         , '11.2'       , ' '       from dual union all
select 'Real Application Clusters'                           , 'Real Application Clusters (RAC)'                         , '12.1'       , ' '       from dual union all
select 'Real Application Clusters One Node'                  , 'Real Application Cluster One Node'                       , '12.1'       , ' '       from dual union all
select 'Real Application Testing'                            , 'Database Replay: Workload Capture'                       , '11.2'       , ' '       from dual union all
select 'Real Application Testing'                            , 'Database Replay: Workload Capture'                       , '12.1'       , ' '       from dual union all
select 'Real Application Testing'                            , 'Database Replay: Workload Replay'                        , '11.2'       , ' '       from dual union all
select 'Real Application Testing'                            , 'Database Replay: Workload Replay'                        , '12.1'       , ' '       from dual union all
select 'Real Application Testing'                            , 'SQL Performance Analyzer'                                , '11.2'       , ' '       from dual union all
select 'Real Application Testing'                            , 'SQL Performance Analyzer'                                , '12.1'       , ' '       from dual union all
select '.Secure Backup'                                      , 'Oracle Secure Backup'                                    , '12.1'       , 'INVALID' from dual union all  -- does not differentiate usage of Oracle Secure Backup Express, which is free
select 'Spatial and Graph'                                   , 'Spatial'                                                 , '11.2'       , 'INVALID' from dual union all  -- does not differentiate usage of Locator, which is free
select 'Spatial and Graph'                                   , 'Spatial'                                                 , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'Automatic Maintenance - SQL Tuning Advisor'              , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'Automatic SQL Tuning Advisor'                            , '11.2'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'Automatic SQL Tuning Advisor'                            , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'Real-Time SQL Monitoring'                                , '11.2'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'Real-Time SQL Monitoring'                                , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'SQL Access Advisor'                                      , '11.2'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'SQL Access Advisor'                                      , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'SQL Monitoring and Tuning pages'                         , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'SQL Profile'                                             , '11.2'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'SQL Profile'                                             , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'SQL Tuning Advisor'                                      , '11.2'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'SQL Tuning Advisor'                                      , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'SQL Tuning Set (user)'                                   , '12.1'       , ' '       from dual union all
select 'Tuning Pack'                                         , 'Tuning Pack'                                             , '11.2'       , ' '       from dual union all
select '.WebLogic Server Management Pack Enterprise Edition' , 'EM AS Provisioning and Patch Automation Pack'            , '11.2'       , ' '       from dual union all
select '' PRODUCT, '' FEATURE, '' MVERSION, '' CONDITION from dual),
FUS as (
-- the current data set to be used: DBA_FEATURE_USAGE_STATISTICS or CDB_FEATURE_USAGE_STATISTICS for Container Databases(CDBs)
select
    &&DCID as CON_ID,
    &&DCNA as CON_NAME,
    -- Detect and mark with Y the current DBA_FUS data set = Most Recent Sample based on LAST_SAMPLE_DATE
      case when DBID || '#' || VERSION || '#' || to_char(LAST_SAMPLE_DATE, 'YYYYMMDDHH24MISS') =
                first_value (DBID    ) over (partition by &&DCID order by LAST_SAMPLE_DATE desc nulls last, DBID desc) || '#' ||
                first_value (VERSION ) over (partition by &&DCID order by LAST_SAMPLE_DATE desc nulls last, DBID desc) || '#' ||
                first_value (to_char(LAST_SAMPLE_DATE, 'YYYYMMDDHH24MISS')) over (partition by &&DCID order by LAST_SAMPLE_DATE desc nulls last, DBID desc)
           then 'Y'
           else 'N'
    end as CURRENT_ENTRY,
    NAME            ,
    LAST_SAMPLE_DATE,
    DBID            ,
    VERSION         ,
    DETECTED_USAGES ,
    TOTAL_SAMPLES   ,
    CURRENTLY_USED  ,
    FIRST_USAGE_DATE,
    LAST_USAGE_DATE ,
    AUX_COUNT       ,
    FEATURE_INFO
from &&DFUS.FEATURE_USAGE_STATISTICS xy),
PFUS as (
-- Product-Feature Usage Statitsics = DBA_FUS entries mapped to their corresponding database products
select CON_ID,
    CON_NAME,
    PRODUCT,
    NAME as FEATURE_BEING_USED,
    case  when CONDITION = 'BUG'
               --suppressed due to exceptions/defects
            then '3.SUPPRESSED_DUE_TO_BUG'
          when detected_usages > 0               -- some usage detection - current or past
           and(trim(CONDITION) is null
               -- if special conditions (coded on the MAP.CONDITION column) are required, check if entries satisfy the condition
               -- C001 = compression has been used
               or CONDITION = 'C001' and regexp_like(to_char(FEATURE_INFO), 'compression used: *TRUE', 'i')
               -- C002 = encryption has been used
               or CONDITION = 'C002' and regexp_like(to_char(FEATURE_INFO), 'encryption used: *TRUE', 'i')
               -- C003 = more than one PDB are created
               or CONDITION = 'C003' and CON_ID=1 and AUX_COUNT > 1
              )
            then decode(CURRENT_ENTRY || '#' || CURRENTLY_USED, 'Y#TRUE', '6.CURRENT_USAGE', '4.PAST_USAGE')
          when detected_usages > 0               -- some usage detection - current or past
           and (
               -- if special counter conditions (coded on the MAP.CONDITION column) are required, check if the counter value is not 0
               -- C001 = compression has been used at least once
                  CONDITION = 'C001' and regexp_like(to_char(FEATURE_INFO), 'compression used:[ 0-9]*[1-9][ 0-9]*time', 'i')
               -- C002 = encryption has been used at least once
               or CONDITION = 'C002' and regexp_like(to_char(FEATURE_INFO), 'encryption used:[ 0-9]*[1-9][ 0-9]*time', 'i')
              )
            then decode(CURRENT_ENTRY || '#' || CURRENTLY_USED, 'Y#TRUE', '5.PAST_OR_CURRENT_USAGE', '4.PAST_USAGE') -- FEATURE_INFO counters indicate current or past usage
          when CURRENT_ENTRY = 'Y' then '2.NO_CURRENT_USAGE'   -- detectable feature shows no current usage
          else '1.NO_PAST_USAGE'
    end as USAGE,
    LAST_SAMPLE_DATE,
    DBID            ,
    VERSION         ,
    DETECTED_USAGES ,
    TOTAL_SAMPLES   ,
    CURRENTLY_USED  ,
    FIRST_USAGE_DATE,
    LAST_USAGE_DATE,
    case when CONDITION = 'C001' then regexp_substr(to_char(FEATURE_INFO), 'compression used:(.*?)(times|TRUE|FALSE)', 1, 1, 'i')
         when CONDITION = 'C002' then regexp_substr(to_char(FEATURE_INFO), 'encryption used:(.*?)(times|TRUE|FALSE)', 1, 1, 'i')
         when CONDITION = 'C003' then 'AUX_COUNT=' || AUX_COUNT
         else '' end as EXTRA_FEATURE_INFO
from (select m.PRODUCT, m.CONDITION, m.MVERSION, first_value (m.MVERSION) over (partition by f.CON_ID, f.NAME, f.VERSION order by m.MVERSION desc nulls last) as MMVERSION, f.*
  from MAP m
  join FUS f on m.FEATURE = f.NAME and m.MVERSION = substr(f.VERSION, 1, length(m.MVERSION))
  where nvl(f.TOTAL_SAMPLES, 0) > 0                      -- ignore features that have never been sampled
)
  where MVERSION = MMVERSION                             -- retain only the MAP entry that mathces the most to the DBA_FUS version = the "most matching version"
  and nvl(CONDITION, '-') != 'INVALID'                   -- ignore entries that are invalidated by bugs or known issues or correspond to features which became free of charge
  and not (CONDITION = 'C003' and CON_ID not in (0, 1))  -- multiple PDBs are visible only in CDB$ROOT
)
select '<tr><td>' || CON_NAME ||'</td><td>' 
  || PRODUCT || '</td><td>' 
  || FEATURE_BEING_USED || '</td><td>' 
  || LAST_SAMPLE_DATE || '</td><td>' 
  || VERSION || '</td><td' 
  || DECODE(DETECTED_USAGES, 0, '>', ' class="critical">') 
  || DETECTED_USAGES || '</td><td' 
  || DECODE(CURRENTLY_USED, 'TRUE', ' class="critical">', '>') 
  || CURRENTLY_USED || '</td><td>' 
  || FIRST_USAGE_DATE || '</td><td>' 
  || LAST_USAGE_DATE || '</td><td>' 
  || EXTRA_FEATURE_INFO || '</td></tr>'
from (select CON_ID   ,
    CON_NAME          ,
    PRODUCT           ,
    FEATURE_BEING_USED,
    decode(USAGE,
          '1.NO_PAST_USAGE'        , 'NO_PAST_USAGE'        ,
          '2.NO_CURRENT_USAGE'     , 'NO_CURRENT_USAGE'     ,
          '3.SUPPRESSED_DUE_TO_BUG', 'SUPPRESSED_DUE_TO_BUG',
          '4.PAST_USAGE'           , 'PAST_USAGE'           ,
          '5.PAST_OR_CURRENT_USAGE', 'PAST_OR_CURRENT_USAGE',
          '6.CURRENT_USAGE'        , 'CURRENT_USAGE'        ,
          'UNKNOWN') as USAGE,
    LAST_SAMPLE_DATE  ,
    DBID              ,
    VERSION           ,
    DETECTED_USAGES   ,
    TOTAL_SAMPLES     ,
    CURRENTLY_USED    ,
    FIRST_USAGE_DATE  ,
    LAST_USAGE_DATE   ,
    EXTRA_FEATURE_INFO
  from PFUS
  where USAGE in ('2.NO_CURRENT_USAGE', '3.SUPPRESSED_DUE_TO_BUG', '4.PAST_USAGE', '5.PAST_OR_CURRENT_USAGE', '6.CURRENT_USAGE')  -- ignore '1.NO_PAST_USAGE'
order by CON_ID, decode(substr(PRODUCT, 1, 1), '.', 2, 1), PRODUCT, FEATURE_BEING_USED, LAST_SAMPLE_DATE desc, PFUS.USAGE);
select '</table></div><br>' FROM dual;
set define off
---------------DB growth----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('DB growth');
select '<a name="DB growth"><h3>DB growth</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Month</th><th>Growth MB</th></tr>' FROM dual;
select '<tr><td>' || month || '</td><td class="number">' || to_char(growth_mb,'999g999g999') || '</td></tr>'
FROM (select trunc(creation_time, 'MM') month, round(SUM(bytes/1024/1024)) growth_mb
FROM v$datafile
GROUP BY trunc(creation_time, 'MM')
ORDER BY trunc(creation_time, 'MM'));
select '</table></div><br>' FROM dual;
---------------Schema Sizes----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('schema_sizes');
select '<a name="schema_sizes"><h3>Schema Sizes / # segments</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Owner</th><th>MB Tables</th><th># Tables</th><th>MB Index</th><th># Index</th><th>MB Lob</th><th># Lob</th><th>MB Other</th><th># Other</th><th>MB Total</th><th># Total</th></tr>' FROM dual;
select '<tr><td>' || owner || '</td><td class="number">' 
  || sum(decode(SEG_TYPE, 'TABLE', mbytes, 0)) || '</td><td class="number">'
  || count(decode(SEG_TYPE, 'TABLE', mbytes, 0)) || '</td><td class="number">'
  || sum(decode(SEG_TYPE, 'INDEX', mbytes, 0)) || '</td><td class="number">'
  || count(decode(SEG_TYPE, 'INDEX', mbytes, 0)) ||'</td><td class="number">'
  || sum(decode(SEG_TYPE, 'LOB', mbytes, 0)) || '</td><td class="number">'
  || count(decode(SEG_TYPE, 'LOB', mbytes, 0)) || '</td><td class="number">'
  || sum(decode(SEG_TYPE, 'OTHER', mbytes, 0)) || '</td><td class="number">'
  || count(decode(SEG_TYPE, 'OTHER', mbytes, 0)) || '</td><td class="number">'
  || sum(mbytes) || '</td><td class="number">'
  || count(mbytes) || '</td></tr>'
from (select owner, round(bytes/1024/1024,2) mbytes,
 (case
  when SEGMENT_TYPE like 'TABLE%' then 'TABLE'
  when SEGMENT_TYPE like 'INDEX%' then 'INDEX'
  when SEGMENT_TYPE like 'LOB%' then 'LOB'
  else 'OTHER'
 end) SEG_TYPE
from dba_segments)
group by owner
order by sum(mbytes) desc;
select '</table><br>' FROM dual;
---------------Size Summary----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('size_summary');
select '<a name="size_summary"><h3>Size Summary</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>MB Tables</th><th># Tables</th><th>MB Index</th><th># Index</th><th>MB Lob</th><th># Lob</th><th>MB Other</th><th># Other</th><th>MB Total</th><th># Total</th><th>MB Datafiles</th></tr>' FROM dual;
select '<tr><td class="number">' || round(sum(decode(SEG_TYPE, 'TABLE', mbytes, 0))) || '</td><td class="number">'
  || count(decode(SEG_TYPE, 'TABLE', mbytes, 0)) || '</td><td class="number">'
  || round(sum(decode(SEG_TYPE, 'INDEX', mbytes, 0))) || '</td><td class="number">'
  || count(decode(SEG_TYPE, 'INDEX', mbytes, 0)) || '</td><td class="number">'
  || round(sum(decode(SEG_TYPE, 'LOB', mbytes, 0))) || '</td><td class="number">'
  || count(decode(SEG_TYPE, 'LOB', mbytes, 0)) || '</td><td class="number">'
  || round(sum(decode(SEG_TYPE, 'OTHER', mbytes, 0))) || '</td><td class="number">'
  || count(decode(SEG_TYPE, 'OTHER', mbytes, 0)) || '</td><td class="number">'
  || round(sum(mbytes)) || '</td><td class="number">'
  || count(mbytes) || '</td><td class="number">'
  || avg((select round(sum(bytes)/1024/1024) from v$datafile)) || '</td></tr>'
from (select owner, round(bytes/1024/1024,2) mbytes,
 (case
  when SEGMENT_TYPE like 'TABLE%' then 'TABLE'
  when SEGMENT_TYPE like 'INDEX%' then 'INDEX'
  when SEGMENT_TYPE like 'LOB%' then 'LOB'
  else 'OTHER'
 end) SEG_TYPE
from dba_segments)
order by sum(mbytes) desc;
select '</table><br>' FROM dual;
---------------All Files----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char( (sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('all_files');
prompt <hr /><a name="all_files"><h3>All Files</h3></a><a id="b_all_files" href="javascript:switchdiv('d_all_files')">(+)</a><div id="d_all_files" style="display:none;">
select '<table class="sortable"><tr><th>Type</th><th>Tablespace</th><th>Filename</th><th>Group</th><th>Thread</th><th>Size (MB)</th><th>Max Size (MB)</th><th>Autoextensible</th></tr>' FROM dual;
select '<tr><td>' || FILETYPE || '</td><td>'
  || TABLESPACE || '</td><td>'
  || Filename || '</td><td>'
  || group# || '</td><td>'
  || thread# || '</td><td>'
  || to_char(round(Filesize),'999g999g999g999') || '</td><td>'
  || to_char(round(MaxFileSize),'999g999g999g999') || '</td><td>'
  || AUTOEXTENSIBLE || '</td></tr>'
from (select 'DATAFILE' FILETYPE
        , TABLESPACE_NAME as TABLESPACE
		, FILE_NAME as Filename
		, null as group#
		, null as thread#
		, bytes/1024/1024 Filesize
		, decode(AUTOEXTENSIBLE, 'YES', maxbytes/1024/1024, bytes/1024/1024) MaxFileSize
		, AUTOEXTENSIBLE
	from dba_data_files
	union all
	select 'TEMPFILE' FILETYPE
	  , TABLESPACE_NAME 
	  , FILE_NAME 
	  , null as group#
	  , null as thread#
	  , bytes/1024/1024
	  , decode(AUTOEXTENSIBLE, 'YES', maxbytes/1024/1024, bytes/1024/1024) 
	  , AUTOEXTENSIBLE
	from dba_temp_files
	union all
	select 'CONTROLFILE' FILETYPE
	  , '' TABLESPACE
	  , NAME
	  , null as group#
	  , null as thread#
	  , 0 
	  , 0 
	  , '' AUTOEXTENSIBLE
	from v$controlfile
	union all
	select 'REDO' FILETYPE
	  , '' TABLESPACE
	  , MEMBER
	  , l.group#
	  , l.thread#
	  , bytes/1024/1024
	  , bytes/1024/1024
	  , '' AUTOEXTENSIBLE
	from gv$log l, gv$logfile lf
	where lf.group# = l.group#
	and lf.inst_id = l.inst_id
	union all
	select 'STANDBY REDO' FILETYPE
	  , '' TABLESPACE
	  , MEMBER
	  , l.group#
	  , l.thread#
	  , bytes/1024/1024
	  , bytes/1024/1024
	  , '' AUTOEXTENSIBLE
	from gv$standby_log l, gv$logfile lf
	where lf.group# = l.group#
	and lf.inst_id = l.inst_id)
order by FILETYPE, TABLESPACE, FILENAME;
select '</table></div><br>' FROM dual;
---------------DB Links----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('db_links');
select '<a name="db_links"><h3>Database Links</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Owner</th><th>DB Link</th><th>Host</th><th>Username</th><th>Created</th></tr>' FROM dual;
select '<tr><td>' || owner || '</td><td>'
  || db_link || '</td><td>'
  || host || '</td><td>'
  || username || '</td><td>'
  || created || '</td></tr>'
from dba_db_links
order by owner, db_link;
select '</table><br>' FROM dual;
---------------Directories----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('directories');
select '<a name="directories"><h3>Directories</h3></a>' FROM dual;
select '<table class="sortable"><tr><th>Owner</th><th>Directory</th><th>Path</th></tr>' FROM dual;
select '<tr><td>' || owner || '</td><td>'
  || directory_name || '</td><td>'
  || directory_path || '</td></tr>'
from dba_directories
order by owner, directory_name;
select '</table><br>' FROM dual;
---------------Roles----------------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('roles');
prompt <hr /><a name="roles"><h3>Roles</h3></a><a id="b_roles" href="javascript:switchdiv('d_roles')">(+)</a><div id="d_roles" style="display:none;">
select '<table class="sortable"><tr><th>Role</th><th>Pwd equired</th></tr>' FROM dual;
select '<tr><td>' || role || '</td><td>'
  || PASSWORD_REQUIRED || '</td></tr>'
from dba_roles
order by role;
select '</table></div><br>' FROM dual;
---------------Network ACLs---------------------------------------------------------------------------
select '<!-- Time: ' || to_char(sysdate,'hh24:mi:ss') || ' - since start: ' || to_char((sysdate - to_date(:starttime, 'dd/mm/yyyy hh24:mi:ss'))*86400, '999g999d0') || 's -->' from dual;
exec dbms_application_info.set_action('net-acls');
prompt <hr /><a name="net-acls"><h3>Network ACLs</h3></a>
select '<table class="sortable"><tr><th>ACL</th><th>Hostname</th><th>lower port</th><th>upper port</th><th>Grantee</th><th>Privilege</th><th>is grant</th></tr>' FROM dual;
select '<tr><td>' || a.acl || '</td><td>'
  || a.host || '</td><td>'
  || a.lower_port || '</td><td>'
  || a.upper_port || '</td><td>'
  || p.principal || '</td><td>'
  || p.privilege || '</td><td>'
  || p.is_grant || '</td></tr>'
from dba_network_acls a, dba_network_acl_privileges p
where a.aclid = p.aclid
order by a.acl, p.principal;
select '</table><br>' FROM dual;
exec dbms_application_info.set_action('End');
---------------done------------------------------------------------------------------------------------------
prompt </BODY>
prompt </HTML>
spool off