-- Parametro 1 quantidade de total das SGAs 
-- Parametro 2 processes que quer implementar
-- @hugepages.sql 204800 3000
col config for a100
select
  '# Configuracao do HugePages - Mufalani - Use o kernel.sem desejado ' || chr(10) ||
  '# Soma de todas as SGAs &1 Gb' || chr(10) ||
  'kernel.shmmax = ' || (&1 * 1024 * 1024 * 1024) || chr(10) ||
  'kernel.shmmni = 4096' || chr(10) || 
  'kernel.shmall = ' || (&1 * 1024 * 1024 * 1024) / 4096 || chr(10) ||
  'vm.nr_hugepages = ' || (&1 * 1024 * 1024 * 1024) / 2048 / 1024 || chr(10) ||
  '# kernel.sem com base no processes atual da base' || chr(10) ||
  '# kernel.sem = ' || (select value + 50 from v$parameter where name = 'processes') || ' ' || (select value + 50 * 128 from v$parameter where name = 'processes') || ' ' || (select value + 50 from v$parameter where name = 'processes') || ' ' || 128 || chr(10) ||
  '# kernel.sem com base no segundo parametro passado' || chr(10) ||
  '# kernel.sem = ' || (select &2 + 50 from dual) || ' ' || (select (&2 + 50) * 128 from dual) || ' ' || (select &2 + 50 from dual) || ' ' || 128 config
from dual;              
