@echo off

SET libs=lib\OracleKiller.jar
SET libs=%libs%;lib\LicControll.jar
SET libs=%libs%;lib\commons-pool-1.3.jar
SET libs=%libs%;lib\jasperreports-fonts-5.6.0.jar
SET libs=%libs%;lib\commons-pool-1.6.jar
SET libs=%libs%;lib\jasperreports-functions-5.6.0.jar
SET libs=%libs%;lib\commons-beanutils-1.8.2.jar
SET libs=%libs%;lib\commons-vfs-1.0.jar
SET libs=%libs%;lib\jasperreports-htmlcomponent-4.7.1.jar
SET libs=%libs%;lib\commons-collections-3.2.1.jar
SET libs=%libs%;lib\commons.collections-3.2.1.jar
SET libs=%libs%;lib\jasperreports-htmlcomponent-5.0.1.jar
SET libs=%libs%;lib\commons-dbcp-1.2.2.jar
SET libs=%libs%;lib\groovy-all-2.0.1.jar
SET libs=%libs%;lib\jasperreports-json.jar
SET libs=%libs%;lib\commons-digester-1.7.jar
SET libs=%libs%;lib\itext-2.1.7.jar
SET libs=%libs%;lib\jasperreports-jtidy-r938.jar
SET libs=%libs%;lib\commons-digester-2.1.jar
SET libs=%libs%;lib\jasperreports-5.6.0.jar
SET libs=%libs%;lib\joda-time-2.1.jar
SET libs=%libs%;lib\commons-javaflow-20060411.jar
SET libs=%libs%;lib\jasperreports-chart-themes-5.6.0.jar
SET libs=%libs%;lib\log4j.jar
SET libs=%libs%;lib\commons-logging-1.1.jar
SET libs=%libs%;lib\jasperreports-core-renderer.jar
SET libs=%libs%;lib\oracle.jar
SET libs=%libs%;lib\commons-math-1.0.jar
SET libs=%libs%;lib\jasperreports-extensions-3.5.3.jar
SET libs=%libs%;lib\swing-layout-1.0.4.jar
 
java -Xmx256m -classpath %libs% com.fsolutions.oraclepdikiller.OracleKillerMain "%cd%"