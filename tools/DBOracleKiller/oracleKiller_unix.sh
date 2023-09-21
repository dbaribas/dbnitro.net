#!/bin/sh
java=/usr/bin/java

libs=lib/OracleKiller.jar
libs=$libs:lib/LicControll.jar
libs=$libs:lib/commons-pool-1.3.jar
libs=$libs:lib/jasperreports-fonts-5.6.0.jar
libs=$libs:lib/commons-pool-1.6.jar
libs=$libs:lib/jasperreports-functions-5.6.0.jar
libs=$libs:lib/commons-beanutils-1.8.2.jar
libs=$libs:lib/commons-vfs-1.0.jar
libs=$libs:lib/jasperreports-htmlcomponent-4.7.1.jar
libs=$libs:lib/commons-collections-3.2.1.jar
libs=$libs:lib/commons.collections-3.2.1.jar
libs=$libs:lib/jasperreports-htmlcomponent-5.0.1.jar
libs=$libs:lib/commons-dbcp-1.2.2.jar
libs=$libs:lib/groovy-all-2.0.1.jar
libs=$libs:lib/jasperreports-json.jar
libs=$libs:lib/commons-digester-1.7.jar
libs=$libs:lib/itext-2.1.7.jar
libs=$libs:lib/jasperreports-jtidy-r938.jar
libs=$libs:lib/commons-digester-2.1.jar
libs=$libs:lib/jasperreports-5.6.0.jar
libs=$libs:lib/joda-time-2.1.jar
libs=$libs:lib/commons-javaflow-20060411.jar
libs=$libs:lib/jasperreports-chart-themes-5.6.0.jar
libs=$libs:lib/log4j.jar
libs=$libs:lib/commons-logging-1.1.jar
libs=$libs:lib/jasperreports-core-renderer.jar
libs=$libs:lib/oracle.jar
libs=$libs:lib/commons-math-1.0.jar
libs=$libs:lib/jasperreports-extensions-3.5.3.jar
libs=$libs:lib/swing-layout-1.0.4.jar

echo java -Xmx256m -classpath $libs com.fsolutions.oraclepdikiller.OracleKillerMain $(pwd)

$java -Xmx256m -classpath $libs com.fsolutions.oraclepdikiller.OracleKillerMain $(pwd)
