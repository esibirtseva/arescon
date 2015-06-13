-- MySQL dump 10.13  Distrib 5.6.23, for Win64 (x86_64)
--
-- Host: localhost    Database: processing
-- ------------------------------------------------------
-- Server version	5.6.25-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `actions`
--

DROP TABLE IF EXISTS `actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `actions` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `id_lib` int(11) unsigned NOT NULL,
  `id_core` int(11) unsigned NOT NULL,
  `id_partner` int(11) unsigned NOT NULL DEFAULT '0',
  `id_host` int(11) unsigned DEFAULT NULL COMMENT 'Партнер, по отношени к кому делается сверка',
  `params` text NOT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'shell',
  `runline` text NOT NULL,
  `maxthreadcount` int(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Максимальное количество активных потоков',
  `maxsteps` int(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Максимальное количество итерраций на исполнение',
  `timeout` int(11) unsigned NOT NULL DEFAULT '120' COMMENT 'Время отведенное на исполнение задачи (сек)',
  `workflow` varchar(20) DEFAULT 'accept' COMMENT 'Тип отчета с точки зрения активных действий',
  `state` int(2) NOT NULL DEFAULT '-1',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_ACTION_ON_CORE` (`id_core`),
  KEY `FK_ACTION_ON_LIB` (`id_lib`),
  KEY `FR_ACTION_ON_PARTNER` (`id_partner`),
  KEY `IND_workflow` (`workflow`),
  KEY `IND_id_host` (`id_host`),
  CONSTRAINT `FK_ACTION_ON_CORE` FOREIGN KEY (`id_core`) REFERENCES `cores` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_ACTION_ON_LIB` FOREIGN KEY (`id_lib`) REFERENCES `libs` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FR_ACTION_ON_PARTNER` FOREIGN KEY (`id_partner`) REFERENCES `partners` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actions`
--

LOCK TABLES `actions` WRITE;
/*!40000 ALTER TABLE `actions` DISABLE KEYS */;
/*!40000 ALTER TABLE `actions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `actions_archive`
--

DROP TABLE IF EXISTS `actions_archive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `actions_archive` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_action` int(11) unsigned NOT NULL,
  `id_event` int(11) unsigned NOT NULL,
  `id_core` int(11) unsigned NOT NULL,
  `data` longtext,
  `last` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `iteration` int(5) unsigned NOT NULL DEFAULT '0',
  `maxsteps` int(5) unsigned NOT NULL DEFAULT '0',
  `workflow` varchar(20) DEFAULT NULL,
  `comment` text,
  `error` int(4) NOT NULL DEFAULT '0',
  `state` int(2) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `CORE_AND_STATE` (`id_core`,`state`),
  KEY `FK_ARCHIVETHREAD_ON_EVENT` (`id_event`),
  KEY `FK_ARCHIVETHREAD_ON_ACTION` (`id_action`),
  CONSTRAINT `FK_ARCHIVETHREAD_ON_ACTION` FOREIGN KEY (`id_action`) REFERENCES `actions` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_ARCHIVETHREAD_ON_CORE` FOREIGN KEY (`id_core`) REFERENCES `cores` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_ARCHIVETHREAD_ON_EVENT` FOREIGN KEY (`id_event`) REFERENCES `actions_events` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actions_archive`
--

LOCK TABLES `actions_archive` WRITE;
/*!40000 ALTER TABLE `actions_archive` DISABLE KEYS */;
/*!40000 ALTER TABLE `actions_archive` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `actions_events`
--

DROP TABLE IF EXISTS `actions_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `actions_events` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_action` int(11) unsigned NOT NULL COMMENT 'Ссылка на действие',
  `id_onerror` int(11) unsigned DEFAULT NULL COMMENT 'Событие при ошибочном завершении',
  `id_next` int(11) unsigned DEFAULT NULL COMMENT 'Ссылка на наследуемое событие',
  `last` datetime DEFAULT NULL COMMENT 'Время последнего события',
  `y` int(2) unsigned NOT NULL DEFAULT '0',
  `m` int(2) unsigned NOT NULL DEFAULT '0',
  `w` int(2) unsigned NOT NULL DEFAULT '0',
  `d` int(3) unsigned NOT NULL DEFAULT '1',
  `h` int(5) unsigned NOT NULL DEFAULT '0',
  `n` int(10) unsigned NOT NULL DEFAULT '0',
  `s` int(15) unsigned NOT NULL DEFAULT '0',
  `state` int(2) unsigned NOT NULL DEFAULT '0' COMMENT 'Тип события (1-стандартное, 2-порождаемое)',
  PRIMARY KEY (`id`),
  KEY `ACTION_AND_STATE` (`id_action`,`state`),
  CONSTRAINT `FK_EVENT_ON_ACTION` FOREIGN KEY (`id_action`) REFERENCES `actions` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actions_events`
--

LOCK TABLES `actions_events` WRITE;
/*!40000 ALTER TABLE `actions_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `actions_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `actions_logs`
--

DROP TABLE IF EXISTS `actions_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `actions_logs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_action_archive` int(11) unsigned NOT NULL,
  `workflow` varchar(20) DEFAULT NULL,
  `comment` text,
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_actionlogs_ON_actionarchive` (`id_action_archive`),
  CONSTRAINT `FK_actionlogs_ON_actionarchive` FOREIGN KEY (`id_action_archive`) REFERENCES `actions_archive` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actions_logs`
--

LOCK TABLES `actions_logs` WRITE;
/*!40000 ALTER TABLE `actions_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `actions_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `actions_threads`
--

DROP TABLE IF EXISTS `actions_threads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `actions_threads` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_action` int(11) unsigned NOT NULL,
  `id_event` int(11) unsigned NOT NULL,
  `id_core` int(11) unsigned NOT NULL,
  `data` longtext,
  `last` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `iteration` int(5) unsigned NOT NULL DEFAULT '0',
  `maxsteps` int(5) unsigned NOT NULL DEFAULT '0',
  `error` int(4) NOT NULL DEFAULT '0',
  `state` int(2) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `CORE_AND_STATE` (`id_core`,`state`),
  KEY `FK_THREAD_ON_EVENT` (`id_event`),
  KEY `FR_THREAD_ON_ACTION` (`id_action`),
  KEY `IND_action_threads_STATE` (`state`),
  CONSTRAINT `FK_THREAD_ON_CORE` FOREIGN KEY (`id_core`) REFERENCES `cores` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_THREAD_ON_EVENT` FOREIGN KEY (`id_event`) REFERENCES `actions_events` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FR_THREAD_ON_ACTION` FOREIGN KEY (`id_action`) REFERENCES `actions` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actions_threads`
--

LOCK TABLES `actions_threads` WRITE;
/*!40000 ALTER TABLE `actions_threads` DISABLE KEYS */;
/*!40000 ALTER TABLE `actions_threads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bills`
--

DROP TABLE IF EXISTS `bills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bills` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `amount` double(15,4) NOT NULL DEFAULT '0.0000',
  `limit` double(15,4) DEFAULT '0.0000',
  `limit_type` tinyint(2) NOT NULL DEFAULT '0' COMMENT '"0"-безлимит,"1"-лимит снизу,"2"-лимит сверху',
  `state` tinyint(3) NOT NULL DEFAULT '0',
  `id_partner` int(11) unsigned NOT NULL DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `comment` longtext,
  `host` varchar(255) NOT NULL DEFAULT '',
  `id_host` int(11) unsigned DEFAULT NULL,
  `bill_type` varchar(255) NOT NULL DEFAULT '',
  `format` tinyint(1) NOT NULL DEFAULT '0' COMMENT '"0"-нал,"1"-б/н,"-1"-виртуал',
  `id_currency` int(10) unsigned NOT NULL DEFAULT '643' COMMENT 'международный код валюты',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `BILL_IDENT_WO_CURRENCY` (`host`,`id_host`,`bill_type`,`format`),
  KEY `FK_CURRENCY` (`id_currency`),
  CONSTRAINT `FK_CURRENCY` FOREIGN KEY (`id_currency`) REFERENCES `currency_rates` (`id_currency`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bills`
--

LOCK TABLES `bills` WRITE;
/*!40000 ALTER TABLE `bills` DISABLE KEYS */;
INSERT INTO `bills` VALUES (1,0.0000,0.0000,0,1,1,'Root bill for \"Arescon Root Partner\"','Main virtual account','partners',0,'root',-1,643,'2015-03-22 19:39:36'),(2,0.0000,0.0000,0,1,1,'Customers bill for \"Arescon Root Partner\"','Account of partner customers','partners',0,'customers',0,643,'2015-03-22 19:39:36'),(3,0.0000,0.0000,0,1,1,'Up-Comission bill for \"Arescon Root Partner\"','Account of partner comission from customers','partners',0,'comission',0,643,'2015-03-22 19:39:36'),(4,0.0000,0.0000,0,1,1,'Cash bill for \"Arescon Root Partner\"','','partners',0,'cash',0,643,'2015-03-22 19:39:36'),(5,0.0000,0.0000,0,1,1,'Non-cash outcome bill for \"Arescon Root Partner\"','','partners',0,'outcome',1,643,'2015-03-22 19:39:36'),(6,0.0000,0.0000,0,1,1,'Non-cash income bill for \"Arescon Root Partner\"','','partners',0,'income',1,643,'2015-03-22 19:39:36'),(7,0.0000,0.0000,0,1,1,'Cash outcome bill for \"Arescon Root Partner\"','','partners',0,'outcome',0,643,'2015-03-22 19:39:36'),(8,0.0000,0.0000,0,1,1,'Cash income bill for \"Arescon Root Partner\"','','partners',0,'income',0,643,'2015-03-22 19:39:36'),(9,0.0000,0.0000,0,1,1,'Cash rounding bill for \"Arescon Root Partner\"','','partners',0,'rounding',0,643,'2015-03-22 19:39:36'),(10,0.0000,0.0000,0,1,0,'Cash in terminal \"010203041002\"','Counted cash','terminals',21,'root',0,643,'2015-03-24 06:29:25'),(11,0.0000,0.0000,0,1,0,'Uncounted cash in terminal \"010203041002\"','Uncounted cash','terminals',21,'uncounted',-1,643,'2015-03-24 06:29:25'),(12,0.0000,0.0000,0,1,0,'Cash in terminal \"001AB6021001\"','Counted cash','terminals',22,'root',0,643,'2015-03-25 06:06:03'),(13,0.0000,0.0000,0,1,0,'Uncounted cash in terminal \"001AB6021001\"','Uncounted cash','terminals',22,'uncounted',-1,643,'2015-03-25 06:06:03'),(14,0.0000,0.0000,0,1,0,'Cash in terminal \"El1.1\"','Counted cash','terminals',23,'root',0,643,'2015-03-28 07:44:41'),(15,0.0000,0.0000,0,1,0,'Uncounted cash in terminal \"El1.1\"','Uncounted cash','terminals',23,'uncounted',-1,643,'2015-03-28 07:44:41'),(16,0.0000,0.0000,0,1,0,'Cash in terminal \"El1.1\"','Counted cash','terminals',25,'root',0,643,'2015-03-28 07:44:55'),(17,0.0000,0.0000,0,1,0,'Uncounted cash in terminal \"El1.1\"','Uncounted cash','terminals',25,'uncounted',-1,643,'2015-03-28 07:44:55'),(18,0.0000,0.0000,0,1,0,'Cash in terminal \"563412561001\"','Counted cash','terminals',26,'root',0,643,'2015-04-02 07:49:38'),(19,0.0000,0.0000,0,1,0,'Uncounted cash in terminal \"563412561001\"','Uncounted cash','terminals',26,'uncounted',-1,643,'2015-04-02 07:49:38'),(20,0.0000,0.0000,0,1,0,'Cash in terminal \"004365001001\"','Counted cash','terminals',27,'root',0,643,'2015-04-07 06:38:35'),(21,0.0000,0.0000,0,1,0,'Uncounted cash in terminal \"004365001001\"','Uncounted cash','terminals',27,'uncounted',-1,643,'2015-04-07 06:38:35'),(22,0.0000,0.0000,0,1,0,'Cash in terminal \"540000000000\"','Counted cash','terminals',28,'root',0,643,'2015-04-08 07:41:43'),(23,0.0000,0.0000,0,1,0,'Uncounted cash in terminal \"540000000000\"','Uncounted cash','terminals',28,'uncounted',-1,643,'2015-04-08 07:41:43'),(24,0.0000,0.0000,0,1,0,'Cash in terminal \"F3D454000000\"','Counted cash','terminals',29,'root',0,643,'2015-04-08 10:20:49'),(25,0.0000,0.0000,0,1,0,'Uncounted cash in terminal \"F3D454000000\"','Uncounted cash','terminals',29,'uncounted',-1,643,'2015-04-08 10:20:49'),(26,0.0000,0.0000,0,1,0,'Cash in terminal \"DEADBEEF1001\"','Counted cash','terminals',30,'root',0,643,'2015-04-09 20:31:17'),(27,0.0000,0.0000,0,1,0,'Uncounted cash in terminal \"DEADBEEF1001\"','Uncounted cash','terminals',30,'uncounted',-1,643,'2015-04-09 20:31:17'),(28,0.0000,0.0000,0,1,0,'Cash in terminal \"123456001002\"','Counted cash','terminals',31,'root',0,643,'2015-06-09 08:47:49'),(29,0.0000,0.0000,0,1,0,'Uncounted cash in terminal \"123456001002\"','Uncounted cash','terminals',31,'uncounted',-1,643,'2015-06-09 08:47:49');
/*!40000 ALTER TABLE `bills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cashouts`
--

DROP TABLE IF EXISTS `cashouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cashouts` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ext_id` varchar(15) DEFAULT NULL,
  `id_terminal` int(11) unsigned NOT NULL DEFAULT '0',
  `id_partner` int(11) unsigned NOT NULL,
  `id_person` int(11) NOT NULL DEFAULT '-1',
  `sum` double(15,4) unsigned NOT NULL DEFAULT '0.0000',
  `value` double(15,4) DEFAULT '0.0000',
  `state` tinyint(2) NOT NULL DEFAULT '0',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_CASH_ON_TERM` (`id_terminal`),
  KEY `FK_CASH_ON_PARTNER` (`id_partner`),
  CONSTRAINT `FK_CASH_ON_PARTNER` FOREIGN KEY (`id_partner`) REFERENCES `partners` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_CASH_ON_TERM` FOREIGN KEY (`id_terminal`) REFERENCES `terminals` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cashouts`
--

LOCK TABLES `cashouts` WRITE;
/*!40000 ALTER TABLE `cashouts` DISABLE KEYS */;
/*!40000 ALTER TABLE `cashouts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cashouts_contents`
--

DROP TABLE IF EXISTS `cashouts_contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cashouts_contents` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_cashout` int(11) unsigned NOT NULL,
  `nominal` double(11,2) NOT NULL DEFAULT '0.00',
  `count` int(10) unsigned NOT NULL DEFAULT '0',
  `id_currency` int(11) unsigned NOT NULL DEFAULT '643',
  `coin` int(2) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `FK_CASHCONT_ON_CURRENCY` (`id_currency`),
  KEY `FK_CASHCONT_ON_CASH` (`id_cashout`),
  CONSTRAINT `FK_CASHCONT_ON_CASH` FOREIGN KEY (`id_cashout`) REFERENCES `cashouts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_CASHCONT_ON_CURRENCY` FOREIGN KEY (`id_currency`) REFERENCES `currency_rates` (`id_currency`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cashouts_contents`
--

LOCK TABLES `cashouts_contents` WRITE;
/*!40000 ALTER TABLE `cashouts_contents` DISABLE KEYS */;
/*!40000 ALTER TABLE `cashouts_contents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cashouts_states`
--

DROP TABLE IF EXISTS `cashouts_states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cashouts_states` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `caption` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cashouts_states`
--

LOCK TABLES `cashouts_states` WRITE;
/*!40000 ALTER TABLE `cashouts_states` DISABLE KEYS */;
/*!40000 ALTER TABLE `cashouts_states` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cores`
--

DROP TABLE IF EXISTS `cores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cores` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `ident` varchar(255) NOT NULL,
  `CoreType` varchar(255) NOT NULL DEFAULT 'CyberCore',
  `Version` char(10) DEFAULT NULL,
  `Public` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Маркер доступности ядра для подключения провайдеров и терминалов партнерами',
  `ServiceName` varchar(255) NOT NULL,
  `DisplayName` varchar(255) NOT NULL,
  `Description` longtext,
  `options` longtext,
  `database` longtext,
  `logs` longtext,
  `pid` int(16) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDENT` (`ident`),
  UNIQUE KEY `ServiceName` (`ServiceName`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cores`
--

LOCK TABLES `cores` WRITE;
/*!40000 ALTER TABLE `cores` DISABLE KEYS */;
INSERT INTO `cores` VALUES (1,'Arescon','BitCore','1.0.0.0',1,'AresconBitCore','Arescon Bit Core','Arescon Bit Core for communicate with counters and routers','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n	<port>85</port>\r\n	<addr>0.0.0.0</addr>\r\n	<maxclients>0</maxclients>\r\n	<keepalive>600</keepalive>\r\n	<flushtimeout>150</flushtimeout>\r\n	<sessiontimeout>600</sessiontimeout>\r\n	<ssl>0</ssl>\r\n	<cert>C:\\Processing\\Cert\\cert.pem</cert>\r\n	<privatekey>C:\\Processing\\Cert\\cert.pem</privatekey>\r\n	<passphrase></passphrase>\r\n	<cafile>C:\\Processing\\Cert\\ca.cer</cafile>\r\n	<libcontroller>1000</libcontroller>\r\n</root>','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n	<type>MySQL</type>\r\n	<name>processing</name>\r\n	<host>192.168.100.9</host>\r\n	<port>3306</port>\r\n	<username>proc</username>\r\n	<password>viasoft1721</password>\r\n	<characterset>UTF8</characterset>\r\n</root>','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n	<enable>1</enable>\r\n	<dir>C:\\Processing\\Logs\\AresconBitCore\\</dir>\r\n</root>',58956);
/*!40000 ALTER TABLE `cores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `currency_rates`
--

DROP TABLE IF EXISTS `currency_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `currency_rates` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_currency` int(10) unsigned NOT NULL,
  `caption` varchar(255) DEFAULT NULL,
  `icon` char(3) DEFAULT NULL,
  `rate` double(11,4) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_currency` (`id_currency`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `currency_rates`
--

LOCK TABLES `currency_rates` WRITE;
/*!40000 ALTER TABLE `currency_rates` DISABLE KEYS */;
INSERT INTO `currency_rates` VALUES (1,643,'Rubble','RUR',1.0000);
/*!40000 ALTER TABLE `currency_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dispatcher_associations`
--

DROP TABLE IF EXISTS `dispatcher_associations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dispatcher_associations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dispatcher_associations`
--

LOCK TABLES `dispatcher_associations` WRITE;
/*!40000 ALTER TABLE `dispatcher_associations` DISABLE KEYS */;
INSERT INTO `dispatcher_associations` VALUES (1,1,'ТСЖ1'),(2,1,'ТСЖ2');
/*!40000 ALTER TABLE `dispatcher_associations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dispatcher_companies`
--

DROP TABLE IF EXISTS `dispatcher_companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dispatcher_companies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dispatcher_companies`
--

LOCK TABLES `dispatcher_companies` WRITE;
/*!40000 ALTER TABLE `dispatcher_companies` DISABLE KEYS */;
INSERT INTO `dispatcher_companies` VALUES (1,'company');
/*!40000 ALTER TABLE `dispatcher_companies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dispatcher_flats`
--

DROP TABLE IF EXISTS `dispatcher_flats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dispatcher_flats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `house_id` int(11) NOT NULL,
  `number` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dispatcher_flats`
--

LOCK TABLES `dispatcher_flats` WRITE;
/*!40000 ALTER TABLE `dispatcher_flats` DISABLE KEYS */;
INSERT INTO `dispatcher_flats` VALUES (1,1,65),(2,2,32),(3,3,20),(4,4,145),(5,3,57);
/*!40000 ALTER TABLE `dispatcher_flats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dispatcher_houses`
--

DROP TABLE IF EXISTS `dispatcher_houses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dispatcher_houses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `association_id` int(11) NOT NULL,
  `address` varchar(60) NOT NULL,
  `x` varchar(45) NOT NULL,
  `y` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dispatcher_houses`
--

LOCK TABLES `dispatcher_houses` WRITE;
/*!40000 ALTER TABLE `dispatcher_houses` DISABLE KEYS */;
INSERT INTO `dispatcher_houses` VALUES (1,1,'Башиловская улица, д. 15','55.706921098504964','37.470398559570306'),(2,1,'Иловайская улица, д. 3','55.87404807445789','37.690125122070306'),(3,2,'Минусинская улица, д. 37','55.71855041425817','37.66815246582029'),(4,2,'Нежинская улица, д. 13','55.78283647321973','37.55691589355467');
/*!40000 ALTER TABLE `dispatcher_houses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dispatcher_services`
--

DROP TABLE IF EXISTS `dispatcher_services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dispatcher_services` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type` int(11) NOT NULL,
  `flat_id` int(11) NOT NULL,
  `start` bigint(20) NOT NULL,
  `period` int(11) NOT NULL,
  `name` varchar(45) NOT NULL,
  `ext_id` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dispatcher_services`
--

LOCK TABLES `dispatcher_services` WRITE;
/*!40000 ALTER TABLE `dispatcher_services` DISABLE KEYS */;
INSERT INTO `dispatcher_services` VALUES (1,0,3,1409504400000,300000,'Счетчик Techem AP',''),(2,3,3,1409592882825,300000,'Счетчик однофазный СОЭ-52',' '),(3,2,3,1409592882825,300000,'Счетчик ГРАНД-25Т',' '),(4,1,3,1409592882825,300000,'Счетчик СВ-15 Х \"МЕТЕР\"',' '),(5,1,4,1409592882825,300000,'счетчик 5',' '),(6,3,4,1409592882825,300000,'счетчик 6',' '),(7,2,1,1409592882825,300000,'счетчик 7',' '),(8,0,1,1409592882825,300000,'счетчик 8',' '),(9,3,1,1409592882825,300000,'счетчик 9',' '),(10,3,2,1409592882825,300000,'счетчик 10',' '),(11,1,2,1409592882825,300000,'счетчик 11',' '),(12,2,2,1409592882825,300000,'счетчик 12',' ');
/*!40000 ALTER TABLE `dispatcher_services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gate_inits`
--

DROP TABLE IF EXISTS `gate_inits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gate_inits` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_gate` int(11) unsigned NOT NULL,
  `id_core` int(11) unsigned NOT NULL,
  `state` tinyint(2) NOT NULL DEFAULT '0',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `GATE_AND_CORE` (`id_gate`,`id_core`),
  KEY `FK_gate_inits` (`id_gate`),
  KEY `FK_gate_initscore` (`id_core`),
  CONSTRAINT `FK_gate_inits` FOREIGN KEY (`id_gate`) REFERENCES `gates` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_gate_initscore` FOREIGN KEY (`id_core`) REFERENCES `cores` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gate_inits`
--

LOCK TABLES `gate_inits` WRITE;
/*!40000 ALTER TABLE `gate_inits` DISABLE KEYS */;
INSERT INTO `gate_inits` VALUES (1,1,1,1,'2015-05-28 15:24:29');
/*!40000 ALTER TABLE `gate_inits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gates`
--

DROP TABLE IF EXISTS `gates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gates` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `id_lib` int(11) unsigned NOT NULL DEFAULT '0',
  `id_bill` int(11) unsigned NOT NULL DEFAULT '0',
  `id_partner` int(11) unsigned NOT NULL DEFAULT '0',
  `id_terminal` int(11) unsigned DEFAULT NULL COMMENT 'Ссылка на терминал отправки запроса (для транзитных шлюзов)',
  `id_nextgate` int(11) unsigned DEFAULT NULL COMMENT 'Ссылка на шлюз вторичной обработки запроса',
  `id_errorgate` int(11) unsigned DEFAULT NULL COMMENT 'Ссылка на шлюз вторичной обработки запроса в случае ошибки',
  `params` longtext,
  `state` tinyint(3) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `FK_gates_libs` (`id_lib`),
  KEY `FK_GATES_ON_BILL` (`id_bill`),
  KEY `FK_GATES_ON_PARTNER` (`id_partner`),
  CONSTRAINT `FK_GATES_ON_BILL` FOREIGN KEY (`id_bill`) REFERENCES `bills` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_GATES_ON_LIB` FOREIGN KEY (`id_lib`) REFERENCES `libs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_GATES_ON_PARTNER` FOREIGN KEY (`id_partner`) REFERENCES `partners` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gates`
--

LOCK TABLES `gates` WRITE;
/*!40000 ALTER TABLE `gates` DISABLE KEYS */;
INSERT INTO `gates` VALUES (1,'Areson Interopt API',1,1,0,NULL,NULL,NULL,'<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n	<check>\r\n		<enabled>0</enabled>\r\n		<default>\r\n			<error>0</error>\r\n			<result>0</result>\r\n		</default>\r\n		<ignore_session>1</ignore_session>\r\n	</check>\r\n	<paycheck>\r\n		<enabled>0</enabled>\r\n		<default>\r\n			<error>0</error>\r\n			<result>7</result>\r\n		</default>\r\n	</paycheck>\r\n	<payment>\r\n		<enabled>0</enabled>\r\n		<default>\r\n			<error>0</error>\r\n			<result>0</result>\r\n		</default>\r\n	</payment>\r\n	<status>\r\n		<enabled>0</enabled>\r\n	</status>\r\n	<mon>\r\n		<enabled>1</enabled>\r\n		<default>\r\n			<error>0</error>\r\n			<result>0</result>\r\n		</default>\r\n	</mon>\r\n	<cancel>\r\n		<enabled>0</enabled>\r\n		<default>\r\n			<error>7</error>\r\n			<result>1</result>\r\n		</default>\r\n	</cancel>\r\n	<connection>\r\n		<characterset>UTF8</characterset>\r\n		<useunicode>true</useunicode>\r\n		<server>192.168.100.9</server>\r\n		<port>3306</port>\r\n		<database>processing</database>\r\n		<username>proc</username>\r\n		<password>viasoft1721</password>\r\n	</connection>\r\n	<mapping>\r\n		<1001>0<1001>\r\n		<0000>1<0000>\r\n		<1002>2<1002>\r\n		<0001>3<0001>\r\n	</mapping>\r\n</root>',1);
/*!40000 ALTER TABLE `gates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gates_on_providers`
--

DROP TABLE IF EXISTS `gates_on_providers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gates_on_providers` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_gate` int(11) unsigned NOT NULL,
  `id_provider` int(11) unsigned NOT NULL,
  `id_partner` int(11) unsigned DEFAULT NULL COMMENT 'Если пустая, то доступна для всех партнеров',
  PRIMARY KEY (`id`),
  KEY `FK_GOP_ON_gate` (`id_gate`),
  KEY `FK_GOP_ON_provider` (`id_provider`),
  KEY `IND_partner` (`id_partner`),
  CONSTRAINT `FK_GOP_ON_gate` FOREIGN KEY (`id_gate`) REFERENCES `gates` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_GOP_ON_provider` FOREIGN KEY (`id_provider`) REFERENCES `providers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gates_on_providers`
--

LOCK TABLES `gates_on_providers` WRITE;
/*!40000 ALTER TABLE `gates_on_providers` DISABLE KEYS */;
/*!40000 ALTER TABLE `gates_on_providers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `goods`
--

DROP TABLE IF EXISTS `goods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `goods` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_partner` int(11) unsigned NOT NULL DEFAULT '0',
  `id_place` int(11) DEFAULT NULL,
  `id_person` int(11) DEFAULT NULL,
  `id_terminal` int(11) DEFAULT NULL,
  `id_goods_type` int(11) unsigned NOT NULL DEFAULT '0',
  `count` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `FK_GoodPartner` (`id_partner`),
  KEY `FK_GoodType` (`id_goods_type`),
  KEY `IND_place` (`id_place`),
  KEY `IND_person` (`id_person`),
  KEY `IND_terminal` (`id_terminal`),
  CONSTRAINT `FK_GoodPartner` FOREIGN KEY (`id_partner`) REFERENCES `partners` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_GoodType` FOREIGN KEY (`id_goods_type`) REFERENCES `goods_types` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Таблица склада и комплектующих';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goods`
--

LOCK TABLES `goods` WRITE;
/*!40000 ALTER TABLE `goods` DISABLE KEYS */;
/*!40000 ALTER TABLE `goods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `goods_logs`
--

DROP TABLE IF EXISTS `goods_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `goods_logs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_partner` int(11) unsigned NOT NULL,
  `id_place` int(11) DEFAULT NULL,
  `id_person` int(11) DEFAULT NULL,
  `id_terminal` int(11) DEFAULT NULL,
  `id_goods_type` int(11) unsigned NOT NULL,
  `count` int(11) NOT NULL DEFAULT '0' COMMENT 'Если больше нуля - детали приносятся, если меньше нуля - забираются.',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_goodlogs_ON_goodtypes` (`id_goods_type`),
  KEY `IND_place` (`id_place`),
  KEY `IND_person` (`id_person`),
  KEY `IND_terminal` (`id_terminal`),
  KEY `FK_goodlogs_ON_partner` (`id_partner`),
  CONSTRAINT `FK_goodlogs_ON_goodtypes` FOREIGN KEY (`id_goods_type`) REFERENCES `goods_types` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_goodlogs_ON_partner` FOREIGN KEY (`id_partner`) REFERENCES `partners` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goods_logs`
--

LOCK TABLES `goods_logs` WRITE;
/*!40000 ALTER TABLE `goods_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `goods_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `goods_types`
--

DROP TABLE IF EXISTS `goods_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `goods_types` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `caption` varchar(255) NOT NULL,
  `description` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Таблица спецификаций элементов';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goods_types`
--

LOCK TABLES `goods_types` WRITE;
/*!40000 ALTER TABLE `goods_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `goods_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lib_handles`
--

DROP TABLE IF EXISTS `lib_handles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lib_handles` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `handle` int(16) unsigned NOT NULL DEFAULT '0',
  `id_lib` int(11) unsigned NOT NULL,
  `id_core` int(11) unsigned NOT NULL,
  `state` tinyint(2) NOT NULL DEFAULT '1',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `LIB_AND_CORE` (`id_lib`,`id_core`),
  KEY `FK_lib_handles` (`id_lib`),
  KEY `CORE_INDEX` (`id_core`),
  CONSTRAINT `FK_lib_handles` FOREIGN KEY (`id_lib`) REFERENCES `libs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `LIBHANDLES_ON_CORE` FOREIGN KEY (`id_core`) REFERENCES `cores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lib_handles`
--

LOCK TABLES `lib_handles` WRITE;
/*!40000 ALTER TABLE `lib_handles` DISABLE KEYS */;
INSERT INTO `lib_handles` VALUES (1,47841280,1,1,1,'2015-05-28 15:24:29');
/*!40000 ALTER TABLE `lib_handles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `libs`
--

DROP TABLE IF EXISTS `libs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `libs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `type` varchar(20) DEFAULT NULL,
  `path` longtext NOT NULL,
  `description` longtext,
  `state` tinyint(2) NOT NULL DEFAULT '0',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `libs`
--

LOCK TABLES `libs` WRITE;
/*!40000 ALTER TABLE `libs` DISABLE KEYS */;
INSERT INTO `libs` VALUES (1,'provider','C:\\Processing\\Providers\\aresconapi.dll','Обработчик пакетов для ядра BitCore по протоколу Arescon (InterOpt) v1.0 от 10.01.2015',1,'2015-03-22 19:25:47');
/*!40000 ALTER TABLE `libs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `logs_triggers`
--

DROP TABLE IF EXISTS `logs_triggers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `logs_triggers` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `ext_id` int(11) unsigned DEFAULT NULL,
  `caption` varchar(255) DEFAULT NULL,
  `content` text,
  `stamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logs_triggers`
--

LOCK TABLES `logs_triggers` WRITE;
/*!40000 ALTER TABLE `logs_triggers` DISABLE KEYS */;
/*!40000 ALTER TABLE `logs_triggers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partners`
--

DROP TABLE IF EXISTS `partners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partners` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `date_created` datetime DEFAULT NULL,
  `state` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `id_root` int(11) unsigned NOT NULL DEFAULT '0',
  `id_partner_type` int(11) unsigned NOT NULL DEFAULT '0',
  `comment` text,
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `id_root` (`id_root`),
  KEY `partners_ibfk_1` (`id_partner_type`),
  CONSTRAINT `partners_ibfk_1` FOREIGN KEY (`id_partner_type`) REFERENCES `partners_types` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partners`
--

LOCK TABLES `partners` WRITE;
/*!40000 ALTER TABLE `partners` DISABLE KEYS */;
INSERT INTO `partners` VALUES (0,'Arescon Root Partner','2015-03-22 22:39:36',1,1,1,NULL,'2015-03-24 06:37:13');
/*!40000 ALTER TABLE `partners` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partners_accounts`
--

DROP TABLE IF EXISTS `partners_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partners_accounts` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_partner` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Дилер хозяин субсчета',
  `id_host` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Дилер по отношению к которому открыт счет',
  `id_connected` int(11) unsigned NOT NULL COMMENT 'Связанный ответный аккаунт',
  `ext_id` int(11) NOT NULL COMMENT 'Внешний идентификатор счета (для зеркальных счетов)',
  `info` longtext COMMENT 'Информация о внешнем счете',
  `comment` varchar(255) DEFAULT NULL COMMENT 'Комментарий к относительному аккаунту',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `partners_accounts_ibfk_1` (`id_partner`),
  KEY `IND_id_connected` (`id_connected`),
  KEY `IND_ext_id` (`ext_id`),
  KEY `IND_id_host` (`id_host`),
  CONSTRAINT `partners_accounts_ibfk_1` FOREIGN KEY (`id_partner`) REFERENCES `partners` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `partners_accounts_ibfk_2` FOREIGN KEY (`id_host`) REFERENCES `partners` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `partners_accounts_ibfk_3` FOREIGN KEY (`id_connected`) REFERENCES `partners_accounts` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partners_accounts`
--

LOCK TABLES `partners_accounts` WRITE;
/*!40000 ALTER TABLE `partners_accounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `partners_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partners_accounts_rules`
--

DROP TABLE IF EXISTS `partners_accounts_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partners_accounts_rules` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) DEFAULT NULL COMMENT 'Name of rule',
  `id_terminals_group` int(11) unsigned DEFAULT NULL,
  `id_places_group` int(11) unsigned DEFAULT NULL,
  `id_rewards_tarif` int(11) unsigned NOT NULL,
  `id_partners_account` int(11) unsigned NOT NULL,
  `startuse` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date of rule start of use',
  `enduse` timestamp NULL DEFAULT NULL COMMENT 'Date of rule end of use',
  `state` tinyint(3) NOT NULL DEFAULT '1' COMMENT 'Enable of rule: 0 - blocked, 1 - allow',
  PRIMARY KEY (`id`),
  KEY `FK_RULES_ON_REWARDS_TARIF` (`id_rewards_tarif`),
  KEY `FK_RULES_ON_PARTNERS_ACCOUNT` (`id_partners_account`),
  CONSTRAINT `FK_RULES_ON_PARTNERS_ACCOUNT` FOREIGN KEY (`id_partners_account`) REFERENCES `partners_accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_RULES_ON_REWARDS_TARIF` FOREIGN KEY (`id_rewards_tarif`) REFERENCES `rewards_tarifs` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partners_accounts_rules`
--

LOCK TABLES `partners_accounts_rules` WRITE;
/*!40000 ALTER TABLE `partners_accounts_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `partners_accounts_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partners_types`
--

DROP TABLE IF EXISTS `partners_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partners_types` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_site_role` int(11) unsigned NOT NULL DEFAULT '0',
  `name` varchar(50) DEFAULT NULL,
  `description` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partners_types`
--

LOCK TABLES `partners_types` WRITE;
/*!40000 ALTER TABLE `partners_types` DISABLE KEYS */;
INSERT INTO `partners_types` VALUES (1,0,'Root',NULL);
/*!40000 ALTER TABLE `partners_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payments` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_provider` int(11) unsigned NOT NULL DEFAULT '0',
  `id_gate` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Ссылка на шлюз, через который платеж проведен',
  `id_terminal` int(11) unsigned NOT NULL DEFAULT '0',
  `id_place` int(11) unsigned NOT NULL DEFAULT '0',
  `id_transaction` int(11) unsigned DEFAULT NULL,
  `id_root` int(11) unsigned DEFAULT NULL COMMENT 'Ссылка на исходный платеж (для перепроведения и каскадных запросов)',
  `id_root_terminal` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Ссылка на исходный терминал (железный)',
  `date_init` datetime NOT NULL,
  `date_done` datetime DEFAULT NULL,
  `date_provider` datetime DEFAULT NULL,
  `date_terminal` datetime DEFAULT NULL,
  `session` varchar(20) NOT NULL DEFAULT '',
  `comment` varchar(255) DEFAULT NULL,
  `number` varchar(255) NOT NULL DEFAULT '',
  `account` varchar(255) DEFAULT NULL,
  `amount` double(11,2) NOT NULL DEFAULT '0.00',
  `amount_all` double(11,2) NOT NULL DEFAULT '0.00',
  `result` int(7) NOT NULL DEFAULT '0',
  `error` int(7) NOT NULL DEFAULT '0',
  `errmsg` varchar(255) DEFAULT NULL,
  `transid` varchar(20) NOT NULL DEFAULT '',
  `authcode` varchar(20) DEFAULT NULL,
  `addinfo` longtext,
  `other` longtext,
  `state` tinyint(3) NOT NULL DEFAULT '0',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `SESSION_AND_TERMINAL` (`id_terminal`,`session`),
  UNIQUE KEY `TRANSID_AND_PROVIDER` (`id_provider`,`transid`),
  KEY `session` (`session`),
  KEY `FK_payments_provider` (`id_provider`),
  KEY `FK_payments_terminal` (`id_terminal`),
  KEY `FK_PAYMENT_ON_RTERMINAL` (`id_root_terminal`),
  KEY `FK_PAYMENT_ON_PLACE` (`id_place`),
  KEY `IND_payments_state` (`state`),
  KEY `IND_for_actions` (`id_gate`,`account`,`result`,`date_done`),
  KEY `IND_for_symple_actions` (`id_gate`,`date_done`,`result`),
  KEY `IND_comment` (`comment`),
  KEY `FK_ON_GATE` (`id_gate`),
  KEY `IND_transid` (`transid`),
  CONSTRAINT `FK_PAYMENT_ON_GATE` FOREIGN KEY (`id_gate`) REFERENCES `gates` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_PAYMENT_ON_PLACE` FOREIGN KEY (`id_place`) REFERENCES `places` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_PAYMENT_ON_PROVIDER` FOREIGN KEY (`id_provider`) REFERENCES `providers` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_PAYMENT_ON_RTERMINAL` FOREIGN KEY (`id_root_terminal`) REFERENCES `terminals` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_PAYMENT_ON_TERMINAL` FOREIGN KEY (`id_terminal`) REFERENCES `terminals` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments_errors`
--

DROP TABLE IF EXISTS `payments_errors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payments_errors` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_error` int(11) NOT NULL,
  `id_core` int(11) unsigned NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ERROR_AND_CORE` (`id_error`,`id_core`),
  KEY `ERRORCODES_ON_CORE` (`id_core`),
  CONSTRAINT `ERRORCODES_ON_CORE` FOREIGN KEY (`id_core`) REFERENCES `cores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=337 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments_errors`
--

LOCK TABLES `payments_errors` WRITE;
/*!40000 ALTER TABLE `payments_errors` DISABLE KEYS */;
INSERT INTO `payments_errors` VALUES (331,0,1,'OK'),(332,1,1,'Шлюз временно недоступен'),(333,2,1,'Превышено число попыток'),(334,3,1,'Техническая ошибка, нельзя обработать запрос'),(335,24,1,'Внутренняя ошибка обработки запроса'),(336,30,1,'Общая ошибка системы');
/*!40000 ALTER TABLE `payments_errors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments_history`
--

DROP TABLE IF EXISTS `payments_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payments_history` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_payment` int(11) unsigned NOT NULL,
  `ptype` varchar(20) NOT NULL,
  `date` datetime NOT NULL,
  `logfile` varchar(255) NOT NULL,
  `ip` varchar(25) DEFAULT NULL,
  `error` int(7) NOT NULL DEFAULT '0',
  `result` int(7) NOT NULL DEFAULT '0',
  `state` tinyint(2) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `FK_HISTORY_ON_PAYMENT` (`id_payment`),
  CONSTRAINT `payments_history_ibfk_1` FOREIGN KEY (`id_payment`) REFERENCES `payments` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments_history`
--

LOCK TABLES `payments_history` WRITE;
/*!40000 ALTER TABLE `payments_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments_history_temp`
--

DROP TABLE IF EXISTS `payments_history_temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payments_history_temp` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_payment` int(11) unsigned NOT NULL,
  `ptype` varchar(20) NOT NULL,
  `date` datetime NOT NULL,
  `logfile` varchar(255) NOT NULL,
  `ip` varchar(25) DEFAULT NULL,
  `error` int(7) NOT NULL DEFAULT '0',
  `result` int(7) NOT NULL DEFAULT '0',
  `state` tinyint(2) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `FK_PAYHISTORY_ON_PAYTEMP` (`id_payment`),
  CONSTRAINT `PAYHISTORY_ON_PAYTEMP` FOREIGN KEY (`id_payment`) REFERENCES `payments_temp` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments_history_temp`
--

LOCK TABLES `payments_history_temp` WRITE;
/*!40000 ALTER TABLE `payments_history_temp` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments_history_temp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments_results`
--

DROP TABLE IF EXISTS `payments_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payments_results` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_result` int(11) NOT NULL,
  `title` varchar(60) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_result` (`id_result`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments_results`
--

LOCK TABLES `payments_results` WRITE;
/*!40000 ALTER TABLE `payments_results` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments_results` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments_states`
--

DROP TABLE IF EXISTS `payments_states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payments_states` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_state` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_state` (`id_state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments_states`
--

LOCK TABLES `payments_states` WRITE;
/*!40000 ALTER TABLE `payments_states` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments_states` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments_temp`
--

DROP TABLE IF EXISTS `payments_temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payments_temp` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_provider` int(11) unsigned NOT NULL DEFAULT '0',
  `id_gate` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Ссылка на шлюз, через который платеж проведен',
  `id_terminal` int(11) unsigned NOT NULL DEFAULT '0',
  `id_place` int(11) unsigned NOT NULL DEFAULT '0',
  `id_transaction` int(11) unsigned DEFAULT NULL,
  `id_root` int(11) unsigned DEFAULT NULL COMMENT 'Ссылка на исходный платеж (для перепроведения и каскадных запросов)',
  `id_root_terminal` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Ссылка на исходный терминал (железный)',
  `date_init` datetime NOT NULL,
  `date_done` datetime DEFAULT NULL,
  `date_provider` datetime DEFAULT NULL,
  `date_terminal` datetime DEFAULT NULL,
  `session` varchar(20) NOT NULL DEFAULT '',
  `comment` varchar(255) DEFAULT NULL,
  `number` varchar(255) NOT NULL DEFAULT '',
  `account` varchar(255) DEFAULT NULL,
  `amount` double(11,2) NOT NULL DEFAULT '0.00',
  `amount_all` double(11,2) NOT NULL DEFAULT '0.00',
  `result` int(7) NOT NULL DEFAULT '0',
  `error` int(7) NOT NULL DEFAULT '0',
  `errmsg` varchar(255) DEFAULT NULL,
  `transid` varchar(20) NOT NULL DEFAULT '',
  `authcode` varchar(20) DEFAULT NULL,
  `addinfo` longtext,
  `other` longtext,
  `state` tinyint(3) NOT NULL DEFAULT '0',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `PTEMP_SESSION_AND_TERMINAL` (`id_terminal`,`session`),
  UNIQUE KEY `IND_transid_AND_provider` (`id_provider`,`transid`),
  KEY `session` (`session`),
  KEY `FK_payments_provider` (`id_provider`),
  KEY `FK_payments_terminal` (`id_terminal`),
  KEY `FK_PTEMP_ON_RTERMINAL` (`id_root_terminal`),
  KEY `FK_PTEMP_ON_GATE` (`id_gate`),
  KEY `FK_PTEMP_ON_PLACE` (`id_place`),
  KEY `IND_payments_temp_state` (`state`),
  KEY `IND_comment` (`comment`),
  KEY `INT_transid` (`transid`),
  CONSTRAINT `FK_PTEMP_ON_GATE` FOREIGN KEY (`id_gate`) REFERENCES `gates` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_PTEMP_ON_PLACE` FOREIGN KEY (`id_place`) REFERENCES `places` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_PTEMP_ON_PROVIDER` FOREIGN KEY (`id_provider`) REFERENCES `providers` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_PTEMP_ON_RTERMINAL` FOREIGN KEY (`id_root_terminal`) REFERENCES `terminals` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_PTEMP_ON_TERMINAL` FOREIGN KEY (`id_terminal`) REFERENCES `terminals` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments_temp`
--

LOCK TABLES `payments_temp` WRITE;
/*!40000 ALTER TABLE `payments_temp` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments_temp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL COMMENT 'Имя',
  `sname` varchar(255) DEFAULT NULL COMMENT 'Фамилия',
  `fname` varchar(255) DEFAULT NULL COMMENT 'Отчество',
  `phone` bigint(15) DEFAULT NULL COMMENT 'Номер телефона (сотового)',
  `settings` text COMMENT 'Настройки личного кабинета пользователя',
  `birthday` date DEFAULT NULL COMMENT 'Дата рождения',
  `deadday` date DEFAULT NULL COMMENT 'Дата смерти (если применимо)',
  `id_partner` int(11) DEFAULT '-1' COMMENT 'Если "-1" - это не персонал партнера',
  `state` tinyint(2) NOT NULL DEFAULT '1' COMMENT 'Состояние',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата последней коррекции',
  PRIMARY KEY (`id`),
  KEY `IND_partner` (`id_partner`),
  KEY `IND_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person`
--

LOCK TABLES `person` WRITE;
/*!40000 ALTER TABLE `person` DISABLE KEYS */;
/*!40000 ALTER TABLE `person` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person_cards`
--

DROP TABLE IF EXISTS `person_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_cards` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_person` int(11) unsigned NOT NULL,
  `id_place` int(11) unsigned DEFAULT NULL,
  `id_provider` int(11) unsigned NOT NULL,
  `number` bigint(16) NOT NULL,
  `caption` varchar(255) NOT NULL,
  `params` text,
  `state` tinyint(3) NOT NULL DEFAULT '0',
  `stamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_card_ON_person` (`id_person`),
  KEY `FK_card_ON_provider` (`id_provider`),
  KEY `IND_number` (`number`),
  KEY `IND_place` (`id_place`),
  CONSTRAINT `FK_card_ON_person` FOREIGN KEY (`id_person`) REFERENCES `person` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_card_ON_provider` FOREIGN KEY (`id_provider`) REFERENCES `providers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_cards`
--

LOCK TABLES `person_cards` WRITE;
/*!40000 ALTER TABLE `person_cards` DISABLE KEYS */;
/*!40000 ALTER TABLE `person_cards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person_checkout`
--

DROP TABLE IF EXISTS `person_checkout`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_checkout` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_card` int(11) unsigned NOT NULL,
  `caption` varchar(150) DEFAULT NULL,
  `amount` double(15,4) NOT NULL DEFAULT '0.0000',
  `params` text,
  `state` tinyint(3) NOT NULL DEFAULT '0',
  `stamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_checkout_ON_card` (`id_card`),
  CONSTRAINT `FK_checkout_ON_card` FOREIGN KEY (`id_card`) REFERENCES `person_cards` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_checkout`
--

LOCK TABLES `person_checkout` WRITE;
/*!40000 ALTER TABLE `person_checkout` DISABLE KEYS */;
/*!40000 ALTER TABLE `person_checkout` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `places`
--

DROP TABLE IF EXISTS `places`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `places` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_partner` int(11) unsigned DEFAULT NULL,
  `id_person` int(11) unsigned DEFAULT NULL,
  `type` varchar(255) NOT NULL DEFAULT 'terminal' COMMENT 'terminal, cashier, office, habitation - типы мест',
  `name` varchar(255) DEFAULT NULL,
  `params` text COMMENT 'Параметры места, опциональное поле для белых списков, данных по аренде и контактах',
  `country` varchar(30) DEFAULT NULL,
  `index` int(7) DEFAULT NULL,
  `region` varchar(60) DEFAULT NULL,
  `city` varchar(60) DEFAULT NULL,
  `street` varchar(60) DEFAULT NULL,
  `house` varchar(5) DEFAULT NULL,
  `room` varchar(5) DEFAULT NULL,
  `floor` tinyint(3) DEFAULT NULL,
  `x` double DEFAULT NULL,
  `y` double DEFAULT NULL,
  `state` tinyint(2) NOT NULL DEFAULT '1',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `IND_partner` (`id_partner`),
  KEY `IND_person` (`id_person`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `places`
--

LOCK TABLES `places` WRITE;
/*!40000 ALTER TABLE `places` DISABLE KEYS */;
INSERT INTO `places` VALUES (0,0,NULL,'terminal',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'2015-03-24 06:29:11');
/*!40000 ALTER TABLE `places` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `places_groups`
--

DROP TABLE IF EXISTS `places_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `places_groups` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_partner` int(11) unsigned NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `PLACESGROUP_ON_PARTNER` (`id_partner`),
  CONSTRAINT `PLACESGROUP_ON_PARTNER` FOREIGN KEY (`id_partner`) REFERENCES `partners` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `places_groups`
--

LOCK TABLES `places_groups` WRITE;
/*!40000 ALTER TABLE `places_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `places_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `places_on_groups`
--

DROP TABLE IF EXISTS `places_on_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `places_on_groups` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_place` int(11) unsigned NOT NULL,
  `id_places_group` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_PG_ON_Place` (`id_place`),
  KEY `FK_PG_ON_PlacesGroup` (`id_places_group`),
  CONSTRAINT `FK_PG_ON_Place` FOREIGN KEY (`id_place`) REFERENCES `places` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_PG_ON_PlacesGroup` FOREIGN KEY (`id_places_group`) REFERENCES `places_groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `places_on_groups`
--

LOCK TABLES `places_on_groups` WRITE;
/*!40000 ALTER TABLE `places_on_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `places_on_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plan`
--

DROP TABLE IF EXISTS `plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plan` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `id_terminal` int(11) unsigned DEFAULT '0',
  `id_person` int(11) unsigned NOT NULL DEFAULT '0',
  `id_task` int(11) unsigned NOT NULL DEFAULT '0',
  `id_state` int(11) unsigned NOT NULL DEFAULT '0',
  `comment` longtext,
  PRIMARY KEY (`id`),
  KEY `FK_person` (`id_person`),
  KEY `FK_task` (`id_task`),
  KEY `FK_state` (`id_state`),
  KEY `FK_terminal` (`id_terminal`),
  CONSTRAINT `FK_person` FOREIGN KEY (`id_person`) REFERENCES `person` (`id`),
  CONSTRAINT `FK_state` FOREIGN KEY (`id_state`) REFERENCES `plan_states` (`id`),
  CONSTRAINT `FK_task` FOREIGN KEY (`id_task`) REFERENCES `plan_tasks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plan`
--

LOCK TABLES `plan` WRITE;
/*!40000 ALTER TABLE `plan` DISABLE KEYS */;
/*!40000 ALTER TABLE `plan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plan_states`
--

DROP TABLE IF EXISTS `plan_states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plan_states` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `caption` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plan_states`
--

LOCK TABLES `plan_states` WRITE;
/*!40000 ALTER TABLE `plan_states` DISABLE KEYS */;
/*!40000 ALTER TABLE `plan_states` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plan_tasks`
--

DROP TABLE IF EXISTS `plan_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plan_tasks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `caption` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plan_tasks`
--

LOCK TABLES `plan_tasks` WRITE;
/*!40000 ALTER TABLE `plan_tasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `plan_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `providers`
--

DROP TABLE IF EXISTS `providers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `providers` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `id_gate` int(11) unsigned NOT NULL,
  `id_core` int(11) unsigned NOT NULL,
  `ident` varchar(255) NOT NULL DEFAULT '',
  `settings` text COMMENT 'Настройки провайдера по данному ядру',
  `minvalue` double(11,2) NOT NULL DEFAULT '0.00',
  `maxvalue` double(11,2) NOT NULL DEFAULT '30000.00',
  `comment` varchar(255) DEFAULT NULL COMMENT 'Комментарий к провайдеру',
  `state` tinyint(3) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `IND_ident_core` (`id_core`,`ident`),
  KEY `FK_providers_gate` (`id_gate`),
  KEY `FK_providers` (`id_core`),
  CONSTRAINT `FK_providers` FOREIGN KEY (`id_core`) REFERENCES `cores` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_providers_gate` FOREIGN KEY (`id_gate`) REFERENCES `gates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `providers`
--

LOCK TABLES `providers` WRITE;
/*!40000 ALTER TABLE `providers` DISABLE KEYS */;
INSERT INTO `providers` VALUES (1,'InterOpt API Arescon',1,1,'0001',NULL,0.00,30000.00,NULL,1);
/*!40000 ALTER TABLE `providers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rewards_gates_rules`
--

DROP TABLE IF EXISTS `rewards_gates_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rewards_gates_rules` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_rewards_tarif` int(11) unsigned NOT NULL,
  `id_gate` int(11) unsigned NOT NULL,
  `min` double(11,4) NOT NULL DEFAULT '0.0000' COMMENT 'Minimum comission',
  `max` double(11,4) NOT NULL DEFAULT '30000.0000' COMMENT 'Maximum comission',
  `fix` double(11,4) NOT NULL DEFAULT '0.0000' COMMENT 'Comission fix part',
  `up` double(7,4) NOT NULL DEFAULT '0.0000' COMMENT 'Up comission percent',
  `down` double(7,4) NOT NULL DEFAULT '0.0000' COMMENT 'Back comission percent',
  `state` tinyint(2) unsigned NOT NULL DEFAULT '1' COMMENT 'Gate access state: 0 - blocked, 1 - allow',
  PRIMARY KEY (`id`),
  UNIQUE KEY `TARIF_AND_GATE` (`id_rewards_tarif`,`id_gate`),
  KEY `FK_GATE` (`id_gate`),
  KEY `FK_REWARDS_TARIF` (`id_rewards_tarif`),
  CONSTRAINT `FK_GATE` FOREIGN KEY (`id_gate`) REFERENCES `gates` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_REWARDS_TARIF` FOREIGN KEY (`id_rewards_tarif`) REFERENCES `rewards_tarifs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rewards_gates_rules`
--

LOCK TABLES `rewards_gates_rules` WRITE;
/*!40000 ALTER TABLE `rewards_gates_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `rewards_gates_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rewards_tarifs`
--

DROP TABLE IF EXISTS `rewards_tarifs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rewards_tarifs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rewards_tarifs`
--

LOCK TABLES `rewards_tarifs` WRITE;
/*!40000 ALTER TABLE `rewards_tarifs` DISABLE KEYS */;
/*!40000 ALTER TABLE `rewards_tarifs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sms`
--

DROP TABLE IF EXISTS `sms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sms` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_LC` int(11) unsigned DEFAULT NULL,
  `id_sms_provider` int(11) unsigned NOT NULL,
  `phone` varchar(30) NOT NULL,
  `text` text,
  `mes_id` varchar(11) DEFAULT NULL,
  `created` timestamp NULL DEFAULT NULL,
  `iteration` int(3) unsigned NOT NULL DEFAULT '0',
  `state` int(3) NOT NULL DEFAULT '0',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_SMS_ON_SMS_PROVIDER` (`id_sms_provider`),
  KEY `IND_sms_STATE` (`state`),
  CONSTRAINT `FK_SMS_ON_SMS_PROVIDER` FOREIGN KEY (`id_sms_provider`) REFERENCES `sms_providers` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sms`
--

LOCK TABLES `sms` WRITE;
/*!40000 ALTER TABLE `sms` DISABLE KEYS */;
/*!40000 ALTER TABLE `sms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sms_providers`
--

DROP TABLE IF EXISTS `sms_providers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sms_providers` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `settings` text,
  `id_partner` int(11) unsigned NOT NULL DEFAULT '0',
  `timeout` int(11) unsigned NOT NULL DEFAULT '120',
  `state` int(3) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `FK_SMS_PROVIDER_ON_PARTNER` (`id_partner`),
  CONSTRAINT `FK_SMS_PROVIDER_ON_PARTNER` FOREIGN KEY (`id_partner`) REFERENCES `partners` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sms_providers`
--

LOCK TABLES `sms_providers` WRITE;
/*!40000 ALTER TABLE `sms_providers` DISABLE KEYS */;
/*!40000 ALTER TABLE `sms_providers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sms_temp`
--

DROP TABLE IF EXISTS `sms_temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sms_temp` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_LC` int(11) unsigned DEFAULT NULL,
  `id_sms_provider` int(11) unsigned NOT NULL,
  `phone` varchar(30) NOT NULL,
  `text` text,
  `mes_id` varchar(11) DEFAULT NULL,
  `created` timestamp NULL DEFAULT NULL,
  `iteration` int(3) unsigned NOT NULL DEFAULT '0',
  `state` int(3) NOT NULL DEFAULT '0',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_TEMPSMS_ON_SMS_PROVIDER` (`id_sms_provider`),
  KEY `IND_sms_temp_STATE` (`state`),
  CONSTRAINT `FK_TEMPSMS_ON_SMS_PROVIDER` FOREIGN KEY (`id_sms_provider`) REFERENCES `sms_providers` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sms_temp`
--

LOCK TABLES `sms_temp` WRITE;
/*!40000 ALTER TABLE `sms_temp` DISABLE KEYS */;
/*!40000 ALTER TABLE `sms_temp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `terminals`
--

DROP TABLE IF EXISTS `terminals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `terminals` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_core` int(11) unsigned NOT NULL,
  `id_partner` int(11) unsigned NOT NULL,
  `id_bill` int(11) unsigned NOT NULL COMMENT 'Если заполнено, терминал имеет собственный счет средств',
  `id_place` int(11) unsigned NOT NULL,
  `id_terminals_type` int(11) unsigned NOT NULL DEFAULT '1',
  `id_root` int(11) unsigned DEFAULT NULL COMMENT 'Если заполнено, терминал является частью другого терминала или подключается через него в туннеле',
  `ext_id` varchar(255) NOT NULL,
  `security` longtext,
  `name` varchar(255) NOT NULL,
  `settings` text COMMENT 'Специальные настройки терминала',
  `lastconnect` datetime DEFAULT NULL COMMENT 'Дата и время последнего подключения или обращения',
  `state` tinyint(3) NOT NULL DEFAULT '0',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `EXT_ID_AND CORE` (`id_core`,`ext_id`),
  KEY `terminals_ibfk_1` (`id_terminals_type`),
  KEY `terminals_ibfk_2` (`id_bill`),
  KEY `terminals_ibfk_4` (`id_partner`),
  KEY `terminals_ibfk_5` (`id_place`),
  CONSTRAINT `terminals_ibfk_1` FOREIGN KEY (`id_terminals_type`) REFERENCES `terminals_types` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `terminals_ibfk_2` FOREIGN KEY (`id_bill`) REFERENCES `bills` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `terminals_ibfk_3` FOREIGN KEY (`id_core`) REFERENCES `cores` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `terminals_ibfk_4` FOREIGN KEY (`id_partner`) REFERENCES `partners` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `terminals_ibfk_5` FOREIGN KEY (`id_place`) REFERENCES `places` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `terminals`
--

LOCK TABLES `terminals` WRITE;
/*!40000 ALTER TABLE `terminals` DISABLE KEYS */;
INSERT INTO `terminals` VALUES (21,1,0,1,0,2,NULL,'010203041002','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<pass>630B69F7FF7F0000</pass>\r\n</root>','010203041002',NULL,'2015-04-20 09:29:34',1,'2015-03-24 06:29:25'),(22,1,0,1,0,0,NULL,'001AB6021001','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<pass>0000000000000000</pass>\r\n</root>','001AB6021001','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<type>16</type>\r\n<channel>1</channel>\r\n<deactivate>0000000000000000</deactivate>\r\n<firmware>0002</firmware>\r\n</root>','2015-06-01 13:15:41',1,'2015-03-25 06:06:03'),(23,1,0,1,0,1,22,'001AB6021001-1','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<pass>0000000000000000</pass>\r\n</root>','El1.1','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<port>8N1</port>\r\n<bitrate>9600</bitrate>\r\n<timeout>2000</timeout>\r\n</root>','2015-06-01 13:16:50',1,'2015-03-25 06:06:03'),(25,1,0,1,0,1,21,'010203041002-1','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<pass>630B69F7FF7F0000</pass>\r\n</root>','El1.1','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<port>8N1</port>\r\n<bitrate>9600</bitrate>\r\n<timeout>2000</timeout>\r\n</root>','2015-04-20 09:29:34',1,'2015-03-25 06:06:03'),(26,1,0,1,0,0,NULL,'563412561001','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<pass>0000000000000000</pass>\r\n</root>','563412561001','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<type>16</type>\r\n<channel>1</channel>\r\n<deactivate>0000000000000000</deactivate>\r\n<firmware>0001</firmware>\r\n</root>','2015-04-07 09:34:21',1,'2015-04-02 07:49:38'),(27,1,0,1,0,0,NULL,'004365001001','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<pass>0000000000000000</pass>\r\n</root>','004365001001','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<type>16</type>\r\n<channel>1</channel>\r\n<deactivate>0000000000000000</deactivate>\r\n<firmware>0001</firmware>\r\n</root>','2015-04-09 17:19:23',1,'2015-04-07 06:38:35'),(28,1,0,1,0,0,NULL,'540000000000','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<pass>0000000000000000</pass>\r\n</root>','540000000000',NULL,NULL,1,'2015-04-08 07:41:43'),(29,1,0,1,0,0,NULL,'F3D454000000','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<pass>0000000000000000</pass>\r\n</root>','F3D454000000',NULL,NULL,1,'2015-04-08 10:20:49'),(30,1,0,1,0,0,NULL,'DEADBEEF1001','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<pass>0000000000000000</pass>\r\n</root>','DEADBEEF1001','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<type>16</type>\r\n<channel>1</channel>\r\n<deactivate>0000000000000000</deactivate>\r\n<firmware>0002</firmware>\r\n</root>','2015-04-10 21:42:40',1,'2015-04-09 20:31:17'),(31,1,0,1,0,0,NULL,'123456001002','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<pass>0102030405060708</pass>\r\n</root>','123456001002','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<root>\r\n<type>16</type>\r\n<channel>2</channel>\r\n<deactivate>0102030405060708</deactivate>\r\n<firmware>0000</firmware>\r\n</root>','2015-06-09 17:52:14',1,'2015-06-09 08:47:49');
/*!40000 ALTER TABLE `terminals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `terminals_data`
--

DROP TABLE IF EXISTS `terminals_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `terminals_data` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_provider` int(11) unsigned NOT NULL,
  `id_gate` int(11) unsigned NOT NULL,
  `id_terminal` int(11) unsigned NOT NULL,
  `id_place` int(11) unsigned NOT NULL,
  `date_server` datetime NOT NULL,
  `date_terminal` datetime NOT NULL,
  `value` double(15,4) unsigned NOT NULL DEFAULT '0.0000',
  `weight` double(15,4) unsigned NOT NULL DEFAULT '0.0000',
  `state` tinyint(3) NOT NULL DEFAULT '1',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_termdata_ON_provider` (`id_provider`),
  KEY `FK_termdata_ON_gate` (`id_gate`),
  KEY `FK_termdata_ON_terminal` (`id_terminal`),
  KEY `FK_termdata_ON_place` (`id_place`),
  CONSTRAINT `FK_termdata_ON_gate` FOREIGN KEY (`id_gate`) REFERENCES `gates` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_termdata_ON_place` FOREIGN KEY (`id_place`) REFERENCES `places` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_termdata_ON_provider` FOREIGN KEY (`id_provider`) REFERENCES `providers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_termdata_ON_terminal` FOREIGN KEY (`id_terminal`) REFERENCES `terminals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2830 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `terminals_data`
--

LOCK TABLES `terminals_data` WRITE;
/*!40000 ALTER TABLE `terminals_data` DISABLE KEYS */;
INSERT INTO `terminals_data` VALUES (670,1,1,21,0,'2015-03-24 09:38:25','2015-03-24 05:20:34',0.0000,0.0000,1,'2015-03-24 06:38:25'),(671,1,1,21,0,'2015-03-24 09:43:25','2015-03-24 05:20:34',0.0000,0.0000,1,'2015-03-24 06:43:25'),(672,1,1,21,0,'2015-03-24 09:48:25','2015-03-24 05:20:34',0.0000,0.0000,1,'2015-03-24 06:48:25'),(673,1,1,21,0,'2015-03-24 09:53:25','2015-03-24 05:20:34',0.0000,0.0000,1,'2015-03-24 06:53:25'),(674,1,1,21,0,'2015-03-24 09:58:26','2015-03-24 05:20:34',0.0000,0.0000,1,'2015-03-24 06:58:26'),(675,1,1,22,0,'2015-03-25 09:06:03','1977-12-08 02:56:20',0.0000,0.0000,1,'2015-03-25 06:06:03'),(676,1,1,22,0,'2015-03-25 09:11:03','1923-06-22 10:43:33',0.0000,0.0000,1,'2015-03-25 06:11:03'),(677,1,1,22,0,'2015-03-25 09:21:05','1970-10-17 19:24:05',0.0000,0.0000,1,'2015-03-25 06:21:05'),(678,1,1,22,0,'2015-03-25 09:26:05','1994-03-10 12:28:05',0.0000,0.0000,1,'2015-03-25 06:26:05'),(679,1,1,22,0,'2015-03-25 09:36:05','1905-05-29 20:28:05',0.0000,0.0000,1,'2015-03-25 06:36:05'),(680,1,1,22,0,'2015-03-25 09:41:06','1928-10-20 13:32:05',0.0000,0.0000,1,'2015-03-25 06:41:06'),(681,1,1,22,0,'2015-03-25 09:51:07','1976-02-15 22:12:37',0.0000,0.0000,1,'2015-03-25 06:51:07'),(682,1,1,22,0,'2015-03-25 09:56:07','2000-01-19 19:36:53',0.0000,0.0000,1,'2015-03-25 06:56:07'),(683,1,1,22,0,'2015-03-25 10:06:08','1910-09-27 23:16:37',0.0000,0.0000,1,'2015-03-25 07:06:08'),(684,1,1,22,0,'2015-03-25 10:11:09','1934-08-31 20:40:53',0.0000,0.0000,1,'2015-03-25 07:11:09'),(685,1,1,22,0,'2015-03-25 10:21:09','1981-12-27 05:21:25',0.0000,0.0000,1,'2015-03-25 07:21:09'),(686,1,1,22,0,'2015-03-25 10:26:10','2005-05-19 22:25:25',0.0000,0.0000,1,'2015-03-25 07:26:10'),(687,1,1,22,0,'2015-03-25 10:36:11','1916-08-08 06:25:25',0.0000,0.0000,1,'2015-03-25 07:36:11'),(688,1,1,22,0,'2015-03-25 10:41:11','1939-12-30 23:29:25',0.0000,0.0000,1,'2015-03-25 07:41:11'),(689,1,1,22,0,'2015-03-25 10:51:12','1987-04-27 08:09:57',0.0000,0.0000,1,'2015-03-25 07:51:12'),(690,1,1,22,0,'2015-03-25 10:56:12','2011-03-31 05:34:13',0.0000,0.0000,1,'2015-03-25 07:56:12'),(691,1,1,22,0,'2015-03-25 11:06:13','1921-12-07 09:13:57',0.0000,0.0000,1,'2015-03-25 08:06:13'),(692,1,1,22,0,'2015-03-25 11:11:14','1945-11-10 06:38:13',0.0000,0.0000,1,'2015-03-25 08:11:14'),(693,1,1,22,0,'2015-03-25 11:21:14','1992-08-25 10:58:29',0.0000,0.0000,1,'2015-03-25 08:21:14'),(694,1,1,22,0,'2015-03-25 11:26:15','2016-07-29 08:22:45',0.0000,0.0000,1,'2015-03-25 08:26:15'),(695,1,1,22,0,'2015-03-25 11:36:16','1927-10-18 16:22:45',0.0000,0.0000,1,'2015-03-25 08:36:16'),(696,1,1,22,0,'2015-03-25 11:41:16','1951-03-11 09:26:45',0.0000,0.0000,1,'2015-03-25 08:41:16'),(697,1,1,22,0,'2015-03-25 11:51:17','1998-07-06 18:07:17',0.0000,0.0000,1,'2015-03-25 08:51:17'),(698,1,1,22,0,'2015-03-25 11:56:17','2021-11-27 11:11:17',0.0000,0.0000,1,'2015-03-25 08:56:17'),(699,1,1,22,0,'2015-03-25 12:06:18','1933-02-15 19:11:17',0.0000,0.0000,1,'2015-03-25 09:06:18'),(700,1,1,22,0,'2015-03-25 12:11:19','1956-07-09 12:15:17',0.0000,0.0000,1,'2015-03-25 09:11:19'),(701,1,1,22,0,'2015-03-25 12:21:20','2004-05-17 01:16:05',0.0000,0.0000,1,'2015-03-25 09:21:20'),(702,1,1,22,0,'2015-03-25 12:26:21','2028-04-19 22:40:21',0.0000,0.0000,1,'2015-03-25 09:26:21'),(703,1,1,22,0,'2015-03-25 12:36:21','1938-12-28 02:20:05',0.0000,0.0000,1,'2015-03-25 09:36:21'),(704,1,1,22,0,'2015-03-25 12:41:22','1962-11-30 23:44:21',0.0000,0.0000,1,'2015-03-25 09:41:22'),(705,1,1,22,0,'2015-03-25 12:51:23','2010-03-28 08:24:53',0.0000,0.0000,1,'2015-03-25 09:51:23'),(706,1,1,22,0,'2015-03-25 12:56:23','2033-08-19 01:28:53',0.0000,0.0000,1,'2015-03-25 09:56:23'),(707,1,1,22,0,'2015-03-25 13:06:24','1944-11-07 09:28:53',0.0000,0.0000,1,'2015-03-25 10:06:24'),(708,1,1,22,0,'2015-03-25 13:11:25','1968-03-31 02:32:53',0.0000,0.0000,1,'2015-03-25 10:11:25'),(709,1,1,22,0,'2015-03-25 13:21:25','2015-07-27 11:13:25',0.0000,0.0000,1,'2015-03-25 10:21:25'),(710,1,1,22,0,'2015-03-25 13:26:25','1902-11-11 21:49:09',0.0000,0.0000,1,'2015-03-25 10:26:25'),(711,1,1,22,0,'2015-03-25 13:36:27','1950-03-08 12:17:25',0.0000,0.0000,1,'2015-03-25 10:36:27'),(712,1,1,22,0,'2015-03-25 13:41:27','1974-02-10 03:53:57',0.0000,0.0000,1,'2015-03-25 10:41:27'),(713,1,1,22,0,'2015-03-25 13:51:27','2020-11-24 14:01:57',0.0000,0.0000,1,'2015-03-25 10:51:27'),(714,1,1,22,0,'2015-03-25 13:56:28','1908-09-22 04:57:57',0.0000,0.0000,1,'2015-03-25 10:56:28'),(715,1,1,22,0,'2015-03-25 14:06:29','1956-01-17 19:26:13',0.0000,0.0000,1,'2015-03-25 11:06:29'),(716,1,1,22,0,'2015-03-25 14:11:29','1979-06-11 06:42:29',0.0000,0.0000,1,'2015-03-25 11:11:29'),(717,1,1,22,0,'2015-03-25 14:21:30','2026-10-05 21:10:45',0.0000,0.0000,1,'2015-03-25 11:21:30'),(718,1,1,22,0,'2015-03-25 14:26:31','1914-08-03 12:06:45',0.0000,0.0000,1,'2015-03-25 11:26:31'),(719,1,1,22,0,'2015-03-25 14:36:31','1961-05-17 22:14:45',0.0000,0.0000,1,'2015-03-25 11:36:31'),(720,1,1,22,0,'2015-03-25 14:41:31','1984-10-09 09:31:01',0.0000,0.0000,1,'2015-03-25 11:41:31'),(721,1,1,22,0,'2015-03-25 14:51:33','2032-08-16 04:19:33',0.0000,0.0000,1,'2015-03-25 11:51:33'),(722,1,1,22,0,'2015-03-25 14:56:33','1919-12-02 14:55:17',0.0000,0.0000,1,'2015-03-25 11:56:33'),(723,1,1,22,0,'2015-03-25 15:06:33','1966-09-16 01:03:17',0.0000,0.0000,1,'2015-03-25 12:06:33'),(724,1,1,22,0,'2015-03-25 15:11:34','1990-08-20 16:39:49',0.0000,0.0000,1,'2015-03-25 12:11:34'),(725,1,1,22,0,'2015-03-25 15:12:34','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-03-25 12:12:34'),(726,1,1,22,0,'2015-03-25 15:17:34','1910-05-12 03:51:49',0.0000,0.0000,1,'2015-03-25 12:17:34'),(727,1,1,22,0,'2015-03-25 15:27:34','1957-02-23 13:59:49',0.0000,0.0000,1,'2015-03-25 12:27:34'),(728,1,1,22,0,'2015-03-25 15:32:35','1981-01-28 05:36:21',0.0000,0.0000,1,'2015-03-25 12:32:35'),(729,1,1,22,0,'2015-03-25 15:42:36','2028-05-24 20:04:37',0.0000,0.0000,1,'2015-03-25 12:42:36'),(730,1,1,22,0,'2015-03-25 15:47:36','1915-09-10 06:40:21',0.0000,0.0000,1,'2015-03-25 12:47:36'),(731,1,1,22,0,'2015-03-25 15:57:37','1963-01-04 21:08:37',0.0000,0.0000,1,'2015-03-25 12:57:37'),(732,1,1,22,0,'2015-03-25 16:02:38','1986-05-29 08:24:53',0.0000,0.0000,1,'2015-03-25 13:02:38'),(733,1,1,22,0,'2015-03-25 16:12:38','2033-09-22 22:53:09',0.0000,0.0000,1,'2015-03-25 13:12:38'),(734,1,1,22,0,'2015-03-25 16:17:38','1921-01-08 09:28:53',0.0000,0.0000,1,'2015-03-25 13:17:38'),(735,1,1,22,0,'2015-03-25 16:27:40','1968-05-04 23:57:09',0.0000,0.0000,1,'2015-03-25 13:27:40'),(736,1,1,22,0,'2015-03-25 16:32:40','1992-04-08 15:33:41',0.0000,0.0000,1,'2015-03-25 13:32:40'),(737,1,1,22,0,'2015-03-25 16:42:40','1902-12-16 19:13:25',0.0000,0.0000,1,'2015-03-25 13:42:40'),(738,1,1,22,0,'2015-03-25 16:47:41','1926-11-19 16:37:41',0.0000,0.0000,1,'2015-03-25 13:47:41'),(739,1,1,22,0,'2015-03-25 16:57:42','1974-03-17 01:18:13',0.0000,0.0000,1,'2015-03-25 13:57:42'),(740,1,1,22,0,'2015-03-25 17:02:42','1997-08-07 18:22:13',0.0000,0.0000,1,'2015-03-25 14:02:42'),(741,1,1,22,0,'2015-03-25 17:12:44','1908-10-27 02:22:13',0.0000,0.0000,1,'2015-03-25 14:12:44'),(742,1,1,22,0,'2015-03-25 17:17:44','1932-03-19 19:26:13',0.0000,0.0000,1,'2015-03-25 14:17:44'),(743,1,1,22,0,'2015-03-25 17:27:44','1979-07-16 04:06:45',0.0000,0.0000,1,'2015-03-25 14:27:44'),(744,1,1,22,0,'2015-03-25 17:32:44','2002-12-06 21:10:45',0.0000,0.0000,1,'2015-03-25 14:32:44'),(745,1,1,22,0,'2015-03-25 17:42:46','1914-02-25 05:10:45',0.0000,0.0000,1,'2015-03-25 14:42:46'),(746,1,1,22,0,'2015-03-25 17:47:46','1938-01-29 02:35:01',0.0000,0.0000,1,'2015-03-25 14:47:46'),(747,1,1,22,0,'2015-03-26 08:22:13','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-03-26 05:22:13'),(748,1,1,22,0,'2015-03-26 08:27:13','1953-12-03 14:33:57',0.0000,0.0000,1,'2015-03-26 05:27:13'),(749,1,1,22,0,'2015-03-26 08:37:13','2000-09-17 18:54:13',0.0000,0.0000,1,'2015-03-26 05:37:13'),(750,1,1,22,0,'2015-03-26 08:42:14','2024-08-21 16:18:29',0.0000,0.0000,1,'2015-03-26 05:42:14'),(751,1,1,22,0,'2015-03-26 08:52:15','1935-11-11 00:18:29',0.0000,0.0000,1,'2015-03-26 05:52:15'),(752,1,1,22,0,'2015-03-26 08:57:15','1959-04-03 17:22:29',0.0000,0.0000,1,'2015-03-26 05:57:15'),(753,1,1,22,0,'2015-03-26 09:07:16','2006-07-30 02:03:01',0.0000,0.0000,1,'2015-03-26 06:07:16'),(754,1,1,22,0,'2015-03-26 09:12:17','2030-07-02 23:27:17',0.0000,0.0000,1,'2015-03-26 06:12:17'),(755,1,1,22,0,'2015-03-26 09:22:17','1941-03-11 03:07:01',0.0000,0.0000,1,'2015-03-26 06:22:17'),(756,1,1,22,0,'2015-03-26 09:27:17','1964-08-01 20:11:01',0.0000,0.0000,1,'2015-03-26 06:27:17'),(757,1,1,22,0,'2015-03-26 09:37:19','2012-06-09 09:11:49',0.0000,0.0000,1,'2015-03-26 06:37:19'),(758,1,1,22,0,'2015-03-26 09:42:19','2035-11-01 02:15:49',0.0000,0.0000,1,'2015-03-26 06:42:19'),(759,1,1,22,0,'2015-03-26 09:52:19','1946-07-10 05:55:33',0.0000,0.0000,1,'2015-03-26 06:52:19'),(760,1,1,22,0,'2015-03-26 09:57:20','1970-12-25 01:52:21',0.0000,0.0000,1,'2015-03-26 06:57:20'),(761,1,1,22,0,'2015-03-26 10:07:21','2017-10-08 12:00:21',0.0000,0.0000,1,'2015-03-26 07:07:21'),(762,1,1,22,0,'2015-03-26 10:12:21','1905-01-23 22:36:05',0.0000,0.0000,1,'2015-03-26 07:12:21'),(763,1,1,22,0,'2015-03-26 10:22:22','1952-11-30 17:24:37',0.0000,0.0000,1,'2015-03-26 07:22:22'),(764,1,1,22,0,'2015-03-26 10:27:23','1976-04-24 04:40:53',0.0000,0.0000,1,'2015-03-26 07:27:23'),(765,1,1,22,0,'2015-03-26 10:37:23','2023-02-06 14:48:53',0.0000,0.0000,1,'2015-03-26 07:37:23'),(766,1,1,22,0,'2015-03-26 10:42:23','1910-05-25 01:24:37',0.0000,0.0000,1,'2015-03-26 07:42:23'),(767,1,1,22,0,'2015-03-26 10:52:25','1958-03-31 20:13:09',0.0000,0.0000,1,'2015-03-26 07:52:25'),(768,1,1,22,0,'2015-03-26 10:57:25','1981-08-23 07:29:25',0.0000,0.0000,1,'2015-03-26 07:57:25'),(769,1,1,22,0,'2015-03-26 11:07:25','2028-06-06 17:37:25',0.0000,0.0000,1,'2015-03-26 08:07:25'),(770,1,1,22,0,'2015-03-26 11:12:26','1916-10-15 12:53:41',0.0000,0.0000,1,'2015-03-26 08:12:26'),(771,1,1,22,0,'2015-03-26 11:22:27','1963-07-30 23:01:41',0.0000,0.0000,1,'2015-03-26 08:22:27'),(772,1,1,22,0,'2015-03-26 11:27:27','1986-12-22 10:17:57',0.0000,0.0000,1,'2015-03-26 08:27:27'),(773,1,1,22,0,'2015-03-26 11:37:29','2035-05-11 09:26:45',0.0000,0.0000,1,'2015-03-26 08:37:29'),(774,1,1,22,0,'2015-03-26 11:42:30','1922-08-26 20:02:29',0.0000,0.0000,1,'2015-03-26 08:42:30'),(775,1,1,22,0,'2015-03-26 11:52:30','1969-06-10 06:10:29',0.0000,0.0000,1,'2015-03-26 08:52:30'),(776,1,1,22,0,'2015-03-26 11:57:30','1993-05-14 21:47:01',0.0000,0.0000,1,'2015-03-26 08:57:30'),(777,1,1,22,0,'2015-03-26 12:06:27','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-03-26 09:06:27'),(778,1,1,22,0,'2015-03-26 12:11:27','2030-01-21 15:42:13',0.0000,0.0000,1,'2015-03-26 09:11:27'),(779,1,1,22,0,'2015-03-26 12:21:27','1940-09-29 19:21:57',0.0000,0.0000,1,'2015-03-26 09:21:27'),(780,1,1,22,0,'2015-03-26 12:26:28','1964-09-02 16:46:13',0.0000,0.0000,1,'2015-03-26 09:26:28'),(781,1,1,22,0,'2015-03-26 12:36:29','2011-12-30 01:26:45',0.0000,0.0000,1,'2015-03-26 09:36:29'),(782,1,1,22,0,'2015-03-26 12:41:29','2035-05-22 18:30:45',0.0000,0.0000,1,'2015-03-26 09:41:29'),(783,1,1,22,0,'2015-03-26 12:51:30','1946-01-28 22:14:45',0.0000,0.0000,1,'2015-03-26 09:51:30'),(784,1,1,22,0,'2015-03-26 12:56:31','1969-06-21 15:18:45',0.0000,0.0000,1,'2015-03-26 09:56:31'),(785,1,1,22,0,'2015-03-26 13:06:31','2016-10-16 23:59:17',0.0000,0.0000,1,'2015-03-26 10:06:31'),(786,1,1,22,0,'2015-03-26 13:11:31','1904-02-02 10:35:01',0.0000,0.0000,1,'2015-03-26 10:11:31'),(787,1,1,22,0,'2015-03-26 13:21:33','1951-05-30 01:03:17',0.0000,0.0000,1,'2015-03-26 10:21:33'),(788,1,1,22,0,'2015-03-26 13:26:33','1975-05-03 16:39:49',0.0000,0.0000,1,'2015-03-26 10:26:33'),(789,1,1,22,0,'2015-03-26 13:36:33','2022-02-15 02:47:49',0.0000,0.0000,1,'2015-03-26 10:36:33'),(790,1,1,22,0,'2015-03-26 13:41:35','1909-12-13 17:43:49',0.0000,0.0000,1,'2015-03-26 10:41:35'),(791,1,1,22,0,'2015-03-26 13:51:35','1957-04-09 08:12:05',0.0000,0.0000,1,'2015-03-26 10:51:35'),(792,1,1,22,0,'2015-03-26 13:56:35','1980-08-31 19:28:21',0.0000,0.0000,1,'2015-03-26 10:56:35'),(793,1,1,22,0,'2015-03-26 14:06:37','2027-12-27 09:56:37',0.0000,0.0000,1,'2015-03-26 11:06:37'),(794,1,1,22,0,'2015-03-26 14:11:37','1915-04-13 20:32:21',0.0000,0.0000,1,'2015-03-26 11:11:37'),(795,1,1,22,0,'2015-03-26 14:21:37','1962-08-08 11:00:37',0.0000,0.0000,1,'2015-03-26 11:21:37'),(796,1,1,22,0,'2015-03-26 14:26:37','1985-12-30 22:16:53',0.0000,0.0000,1,'2015-03-26 11:26:37'),(797,1,1,22,0,'2015-03-26 14:36:39','2033-04-26 12:45:09',0.0000,0.0000,1,'2015-03-26 11:36:39'),(798,1,1,22,0,'2015-03-26 14:41:39','1921-02-22 03:41:09',0.0000,0.0000,1,'2015-03-26 11:41:39'),(799,1,1,22,0,'2015-03-26 14:51:39','1967-12-07 13:49:09',0.0000,0.0000,1,'2015-03-26 11:51:40'),(800,1,1,22,0,'2015-03-26 14:56:41','1991-11-11 05:25:41',0.0000,0.0000,1,'2015-03-26 11:56:41'),(801,1,1,22,0,'2015-03-26 15:06:41','1903-01-30 13:25:41',0.0000,0.0000,1,'2015-03-26 12:06:41'),(802,1,1,22,0,'2015-03-26 15:11:41','1926-06-23 06:29:41',0.0000,0.0000,1,'2015-03-26 12:11:41'),(803,1,1,22,0,'2015-03-26 15:21:43','1973-10-18 15:10:13',0.0000,0.0000,1,'2015-03-26 12:21:43'),(804,1,1,22,0,'2015-03-26 15:26:43','1997-03-11 08:14:13',0.0000,0.0000,1,'2015-03-26 12:26:43'),(805,1,1,22,0,'2015-03-26 15:36:43','1908-05-30 16:14:13',0.0000,0.0000,1,'2015-03-26 12:36:43'),(806,1,1,22,0,'2015-03-26 15:41:44','1931-10-22 09:18:13',0.0000,0.0000,1,'2015-03-26 12:41:44'),(807,1,1,22,0,'2015-03-26 15:51:45','1979-02-16 17:58:45',0.0000,0.0000,1,'2015-03-26 12:51:45'),(808,1,1,22,0,'2015-03-26 15:56:46','2003-01-20 15:23:01',0.0000,0.0000,1,'2015-03-26 12:56:46'),(809,1,1,22,0,'2015-03-26 16:06:47','1914-04-10 23:23:01',0.0000,0.0000,1,'2015-03-26 13:06:47'),(810,1,1,22,0,'2015-03-26 16:11:48','1938-03-14 20:47:17',0.0000,0.0000,1,'2015-03-26 13:11:48'),(811,1,1,22,0,'2015-03-26 16:21:48','1985-07-10 05:27:49',0.0000,0.0000,1,'2015-03-26 13:21:48'),(812,1,1,22,0,'2015-03-26 16:26:49','2008-11-30 22:31:49',0.0000,0.0000,1,'2015-03-26 13:26:49'),(813,1,1,22,0,'2015-03-26 16:36:50','1920-02-20 06:31:49',0.0000,0.0000,1,'2015-03-26 13:36:50'),(814,1,1,22,0,'2015-03-26 16:41:50','1943-07-13 23:35:49',0.0000,0.0000,1,'2015-03-26 13:41:50'),(815,1,1,22,0,'2015-03-26 16:51:51','1990-11-08 08:16:21',0.0000,0.0000,1,'2015-03-26 13:51:51'),(816,1,1,22,0,'2015-03-26 16:56:51','2014-04-01 01:20:21',0.0000,0.0000,1,'2015-03-26 13:56:51'),(817,1,1,22,0,'2015-03-26 17:06:52','1925-06-20 09:20:21',0.0000,0.0000,1,'2015-03-26 14:06:52'),(818,1,1,22,0,'2015-03-26 17:11:52','1949-05-24 06:44:37',0.0000,0.0000,1,'2015-03-26 14:11:52'),(819,1,1,22,0,'2015-03-26 17:21:53','1996-03-08 11:04:53',0.0000,0.0000,1,'2015-03-26 14:21:53'),(820,1,1,22,0,'2015-03-26 17:26:54','2020-02-10 08:29:09',0.0000,0.0000,1,'2015-03-26 14:26:54'),(821,1,1,22,0,'2015-03-27 08:25:17','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-03-27 05:25:17'),(822,1,1,22,0,'2015-03-27 08:30:17','1983-05-03 12:15:17',0.0000,0.0000,1,'2015-03-27 05:30:17'),(823,1,1,22,0,'2015-03-27 08:40:17','2030-02-14 22:23:17',0.0000,0.0000,1,'2015-03-27 05:40:17'),(824,1,1,22,0,'2015-03-27 08:45:18','1918-06-25 17:39:33',0.0000,0.0000,1,'2015-03-27 05:45:18'),(825,1,1,22,0,'2015-03-27 08:55:19','1965-04-09 03:47:33',0.0000,0.0000,1,'2015-03-27 05:55:19'),(826,1,1,22,0,'2015-03-27 09:00:19','1988-08-31 15:03:49',0.0000,0.0000,1,'2015-03-27 06:00:19'),(827,1,1,22,0,'2015-03-27 09:10:20','2036-07-08 09:52:21',0.0000,0.0000,1,'2015-03-27 06:10:20'),(828,1,1,22,0,'2015-03-27 09:15:21','1923-10-24 20:28:05',0.0000,0.0000,1,'2015-03-27 06:15:21'),(829,1,1,22,0,'2015-03-27 09:25:21','1970-08-09 00:48:21',0.0000,0.0000,1,'2015-03-27 06:25:21'),(830,1,1,22,0,'2015-03-27 09:30:21','1993-12-30 17:52:21',0.0000,0.0000,1,'2015-03-27 06:30:21'),(831,1,1,22,0,'2015-03-27 09:40:26','1907-05-06 19:13:25',0.0000,0.0000,1,'2015-03-27 06:40:26'),(832,1,1,22,0,'2015-03-27 09:45:26','1930-09-27 12:17:25',0.0000,0.0000,1,'2015-03-27 06:45:26'),(833,1,1,22,0,'2015-03-27 09:55:26','1977-07-12 16:37:41',0.0000,0.0000,1,'2015-03-27 06:55:26'),(834,1,1,22,0,'2015-03-27 10:00:27','2001-12-26 18:22:13',0.0000,0.0000,1,'2015-03-27 07:00:27'),(835,1,1,22,0,'2015-03-27 10:10:28','1912-09-03 22:01:57',0.0000,0.0000,1,'2015-03-27 07:10:28'),(836,1,1,22,0,'2015-03-27 10:15:28','1936-01-26 15:05:57',0.0000,0.0000,1,'2015-03-27 07:15:28'),(837,1,1,22,0,'2015-03-27 10:25:29','1983-12-04 04:06:45',0.0000,0.0000,1,'2015-03-27 07:25:29'),(838,1,1,22,0,'2015-03-27 10:30:30','2007-04-26 21:10:45',0.0000,0.0000,1,'2015-03-27 07:30:30'),(839,1,1,22,0,'2015-03-27 10:40:30','1918-01-03 00:50:29',0.0000,0.0000,1,'2015-03-27 07:40:30'),(840,1,1,22,0,'2015-03-27 10:45:30','1941-12-06 22:14:45',0.0000,0.0000,1,'2015-03-27 07:45:30'),(841,1,1,22,0,'2015-03-27 10:55:32','1989-04-03 06:55:17',0.0000,0.0000,1,'2015-03-27 07:55:32'),(842,1,1,22,0,'2015-03-27 11:00:32','2012-08-24 23:59:17',0.0000,0.0000,1,'2015-03-27 08:00:32'),(843,1,1,22,0,'2015-03-27 11:10:32','1923-11-14 07:59:17',0.0000,0.0000,1,'2015-03-27 08:10:32'),(844,1,1,22,0,'2015-03-27 11:15:33','1947-10-18 05:23:33',0.0000,0.0000,1,'2015-03-27 08:15:33'),(845,1,1,22,0,'2015-03-27 11:25:34','1994-08-02 09:43:49',0.0000,0.0000,1,'2015-03-27 08:25:34'),(846,1,1,22,0,'2015-03-27 11:30:34','2018-07-06 07:08:05',0.0000,0.0000,1,'2015-03-27 08:30:34'),(847,1,1,22,0,'2015-03-27 11:40:35','1929-09-24 15:08:05',0.0000,0.0000,1,'2015-03-27 08:40:35'),(848,1,1,22,0,'2015-03-27 11:45:36','1953-02-15 08:12:05',0.0000,0.0000,1,'2015-03-27 08:45:36'),(849,1,1,22,0,'2015-03-27 11:55:36','2000-06-12 16:52:37',0.0000,0.0000,1,'2015-03-27 08:55:36'),(850,1,1,22,0,'2015-03-27 12:00:36','2023-11-04 09:56:37',0.0000,0.0000,1,'2015-03-27 09:00:36'),(851,1,1,22,0,'2015-03-27 12:10:38','1935-01-23 17:56:37',0.0000,0.0000,1,'2015-03-27 09:10:38'),(852,1,1,22,0,'2015-03-27 12:15:38','1958-06-16 11:00:37',0.0000,0.0000,1,'2015-03-27 09:15:38'),(853,1,1,22,0,'2015-03-27 12:25:38','2005-10-11 19:41:09',0.0000,0.0000,1,'2015-03-27 09:25:38'),(854,1,1,22,0,'2015-03-27 12:30:39','2029-09-14 17:05:25',0.0000,0.0000,1,'2015-03-27 09:30:39'),(855,1,1,22,0,'2015-03-27 12:40:40','1940-05-23 20:45:09',0.0000,0.0000,1,'2015-03-27 09:40:40'),(856,1,1,22,0,'2015-03-27 12:45:40','1964-04-26 18:09:25',0.0000,0.0000,1,'2015-03-27 09:45:40'),(857,1,1,22,0,'2015-03-27 12:55:41','2011-08-23 02:49:57',0.0000,0.0000,1,'2015-03-27 09:55:41'),(858,1,1,22,0,'2015-03-27 13:00:42','2035-07-27 00:14:13',0.0000,0.0000,1,'2015-03-27 10:00:42'),(859,1,1,22,0,'2015-03-27 13:10:43','1946-10-15 08:14:13',0.0000,0.0000,1,'2015-03-27 10:10:43'),(860,1,1,22,0,'2015-03-27 13:15:43','1970-03-08 19:30:29',0.0000,0.0000,1,'2015-03-27 10:15:43'),(861,1,1,22,0,'2015-03-27 13:25:45','2017-07-03 09:58:45',0.0000,0.0000,1,'2015-03-27 10:25:45'),(862,1,1,22,0,'2015-03-27 13:30:45','1905-05-01 00:54:45',0.0000,0.0000,1,'2015-03-27 10:30:45'),(863,1,1,22,0,'2015-03-27 13:40:45','1952-02-13 11:02:45',0.0000,0.0000,1,'2015-03-27 10:40:45'),(864,1,1,22,0,'2015-03-27 13:45:46','1976-01-18 02:39:17',0.0000,0.0000,1,'2015-03-27 10:45:46'),(865,1,1,22,0,'2015-03-27 13:55:47','2023-05-14 17:07:33',0.0000,0.0000,1,'2015-03-27 10:55:47'),(866,1,1,22,0,'2015-03-27 14:00:47','1910-08-30 03:43:17',0.0000,0.0000,1,'2015-03-27 11:00:47'),(867,1,1,22,0,'2015-03-27 14:10:48','1957-12-24 18:11:33',0.0000,0.0000,1,'2015-03-27 11:10:48'),(868,1,1,22,0,'2015-03-27 14:15:49','1981-05-18 05:27:49',0.0000,0.0000,1,'2015-03-27 11:15:49'),(869,1,1,22,0,'2015-03-27 14:25:49','2028-09-11 19:56:05',0.0000,0.0000,1,'2015-03-27 11:25:49'),(870,1,1,22,0,'2015-03-27 14:30:49','1915-12-29 06:31:49',0.0000,0.0000,1,'2015-03-27 11:30:49'),(871,1,1,22,0,'2015-03-27 14:40:51','1963-04-24 21:00:05',0.0000,0.0000,1,'2015-03-27 11:40:51'),(872,1,1,22,0,'2015-03-27 14:45:51','1987-03-29 12:36:37',0.0000,0.0000,1,'2015-03-27 11:45:51'),(873,1,1,22,0,'2015-03-27 14:55:51','2034-01-10 22:44:37',0.0000,0.0000,1,'2015-03-27 11:55:51'),(874,1,1,22,0,'2015-03-27 15:00:53','1921-11-08 13:40:37',0.0000,0.0000,1,'2015-03-27 12:00:53'),(875,1,1,22,0,'2015-03-27 15:10:53','1969-03-05 04:08:53',0.0000,0.0000,1,'2015-03-27 12:10:53'),(876,1,1,22,0,'2015-03-27 15:15:53','1992-07-27 15:25:09',0.0000,0.0000,1,'2015-03-27 12:15:53'),(877,1,1,22,0,'2015-03-27 15:25:58','1905-05-21 12:25:57',0.0000,0.0000,1,'2015-03-27 12:25:58'),(878,1,1,22,0,'2015-03-27 15:30:58','1928-10-12 05:29:57',0.0000,0.0000,1,'2015-03-27 12:30:58'),(879,1,1,22,0,'2015-03-27 15:40:58','1976-02-07 14:10:29',0.0000,0.0000,1,'2015-03-27 12:40:58'),(880,1,1,22,0,'2015-03-27 15:45:59','1999-07-01 07:14:29',0.0000,0.0000,1,'2015-03-27 12:45:59'),(881,1,1,22,0,'2015-03-27 15:56:00','1910-09-19 15:14:29',0.0000,0.0000,1,'2015-03-27 12:56:00'),(882,1,1,22,0,'2015-03-27 16:01:00','1934-08-23 12:38:45',0.0000,0.0000,1,'2015-03-27 13:01:00'),(883,1,1,22,0,'2015-03-27 16:11:01','1981-06-07 16:59:01',0.0000,0.0000,1,'2015-03-27 13:11:01'),(884,1,1,22,0,'2015-03-27 16:16:02','2005-05-11 14:23:17',0.0000,0.0000,1,'2015-03-27 13:16:02'),(885,1,1,22,0,'2015-03-27 16:26:02','1916-07-30 22:23:17',0.0000,0.0000,1,'2015-03-27 13:26:02'),(886,1,1,22,0,'2015-03-27 16:31:02','1939-12-22 15:27:17',0.0000,0.0000,1,'2015-03-27 13:31:02'),(887,1,1,22,0,'2015-03-27 16:41:04','1987-04-19 00:07:49',0.0000,0.0000,1,'2015-03-27 13:41:04'),(888,1,1,22,0,'2015-03-27 16:46:04','2010-09-09 17:11:49',0.0000,0.0000,1,'2015-03-27 13:46:04'),(889,1,1,22,0,'2015-03-27 16:56:04','1921-11-29 01:11:49',0.0000,0.0000,1,'2015-03-27 13:56:04'),(890,1,1,22,0,'2015-03-27 17:01:05','1945-04-21 18:15:49',0.0000,0.0000,1,'2015-03-27 14:01:05'),(891,1,1,22,0,'2015-03-27 17:11:06','1992-08-17 02:56:21',0.0000,0.0000,1,'2015-03-27 14:11:06'),(892,1,1,22,0,'2015-03-27 17:16:06','2016-07-21 00:20:37',0.0000,0.0000,1,'2015-03-27 14:16:06'),(893,1,1,22,0,'2015-03-27 17:26:07','1927-03-30 04:00:21',0.0000,0.0000,1,'2015-03-27 14:26:07'),(894,1,1,22,0,'2015-03-27 17:31:08','1951-03-03 01:24:37',0.0000,0.0000,1,'2015-03-27 14:31:08'),(895,1,1,22,0,'2015-03-30 10:10:57','1977-12-08 02:56:20',0.0000,0.0000,1,'2015-03-30 06:11:00'),(896,1,1,22,0,'2015-03-30 10:19:49','2006-10-04 02:15:49',0.0000,0.0000,1,'2015-03-30 06:19:52'),(897,1,1,22,0,'2015-03-30 10:31:26','1969-01-05 18:41:25',0.0000,0.0000,1,'2015-03-30 06:31:29'),(898,1,1,22,0,'2015-03-30 10:36:34','1996-08-30 16:39:49',0.0000,0.0000,1,'2015-03-30 06:36:37'),(899,1,1,22,0,'2015-03-30 10:46:49','1915-04-30 13:23:33',0.0000,0.0000,1,'2015-03-30 06:46:52'),(900,1,1,22,0,'2015-03-30 10:52:04','1946-09-11 23:31:33',0.0000,0.0000,1,'2015-03-30 06:52:07'),(901,1,1,22,0,'2015-03-30 11:04:27','1933-12-10 22:01:57',0.0000,0.0000,1,'2015-03-30 07:04:30'),(902,1,1,22,0,'2015-03-30 11:09:42','1965-11-04 12:30:13',0.0000,0.0000,1,'2015-03-30 07:09:45'),(903,1,1,22,0,'2015-03-30 11:36:29','2003-08-09 15:55:01',0.0000,0.0000,1,'2015-03-30 07:36:32'),(904,1,1,22,0,'2015-03-30 11:42:55','1935-07-23 06:53:09',0.0000,0.0000,1,'2015-03-30 07:42:58'),(905,1,1,22,0,'2015-03-30 11:58:05','2011-01-21 23:40:05',0.0000,0.0000,1,'2015-03-30 07:58:08'),(906,1,1,22,0,'2015-03-30 12:02:36','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-03-30 08:02:39'),(907,1,1,22,0,'2015-03-30 12:03:51','1960-11-30 07:18:44',0.0000,0.0000,1,'2015-03-30 08:03:54'),(908,1,1,22,0,'2015-03-30 12:13:18','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-03-30 08:13:21'),(909,1,1,22,0,'2015-03-30 14:32:18','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-03-30 10:32:21'),(910,1,1,22,0,'2015-03-30 17:56:17','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-03-30 13:56:20'),(911,1,1,22,0,'2015-03-31 17:36:25','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-03-31 13:36:28'),(912,1,1,22,0,'2015-03-31 17:41:25','2007-02-21 10:09:25',0.0000,0.0000,1,'2015-03-31 13:41:28'),(913,1,1,22,0,'2015-03-31 17:44:43','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-03-31 13:44:46'),(914,1,1,22,0,'2015-03-31 17:49:43','2000-03-26 14:10:29',0.0000,0.0000,1,'2015-03-31 13:49:46'),(915,1,1,22,0,'2015-03-31 17:52:48','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-03-31 13:52:51'),(916,1,1,22,0,'2015-03-31 17:53:51','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-03-31 13:53:54'),(917,1,1,22,0,'2015-03-31 18:01:21','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-03-31 14:01:24'),(918,1,1,22,0,'2015-03-31 18:06:21','1985-11-20 17:52:21',0.0000,0.0000,1,'2015-03-31 14:06:24'),(919,1,1,22,0,'2015-03-31 18:13:57','1966-10-06 07:01:40',0.0000,0.0000,1,'2015-03-31 14:14:00'),(920,1,1,22,0,'2015-03-31 18:20:36','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-03-31 14:20:39'),(921,1,1,22,0,'2015-03-31 18:24:06','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-03-31 14:24:09'),(922,1,1,22,0,'2015-03-31 18:29:06','2031-08-15 01:56:37',0.0000,0.0000,1,'2015-03-31 14:29:09'),(923,1,1,22,0,'2015-04-01 09:35:24','1967-04-18 11:21:56',0.0000,0.0000,1,'2015-04-01 05:35:27'),(924,1,1,22,0,'2015-04-01 09:40:24','1975-03-07 01:37:25',0.0000,0.0000,1,'2015-04-01 05:40:27'),(925,1,1,22,0,'2015-04-01 09:46:43','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-01 05:46:46'),(926,1,1,22,0,'2015-04-01 09:47:39','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-01 05:47:42'),(927,1,1,22,0,'2015-04-01 09:52:39','1957-08-21 14:53:09',0.0000,0.0000,1,'2015-04-01 05:52:42'),(928,1,1,22,0,'2015-04-01 10:04:47','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-01 06:04:49'),(929,1,1,22,0,'2015-04-01 10:09:47','1959-03-30 04:43:01',0.0000,0.0000,1,'2015-04-01 06:09:50'),(930,1,1,22,0,'2015-04-01 10:19:48','2006-07-25 13:23:33',0.0000,0.0000,1,'2015-04-01 06:19:51'),(931,1,1,22,0,'2015-04-01 10:24:48','2029-12-16 06:27:33',0.0000,0.0000,1,'2015-04-01 06:24:51'),(932,1,1,22,0,'2015-04-01 10:34:49','1941-03-06 14:27:33',0.0000,0.0000,1,'2015-04-01 06:34:52'),(933,1,1,22,0,'2015-04-01 10:39:49','1964-07-28 07:31:33',0.0000,0.0000,1,'2015-04-01 06:39:52'),(934,1,1,22,0,'2015-04-01 10:49:51','2011-11-23 16:12:05',0.0000,0.0000,1,'2015-04-01 06:49:53'),(935,1,1,22,0,'2015-04-01 10:54:51','2036-05-08 17:56:37',0.0000,0.0000,1,'2015-04-01 06:54:54'),(936,1,1,22,0,'2015-04-01 11:04:52','1946-07-05 17:16:05',0.0000,0.0000,1,'2015-04-01 07:04:55'),(937,1,1,22,0,'2015-04-01 11:09:53','1970-06-09 08:52:37',0.0000,0.0000,1,'2015-04-01 07:09:55'),(938,1,1,22,0,'2015-04-01 11:19:53','2017-10-03 23:20:53',0.0000,0.0000,1,'2015-04-01 07:19:56'),(939,1,1,22,0,'2015-04-01 11:24:53','1905-01-19 09:56:37',0.0000,0.0000,1,'2015-04-01 07:24:56'),(940,1,1,22,0,'2015-04-01 11:34:55','1952-11-26 04:45:09',0.0000,0.0000,1,'2015-04-01 07:34:58'),(941,1,1,22,0,'2015-04-01 11:39:55','1976-04-19 16:01:25',0.0000,0.0000,1,'2015-04-01 07:39:58'),(942,1,1,22,0,'2015-04-01 11:49:55','2023-02-02 02:09:25',0.0000,0.0000,1,'2015-04-01 07:49:58'),(943,1,1,22,0,'2015-04-01 11:54:56','1910-05-20 12:45:09',0.0000,0.0000,1,'2015-04-01 07:54:58'),(944,1,1,22,0,'2015-04-01 12:04:56','1957-09-14 03:13:25',0.0000,0.0000,1,'2015-04-01 08:04:59'),(945,1,1,22,0,'2015-04-01 12:09:56','1981-02-05 14:29:41',0.0000,0.0000,1,'2015-04-01 08:09:59'),(946,1,1,22,0,'2015-04-01 12:19:58','2028-12-13 09:18:13',0.0000,0.0000,1,'2015-04-01 08:20:01'),(947,1,1,22,0,'2015-04-01 12:24:58','1916-03-30 19:53:57',0.0000,0.0000,1,'2015-04-01 08:25:01'),(948,1,1,22,0,'2015-04-01 12:34:58','1963-01-13 06:01:57',0.0000,0.0000,1,'2015-04-01 08:35:01'),(949,1,1,22,0,'2015-04-01 12:39:59','1986-12-17 21:38:29',0.0000,0.0000,1,'2015-04-01 08:40:02'),(950,1,1,22,0,'2015-04-01 12:49:59','2033-10-01 07:46:29',0.0000,0.0000,1,'2015-04-01 08:50:02'),(951,1,1,22,0,'2015-04-01 12:54:59','1921-01-16 18:22:13',0.0000,0.0000,1,'2015-04-01 08:55:02'),(952,1,1,22,0,'2015-04-01 13:05:01','1968-11-23 13:10:45',0.0000,0.0000,1,'2015-04-01 09:05:04'),(953,1,1,22,0,'2015-04-01 13:10:02','1992-04-17 00:27:01',0.0000,0.0000,1,'2015-04-01 09:10:05'),(954,1,1,22,0,'2015-04-01 13:20:03','1903-07-07 08:27:01',0.0000,0.0000,1,'2015-04-01 09:20:06'),(955,1,1,22,0,'2015-04-01 13:25:04','1927-12-21 10:11:33',0.0000,0.0000,1,'2015-04-01 09:25:07'),(956,1,1,22,0,'2015-04-01 13:35:04','1974-10-05 14:31:49',0.0000,0.0000,1,'2015-04-01 09:35:07'),(957,1,1,22,0,'2015-04-01 13:40:04','1998-02-26 07:35:49',0.0000,0.0000,1,'2015-04-01 09:40:07'),(958,1,1,22,0,'2015-04-01 13:50:06','1909-11-27 19:56:05',0.0000,0.0000,1,'2015-04-01 09:50:09'),(959,1,1,22,0,'2015-04-01 13:55:06','1933-04-20 13:00:05',0.0000,0.0000,1,'2015-04-01 09:55:09'),(960,1,1,22,0,'2015-04-01 14:05:06','1980-02-03 17:20:21',0.0000,0.0000,1,'2015-04-01 10:05:09'),(961,1,1,22,0,'2015-04-01 14:10:07','2004-01-07 14:44:37',0.0000,0.0000,1,'2015-04-01 10:10:10'),(962,1,1,22,0,'2015-04-01 14:20:07','1914-09-15 18:24:21',0.0000,0.0000,1,'2015-04-01 10:20:10'),(963,1,1,22,0,'2015-04-01 14:25:07','1938-02-06 11:28:21',0.0000,0.0000,1,'2015-04-01 10:25:10'),(964,1,1,22,0,'2015-04-01 14:35:09','1985-06-03 20:13:09',0.0000,0.0000,1,'2015-04-01 10:35:12'),(965,1,1,22,0,'2015-04-01 14:40:09','2008-10-25 13:17:09',0.0000,0.0000,1,'2015-04-01 10:40:12'),(966,1,1,22,0,'2015-04-01 14:50:09','1920-01-14 21:17:09',0.0000,0.0000,1,'2015-04-01 10:50:12'),(967,1,1,22,0,'2015-04-01 14:55:10','1943-06-07 14:21:09',0.0000,0.0000,1,'2015-04-01 10:55:13'),(968,1,1,22,0,'2015-04-01 15:05:10','1990-03-22 18:41:25',0.0000,0.0000,1,'2015-04-01 11:05:13'),(969,1,1,22,0,'2015-04-01 15:10:10','2014-02-23 16:05:41',0.0000,0.0000,1,'2015-04-01 11:10:13'),(970,1,1,22,0,'2015-04-01 15:20:12','1925-05-15 00:05:41',0.0000,0.0000,1,'2015-04-01 11:20:15'),(971,1,1,22,0,'2015-04-01 15:25:12','1948-10-05 17:09:41',0.0000,0.0000,1,'2015-04-01 11:25:15'),(972,1,1,22,0,'2015-04-01 15:35:12','1996-02-01 01:50:13',0.0000,0.0000,1,'2015-04-01 11:35:15'),(973,1,1,22,0,'2015-04-01 15:40:13','2019-06-24 18:54:13',0.0000,0.0000,1,'2015-04-01 11:40:16'),(974,1,1,22,0,'2015-04-01 15:50:13','1930-03-02 22:33:57',0.0000,0.0000,1,'2015-04-01 11:50:16'),(975,1,1,22,0,'2015-04-01 15:55:13','1954-02-03 19:58:13',0.0000,0.0000,1,'2015-04-01 11:55:16'),(976,1,1,22,0,'2015-04-01 16:05:15','2001-06-01 04:38:45',0.0000,0.0000,1,'2015-04-01 12:05:18'),(977,1,1,22,0,'2015-04-01 16:10:15','2024-10-22 21:42:45',0.0000,0.0000,1,'2015-04-01 12:10:18'),(978,1,1,22,0,'2015-04-01 16:20:16','1936-01-12 05:42:45',0.0000,0.0000,1,'2015-04-01 12:20:19'),(979,1,1,22,0,'2015-04-01 16:25:17','1959-12-16 03:07:01',0.0000,0.0000,1,'2015-04-01 12:25:20'),(980,1,1,22,0,'2015-04-01 16:35:17','2006-09-30 07:27:17',0.0000,0.0000,1,'2015-04-01 12:35:20'),(981,1,1,22,0,'2015-04-01 16:40:17','2030-09-03 04:51:33',0.0000,0.0000,1,'2015-04-01 12:40:20'),(982,1,1,22,0,'2015-04-01 16:46:41','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-01 12:46:44'),(983,1,1,22,0,'2015-04-01 16:48:29','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-01 12:48:32'),(984,1,1,22,0,'2015-04-01 16:53:29','1907-05-04 13:06:29',0.0000,0.0000,1,'2015-04-01 12:53:32'),(985,1,1,22,0,'2015-04-01 17:04:01','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-01 13:04:03'),(986,1,1,22,0,'2015-04-01 17:05:20','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-01 13:05:23'),(987,1,1,22,0,'2015-04-01 17:10:20','2015-04-01 17:10:20',0.0000,0.0000,1,'2015-04-01 13:10:23'),(988,1,1,22,0,'2015-04-01 17:20:20','2015-04-01 17:20:20',0.0000,0.0000,1,'2015-04-01 13:20:23'),(989,1,1,22,0,'2015-04-01 17:25:21','2015-04-01 17:25:21',0.0000,0.0000,1,'2015-04-01 13:25:24'),(990,1,1,22,0,'2015-04-01 17:35:21','2015-04-01 17:35:21',0.0000,0.0000,1,'2015-04-01 13:35:24'),(991,1,1,22,0,'2015-04-01 17:40:44','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-01 13:40:47'),(992,1,1,22,0,'2015-04-01 17:45:44','2015-04-01 17:45:45',0.0000,0.0000,1,'2015-04-01 13:45:47'),(993,1,1,22,0,'2015-04-01 17:55:45','2015-04-01 17:55:45',0.0000,0.0000,1,'2015-04-01 13:55:48'),(994,1,1,22,0,'2015-04-01 18:00:45','2015-04-01 18:00:46',0.0000,0.0000,1,'2015-04-01 14:00:48'),(995,1,1,22,0,'2015-04-01 18:10:46','2015-04-01 18:10:46',0.0000,0.0000,1,'2015-04-01 14:10:48'),(996,1,1,22,0,'2015-04-01 18:15:46','2015-04-01 18:15:46',0.0000,0.0000,1,'2015-04-01 14:15:49'),(997,1,1,22,0,'2015-04-01 18:25:47','2015-04-01 18:25:47',0.0000,0.0000,1,'2015-04-01 14:25:50'),(998,1,1,26,0,'2015-04-02 11:49:35','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-02 07:49:38'),(999,1,1,26,0,'2015-04-02 11:54:35','2015-04-02 11:54:36',0.0000,0.0000,1,'2015-04-02 07:54:38'),(1000,1,1,26,0,'2015-04-02 12:04:35','2015-04-02 12:04:36',0.0000,0.0000,1,'2015-04-02 08:04:38'),(1001,1,1,26,0,'2015-04-02 12:09:36','2015-04-02 12:09:37',0.0000,0.0000,1,'2015-04-02 08:09:39'),(1002,1,1,26,0,'2015-04-02 12:19:37','2015-04-02 12:19:37',0.0000,0.0000,1,'2015-04-02 08:19:40'),(1003,1,1,26,0,'2015-04-02 12:24:37','2015-04-02 12:24:38',0.0000,0.0000,1,'2015-04-02 08:24:40'),(1004,1,1,26,0,'2015-04-02 12:34:38','2015-04-02 12:34:39',0.0000,0.0000,1,'2015-04-02 08:34:41'),(1005,1,1,26,0,'2015-04-02 12:39:39','2015-04-02 12:39:39',0.0000,0.0000,1,'2015-04-02 08:39:42'),(1006,1,1,26,0,'2015-04-02 12:49:40','2015-04-02 12:49:40',0.0000,0.0000,1,'2015-04-02 08:49:43'),(1007,1,1,26,0,'2015-04-02 12:54:40','2015-04-02 12:54:40',0.0000,0.0000,1,'2015-04-02 08:54:43'),(1008,1,1,26,0,'2015-04-02 13:04:42','2015-04-02 13:04:42',0.0000,0.0000,1,'2015-04-02 09:04:45'),(1009,1,1,26,0,'2015-04-02 13:09:42','2015-04-02 13:09:42',0.0000,0.0000,1,'2015-04-02 09:09:45'),(1010,1,1,26,0,'2015-04-02 13:19:43','2015-04-02 13:19:42',0.0000,0.0000,1,'2015-04-02 09:19:46'),(1011,1,1,26,0,'2015-04-02 13:24:44','2015-04-02 13:24:44',0.0000,0.0000,1,'2015-04-02 09:24:47'),(1012,1,1,26,0,'2015-04-02 13:34:45','2015-04-02 13:34:45',0.0000,0.0000,1,'2015-04-02 09:34:47'),(1013,1,1,26,0,'2015-04-02 13:39:46','2015-04-02 13:39:45',0.0000,0.0000,1,'2015-04-02 09:39:48'),(1014,1,1,26,0,'2015-04-02 13:49:48','2015-04-02 13:49:48',0.0000,0.0000,1,'2015-04-02 09:49:51'),(1015,1,1,26,0,'2015-04-02 13:54:49','2015-04-02 13:54:49',0.0000,0.0000,1,'2015-04-02 09:54:52'),(1016,1,1,26,0,'2015-04-02 14:04:56','2015-04-02 14:04:56',0.0000,0.0000,1,'2015-04-02 10:04:59'),(1017,1,1,26,0,'2015-04-02 14:09:56','2015-04-02 14:09:56',0.0000,0.0000,1,'2015-04-02 10:09:59'),(1018,1,1,26,0,'2015-04-02 14:19:58','2015-04-02 14:19:58',0.0000,0.0000,1,'2015-04-02 10:20:01'),(1019,1,1,26,0,'2015-04-02 14:24:59','2015-04-02 14:24:59',0.0000,0.0000,1,'2015-04-02 10:25:02'),(1020,1,1,26,0,'2015-04-02 14:34:59','2015-04-02 14:35:00',0.0000,0.0000,1,'2015-04-02 10:35:02'),(1021,1,1,26,0,'2015-04-02 14:40:00','2015-04-02 14:40:01',0.0000,0.0000,1,'2015-04-02 10:40:03'),(1022,1,1,26,0,'2015-04-02 14:50:01','2015-04-02 14:50:01',0.0000,0.0000,1,'2015-04-02 10:50:04'),(1023,1,1,26,0,'2015-04-02 14:55:01','2015-04-02 14:55:01',0.0000,0.0000,1,'2015-04-02 10:55:04'),(1024,1,1,26,0,'2015-04-02 15:05:02','2015-04-02 15:05:02',0.0000,0.0000,1,'2015-04-02 11:05:05'),(1025,1,1,26,0,'2015-04-02 15:10:03','2015-04-02 15:10:02',0.0000,0.0000,1,'2015-04-02 11:10:06'),(1026,1,1,26,0,'2015-04-02 15:20:04','2015-04-02 15:20:04',0.0000,0.0000,1,'2015-04-02 11:20:07'),(1027,1,1,26,0,'2015-04-02 15:25:04','2015-04-02 15:25:04',0.0000,0.0000,1,'2015-04-02 11:25:07'),(1028,1,1,26,0,'2015-04-02 15:33:57','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-02 11:34:00'),(1029,1,1,26,0,'2015-04-02 15:38:57','2015-04-02 15:38:57',0.0000,0.0000,1,'2015-04-02 11:39:00'),(1030,1,1,26,0,'2015-04-02 15:48:57','2015-04-02 15:48:57',0.0000,0.0000,1,'2015-04-02 11:49:00'),(1031,1,1,26,0,'2015-04-02 15:53:58','2015-04-02 15:53:58',0.0000,0.0000,1,'2015-04-02 11:54:01'),(1032,1,1,26,0,'2015-04-02 16:04:01','2015-04-02 16:04:01',0.0000,0.0000,1,'2015-04-02 12:04:04'),(1033,1,1,26,0,'2015-04-02 16:09:04','2015-04-02 16:09:05',0.0000,0.0000,1,'2015-04-02 12:09:07'),(1034,1,1,26,0,'2015-04-02 16:19:09','2015-04-02 16:19:09',0.0000,0.0000,1,'2015-04-02 12:19:12'),(1035,1,1,26,0,'2015-04-02 16:24:10','2015-04-02 16:24:10',0.0000,0.0000,1,'2015-04-02 12:24:13'),(1036,1,1,26,0,'2015-04-02 16:34:10','2015-04-02 16:34:11',0.0000,0.0000,1,'2015-04-02 12:34:13'),(1037,1,1,26,0,'2015-04-02 16:39:12','2015-04-02 16:39:12',0.0000,0.0000,1,'2015-04-02 12:39:15'),(1038,1,1,26,0,'2015-04-02 16:45:33','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-02 12:45:36'),(1039,1,1,26,0,'2015-04-02 16:50:33','2015-04-02 16:50:33',0.0000,0.0000,1,'2015-04-02 12:50:36'),(1040,1,1,26,0,'2015-04-02 17:00:34','2015-04-02 17:00:34',0.0000,0.0000,1,'2015-04-02 13:00:37'),(1041,1,1,26,0,'2015-04-02 17:05:35','2015-04-02 17:05:36',0.0000,0.0000,1,'2015-04-02 13:05:38'),(1042,1,1,26,0,'2015-04-02 17:15:36','2015-04-02 17:15:36',0.0000,0.0000,1,'2015-04-02 13:15:39'),(1043,1,1,26,0,'2015-04-02 17:20:37','2015-04-02 17:20:37',0.0000,0.0000,1,'2015-04-02 13:20:40'),(1044,1,1,26,0,'2015-04-02 17:30:39','2015-04-02 17:30:39',0.0000,0.0000,1,'2015-04-02 13:30:42'),(1045,1,1,26,0,'2015-04-02 17:35:40','2015-04-02 17:35:39',0.0000,0.0000,1,'2015-04-02 13:35:43'),(1046,1,1,26,0,'2015-04-02 17:45:43','2015-04-02 17:45:43',0.0000,0.0000,1,'2015-04-02 13:45:46'),(1047,1,1,26,0,'2015-04-02 17:50:44','2015-04-02 17:50:44',0.0000,0.0000,1,'2015-04-02 13:50:47'),(1048,1,1,26,0,'2015-04-02 18:00:44','2015-04-02 18:00:44',0.0000,0.0000,1,'2015-04-02 14:00:47'),(1049,1,1,26,0,'2015-04-02 18:05:44','2015-04-02 18:05:45',0.0000,0.0000,1,'2015-04-02 14:05:47'),(1050,1,1,26,0,'2015-04-02 18:15:45','2015-04-02 18:15:46',0.0000,0.0000,1,'2015-04-02 14:15:48'),(1051,1,1,26,0,'2015-04-02 18:20:46','2015-04-02 18:20:47',0.0000,0.0000,1,'2015-04-02 14:20:49'),(1052,1,1,26,0,'2015-04-03 09:24:52','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-03 05:24:55'),(1053,1,1,26,0,'2015-04-03 09:29:52','2015-04-03 09:29:53',0.0000,0.0000,1,'2015-04-03 05:29:55'),(1054,1,1,26,0,'2015-04-03 09:39:52','2015-04-03 09:39:53',0.0000,0.0000,1,'2015-04-03 05:39:55'),(1055,1,1,26,0,'2015-04-03 09:44:53','2015-04-03 09:44:54',0.0000,0.0000,1,'2015-04-03 05:44:56'),(1056,1,1,26,0,'2015-04-03 09:54:54','2015-04-03 09:54:54',0.0000,0.0000,1,'2015-04-03 05:54:57'),(1057,1,1,26,0,'2015-04-03 09:59:54','2015-04-03 09:59:54',0.0000,0.0000,1,'2015-04-03 05:59:57'),(1058,1,1,26,0,'2015-04-03 10:09:55','2015-04-03 10:09:56',0.0000,0.0000,1,'2015-04-03 06:09:58'),(1059,1,1,26,0,'2015-04-03 10:14:56','2015-04-03 10:14:56',0.0000,0.0000,1,'2015-04-03 06:14:59'),(1060,1,1,26,0,'2015-04-03 10:24:56','2015-04-03 10:24:56',0.0000,0.0000,1,'2015-04-03 06:24:59'),(1061,1,1,26,0,'2015-04-03 10:29:56','2015-04-03 10:29:56',0.0000,0.0000,1,'2015-04-03 06:29:59'),(1062,1,1,26,0,'2015-04-03 10:39:57','2015-04-03 10:39:57',0.0000,0.0000,1,'2015-04-03 06:40:00'),(1063,1,1,26,0,'2015-04-03 10:44:58','2015-04-03 10:44:58',0.0000,0.0000,1,'2015-04-03 06:45:00'),(1064,1,1,26,0,'2015-04-03 10:54:58','2015-04-03 10:54:58',0.0000,0.0000,1,'2015-04-03 06:55:01'),(1065,1,1,26,0,'2015-04-03 10:59:59','2015-04-03 10:59:59',0.0000,0.0000,1,'2015-04-03 07:00:02'),(1066,1,1,26,0,'2015-04-03 11:09:59','2015-04-03 11:10:00',0.0000,0.0000,1,'2015-04-03 07:10:02'),(1067,1,1,26,0,'2015-04-03 11:14:59','2015-04-03 11:15:00',0.0000,0.0000,1,'2015-04-03 07:15:02'),(1068,1,1,26,0,'2015-04-03 11:25:00','2015-04-03 11:25:01',0.0000,0.0000,1,'2015-04-03 07:25:03'),(1069,1,1,26,0,'2015-04-03 11:30:01','2015-04-03 11:30:01',0.0000,0.0000,1,'2015-04-03 07:30:04'),(1070,1,1,26,0,'2015-04-03 11:40:01','2015-04-03 11:40:02',0.0000,0.0000,1,'2015-04-03 07:40:04'),(1071,1,1,26,0,'2015-04-03 11:45:01','2015-04-03 11:45:02',0.0000,0.0000,1,'2015-04-03 07:45:04'),(1072,1,1,26,0,'2015-04-03 11:55:03','2015-04-03 11:55:03',0.0000,0.0000,1,'2015-04-03 07:55:06'),(1073,1,1,26,0,'2015-04-03 12:00:03','2015-04-03 12:00:03',0.0000,0.0000,1,'2015-04-03 08:00:06'),(1074,1,1,26,0,'2015-04-03 12:10:03','2015-04-03 12:10:03',0.0000,0.0000,1,'2015-04-03 08:10:06'),(1075,1,1,26,0,'2015-04-03 12:15:04','2015-04-03 12:15:04',0.0000,0.0000,1,'2015-04-03 08:15:07'),(1076,1,1,26,0,'2015-04-03 12:25:05','2015-04-03 12:25:05',0.0000,0.0000,1,'2015-04-03 08:25:08'),(1077,1,1,26,0,'2015-04-03 12:30:05','2015-04-03 12:30:05',0.0000,0.0000,1,'2015-04-03 08:30:08'),(1078,1,1,26,0,'2015-04-03 12:40:06','2015-04-03 12:40:06',0.0000,0.0000,1,'2015-04-03 08:40:09'),(1079,1,1,26,0,'2015-04-03 12:45:06','2015-04-03 12:45:06',0.0000,0.0000,1,'2015-04-03 08:45:09'),(1080,1,1,26,0,'2015-04-03 12:55:06','2015-04-03 12:55:07',0.0000,0.0000,1,'2015-04-03 08:55:09'),(1081,1,1,26,0,'2015-04-03 13:00:07','2015-04-03 13:00:08',0.0000,0.0000,1,'2015-04-03 09:00:10'),(1082,1,1,26,0,'2015-04-03 13:10:08','2015-04-03 13:10:08',0.0000,0.0000,1,'2015-04-03 09:10:11'),(1083,1,1,26,0,'2015-04-03 13:15:08','2015-04-03 13:15:09',0.0000,0.0000,1,'2015-04-03 09:15:11'),(1084,1,1,26,0,'2015-04-03 13:25:09','2015-04-03 13:25:10',0.0000,0.0000,1,'2015-04-03 09:25:12'),(1085,1,1,26,0,'2015-04-03 13:30:10','2015-04-03 13:30:11',0.0000,0.0000,1,'2015-04-03 09:30:13'),(1086,1,1,26,0,'2015-04-03 13:40:12','2015-04-03 13:40:12',0.0000,0.0000,1,'2015-04-03 09:40:15'),(1087,1,1,26,0,'2015-04-03 13:45:12','2015-04-03 13:45:13',0.0000,0.0000,1,'2015-04-03 09:45:15'),(1088,1,1,26,0,'2015-04-03 13:55:13','2015-04-03 13:55:14',0.0000,0.0000,1,'2015-04-03 09:55:16'),(1089,1,1,26,0,'2015-04-03 14:00:14','2015-04-03 14:00:14',0.0000,0.0000,1,'2015-04-03 10:00:17'),(1090,1,1,26,0,'2015-04-03 14:10:14','2015-04-03 14:10:14',0.0000,0.0000,1,'2015-04-03 10:10:17'),(1091,1,1,26,0,'2015-04-03 14:15:14','2015-04-03 14:15:14',0.0000,0.0000,1,'2015-04-03 10:15:17'),(1092,1,1,26,0,'2015-04-03 14:25:16','2015-04-03 14:25:15',0.0000,0.0000,1,'2015-04-03 10:25:18'),(1093,1,1,26,0,'2015-04-03 14:30:16','2015-04-03 14:30:16',0.0000,0.0000,1,'2015-04-03 10:30:19'),(1094,1,1,26,0,'2015-04-03 14:40:16','2015-04-03 14:40:16',0.0000,0.0000,1,'2015-04-03 10:40:19'),(1095,1,1,26,0,'2015-04-03 14:45:17','2015-04-03 14:45:17',0.0000,0.0000,1,'2015-04-03 10:45:20'),(1096,1,1,26,0,'2015-04-03 14:55:18','2015-04-03 14:55:18',0.0000,0.0000,1,'2015-04-03 10:55:21'),(1097,1,1,26,0,'2015-04-03 15:00:18','2015-04-03 15:00:19',0.0000,0.0000,1,'2015-04-03 11:00:21'),(1098,1,1,26,0,'2015-04-03 15:10:20','2015-04-03 15:10:20',0.0000,0.0000,1,'2015-04-03 11:10:22'),(1099,1,1,26,0,'2015-04-03 15:15:20','2015-04-03 15:15:20',0.0000,0.0000,1,'2015-04-03 11:15:23'),(1100,1,1,26,0,'2015-04-03 15:25:20','2015-04-03 15:25:21',0.0000,0.0000,1,'2015-04-03 11:25:23'),(1101,1,1,26,0,'2015-04-03 15:30:20','2015-04-03 15:30:21',0.0000,0.0000,1,'2015-04-03 11:30:23'),(1102,1,1,26,0,'2015-04-03 15:40:22','2015-04-03 15:40:22',0.0000,0.0000,1,'2015-04-03 11:40:25'),(1103,1,1,26,0,'2015-04-03 15:45:22','2015-04-03 15:45:22',0.0000,0.0000,1,'2015-04-03 11:45:25'),(1104,1,1,26,0,'2015-04-03 15:55:22','2015-04-03 15:55:23',0.0000,0.0000,1,'2015-04-03 11:55:25'),(1105,1,1,26,0,'2015-04-03 16:00:23','2015-04-03 16:00:24',0.0000,0.0000,1,'2015-04-03 12:00:26'),(1106,1,1,26,0,'2015-04-03 16:10:24','2015-04-03 16:10:24',0.0000,0.0000,1,'2015-04-03 12:10:27'),(1107,1,1,26,0,'2015-04-03 16:15:25','2015-04-03 16:15:24',0.0000,0.0000,1,'2015-04-03 12:15:28'),(1108,1,1,26,0,'2015-04-03 16:25:26','2015-04-03 16:25:26',0.0000,0.0000,1,'2015-04-03 12:25:29'),(1109,1,1,26,0,'2015-04-03 16:30:26','2015-04-03 16:30:26',0.0000,0.0000,1,'2015-04-03 12:30:29'),(1110,1,1,26,0,'2015-04-03 16:40:27','2015-04-03 16:40:27',0.0000,0.0000,1,'2015-04-03 12:40:30'),(1111,1,1,26,0,'2015-04-03 16:45:27','2015-04-03 16:45:27',0.0000,0.0000,1,'2015-04-03 12:45:30'),(1112,1,1,26,0,'2015-04-03 16:55:28','2015-04-03 16:55:28',0.0000,0.0000,1,'2015-04-03 12:55:31'),(1113,1,1,26,0,'2015-04-03 17:00:28','2015-04-03 17:00:29',0.0000,0.0000,1,'2015-04-03 13:00:31'),(1114,1,1,26,0,'2015-04-03 17:08:03','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-03 13:08:06'),(1115,1,1,26,0,'2015-04-03 17:13:03','2015-04-03 17:13:04',0.0000,0.0000,1,'2015-04-03 13:13:06'),(1116,1,1,26,0,'2015-04-03 17:23:03','2015-04-03 17:23:04',0.0000,0.0000,1,'2015-04-03 13:23:06'),(1117,1,1,26,0,'2015-04-03 17:28:04','2015-04-03 17:28:05',0.0000,0.0000,1,'2015-04-03 13:28:07'),(1118,1,1,26,0,'2015-04-03 17:38:05','2015-04-03 17:38:05',0.0000,0.0000,1,'2015-04-03 13:38:08'),(1119,1,1,26,0,'2015-04-03 17:43:05','2015-04-03 17:43:05',0.0000,0.0000,1,'2015-04-03 13:43:08'),(1120,1,1,26,0,'2015-04-03 17:53:06','2015-04-03 17:53:07',0.0000,0.0000,1,'2015-04-03 13:53:09'),(1121,1,1,26,0,'2015-04-03 17:58:07','2015-04-03 17:58:07',0.0000,0.0000,1,'2015-04-03 13:58:10'),(1122,1,1,26,0,'2015-04-03 18:08:07','2015-04-03 18:08:07',0.0000,0.0000,1,'2015-04-03 14:08:10'),(1123,1,1,26,0,'2015-04-03 18:13:08','2015-04-03 18:13:07',0.0000,0.0000,1,'2015-04-03 14:13:11'),(1124,1,1,26,0,'2015-04-03 18:23:09','2015-04-03 18:23:09',0.0000,0.0000,1,'2015-04-03 14:23:12'),(1125,1,1,26,0,'2015-04-03 18:28:10','2015-04-03 18:28:10',0.0000,0.0000,1,'2015-04-03 14:28:12'),(1126,1,1,26,0,'2015-04-06 09:19:53','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-06 05:19:59'),(1127,1,1,26,0,'2015-04-06 09:24:53','2015-04-06 09:24:54',0.0000,0.0000,1,'2015-04-06 05:24:59'),(1128,1,1,26,0,'2015-04-06 09:34:53','2015-04-06 09:34:54',0.0000,0.0000,1,'2015-04-06 05:34:59'),(1129,1,1,26,0,'2015-04-06 09:39:54','2015-04-06 09:39:55',0.0000,0.0000,1,'2015-04-06 05:40:00'),(1130,1,1,26,0,'2015-04-06 09:49:55','2015-04-06 09:49:56',0.0000,0.0000,1,'2015-04-06 05:50:00'),(1131,1,1,26,0,'2015-04-06 09:54:55','2015-04-06 09:54:56',0.0000,0.0000,1,'2015-04-06 05:55:01'),(1132,1,1,26,0,'2015-04-06 10:04:56','2015-04-06 10:04:57',0.0000,0.0000,1,'2015-04-06 06:05:02'),(1133,1,1,26,0,'2015-04-06 10:09:57','2015-04-06 10:09:57',0.0000,0.0000,1,'2015-04-06 06:10:02'),(1134,1,1,26,0,'2015-04-06 10:19:57','2015-04-06 10:19:57',0.0000,0.0000,1,'2015-04-06 06:20:02'),(1135,1,1,26,0,'2015-04-06 10:24:57','2015-04-06 10:24:57',0.0000,0.0000,1,'2015-04-06 06:25:02'),(1136,1,1,26,0,'2015-04-06 10:34:59','2015-04-06 10:34:59',0.0000,0.0000,1,'2015-04-06 06:35:04'),(1137,1,1,26,0,'2015-04-06 10:39:59','2015-04-06 10:39:59',0.0000,0.0000,1,'2015-04-06 06:40:04'),(1138,1,1,26,0,'2015-04-06 10:49:59','2015-04-06 10:49:59',0.0000,0.0000,1,'2015-04-06 06:50:04'),(1139,1,1,26,0,'2015-04-06 10:55:00','2015-04-06 10:55:00',0.0000,0.0000,1,'2015-04-06 06:55:05'),(1140,1,1,26,0,'2015-04-06 11:05:00','2015-04-06 11:05:01',0.0000,0.0000,1,'2015-04-06 07:05:06'),(1141,1,1,26,0,'2015-04-06 11:10:01','2015-04-06 11:10:01',0.0000,0.0000,1,'2015-04-06 07:10:06'),(1142,1,1,26,0,'2015-04-06 11:20:02','2015-04-06 11:20:02',0.0000,0.0000,1,'2015-04-06 07:20:07'),(1143,1,1,26,0,'2015-04-06 11:25:02','2015-04-06 11:25:02',0.0000,0.0000,1,'2015-04-06 07:25:08'),(1144,1,1,26,0,'2015-04-06 11:35:02','2015-04-06 11:35:03',0.0000,0.0000,1,'2015-04-06 07:35:08'),(1145,1,1,26,0,'2015-04-06 11:40:02','2015-04-06 11:40:03',0.0000,0.0000,1,'2015-04-06 07:40:08'),(1146,1,1,26,0,'2015-04-06 11:50:04','2015-04-06 11:50:04',0.0000,0.0000,1,'2015-04-06 07:50:09'),(1147,1,1,26,0,'2015-04-06 11:55:04','2015-04-06 11:55:04',0.0000,0.0000,1,'2015-04-06 07:55:09'),(1148,1,1,26,0,'2015-04-06 12:05:04','2015-04-06 12:05:05',0.0000,0.0000,1,'2015-04-06 08:05:10'),(1149,1,1,26,0,'2015-04-06 12:10:05','2015-04-06 12:10:06',0.0000,0.0000,1,'2015-04-06 08:10:11'),(1150,1,1,26,0,'2015-04-06 12:20:06','2015-04-06 12:20:06',0.0000,0.0000,1,'2015-04-06 08:20:11'),(1151,1,1,26,0,'2015-04-06 12:25:06','2015-04-06 12:25:06',0.0000,0.0000,1,'2015-04-06 08:25:11'),(1152,1,1,26,0,'2015-04-06 12:35:07','2015-04-06 12:35:07',0.0000,0.0000,1,'2015-04-06 08:35:12'),(1153,1,1,26,0,'2015-04-06 12:40:08','2015-04-06 12:40:08',0.0000,0.0000,1,'2015-04-06 08:40:13'),(1154,1,1,26,0,'2015-04-06 12:50:08','2015-04-06 12:50:08',0.0000,0.0000,1,'2015-04-06 08:50:13'),(1155,1,1,26,0,'2015-04-06 12:55:08','2015-04-06 12:55:08',0.0000,0.0000,1,'2015-04-06 08:55:13'),(1156,1,1,26,0,'2015-04-06 13:05:09','2015-04-06 13:05:09',0.0000,0.0000,1,'2015-04-06 09:05:15'),(1157,1,1,26,0,'2015-04-06 13:10:09','2015-04-06 13:10:10',0.0000,0.0000,1,'2015-04-06 09:10:15'),(1158,1,1,26,0,'2015-04-06 13:20:10','2015-04-06 13:20:10',0.0000,0.0000,1,'2015-04-06 09:20:15'),(1159,1,1,26,0,'2015-04-06 13:25:11','2015-04-06 13:25:11',0.0000,0.0000,1,'2015-04-06 09:25:16'),(1160,1,1,26,0,'2015-04-06 13:35:11','2015-04-06 13:35:12',0.0000,0.0000,1,'2015-04-06 09:35:17'),(1161,1,1,26,0,'2015-04-06 13:40:12','2015-04-06 13:40:12',0.0000,0.0000,1,'2015-04-06 09:40:18'),(1162,1,1,26,0,'2015-04-06 13:50:13','2015-04-06 13:50:14',0.0000,0.0000,1,'2015-04-06 09:50:19'),(1163,1,1,26,0,'2015-04-06 13:55:14','2015-04-06 13:55:14',0.0000,0.0000,1,'2015-04-06 09:55:19'),(1164,1,1,26,0,'2015-04-06 14:05:14','2015-04-06 14:05:14',0.0000,0.0000,1,'2015-04-06 10:05:19'),(1165,1,1,26,0,'2015-04-06 14:10:14','2015-04-06 14:10:15',0.0000,0.0000,1,'2015-04-06 10:10:19'),(1166,1,1,26,0,'2015-04-06 14:20:16','2015-04-06 14:20:16',0.0000,0.0000,1,'2015-04-06 10:20:21'),(1167,1,1,26,0,'2015-04-06 14:25:16','2015-04-06 14:25:16',0.0000,0.0000,1,'2015-04-06 10:25:21'),(1168,1,1,26,0,'2015-04-06 14:35:16','2015-04-06 14:35:16',0.0000,0.0000,1,'2015-04-06 10:35:21'),(1169,1,1,26,0,'2015-04-06 14:40:17','2015-04-06 14:40:17',0.0000,0.0000,1,'2015-04-06 10:40:22'),(1170,1,1,26,0,'2015-04-06 14:50:18','2015-04-06 14:50:18',0.0000,0.0000,1,'2015-04-06 10:50:23'),(1171,1,1,26,0,'2015-04-06 14:55:18','2015-04-06 14:55:18',0.0000,0.0000,1,'2015-04-06 10:55:23'),(1172,1,1,26,0,'2015-04-06 15:05:19','2015-04-06 15:05:19',0.0000,0.0000,1,'2015-04-06 11:05:24'),(1173,1,1,26,0,'2015-04-06 15:10:19','2015-04-06 15:10:19',0.0000,0.0000,1,'2015-04-06 11:10:25'),(1174,1,1,26,0,'2015-04-06 15:20:19','2015-04-06 15:20:20',0.0000,0.0000,1,'2015-04-06 11:20:25'),(1175,1,1,26,0,'2015-04-06 15:25:19','2015-04-06 15:25:20',0.0000,0.0000,1,'2015-04-06 11:25:25'),(1176,1,1,26,0,'2015-04-06 15:35:21','2015-04-06 15:35:21',0.0000,0.0000,1,'2015-04-06 11:35:26'),(1177,1,1,26,0,'2015-04-06 15:40:21','2015-04-06 15:40:22',0.0000,0.0000,1,'2015-04-06 11:40:26'),(1178,1,1,26,0,'2015-04-06 15:50:21','2015-04-06 15:50:22',0.0000,0.0000,1,'2015-04-06 11:50:27'),(1179,1,1,26,0,'2015-04-06 15:55:22','2015-04-06 15:55:23',0.0000,0.0000,1,'2015-04-06 11:55:28'),(1180,1,1,26,0,'2015-04-06 16:05:23','2015-04-06 16:05:23',0.0000,0.0000,1,'2015-04-06 12:05:28'),(1181,1,1,26,0,'2015-04-06 16:10:23','2015-04-06 16:10:23',0.0000,0.0000,1,'2015-04-06 12:10:28'),(1182,1,1,26,0,'2015-04-06 16:20:24','2015-04-06 16:20:25',0.0000,0.0000,1,'2015-04-06 12:20:29'),(1183,1,1,26,0,'2015-04-06 16:25:25','2015-04-06 16:25:25',0.0000,0.0000,1,'2015-04-06 12:25:30'),(1184,1,1,26,0,'2015-04-06 16:35:25','2015-04-06 16:35:25',0.0000,0.0000,1,'2015-04-06 12:35:30'),(1185,1,1,26,0,'2015-04-06 16:40:26','2015-04-06 16:40:25',0.0000,0.0000,1,'2015-04-06 12:40:31'),(1186,1,1,26,0,'2015-04-06 16:50:28','2015-04-06 16:50:27',0.0000,0.0000,1,'2015-04-06 12:50:33'),(1187,1,1,26,0,'2015-04-06 16:55:28','2015-04-06 16:55:28',0.0000,0.0000,1,'2015-04-06 12:55:34'),(1188,1,1,26,0,'2015-04-06 17:05:29','2015-04-06 17:05:29',0.0000,0.0000,1,'2015-04-06 13:05:34'),(1189,1,1,26,0,'2015-04-06 17:10:30','2015-04-06 17:10:30',0.0000,0.0000,1,'2015-04-06 13:10:35'),(1190,1,1,26,0,'2015-04-06 17:20:30','2015-04-06 17:20:31',0.0000,0.0000,1,'2015-04-06 13:20:36'),(1191,1,1,26,0,'2015-04-06 17:25:30','2015-04-06 17:25:31',0.0000,0.0000,1,'2015-04-06 13:25:36'),(1192,1,1,26,0,'2015-04-06 17:35:31','2015-04-06 17:35:32',0.0000,0.0000,1,'2015-04-06 13:35:37'),(1193,1,1,26,0,'2015-04-06 17:40:32','2015-04-06 17:40:32',0.0000,0.0000,1,'2015-04-06 13:40:37'),(1194,1,1,26,0,'2015-04-06 17:50:32','2015-04-06 17:50:33',0.0000,0.0000,1,'2015-04-06 13:50:37'),(1195,1,1,26,0,'2015-04-06 17:55:32','2015-04-06 17:55:33',0.0000,0.0000,1,'2015-04-06 13:55:38'),(1196,1,1,26,0,'2015-04-06 18:05:34','2015-04-06 18:05:34',0.0000,0.0000,1,'2015-04-06 14:05:39'),(1197,1,1,26,0,'2015-04-06 18:10:34','2015-04-06 18:10:34',0.0000,0.0000,1,'2015-04-06 14:10:39'),(1198,1,1,26,0,'2015-04-06 18:20:34','2015-04-06 18:20:34',0.0000,0.0000,1,'2015-04-06 14:20:39'),(1199,1,1,26,0,'2015-04-06 18:25:35','2015-04-06 18:25:35',0.0000,0.0000,1,'2015-04-06 14:25:40'),(1200,1,1,26,0,'2015-04-06 18:35:36','2015-04-06 18:35:36',0.0000,0.0000,1,'2015-04-06 14:35:41'),(1201,1,1,26,0,'2015-04-07 09:29:12','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-07 05:29:17'),(1202,1,1,26,0,'2015-04-07 09:34:12','2015-04-07 09:34:12',0.0000,0.0000,1,'2015-04-07 05:34:17'),(1203,1,1,26,0,'2015-04-07 09:44:12','2015-04-07 09:44:13',0.0000,0.0000,1,'2015-04-07 05:44:17'),(1204,1,1,26,0,'2015-04-07 09:49:13','2015-04-07 09:49:14',0.0000,0.0000,1,'2015-04-07 05:49:19'),(1205,1,1,26,0,'2015-04-07 09:59:14','2015-04-07 09:59:14',0.0000,0.0000,1,'2015-04-07 05:59:19'),(1206,1,1,26,0,'2015-04-07 10:04:14','2015-04-07 10:04:14',0.0000,0.0000,1,'2015-04-07 06:04:19'),(1207,1,1,26,0,'2015-04-07 10:14:15','2015-04-07 10:14:15',0.0000,0.0000,1,'2015-04-07 06:14:20'),(1208,1,1,26,0,'2015-04-07 10:19:16','2015-04-07 10:19:15',0.0000,0.0000,1,'2015-04-07 06:19:21'),(1209,1,1,26,0,'2015-04-07 10:29:16','2015-04-07 10:29:16',0.0000,0.0000,1,'2015-04-07 06:29:21'),(1210,1,1,26,0,'2015-04-07 10:34:16','2015-04-07 10:34:16',0.0000,0.0000,1,'2015-04-07 06:34:21'),(1211,1,1,27,0,'2015-04-07 10:38:30','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-07 06:38:35'),(1212,1,1,27,0,'2015-04-07 10:43:30','2015-04-07 10:43:30',0.0000,0.0000,1,'2015-04-07 06:43:35'),(1213,1,1,27,0,'2015-04-07 10:53:31','2015-04-07 10:53:31',0.0000,0.0000,1,'2015-04-07 06:53:36'),(1214,1,1,27,0,'2015-04-07 10:58:31','2015-04-07 10:58:31',0.0000,0.0000,1,'2015-04-07 06:58:36'),(1215,1,1,27,0,'2015-04-07 11:07:36','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-07 07:07:41'),(1216,1,1,27,0,'2015-04-07 11:12:36','2015-04-07 11:12:36',0.0000,0.0000,1,'2015-04-07 07:12:42'),(1217,1,1,27,0,'2015-04-07 11:22:38','2015-04-07 11:22:38',0.0000,0.0000,1,'2015-04-07 07:22:43'),(1218,1,1,27,0,'2015-04-07 11:27:39','2015-04-07 11:27:39',0.0000,0.0000,1,'2015-04-07 07:27:44'),(1219,1,1,27,0,'2015-04-07 11:37:39','2015-04-07 11:37:39',0.0000,0.0000,1,'2015-04-07 07:37:44'),(1220,1,1,27,0,'2015-04-07 11:42:39','2015-04-07 11:42:39',0.0000,0.0000,1,'2015-04-07 07:42:44'),(1221,1,1,27,0,'2015-04-07 11:52:39','2015-04-07 11:52:40',0.0000,0.0000,1,'2015-04-07 07:52:44'),(1222,1,1,27,0,'2015-04-07 11:57:40','2015-04-07 11:57:40',0.0000,0.0000,1,'2015-04-07 07:57:45'),(1223,1,1,27,0,'2015-04-07 12:07:42','2015-04-07 12:07:41',0.0000,0.0000,1,'2015-04-07 08:07:48'),(1224,1,1,27,0,'2015-04-07 12:12:43','2015-04-07 12:12:43',0.0000,0.0000,1,'2015-04-07 08:12:48'),(1225,1,1,27,0,'2015-04-07 12:22:43','2015-04-07 12:22:44',0.0000,0.0000,1,'2015-04-07 08:22:49'),(1226,1,1,27,0,'2015-04-07 12:27:44','2015-04-07 12:27:44',0.0000,0.0000,1,'2015-04-07 08:27:50'),(1227,1,1,27,0,'2015-04-07 12:37:45','2015-04-07 12:37:45',0.0000,0.0000,1,'2015-04-07 08:37:51'),(1228,1,1,27,0,'2015-04-07 12:42:47','2015-04-07 12:42:46',0.0000,0.0000,1,'2015-04-07 08:42:52'),(1229,1,1,27,0,'2015-04-07 12:52:48','2015-04-07 12:52:48',0.0000,0.0000,1,'2015-04-07 08:52:53'),(1230,1,1,27,0,'2015-04-07 12:57:48','2015-04-07 12:57:49',0.0000,0.0000,1,'2015-04-07 08:57:53'),(1231,1,1,27,0,'2015-04-07 13:07:48','2015-04-07 13:07:48',0.0000,0.0000,1,'2015-04-07 09:07:53'),(1232,1,1,27,0,'2015-04-07 13:12:48','2015-04-07 13:12:49',0.0000,0.0000,1,'2015-04-07 09:12:53'),(1233,1,1,27,0,'2015-04-07 13:22:50','2015-04-07 13:22:49',0.0000,0.0000,1,'2015-04-07 09:22:55'),(1234,1,1,27,0,'2015-04-07 13:27:51','2015-04-07 13:27:50',0.0000,0.0000,1,'2015-04-07 09:27:56'),(1235,1,1,27,0,'2015-04-07 13:37:51','2015-04-07 13:37:51',0.0000,0.0000,1,'2015-04-07 09:37:56'),(1236,1,1,27,0,'2015-04-07 13:42:51','2015-04-07 13:42:51',0.0000,0.0000,1,'2015-04-07 09:42:56'),(1237,1,1,27,0,'2015-04-07 13:52:50','2015-04-07 13:52:51',0.0000,0.0000,1,'2015-04-07 09:52:56'),(1238,1,1,27,0,'2015-04-07 13:57:50','2015-04-07 13:57:51',0.0000,0.0000,1,'2015-04-07 09:57:56'),(1239,1,1,27,0,'2015-04-07 14:20:31','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-07 10:20:36'),(1240,1,1,27,0,'2015-04-07 14:21:29','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-07 10:21:35'),(1241,1,1,27,0,'2015-04-07 14:26:29','2015-04-07 14:26:30',0.0000,0.0000,1,'2015-04-07 10:26:35'),(1242,1,1,27,0,'2015-04-07 14:36:30','2015-04-07 14:36:31',0.0000,0.0000,1,'2015-04-07 10:36:36'),(1243,1,1,27,0,'2015-04-07 14:41:32','2015-04-07 14:41:31',0.0000,0.0000,1,'2015-04-07 10:41:38'),(1244,1,1,27,0,'2015-04-07 14:51:33','2015-04-07 14:51:33',0.0000,0.0000,1,'2015-04-07 10:51:39'),(1245,1,1,27,0,'2015-04-07 14:56:33','2015-04-07 14:56:34',0.0000,0.0000,1,'2015-04-07 10:56:38'),(1246,1,1,27,0,'2015-04-07 15:06:33','2015-04-07 15:06:33',0.0000,0.0000,1,'2015-04-07 11:06:38'),(1247,1,1,27,0,'2015-04-07 15:11:33','2015-04-07 15:11:33',0.0000,0.0000,1,'2015-04-07 11:11:38'),(1248,1,1,27,0,'2015-04-07 15:21:34','2015-04-07 15:21:34',0.0000,0.0000,1,'2015-04-07 11:21:39'),(1249,1,1,27,0,'2015-04-07 15:26:35','2015-04-07 15:26:34',0.0000,0.0000,1,'2015-04-07 11:26:40'),(1250,1,1,27,0,'2015-04-07 15:30:47','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-07 11:30:53'),(1251,1,1,27,0,'2015-04-07 15:35:48','2015-04-07 15:35:48',0.0000,0.0000,1,'2015-04-07 11:35:53'),(1252,1,1,27,0,'2015-04-07 15:38:51','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-07 11:38:57'),(1253,1,1,27,0,'2015-04-07 15:39:34','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-07 11:39:39'),(1254,1,1,27,0,'2015-04-07 15:44:34','2015-04-07 15:44:35',0.0000,0.0000,1,'2015-04-07 11:44:39'),(1255,1,1,27,0,'2015-04-07 15:54:35','2015-04-07 15:54:35',0.0000,0.0000,1,'2015-04-07 11:54:41'),(1256,1,1,27,0,'2015-04-07 15:59:19','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-07 11:59:25'),(1257,1,1,27,0,'2015-04-07 16:04:19','2015-04-07 16:04:20',0.0000,0.0000,1,'2015-04-07 12:04:25'),(1258,1,1,27,0,'2015-04-07 16:14:21','2015-04-07 16:14:21',0.0000,0.0000,1,'2015-04-07 12:14:26'),(1259,1,1,27,0,'2015-04-07 16:19:22','2015-04-07 16:19:21',0.0000,0.0000,1,'2015-04-07 12:19:27'),(1260,1,1,27,0,'2015-04-07 16:28:29','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-07 12:28:34'),(1261,1,1,27,0,'2015-04-07 16:33:28','2015-04-07 16:33:29',0.0000,0.0000,1,'2015-04-07 12:33:34'),(1262,1,1,27,0,'2015-04-07 16:43:30','2015-04-07 16:43:30',0.0000,0.0000,1,'2015-04-07 12:43:35'),(1263,1,1,27,0,'2015-04-07 16:48:31','2015-04-07 16:48:30',0.0000,0.0000,1,'2015-04-07 12:48:36'),(1264,1,1,27,0,'2015-04-07 16:58:30','2015-04-07 16:58:31',0.0000,0.0000,1,'2015-04-07 12:58:36'),(1265,1,1,27,0,'2015-04-07 17:03:30','2015-04-07 17:03:31',0.0000,0.0000,1,'2015-04-07 13:03:36'),(1266,1,1,27,0,'2015-04-07 17:13:30','2015-04-07 17:13:31',0.0000,0.0000,1,'2015-04-07 13:13:36'),(1267,1,1,27,0,'2015-04-07 17:18:30','2015-04-07 17:18:31',0.0000,0.0000,1,'2015-04-07 13:18:35'),(1268,1,1,27,0,'2015-04-07 17:28:32','2015-04-07 17:28:31',0.0000,0.0000,1,'2015-04-07 13:28:38'),(1269,1,1,27,0,'2015-04-07 17:33:32','2015-04-07 17:33:33',0.0000,0.0000,1,'2015-04-07 13:33:38'),(1270,1,1,27,0,'2015-04-07 17:43:33','2015-04-07 17:43:34',0.0000,0.0000,1,'2015-04-07 13:43:38'),(1271,1,1,27,0,'2015-04-07 17:48:33','2015-04-07 17:48:34',0.0000,0.0000,1,'2015-04-07 13:48:38'),(1272,1,1,27,0,'2015-04-07 17:58:33','2015-04-07 17:58:33',0.0000,0.0000,1,'2015-04-07 13:58:38'),(1273,1,1,27,0,'2015-04-07 18:03:33','2015-04-07 18:03:33',0.0000,0.0000,1,'2015-04-07 14:03:38'),(1274,1,1,27,0,'2015-04-07 18:13:33','2015-04-07 18:13:33',0.0000,0.0000,1,'2015-04-07 14:13:38'),(1275,1,1,27,0,'2015-04-07 18:18:34','2015-04-07 18:18:33',0.0000,0.0000,1,'2015-04-07 14:18:39'),(1276,1,1,27,0,'2015-04-08 09:41:10','1977-12-08 02:56:20',0.0000,0.0000,1,'2015-04-08 05:41:16'),(1277,1,1,27,0,'2015-04-08 09:46:11','2015-04-08 09:46:12',0.0000,0.0000,1,'2015-04-08 05:46:17'),(1278,1,1,27,0,'2015-04-08 09:56:12','2015-04-08 09:56:12',0.0000,0.0000,1,'2015-04-08 05:56:18'),(1279,1,1,27,0,'2015-04-08 10:01:12','2015-04-08 10:01:13',0.0000,0.0000,1,'2015-04-08 06:01:18'),(1280,1,1,27,0,'2015-04-08 10:11:15','2015-04-08 10:11:14',0.0000,0.0000,1,'2015-04-08 06:11:20'),(1281,1,1,27,0,'2015-04-08 10:16:17','2015-04-08 10:16:16',0.0000,0.0000,1,'2015-04-08 06:16:22'),(1282,1,1,27,0,'2015-04-08 10:26:18','2015-04-08 10:26:18',0.0000,0.0000,1,'2015-04-08 06:26:23'),(1283,1,1,27,0,'2015-04-08 10:31:18','2015-04-08 10:31:18',0.0000,0.0000,1,'2015-04-08 06:31:23'),(1284,1,1,27,0,'2015-04-08 10:41:21','2015-04-08 10:41:20',0.0000,0.0000,1,'2015-04-08 06:41:27'),(1285,1,1,27,0,'2015-04-08 10:46:22','2015-04-08 10:46:22',0.0000,0.0000,1,'2015-04-08 06:46:27'),(1286,1,1,27,0,'2015-04-08 10:56:23','2015-04-08 10:56:23',0.0000,0.0000,1,'2015-04-08 06:56:28'),(1287,1,1,27,0,'2015-04-08 11:01:23','2015-04-08 11:01:23',0.0000,0.0000,1,'2015-04-08 07:01:28'),(1288,1,1,27,0,'2015-04-08 11:05:02','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-08 07:05:08'),(1289,1,1,27,0,'2015-04-08 11:10:03','2015-04-08 11:10:03',0.0000,0.0000,1,'2015-04-08 07:10:08'),(1290,1,1,27,0,'2015-04-08 11:20:03','2015-04-08 11:20:04',0.0000,0.0000,1,'2015-04-08 07:20:09'),(1291,1,1,27,0,'2015-04-08 11:25:03','2015-04-08 11:25:04',0.0000,0.0000,1,'2015-04-08 07:25:09'),(1292,1,1,27,0,'2015-04-08 11:35:08','2015-04-08 11:35:07',0.0000,0.0000,1,'2015-04-08 07:35:13'),(1293,1,1,27,0,'2015-04-08 11:40:08','2015-04-08 11:40:09',0.0000,0.0000,1,'2015-04-08 07:40:14'),(1294,1,1,27,0,'2015-04-08 11:50:10','2015-04-08 11:50:10',0.0000,0.0000,1,'2015-04-08 07:50:15'),(1295,1,1,27,0,'2015-04-08 11:55:11','2015-04-08 11:55:12',0.0000,0.0000,1,'2015-04-08 07:55:17'),(1296,1,1,27,0,'2015-04-08 12:05:13','2015-04-08 12:05:13',0.0000,0.0000,1,'2015-04-08 08:05:18'),(1297,1,1,27,0,'2015-04-08 12:10:13','2015-04-08 12:10:13',0.0000,0.0000,1,'2015-04-08 08:10:18'),(1298,1,1,27,0,'2015-04-08 12:20:14','2015-04-08 12:20:15',0.0000,0.0000,1,'2015-04-08 08:20:20'),(1299,1,1,27,0,'2015-04-08 12:25:16','2015-04-08 12:25:15',0.0000,0.0000,1,'2015-04-08 08:25:21'),(1300,1,1,27,0,'2015-04-08 12:35:18','2015-04-08 12:35:19',0.0000,0.0000,1,'2015-04-08 08:35:23'),(1301,1,1,27,0,'2015-04-08 12:40:18','2015-04-08 12:40:18',0.0000,0.0000,1,'2015-04-08 08:40:24'),(1302,1,1,27,0,'2015-04-08 12:50:19','2015-04-08 12:50:20',0.0000,0.0000,1,'2015-04-08 08:50:24'),(1303,1,1,27,0,'2015-04-08 12:55:21','2015-04-08 12:55:19',0.0000,0.0000,1,'2015-04-08 08:55:27'),(1304,1,1,27,0,'2015-04-08 13:05:24','2015-04-08 13:05:24',0.0000,0.0000,1,'2015-04-08 09:05:29'),(1305,1,1,27,0,'2015-04-08 13:10:24','2015-04-08 13:10:24',0.0000,0.0000,1,'2015-04-08 09:10:29'),(1306,1,1,27,0,'2015-04-08 13:20:27','2015-04-08 13:20:27',0.0000,0.0000,1,'2015-04-08 09:20:33'),(1307,1,1,27,0,'2015-04-08 13:25:28','2015-04-08 13:25:29',0.0000,0.0000,1,'2015-04-08 09:25:34'),(1308,1,1,27,0,'2015-04-08 13:35:31','2015-04-08 13:35:30',0.0000,0.0000,1,'2015-04-08 09:35:37'),(1309,1,1,27,0,'2015-04-08 13:40:32','2015-04-08 13:40:32',0.0000,0.0000,1,'2015-04-08 09:40:37'),(1310,1,1,27,0,'2015-04-08 13:50:33','2015-04-08 13:50:33',0.0000,0.0000,1,'2015-04-08 09:50:38'),(1311,1,1,27,0,'2015-04-08 13:55:34','2015-04-08 13:55:34',0.0000,0.0000,1,'2015-04-08 09:55:39'),(1312,1,1,27,0,'2015-04-08 14:05:37','2015-04-08 14:05:37',0.0000,0.0000,1,'2015-04-08 10:05:42'),(1313,1,1,27,0,'2015-04-08 14:10:37','2015-04-08 14:10:37',0.0000,0.0000,1,'2015-04-08 10:10:43'),(1314,1,1,27,0,'2015-04-08 14:20:41','2015-04-08 14:20:39',0.0000,0.0000,1,'2015-04-08 10:20:47'),(1315,1,1,27,0,'2015-04-08 14:25:43','2015-04-08 14:25:42',0.0000,0.0000,1,'2015-04-08 10:25:48'),(1316,1,1,27,0,'2015-04-08 14:35:44','2015-04-08 14:35:44',0.0000,0.0000,1,'2015-04-08 10:35:49'),(1317,1,1,27,0,'2015-04-08 14:40:44','2015-04-08 14:40:44',0.0000,0.0000,1,'2015-04-08 10:40:49'),(1318,1,1,27,0,'2015-04-08 14:50:46','2015-04-08 14:50:45',0.0000,0.0000,1,'2015-04-08 10:50:51'),(1319,1,1,27,0,'2015-04-08 14:55:47','2015-04-08 14:55:46',0.0000,0.0000,1,'2015-04-08 10:55:52'),(1320,1,1,27,0,'2015-04-08 15:05:48','2015-04-08 15:05:48',0.0000,0.0000,1,'2015-04-08 11:05:54'),(1321,1,1,27,0,'2015-04-08 15:10:48','2015-04-08 15:10:49',0.0000,0.0000,1,'2015-04-08 11:10:53'),(1322,1,1,27,0,'2015-04-08 15:20:50','2015-04-08 15:20:49',0.0000,0.0000,1,'2015-04-08 11:20:55'),(1323,1,1,27,0,'2015-04-08 15:25:50','2015-04-08 15:25:50',0.0000,0.0000,1,'2015-04-08 11:25:55'),(1324,1,1,27,0,'2015-04-08 15:35:51','2015-04-08 15:35:51',0.0000,0.0000,1,'2015-04-08 11:35:56'),(1325,1,1,27,0,'2015-04-08 15:40:51','2015-04-08 15:40:51',0.0000,0.0000,1,'2015-04-08 11:40:57'),(1326,1,1,27,0,'2015-04-08 15:50:53','2015-04-08 15:50:52',0.0000,0.0000,1,'2015-04-08 11:50:58'),(1327,1,1,27,0,'2015-04-08 15:55:53','2015-04-08 15:55:54',0.0000,0.0000,1,'2015-04-08 11:55:58'),(1328,1,1,27,0,'2015-04-08 16:05:53','2015-04-08 16:05:54',0.0000,0.0000,1,'2015-04-08 12:05:59'),(1329,1,1,27,0,'2015-04-08 16:10:54','2015-04-08 16:10:54',0.0000,0.0000,1,'2015-04-08 12:10:59'),(1330,1,1,27,0,'2015-04-08 16:20:57','2015-04-08 16:20:58',0.0000,0.0000,1,'2015-04-08 12:21:03'),(1331,1,1,27,0,'2015-04-08 16:25:57','2015-04-08 16:25:58',0.0000,0.0000,1,'2015-04-08 12:26:03'),(1332,1,1,27,0,'2015-04-08 16:35:58','2015-04-08 16:35:59',0.0000,0.0000,1,'2015-04-08 12:36:04'),(1333,1,1,27,0,'2015-04-08 16:40:59','2015-04-08 16:40:59',0.0000,0.0000,1,'2015-04-08 12:41:05'),(1334,1,1,27,0,'2015-04-08 16:51:02','2015-04-08 16:51:02',0.0000,0.0000,1,'2015-04-08 12:51:07'),(1335,1,1,27,0,'2015-04-08 16:56:02','2015-04-08 16:56:02',0.0000,0.0000,1,'2015-04-08 12:56:07'),(1336,1,1,27,0,'2015-04-08 17:06:03','2015-04-08 17:06:03',0.0000,0.0000,1,'2015-04-08 13:06:08'),(1337,1,1,27,0,'2015-04-08 17:11:03','2015-04-08 17:11:03',0.0000,0.0000,1,'2015-04-08 13:11:08'),(1338,1,1,27,0,'2015-04-08 17:21:06','2015-04-08 17:21:06',0.0000,0.0000,1,'2015-04-08 13:21:11'),(1339,1,1,27,0,'2015-04-08 17:26:07','2015-04-08 17:26:06',0.0000,0.0000,1,'2015-04-08 13:26:13'),(1340,1,1,27,0,'2015-04-08 17:36:08','2015-04-08 17:36:08',0.0000,0.0000,1,'2015-04-08 13:36:13'),(1341,1,1,27,0,'2015-04-08 17:41:09','2015-04-08 17:41:08',0.0000,0.0000,1,'2015-04-08 13:41:14'),(1342,1,1,27,0,'2015-04-08 17:51:10','2015-04-08 17:51:10',0.0000,0.0000,1,'2015-04-08 13:51:16'),(1343,1,1,27,0,'2015-04-08 17:56:10','2015-04-08 17:56:11',0.0000,0.0000,1,'2015-04-08 13:56:16'),(1344,1,1,27,0,'2015-04-08 18:06:13','2015-04-08 18:06:13',0.0000,0.0000,1,'2015-04-08 14:06:18'),(1345,1,1,27,0,'2015-04-08 18:11:13','2015-04-08 18:11:14',0.0000,0.0000,1,'2015-04-08 14:11:19'),(1346,1,1,27,0,'2015-04-08 18:21:17','2015-04-08 18:21:16',0.0000,0.0000,1,'2015-04-08 14:21:22'),(1347,1,1,27,0,'2015-04-08 18:26:17','2015-04-08 18:26:17',0.0000,0.0000,1,'2015-04-08 14:26:23'),(1348,1,1,27,0,'2015-04-09 09:22:09','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-09 05:22:14'),(1349,1,1,27,0,'2015-04-09 09:27:10','2015-04-09 09:27:09',0.0000,0.0000,1,'2015-04-09 05:27:15'),(1350,1,1,27,0,'2015-04-09 09:37:11','2015-04-09 09:37:12',0.0000,0.0000,1,'2015-04-09 05:37:17'),(1351,1,1,27,0,'2015-04-09 09:42:12','2015-04-09 09:42:12',0.0000,0.0000,1,'2015-04-09 05:42:18'),(1352,1,1,27,0,'2015-04-09 09:52:15','2015-04-09 09:52:14',0.0000,0.0000,1,'2015-04-09 05:52:20'),(1353,1,1,27,0,'2015-04-09 09:57:16','2015-04-09 09:57:15',0.0000,0.0000,1,'2015-04-09 05:57:21'),(1354,1,1,27,0,'2015-04-09 10:07:16','2015-04-09 10:07:17',0.0000,0.0000,1,'2015-04-09 06:07:21'),(1355,1,1,27,0,'2015-04-09 10:12:17','2015-04-09 10:12:16',0.0000,0.0000,1,'2015-04-09 06:12:22'),(1356,1,1,27,0,'2015-04-09 10:22:20','2015-04-09 10:22:18',0.0000,0.0000,1,'2015-04-09 06:22:25'),(1357,1,1,27,0,'2015-04-09 10:27:20','2015-04-09 10:27:20',0.0000,0.0000,1,'2015-04-09 06:27:26'),(1358,1,1,27,0,'2015-04-09 10:37:21','2015-04-09 10:37:21',0.0000,0.0000,1,'2015-04-09 06:37:27'),(1359,1,1,27,0,'2015-04-09 10:42:22','2015-04-09 10:42:22',0.0000,0.0000,1,'2015-04-09 06:42:27'),(1360,1,1,27,0,'2015-04-09 10:52:23','2015-04-09 10:52:23',0.0000,0.0000,1,'2015-04-09 06:52:29'),(1361,1,1,27,0,'2015-04-09 10:57:23','2015-04-09 10:57:24',0.0000,0.0000,1,'2015-04-09 06:57:29'),(1362,1,1,27,0,'2015-04-09 11:07:23','2015-04-09 11:07:24',0.0000,0.0000,1,'2015-04-09 07:07:28'),(1363,1,1,27,0,'2015-04-09 11:12:23','2015-04-09 11:12:24',0.0000,0.0000,1,'2015-04-09 07:12:29'),(1364,1,1,27,0,'2015-04-09 11:22:26','2015-04-09 11:22:26',0.0000,0.0000,1,'2015-04-09 07:22:31'),(1365,1,1,27,0,'2015-04-09 11:27:26','2015-04-09 11:27:26',0.0000,0.0000,1,'2015-04-09 07:27:31'),(1366,1,1,27,0,'2015-04-09 11:37:27','2015-04-09 11:37:27',0.0000,0.0000,1,'2015-04-09 07:37:32'),(1367,1,1,27,0,'2015-04-09 11:42:27','2015-04-09 11:42:27',0.0000,0.0000,1,'2015-04-09 07:42:32'),(1368,1,1,27,0,'2015-04-09 11:52:27','2015-04-09 11:52:27',0.0000,0.0000,1,'2015-04-09 07:52:32'),(1369,1,1,27,0,'2015-04-09 11:57:27','2015-04-09 11:57:27',0.0000,0.0000,1,'2015-04-09 07:57:32'),(1370,1,1,27,0,'2015-04-09 12:07:27','2015-04-09 12:07:27',0.0000,0.0000,1,'2015-04-09 08:07:32'),(1371,1,1,27,0,'2015-04-09 12:12:28','2015-04-09 12:12:27',0.0000,0.0000,1,'2015-04-09 08:12:33'),(1372,1,1,27,0,'2015-04-09 12:22:27','2015-04-09 12:22:28',0.0000,0.0000,1,'2015-04-09 08:22:33'),(1373,1,1,27,0,'2015-04-09 12:27:31','2015-04-09 12:27:31',0.0000,0.0000,1,'2015-04-09 08:27:36'),(1374,1,1,27,0,'2015-04-09 12:37:31','2015-04-09 12:37:32',0.0000,0.0000,1,'2015-04-09 08:37:36'),(1375,1,1,27,0,'2015-04-09 12:42:31','2015-04-09 12:42:32',0.0000,0.0000,1,'2015-04-09 08:42:37'),(1376,1,1,27,0,'2015-04-09 12:52:32','2015-04-09 12:52:32',0.0000,0.0000,1,'2015-04-09 08:52:38'),(1377,1,1,27,0,'2015-04-09 12:57:33','2015-04-09 12:57:33',0.0000,0.0000,1,'2015-04-09 08:57:38'),(1378,1,1,27,0,'2015-04-09 13:07:34','2015-04-09 13:07:35',0.0000,0.0000,1,'2015-04-09 09:07:40'),(1379,1,1,27,0,'2015-04-09 13:12:36','2015-04-09 13:12:35',0.0000,0.0000,1,'2015-04-09 09:12:41'),(1380,1,1,27,0,'2015-04-09 13:22:36','2015-04-09 13:22:36',0.0000,0.0000,1,'2015-04-09 09:22:41'),(1381,1,1,27,0,'2015-04-09 13:27:36','2015-04-09 13:27:37',0.0000,0.0000,1,'2015-04-09 09:27:41'),(1382,1,1,27,0,'2015-04-09 13:37:38','2015-04-09 13:37:38',0.0000,0.0000,1,'2015-04-09 09:37:44'),(1383,1,1,27,0,'2015-04-09 13:42:40','2015-04-09 13:42:40',0.0000,0.0000,1,'2015-04-09 09:42:45'),(1384,1,1,27,0,'2015-04-09 13:52:41','2015-04-09 13:52:41',0.0000,0.0000,1,'2015-04-09 09:52:46'),(1385,1,1,27,0,'2015-04-09 13:57:42','2015-04-09 13:57:41',0.0000,0.0000,1,'2015-04-09 09:57:47'),(1386,1,1,27,0,'2015-04-09 14:07:43','2015-04-09 14:07:43',0.0000,0.0000,1,'2015-04-09 10:07:49'),(1387,1,1,27,0,'2015-04-09 14:12:43','2015-04-09 14:12:44',0.0000,0.0000,1,'2015-04-09 10:12:49'),(1388,1,1,27,0,'2015-04-09 14:22:45','2015-04-09 14:22:44',0.0000,0.0000,1,'2015-04-09 10:22:51'),(1389,1,1,27,0,'2015-04-09 14:27:45','2015-04-09 14:27:46',0.0000,0.0000,1,'2015-04-09 10:27:51'),(1390,1,1,27,0,'2015-04-09 14:37:46','2015-04-09 14:37:48',0.0000,0.0000,1,'2015-04-09 10:37:52'),(1391,1,1,27,0,'2015-04-09 14:42:47','2015-04-09 14:42:47',0.0000,0.0000,1,'2015-04-09 10:42:53'),(1392,1,1,27,0,'2015-04-09 14:52:49','2015-04-09 14:52:49',0.0000,0.0000,1,'2015-04-09 10:52:54'),(1393,1,1,27,0,'2015-04-09 14:57:51','2015-04-09 14:57:50',0.0000,0.0000,1,'2015-04-09 10:57:56'),(1394,1,1,27,0,'2015-04-09 15:07:52','2015-04-09 15:07:52',0.0000,0.0000,1,'2015-04-09 11:07:57'),(1395,1,1,27,0,'2015-04-09 15:12:52','2015-04-09 15:12:52',0.0000,0.0000,1,'2015-04-09 11:12:57'),(1396,1,1,27,0,'2015-04-09 15:22:53','2015-04-09 15:22:53',0.0000,0.0000,1,'2015-04-09 11:22:58'),(1397,1,1,27,0,'2015-04-09 15:27:54','2015-04-09 15:27:53',0.0000,0.0000,1,'2015-04-09 11:28:00'),(1398,1,1,27,0,'2015-04-09 15:37:57','2015-04-09 15:37:56',0.0000,0.0000,1,'2015-04-09 11:38:02'),(1399,1,1,27,0,'2015-04-09 15:42:57','2015-04-09 15:42:57',0.0000,0.0000,1,'2015-04-09 11:43:03'),(1400,1,1,27,0,'2015-04-09 15:52:57','2015-04-09 15:52:58',0.0000,0.0000,1,'2015-04-09 11:53:03'),(1401,1,1,27,0,'2015-04-09 15:57:57','2015-04-09 15:57:58',0.0000,0.0000,1,'2015-04-09 11:58:03'),(1402,1,1,27,0,'2015-04-09 16:07:57','2015-04-09 16:07:58',0.0000,0.0000,1,'2015-04-09 12:08:03'),(1403,1,1,27,0,'2015-04-09 16:12:57','2015-04-09 16:12:58',0.0000,0.0000,1,'2015-04-09 12:13:02'),(1404,1,1,27,0,'2015-04-09 16:22:58','2015-04-09 16:22:58',0.0000,0.0000,1,'2015-04-09 12:23:04'),(1405,1,1,27,0,'2015-04-09 16:28:00','2015-04-09 16:27:59',0.0000,0.0000,1,'2015-04-09 12:28:05'),(1406,1,1,27,0,'2015-04-09 16:38:02','2015-04-09 16:38:01',0.0000,0.0000,1,'2015-04-09 12:38:07'),(1407,1,1,27,0,'2015-04-09 16:43:02','2015-04-09 16:43:02',0.0000,0.0000,1,'2015-04-09 12:43:07'),(1408,1,1,27,0,'2015-04-09 16:53:02','2015-04-09 16:53:02',0.0000,0.0000,1,'2015-04-09 12:53:07'),(1409,1,1,27,0,'2015-04-09 16:58:02','2015-04-09 16:58:02',0.0000,0.0000,1,'2015-04-09 12:58:07'),(1410,1,1,27,0,'2015-04-09 17:08:02','2015-04-09 17:08:02',0.0000,0.0000,1,'2015-04-09 13:08:07'),(1411,1,1,27,0,'2015-04-09 17:13:02','2015-04-09 17:13:02',0.0000,0.0000,1,'2015-04-09 13:13:07'),(1412,1,1,27,0,'2015-04-09 17:23:03','2015-04-09 17:23:03',0.0000,0.0000,1,'2015-04-09 13:23:08'),(1413,1,1,27,0,'2015-04-09 17:28:02','2015-04-09 17:28:03',0.0000,0.0000,1,'2015-04-09 13:28:08'),(1414,1,1,27,0,'2015-04-09 17:38:04','2015-04-09 17:38:03',0.0000,0.0000,1,'2015-04-09 13:38:09'),(1415,1,1,27,0,'2015-04-09 17:43:05','2015-04-09 17:43:04',0.0000,0.0000,1,'2015-04-09 13:43:11'),(1416,1,1,27,0,'2015-04-09 17:53:06','2015-04-09 17:53:06',0.0000,0.0000,1,'2015-04-09 13:53:12'),(1417,1,1,27,0,'2015-04-09 17:58:06','2015-04-09 17:58:07',0.0000,0.0000,1,'2015-04-09 13:58:12'),(1418,1,1,27,0,'2015-04-09 18:08:07','2015-04-09 18:08:07',0.0000,0.0000,1,'2015-04-09 14:08:12'),(1419,1,1,27,0,'2015-04-09 18:13:07','2015-04-09 18:13:07',0.0000,0.0000,1,'2015-04-09 14:13:12'),(1420,1,1,22,0,'2015-04-10 00:44:20','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-09 20:44:25'),(1421,1,1,22,0,'2015-04-10 00:49:20','2015-04-10 00:49:20',0.0000,0.0000,1,'2015-04-09 20:49:25'),(1422,1,1,30,0,'2015-04-10 00:55:54','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-09 20:55:59'),(1423,1,1,30,0,'2015-04-10 00:59:28','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-09 20:59:33'),(1424,1,1,30,0,'2015-04-10 01:48:16','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-09 21:48:21'),(1425,1,1,30,0,'2015-04-10 01:52:08','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-09 21:52:14'),(1426,1,1,30,0,'2015-04-10 01:59:32','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-09 21:59:37'),(1427,1,1,30,0,'2015-04-10 02:01:16','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-09 22:01:22'),(1428,1,1,30,0,'2015-04-10 02:03:08','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-09 22:03:14'),(1429,1,1,30,0,'2015-04-10 02:04:53','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-09 22:04:58'),(1430,1,1,30,0,'2015-04-10 02:06:45','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-09 22:06:50'),(1431,1,1,30,0,'2015-04-10 02:13:35','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-09 22:13:40'),(1432,1,1,30,0,'2015-04-10 02:16:30','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-09 22:16:35'),(1433,1,1,30,0,'2015-04-10 02:18:22','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-09 22:18:27'),(1434,1,1,30,0,'2015-04-10 22:11:10','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:11:15'),(1435,1,1,30,0,'2015-04-10 22:18:17','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:18:22'),(1436,1,1,30,0,'2015-04-10 22:18:40','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:18:45'),(1437,1,1,30,0,'2015-04-10 22:20:51','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:20:56'),(1438,1,1,30,0,'2015-04-10 22:24:22','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:24:27'),(1439,1,1,30,0,'2015-04-10 22:25:31','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:25:37'),(1440,1,1,30,0,'2015-04-10 22:25:58','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:26:04'),(1441,1,1,30,0,'2015-04-10 22:27:23','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:27:28'),(1442,1,1,30,0,'2015-04-10 22:28:08','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:28:14'),(1443,1,1,22,0,'2015-04-10 22:33:56','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-10 18:34:02'),(1444,1,1,22,0,'2015-04-10 22:39:20','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:39:25'),(1445,1,1,22,0,'2015-04-10 22:41:36','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:41:42'),(1446,1,1,30,0,'2015-04-10 22:42:13','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:42:18'),(1447,1,1,22,0,'2015-04-10 22:44:54','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:44:59'),(1448,1,1,22,0,'2015-04-10 22:45:14','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:45:19'),(1449,1,1,22,0,'2015-04-10 22:47:11','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:47:17'),(1450,1,1,22,0,'2015-04-10 22:47:53','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:47:59'),(1451,1,1,22,0,'2015-04-10 22:50:41','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:50:46'),(1452,1,1,22,0,'2015-04-10 22:50:52','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:50:58'),(1453,1,1,22,0,'2015-04-10 22:53:34','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:53:39'),(1454,1,1,22,0,'2015-04-10 22:53:44','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:53:50'),(1455,1,1,22,0,'2015-04-10 22:54:33','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 18:54:39'),(1456,1,1,22,0,'2015-04-10 23:00:24','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:00:29'),(1457,1,1,22,0,'2015-04-10 23:05:54','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:06:00'),(1458,1,1,22,0,'2015-04-10 23:06:10','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:06:16'),(1459,1,1,22,0,'2015-04-10 23:06:31','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:06:36'),(1460,1,1,22,0,'2015-04-10 23:08:19','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:08:24'),(1461,1,1,22,0,'2015-04-10 23:08:55','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:09:01'),(1462,1,1,22,0,'2015-04-10 23:10:17','1961-12-23 15:59:16',0.0000,0.0000,1,'2015-04-10 19:10:22'),(1463,1,1,22,0,'2015-04-10 23:15:17','2015-04-10 23:15:17',0.0000,0.0000,1,'2015-04-10 19:15:22'),(1464,1,1,22,0,'2015-04-10 23:17:52','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:17:57'),(1465,1,1,22,0,'2015-04-10 23:19:28','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:19:33'),(1466,1,1,22,0,'2015-04-10 23:19:42','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:19:48'),(1467,1,1,22,0,'2015-04-10 23:20:23','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:20:29'),(1468,1,1,22,0,'2015-04-10 23:20:58','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:21:04'),(1469,1,1,22,0,'2015-04-10 23:24:56','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:25:01'),(1470,1,1,22,0,'2015-04-10 23:25:17','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:25:22'),(1471,1,1,22,0,'2015-04-10 23:25:33','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:25:38'),(1472,1,1,22,0,'2015-04-10 23:29:16','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:29:22'),(1473,1,1,22,0,'2015-04-10 23:29:45','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:29:50'),(1474,1,1,22,0,'2015-04-10 23:30:05','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-10 19:30:11'),(1475,1,1,22,0,'2015-04-15 11:15:05','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-15 07:15:13'),(1476,1,1,22,0,'2015-04-15 11:18:27','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-15 07:18:35'),(1477,1,1,22,0,'2015-04-17 11:06:13','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-17 07:06:21'),(1478,1,1,22,0,'2015-04-17 11:07:59','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-17 07:08:07'),(1479,1,1,22,0,'2015-04-17 11:08:25','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-17 07:08:33'),(1480,1,1,22,0,'2015-04-17 12:02:12','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-17 08:02:20'),(1481,1,1,21,0,'2015-04-17 14:28:55','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 10:29:03'),(1482,1,1,21,0,'2015-04-17 14:33:56','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 10:34:03'),(1483,1,1,21,0,'2015-04-17 14:38:56','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 10:39:04'),(1484,1,1,21,0,'2015-04-17 14:43:56','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 10:44:04'),(1485,1,1,21,0,'2015-04-17 14:48:56','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 10:49:04'),(1486,1,1,21,0,'2015-04-17 14:53:56','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 10:54:04'),(1487,1,1,21,0,'2015-04-17 14:58:56','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 10:59:04'),(1488,1,1,21,0,'2015-04-17 15:03:57','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 11:04:04'),(1489,1,1,21,0,'2015-04-17 15:08:57','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 11:09:05'),(1490,1,1,21,0,'2015-04-17 15:13:57','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 11:14:05'),(1491,1,1,21,0,'2015-04-17 15:18:57','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 11:19:05'),(1492,1,1,21,0,'2015-04-17 15:23:57','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 11:24:05'),(1493,1,1,21,0,'2015-04-17 15:28:57','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 11:29:05'),(1494,1,1,21,0,'2015-04-17 15:33:58','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 11:34:05'),(1495,1,1,21,0,'2015-04-17 15:38:58','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 11:39:06'),(1496,1,1,21,0,'2015-04-17 15:43:59','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 11:44:06'),(1497,1,1,21,0,'2015-04-17 15:48:59','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 11:49:07'),(1498,1,1,21,0,'2015-04-17 15:54:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 11:54:10'),(1499,1,1,21,0,'2015-04-17 15:59:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 11:59:11'),(1500,1,1,21,0,'2015-04-17 16:04:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 12:04:11'),(1501,1,1,21,0,'2015-04-17 16:09:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 12:09:11'),(1502,1,1,21,0,'2015-04-17 16:14:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 12:14:11'),(1503,1,1,21,0,'2015-04-17 16:19:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 12:19:11'),(1504,1,1,21,0,'2015-04-17 16:24:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 12:24:12'),(1505,1,1,21,0,'2015-04-17 16:32:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 12:32:12'),(1506,1,1,21,0,'2015-04-17 16:37:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 12:37:12'),(1507,1,1,21,0,'2015-04-17 16:45:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 12:45:12'),(1508,1,1,21,0,'2015-04-17 16:50:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 12:50:12'),(1509,1,1,21,0,'2015-04-17 16:55:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 12:55:12'),(1510,1,1,21,0,'2015-04-17 17:00:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 13:00:13'),(1511,1,1,21,0,'2015-04-17 17:05:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 13:05:13'),(1512,1,1,21,0,'2015-04-17 17:10:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 13:10:13'),(1513,1,1,21,0,'2015-04-17 17:15:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 13:15:13'),(1514,1,1,21,0,'2015-04-17 17:20:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 13:20:13'),(1515,1,1,21,0,'2015-04-17 17:25:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 13:25:13'),(1516,1,1,21,0,'2015-04-17 17:30:06','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 13:30:13'),(1517,1,1,21,0,'2015-04-17 17:35:06','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 13:35:14'),(1518,1,1,21,0,'2015-04-17 17:40:06','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 13:40:14'),(1519,1,1,22,0,'2015-04-17 17:41:50','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-17 13:41:58'),(1520,1,1,21,0,'2015-04-17 17:45:06','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 13:45:14'),(1521,1,1,22,0,'2015-04-17 17:46:50','2015-04-17 17:41:50',0.0000,0.0000,1,'2015-04-17 13:46:58'),(1522,1,1,21,0,'2015-04-17 17:50:11','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 13:50:19'),(1523,1,1,22,0,'2015-04-17 17:51:50','2015-04-17 17:46:50',0.0000,0.0000,1,'2015-04-17 13:51:58'),(1524,1,1,22,0,'2015-04-17 17:52:30','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-17 13:52:37'),(1525,1,1,22,0,'2015-04-17 17:54:18','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-17 13:54:26'),(1526,1,1,21,0,'2015-04-17 17:55:13','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 13:55:21'),(1527,1,1,22,0,'2015-04-17 17:58:45','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-17 13:58:53'),(1528,1,1,21,0,'2015-04-17 18:00:14','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 14:00:22'),(1529,1,1,22,0,'2015-04-17 18:00:45','2015-01-25 13:00:00',0.0000,0.0000,1,'2015-04-17 14:00:53'),(1530,1,1,21,0,'2015-04-17 18:05:14','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 14:05:22'),(1531,1,1,22,0,'2015-04-17 18:05:45','2015-04-17 18:00:46',0.0000,0.0000,1,'2015-04-17 14:05:53'),(1532,1,1,21,0,'2015-04-17 18:10:14','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 14:10:22'),(1533,1,1,21,0,'2015-04-17 18:15:14','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 14:15:22'),(1534,1,1,21,0,'2015-04-17 18:20:15','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 14:20:22'),(1535,1,1,21,0,'2015-04-17 18:25:15','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 14:25:23'),(1536,1,1,21,0,'2015-04-17 18:30:15','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 14:30:23'),(1537,1,1,21,0,'2015-04-17 18:35:15','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 14:35:23'),(1538,1,1,21,0,'2015-04-17 18:40:15','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 14:40:23'),(1539,1,1,21,0,'2015-04-17 18:45:15','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 14:45:23'),(1540,1,1,21,0,'2015-04-17 18:50:16','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 14:50:24'),(1541,1,1,21,0,'2015-04-17 18:55:16','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 14:55:24'),(1542,1,1,21,0,'2015-04-17 19:00:16','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 15:00:24'),(1543,1,1,21,0,'2015-04-17 19:05:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 15:05:24'),(1544,1,1,21,0,'2015-04-17 19:10:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 15:10:25'),(1545,1,1,21,0,'2015-04-17 19:15:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 15:15:25'),(1546,1,1,21,0,'2015-04-17 19:20:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 15:20:25'),(1547,1,1,21,0,'2015-04-17 19:25:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 15:25:25'),(1548,1,1,21,0,'2015-04-17 19:30:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 15:30:25'),(1549,1,1,21,0,'2015-04-17 19:35:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 15:35:25'),(1550,1,1,21,0,'2015-04-17 19:40:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 15:40:26'),(1551,1,1,21,0,'2015-04-17 19:45:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 15:45:26'),(1552,1,1,21,0,'2015-04-17 19:50:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 15:50:26'),(1553,1,1,21,0,'2015-04-17 19:55:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 15:55:26'),(1554,1,1,21,0,'2015-04-17 20:00:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 16:00:26'),(1555,1,1,21,0,'2015-04-17 20:05:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 16:05:26'),(1556,1,1,21,0,'2015-04-17 20:10:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 16:10:26'),(1557,1,1,21,0,'2015-04-17 20:15:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 16:15:27'),(1558,1,1,21,0,'2015-04-17 20:20:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 16:20:27'),(1559,1,1,21,0,'2015-04-17 20:25:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 16:25:27'),(1560,1,1,21,0,'2015-04-17 20:30:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 16:30:27'),(1561,1,1,21,0,'2015-04-17 20:35:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 16:35:27'),(1562,1,1,21,0,'2015-04-17 20:40:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 16:40:27'),(1563,1,1,21,0,'2015-04-17 20:45:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 16:45:28'),(1564,1,1,21,0,'2015-04-17 20:50:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 16:50:28'),(1565,1,1,21,0,'2015-04-17 20:55:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 16:55:28'),(1566,1,1,21,0,'2015-04-17 21:00:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 17:00:28'),(1567,1,1,21,0,'2015-04-17 21:05:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 17:05:28'),(1568,1,1,21,0,'2015-04-17 21:10:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 17:10:28'),(1569,1,1,21,0,'2015-04-17 21:15:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 17:15:29'),(1570,1,1,21,0,'2015-04-17 21:20:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 17:20:29'),(1571,1,1,21,0,'2015-04-17 21:25:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 17:25:29'),(1572,1,1,21,0,'2015-04-17 21:30:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 17:30:29'),(1573,1,1,21,0,'2015-04-17 21:35:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 17:35:29'),(1574,1,1,21,0,'2015-04-17 21:40:22','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 17:40:29'),(1575,1,1,21,0,'2015-04-17 21:45:22','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 17:45:30'),(1576,1,1,21,0,'2015-04-17 21:50:22','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 17:50:30'),(1577,1,1,21,0,'2015-04-17 21:55:22','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 17:55:30'),(1578,1,1,21,0,'2015-04-17 22:00:22','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 18:00:30'),(1579,1,1,21,0,'2015-04-17 22:05:22','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 18:05:30'),(1580,1,1,21,0,'2015-04-17 22:10:23','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 18:10:30'),(1581,1,1,21,0,'2015-04-17 22:15:23','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 18:15:31'),(1582,1,1,21,0,'2015-04-17 22:20:23','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 18:20:31'),(1583,1,1,21,0,'2015-04-17 22:25:23','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 18:25:31'),(1584,1,1,21,0,'2015-04-17 22:30:23','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 18:30:31'),(1585,1,1,21,0,'2015-04-17 22:35:23','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 18:35:31'),(1586,1,1,21,0,'2015-04-17 22:40:23','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 18:40:31'),(1587,1,1,21,0,'2015-04-17 22:45:24','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 18:45:31'),(1588,1,1,21,0,'2015-04-17 22:50:24','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 18:50:32'),(1589,1,1,21,0,'2015-04-17 22:55:24','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 18:55:32'),(1590,1,1,21,0,'2015-04-17 23:00:24','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 19:00:32'),(1591,1,1,21,0,'2015-04-17 23:05:24','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 19:05:32'),(1592,1,1,21,0,'2015-04-17 23:10:24','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 19:10:32'),(1593,1,1,21,0,'2015-04-17 23:15:25','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 19:15:32'),(1594,1,1,21,0,'2015-04-17 23:20:25','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 19:20:33'),(1595,1,1,21,0,'2015-04-17 23:25:25','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 19:25:33'),(1596,1,1,21,0,'2015-04-17 23:30:25','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 19:30:33'),(1597,1,1,21,0,'2015-04-17 23:35:25','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 19:35:33'),(1598,1,1,21,0,'2015-04-17 23:40:25','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 19:40:33'),(1599,1,1,21,0,'2015-04-17 23:45:26','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 19:45:33'),(1600,1,1,21,0,'2015-04-17 23:50:26','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 19:50:34'),(1601,1,1,21,0,'2015-04-17 23:55:26','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 19:55:34'),(1602,1,1,21,0,'2015-04-18 00:00:26','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 20:00:34'),(1603,1,1,21,0,'2015-04-18 00:05:26','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 20:05:34'),(1604,1,1,21,0,'2015-04-18 00:10:26','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 20:10:34'),(1605,1,1,21,0,'2015-04-18 00:15:27','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 20:15:34'),(1606,1,1,21,0,'2015-04-18 00:20:27','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 20:20:35'),(1607,1,1,21,0,'2015-04-18 00:25:27','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 20:25:35'),(1608,1,1,21,0,'2015-04-18 00:30:27','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 20:30:35'),(1609,1,1,21,0,'2015-04-18 00:35:27','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 20:35:35'),(1610,1,1,21,0,'2015-04-18 00:40:27','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 20:40:35'),(1611,1,1,21,0,'2015-04-18 00:45:27','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 20:45:35'),(1612,1,1,21,0,'2015-04-18 00:50:28','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 20:50:35'),(1613,1,1,21,0,'2015-04-18 00:55:28','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 20:55:36'),(1614,1,1,21,0,'2015-04-18 01:00:28','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 21:00:36'),(1615,1,1,21,0,'2015-04-18 01:05:28','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 21:05:36'),(1616,1,1,21,0,'2015-04-18 01:10:28','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 21:10:36'),(1617,1,1,21,0,'2015-04-18 01:15:28','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 21:15:36'),(1618,1,1,21,0,'2015-04-18 01:20:29','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 21:20:36'),(1619,1,1,21,0,'2015-04-18 01:25:29','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 21:25:37'),(1620,1,1,21,0,'2015-04-18 01:30:29','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 21:30:37'),(1621,1,1,21,0,'2015-04-18 01:35:29','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 21:35:37'),(1622,1,1,21,0,'2015-04-18 01:40:29','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 21:40:37'),(1623,1,1,21,0,'2015-04-18 01:45:30','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 21:45:38'),(1624,1,1,21,0,'2015-04-18 01:50:30','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 21:50:38'),(1625,1,1,21,0,'2015-04-18 01:55:30','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 21:55:38'),(1626,1,1,21,0,'2015-04-18 02:00:30','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 22:00:38'),(1627,1,1,21,0,'2015-04-18 02:05:30','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 22:05:38'),(1628,1,1,21,0,'2015-04-18 02:10:30','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 22:10:38'),(1629,1,1,21,0,'2015-04-18 02:15:31','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 22:15:38'),(1630,1,1,21,0,'2015-04-18 02:20:31','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 22:20:39'),(1631,1,1,21,0,'2015-04-18 02:25:31','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 22:25:39'),(1632,1,1,21,0,'2015-04-18 02:30:31','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 22:30:39'),(1633,1,1,21,0,'2015-04-18 02:35:31','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 22:35:39'),(1634,1,1,21,0,'2015-04-18 02:40:31','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 22:40:39'),(1635,1,1,21,0,'2015-04-18 02:45:32','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 22:45:39'),(1636,1,1,21,0,'2015-04-18 02:50:32','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 22:50:40'),(1637,1,1,21,0,'2015-04-18 02:55:32','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 22:55:40'),(1638,1,1,21,0,'2015-04-18 03:00:32','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 23:00:40'),(1639,1,1,21,0,'2015-04-18 03:05:32','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 23:05:40'),(1640,1,1,21,0,'2015-04-18 03:10:32','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 23:10:40'),(1641,1,1,21,0,'2015-04-18 03:15:33','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 23:15:40'),(1642,1,1,21,0,'2015-04-18 03:20:33','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 23:20:41'),(1643,1,1,21,0,'2015-04-18 03:25:33','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 23:25:41'),(1644,1,1,21,0,'2015-04-18 03:30:33','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 23:30:41'),(1645,1,1,21,0,'2015-04-18 03:35:33','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 23:35:41'),(1646,1,1,21,0,'2015-04-18 03:40:33','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 23:40:41'),(1647,1,1,21,0,'2015-04-18 03:45:34','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 23:45:41'),(1648,1,1,21,0,'2015-04-18 03:50:34','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 23:50:42'),(1649,1,1,21,0,'2015-04-18 03:55:34','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-17 23:55:42'),(1650,1,1,21,0,'2015-04-18 04:00:34','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 00:00:42'),(1651,1,1,21,0,'2015-04-18 04:05:34','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 00:05:42'),(1652,1,1,21,0,'2015-04-18 04:10:34','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 00:10:42'),(1653,1,1,21,0,'2015-04-18 04:15:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 00:15:42'),(1654,1,1,21,0,'2015-04-18 04:20:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 00:20:43'),(1655,1,1,21,0,'2015-04-18 04:25:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 00:25:43'),(1656,1,1,21,0,'2015-04-18 04:30:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 00:30:43'),(1657,1,1,21,0,'2015-04-18 04:35:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 00:35:43'),(1658,1,1,21,0,'2015-04-18 04:40:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 00:40:43'),(1659,1,1,21,0,'2015-04-18 04:45:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 00:45:43'),(1660,1,1,21,0,'2015-04-18 04:50:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 00:50:43'),(1661,1,1,21,0,'2015-04-18 04:55:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 00:55:44'),(1662,1,1,21,0,'2015-04-18 05:00:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 01:00:44'),(1663,1,1,21,0,'2015-04-18 05:05:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 01:05:44'),(1664,1,1,21,0,'2015-04-18 05:10:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 01:10:44'),(1665,1,1,21,0,'2015-04-18 05:15:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 01:15:44'),(1666,1,1,21,0,'2015-04-18 05:20:37','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 01:20:44'),(1667,1,1,21,0,'2015-04-18 05:25:37','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 01:25:45'),(1668,1,1,21,0,'2015-04-18 05:30:41','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 01:30:48'),(1669,1,1,21,0,'2015-04-18 05:35:41','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 01:35:49'),(1670,1,1,21,0,'2015-04-18 05:40:41','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 01:40:49'),(1671,1,1,21,0,'2015-04-18 05:45:45','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 01:45:53'),(1672,1,1,21,0,'2015-04-18 05:50:49','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 01:50:56'),(1673,1,1,21,0,'2015-04-18 05:55:53','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 01:56:00'),(1674,1,1,21,0,'2015-04-18 06:00:53','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 02:01:01'),(1675,1,1,21,0,'2015-04-18 06:05:53','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 02:06:01'),(1676,1,1,21,0,'2015-04-18 06:10:53','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 02:11:01'),(1677,1,1,21,0,'2015-04-18 06:15:53','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 02:16:01'),(1678,1,1,21,0,'2015-04-18 06:20:53','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 02:21:01'),(1679,1,1,21,0,'2015-04-18 06:25:54','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 02:26:01'),(1680,1,1,21,0,'2015-04-18 06:30:54','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 02:31:02'),(1681,1,1,21,0,'2015-04-18 06:35:54','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 02:36:02'),(1682,1,1,21,0,'2015-04-18 06:40:54','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 02:41:02'),(1683,1,1,21,0,'2015-04-18 06:45:58','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 02:46:06'),(1684,1,1,21,0,'2015-04-18 06:50:58','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 02:51:06'),(1685,1,1,21,0,'2015-04-18 06:55:58','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 02:56:06'),(1686,1,1,21,0,'2015-04-18 07:00:59','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 03:01:06'),(1687,1,1,21,0,'2015-04-18 07:05:59','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 03:06:07'),(1688,1,1,21,0,'2015-04-18 07:11:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 03:11:10'),(1689,1,1,21,0,'2015-04-18 07:16:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 03:16:11'),(1690,1,1,21,0,'2015-04-18 07:21:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 03:21:11'),(1691,1,1,21,0,'2015-04-18 07:26:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 03:26:11'),(1692,1,1,21,0,'2015-04-18 07:31:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 03:31:11'),(1693,1,1,21,0,'2015-04-18 07:36:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 03:36:11'),(1694,1,1,21,0,'2015-04-18 07:41:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 03:41:11'),(1695,1,1,21,0,'2015-04-18 07:46:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 03:46:12'),(1696,1,1,21,0,'2015-04-18 07:51:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 03:51:12'),(1697,1,1,21,0,'2015-04-18 07:56:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 03:56:12'),(1698,1,1,21,0,'2015-04-18 08:01:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 04:01:12'),(1699,1,1,21,0,'2015-04-18 08:06:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 04:06:12'),(1700,1,1,21,0,'2015-04-18 08:11:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 04:11:12'),(1701,1,1,21,0,'2015-04-18 08:16:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 04:16:13'),(1702,1,1,21,0,'2015-04-18 08:21:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 04:21:13'),(1703,1,1,21,0,'2015-04-18 08:26:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 04:26:13'),(1704,1,1,21,0,'2015-04-18 08:31:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 04:31:13'),(1705,1,1,21,0,'2015-04-18 08:36:06','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 04:36:13'),(1706,1,1,21,0,'2015-04-18 08:41:06','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 04:41:14'),(1707,1,1,21,0,'2015-04-18 08:46:06','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 04:46:14'),(1708,1,1,21,0,'2015-04-18 08:51:06','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 04:51:14'),(1709,1,1,21,0,'2015-04-18 08:56:06','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 04:56:14'),(1710,1,1,21,0,'2015-04-18 09:01:07','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 05:01:14'),(1711,1,1,21,0,'2015-04-18 09:06:07','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 05:06:15'),(1712,1,1,21,0,'2015-04-18 09:11:07','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 05:11:15'),(1713,1,1,21,0,'2015-04-18 09:16:07','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 05:16:15'),(1714,1,1,21,0,'2015-04-18 09:21:07','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 05:21:15'),(1715,1,1,21,0,'2015-04-18 09:26:07','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 05:26:15'),(1716,1,1,21,0,'2015-04-18 09:31:08','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 05:31:15'),(1717,1,1,21,0,'2015-04-18 09:36:08','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 05:36:16'),(1718,1,1,21,0,'2015-04-18 09:41:08','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 05:41:16'),(1719,1,1,21,0,'2015-04-18 09:46:08','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 05:46:16'),(1720,1,1,21,0,'2015-04-18 09:51:08','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 05:51:16'),(1721,1,1,21,0,'2015-04-18 09:56:08','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 05:56:16'),(1722,1,1,21,0,'2015-04-18 10:01:09','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 06:01:16'),(1723,1,1,21,0,'2015-04-18 10:06:09','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 06:06:17'),(1724,1,1,21,0,'2015-04-18 10:11:09','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 06:11:17'),(1725,1,1,21,0,'2015-04-18 10:16:09','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 06:16:17'),(1726,1,1,21,0,'2015-04-18 10:21:09','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 06:21:17'),(1727,1,1,21,0,'2015-04-18 10:26:09','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 06:26:17'),(1728,1,1,21,0,'2015-04-18 10:31:10','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 06:31:17'),(1729,1,1,21,0,'2015-04-18 10:36:10','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 06:36:18'),(1730,1,1,21,0,'2015-04-18 10:41:10','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 06:41:18'),(1731,1,1,21,0,'2015-04-18 10:46:10','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 06:46:18'),(1732,1,1,21,0,'2015-04-18 10:51:10','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 06:51:18'),(1733,1,1,21,0,'2015-04-18 10:56:10','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 06:56:18'),(1734,1,1,21,0,'2015-04-18 11:01:11','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 07:01:18'),(1735,1,1,21,0,'2015-04-18 11:06:11','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 07:06:19'),(1736,1,1,21,0,'2015-04-18 11:11:11','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 07:11:19'),(1737,1,1,21,0,'2015-04-18 11:16:11','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 07:16:19'),(1738,1,1,21,0,'2015-04-18 11:21:11','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 07:21:19'),(1739,1,1,21,0,'2015-04-18 11:26:11','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 07:26:19'),(1740,1,1,21,0,'2015-04-18 11:31:11','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 07:31:19'),(1741,1,1,21,0,'2015-04-18 11:36:12','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 07:36:19'),(1742,1,1,21,0,'2015-04-18 11:41:12','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 07:41:20'),(1743,1,1,21,0,'2015-04-18 11:46:12','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 07:46:20'),(1744,1,1,21,0,'2015-04-18 11:51:12','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 07:51:20'),(1745,1,1,21,0,'2015-04-18 11:56:12','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 07:56:20'),(1746,1,1,21,0,'2015-04-18 12:01:12','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 08:01:20'),(1747,1,1,21,0,'2015-04-18 12:06:13','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 08:06:20'),(1748,1,1,21,0,'2015-04-18 12:11:13','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 08:11:21'),(1749,1,1,21,0,'2015-04-18 12:16:13','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 08:16:21'),(1750,1,1,21,0,'2015-04-18 12:21:13','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 08:21:21'),(1751,1,1,21,0,'2015-04-18 12:26:13','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 08:26:21'),(1752,1,1,21,0,'2015-04-18 12:31:13','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 08:31:21'),(1753,1,1,21,0,'2015-04-18 12:36:14','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 08:36:21'),(1754,1,1,21,0,'2015-04-18 12:41:14','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 08:41:22'),(1755,1,1,21,0,'2015-04-18 12:46:14','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 08:46:22'),(1756,1,1,21,0,'2015-04-18 12:51:14','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 08:51:22'),(1757,1,1,21,0,'2015-04-18 12:56:14','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 08:56:22'),(1758,1,1,21,0,'2015-04-18 13:01:14','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 09:01:22'),(1759,1,1,21,0,'2015-04-18 13:06:15','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 09:06:22'),(1760,1,1,21,0,'2015-04-18 13:11:15','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 09:11:23'),(1761,1,1,21,0,'2015-04-18 13:16:15','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 09:16:23'),(1762,1,1,21,0,'2015-04-18 13:21:15','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 09:21:23'),(1763,1,1,21,0,'2015-04-18 13:26:15','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 09:26:23'),(1764,1,1,21,0,'2015-04-18 13:31:15','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 09:31:23'),(1765,1,1,21,0,'2015-04-18 13:36:16','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 09:36:23'),(1766,1,1,21,0,'2015-04-18 13:41:16','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 09:41:24'),(1767,1,1,21,0,'2015-04-18 13:46:16','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 09:46:24'),(1768,1,1,21,0,'2015-04-18 13:52:16','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 09:52:24'),(1769,1,1,21,0,'2015-04-18 13:57:16','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 09:57:24'),(1770,1,1,21,0,'2015-04-18 14:02:16','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 10:02:24'),(1771,1,1,21,0,'2015-04-18 14:07:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 10:07:24'),(1772,1,1,21,0,'2015-04-18 14:12:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 10:12:25'),(1773,1,1,21,0,'2015-04-18 14:17:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 10:17:25'),(1774,1,1,21,0,'2015-04-18 14:22:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 10:22:25'),(1775,1,1,21,0,'2015-04-18 14:27:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 10:27:25'),(1776,1,1,21,0,'2015-04-18 14:32:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 10:32:25'),(1777,1,1,21,0,'2015-04-18 14:37:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 10:37:25'),(1778,1,1,21,0,'2015-04-18 14:42:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 10:42:26'),(1779,1,1,21,0,'2015-04-18 14:47:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 10:47:26'),(1780,1,1,21,0,'2015-04-18 14:52:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 10:52:26'),(1781,1,1,21,0,'2015-04-18 14:57:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 10:57:26'),(1782,1,1,21,0,'2015-04-18 15:02:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 11:02:26'),(1783,1,1,21,0,'2015-04-18 15:07:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 11:07:26'),(1784,1,1,21,0,'2015-04-18 15:12:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 11:12:26'),(1785,1,1,21,0,'2015-04-18 15:17:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 11:17:27'),(1786,1,1,21,0,'2015-04-18 15:22:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 11:22:27'),(1787,1,1,21,0,'2015-04-18 15:27:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 11:27:27'),(1788,1,1,21,0,'2015-04-18 15:32:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 11:32:27'),(1789,1,1,21,0,'2015-04-18 15:37:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 11:37:27'),(1790,1,1,21,0,'2015-04-18 15:42:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 11:42:27'),(1791,1,1,21,0,'2015-04-18 15:47:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 11:47:28'),(1792,1,1,21,0,'2015-04-18 15:52:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 11:52:28'),(1793,1,1,21,0,'2015-04-18 15:57:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 11:57:28'),(1794,1,1,21,0,'2015-04-18 16:02:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 12:02:29'),(1795,1,1,21,0,'2015-04-18 16:07:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 12:07:29'),(1796,1,1,21,0,'2015-04-18 16:12:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 12:12:29'),(1797,1,1,21,0,'2015-04-18 16:17:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 12:17:29'),(1798,1,1,21,0,'2015-04-18 16:22:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 12:22:29'),(1799,1,1,21,0,'2015-04-18 16:27:22','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 12:27:29'),(1800,1,1,21,0,'2015-04-18 16:32:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 12:32:30'),(1801,1,1,21,0,'2015-04-18 16:37:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 12:37:30'),(1802,1,1,21,0,'2015-04-18 16:42:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 12:42:30'),(1803,1,1,21,0,'2015-04-18 16:47:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 12:47:30'),(1804,1,1,21,0,'2015-04-18 16:52:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 12:52:30'),(1805,1,1,21,0,'2015-04-18 16:57:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 12:57:30'),(1806,1,1,21,0,'2015-04-18 17:02:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 13:02:31'),(1807,1,1,21,0,'2015-04-18 17:07:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 13:07:31'),(1808,1,1,21,0,'2015-04-18 17:12:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 13:12:31'),(1809,1,1,21,0,'2015-04-18 17:17:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 13:17:31'),(1810,1,1,21,0,'2015-04-18 17:22:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 13:22:31'),(1811,1,1,21,0,'2015-04-18 17:27:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 13:27:31'),(1812,1,1,21,0,'2015-04-18 17:32:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 13:32:32'),(1813,1,1,21,0,'2015-04-18 17:37:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 13:37:32'),(1814,1,1,21,0,'2015-04-18 17:42:22','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 13:42:32'),(1815,1,1,21,0,'2015-04-18 17:47:22','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 13:47:32'),(1816,1,1,21,0,'2015-04-18 17:52:22','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 13:52:32'),(1817,1,1,21,0,'2015-04-18 17:57:22','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 13:57:32'),(1818,1,1,21,0,'2015-04-18 18:02:22','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 14:02:32'),(1819,1,1,21,0,'2015-04-18 18:07:22','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 14:07:33'),(1820,1,1,21,0,'2015-04-18 18:12:23','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 14:12:33'),(1821,1,1,21,0,'2015-04-18 18:17:23','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 14:17:33'),(1822,1,1,21,0,'2015-04-18 18:22:23','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 14:22:33'),(1823,1,1,21,0,'2015-04-18 18:27:23','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 14:27:33'),(1824,1,1,21,0,'2015-04-18 18:32:23','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 14:32:33'),(1825,1,1,21,0,'2015-04-18 18:37:23','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 14:37:34'),(1826,1,1,21,0,'2015-04-18 18:42:24','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 14:42:34'),(1827,1,1,21,0,'2015-04-18 18:47:24','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 14:47:34'),(1828,1,1,21,0,'2015-04-18 18:52:24','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 14:52:34'),(1829,1,1,21,0,'2015-04-18 18:57:24','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 14:57:34'),(1830,1,1,21,0,'2015-04-18 19:02:24','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 15:02:34'),(1831,1,1,21,0,'2015-04-18 19:07:24','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 15:07:35'),(1832,1,1,21,0,'2015-04-18 19:12:24','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 15:12:35'),(1833,1,1,21,0,'2015-04-18 19:17:25','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 15:17:35'),(1834,1,1,21,0,'2015-04-18 19:22:25','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 15:22:35'),(1835,1,1,21,0,'2015-04-18 19:27:25','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 15:27:35'),(1836,1,1,21,0,'2015-04-18 19:32:25','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 15:32:35'),(1837,1,1,21,0,'2015-04-18 19:37:25','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 15:37:36'),(1838,1,1,21,0,'2015-04-18 19:42:25','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 15:42:36'),(1839,1,1,21,0,'2015-04-18 19:47:26','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 15:47:36'),(1840,1,1,21,0,'2015-04-18 19:52:26','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 15:52:36'),(1841,1,1,21,0,'2015-04-18 19:57:26','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 15:57:36'),(1842,1,1,21,0,'2015-04-18 20:02:26','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 16:02:36'),(1843,1,1,21,0,'2015-04-18 20:07:26','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 16:07:37'),(1844,1,1,21,0,'2015-04-18 20:12:26','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 16:12:37'),(1845,1,1,21,0,'2015-04-18 20:17:27','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 16:17:37'),(1846,1,1,21,0,'2015-04-18 20:22:27','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 16:22:37'),(1847,1,1,21,0,'2015-04-18 20:27:27','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 16:27:37'),(1848,1,1,21,0,'2015-04-18 20:32:27','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 16:32:37'),(1849,1,1,21,0,'2015-04-18 20:37:27','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 16:37:38'),(1850,1,1,21,0,'2015-04-18 20:42:27','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 16:42:38'),(1851,1,1,21,0,'2015-04-18 20:47:28','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 16:47:38'),(1852,1,1,21,0,'2015-04-18 20:52:28','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 16:52:38'),(1853,1,1,21,0,'2015-04-18 20:57:28','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 16:57:38'),(1854,1,1,21,0,'2015-04-18 21:02:28','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 17:02:38'),(1855,1,1,21,0,'2015-04-18 21:07:28','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 17:07:38'),(1856,1,1,21,0,'2015-04-18 21:12:28','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 17:12:39'),(1857,1,1,21,0,'2015-04-18 21:17:29','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 17:17:39'),(1858,1,1,21,0,'2015-04-18 21:22:29','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 17:22:39'),(1859,1,1,21,0,'2015-04-18 21:27:29','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 17:27:39'),(1860,1,1,21,0,'2015-04-18 21:32:29','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 17:32:39'),(1861,1,1,21,0,'2015-04-18 21:37:29','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 17:37:39'),(1862,1,1,21,0,'2015-04-18 21:42:29','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 17:42:40'),(1863,1,1,21,0,'2015-04-18 21:47:29','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 17:47:40'),(1864,1,1,21,0,'2015-04-18 21:52:30','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 17:52:40'),(1865,1,1,21,0,'2015-04-18 21:57:30','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 17:57:40'),(1866,1,1,21,0,'2015-04-18 22:02:30','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 18:02:40'),(1867,1,1,21,0,'2015-04-18 22:07:30','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 18:07:40'),(1868,1,1,21,0,'2015-04-18 22:12:30','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 18:12:41'),(1869,1,1,21,0,'2015-04-18 22:17:30','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 18:17:41'),(1870,1,1,21,0,'2015-04-18 22:22:31','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 18:22:41'),(1871,1,1,21,0,'2015-04-18 22:27:31','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 18:27:41'),(1872,1,1,21,0,'2015-04-18 22:32:31','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 18:32:41'),(1873,1,1,21,0,'2015-04-18 22:37:31','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 18:37:41'),(1874,1,1,21,0,'2015-04-18 22:42:31','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 18:42:42'),(1875,1,1,21,0,'2015-04-18 22:47:31','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 18:47:42'),(1876,1,1,21,0,'2015-04-18 22:52:32','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 18:52:42'),(1877,1,1,21,0,'2015-04-18 22:57:32','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 18:57:42'),(1878,1,1,21,0,'2015-04-18 23:02:32','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 19:02:42'),(1879,1,1,21,0,'2015-04-18 23:07:32','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 19:07:42'),(1880,1,1,21,0,'2015-04-18 23:12:32','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 19:12:43'),(1881,1,1,21,0,'2015-04-18 23:17:32','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 19:17:43'),(1882,1,1,21,0,'2015-04-18 23:22:33','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 19:22:43'),(1883,1,1,21,0,'2015-04-18 23:27:33','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 19:27:43'),(1884,1,1,21,0,'2015-04-18 23:32:33','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 19:32:43'),(1885,1,1,21,0,'2015-04-18 23:37:33','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 19:37:43'),(1886,1,1,21,0,'2015-04-18 23:42:33','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 19:42:43'),(1887,1,1,21,0,'2015-04-18 23:47:33','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 19:47:44'),(1888,1,1,21,0,'2015-04-18 23:52:34','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 19:52:44'),(1889,1,1,21,0,'2015-04-18 23:57:34','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 19:57:44'),(1890,1,1,21,0,'2015-04-19 00:02:34','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 20:02:44'),(1891,1,1,21,0,'2015-04-19 00:07:34','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 20:07:44'),(1892,1,1,21,0,'2015-04-19 00:12:34','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 20:12:44'),(1893,1,1,21,0,'2015-04-19 00:17:34','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 20:17:45'),(1894,1,1,21,0,'2015-04-19 00:22:34','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 20:22:45'),(1895,1,1,21,0,'2015-04-19 00:27:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 20:27:45'),(1896,1,1,21,0,'2015-04-19 00:32:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 20:32:45'),(1897,1,1,21,0,'2015-04-19 00:37:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 20:37:45'),(1898,1,1,21,0,'2015-04-19 00:42:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 20:42:45'),(1899,1,1,21,0,'2015-04-19 00:47:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 20:47:46'),(1900,1,1,21,0,'2015-04-19 00:52:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 20:52:46'),(1901,1,1,21,0,'2015-04-19 00:57:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 20:57:46'),(1902,1,1,21,0,'2015-04-19 01:02:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 21:02:46'),(1903,1,1,21,0,'2015-04-19 01:07:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 21:07:46'),(1904,1,1,21,0,'2015-04-19 01:12:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 21:12:46'),(1905,1,1,21,0,'2015-04-19 01:17:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 21:17:47'),(1906,1,1,21,0,'2015-04-19 01:22:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 21:22:47'),(1907,1,1,21,0,'2015-04-19 01:27:37','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 21:27:47'),(1908,1,1,21,0,'2015-04-19 01:32:37','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 21:32:47'),(1909,1,1,21,0,'2015-04-19 01:37:37','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 21:37:47'),(1910,1,1,21,0,'2015-04-19 01:42:37','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 21:42:47'),(1911,1,1,21,0,'2015-04-19 01:47:37','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 21:47:48'),(1912,1,1,21,0,'2015-04-19 01:52:37','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 21:52:48'),(1913,1,1,21,0,'2015-04-19 01:57:38','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 21:57:48'),(1914,1,1,21,0,'2015-04-19 02:02:38','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 22:02:48'),(1915,1,1,21,0,'2015-04-19 02:07:38','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 22:07:48'),(1916,1,1,21,0,'2015-04-19 02:12:38','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 22:12:48'),(1917,1,1,21,0,'2015-04-19 02:17:38','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 22:17:49'),(1918,1,1,21,0,'2015-04-19 02:22:38','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 22:22:49'),(1919,1,1,21,0,'2015-04-19 02:27:39','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 22:27:49'),(1920,1,1,21,0,'2015-04-19 02:32:39','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 22:32:49'),(1921,1,1,21,0,'2015-04-19 02:37:39','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 22:37:49'),(1922,1,1,21,0,'2015-04-19 02:42:39','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 22:42:49'),(1923,1,1,21,0,'2015-04-19 02:47:39','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 22:47:50'),(1924,1,1,21,0,'2015-04-19 02:52:39','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 22:52:50'),(1925,1,1,21,0,'2015-04-19 02:57:40','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 22:57:50'),(1926,1,1,21,0,'2015-04-19 03:02:40','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 23:02:50'),(1927,1,1,21,0,'2015-04-19 03:07:40','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 23:07:50'),(1928,1,1,21,0,'2015-04-19 03:12:40','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 23:12:50'),(1929,1,1,21,0,'2015-04-19 03:17:40','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 23:17:50'),(1930,1,1,21,0,'2015-04-19 03:22:40','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 23:22:51'),(1931,1,1,21,0,'2015-04-19 03:27:41','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 23:27:51'),(1932,1,1,21,0,'2015-04-19 03:32:41','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 23:32:51'),(1933,1,1,21,0,'2015-04-19 03:37:41','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 23:37:51'),(1934,1,1,21,0,'2015-04-19 03:42:41','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 23:42:51'),(1935,1,1,21,0,'2015-04-19 03:48:41','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 23:48:51'),(1936,1,1,21,0,'2015-04-19 03:53:41','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 23:53:52'),(1937,1,1,21,0,'2015-04-19 03:58:42','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-18 23:58:52'),(1938,1,1,21,0,'2015-04-19 04:03:42','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 00:03:52'),(1939,1,1,21,0,'2015-04-19 04:08:42','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 00:08:52'),(1940,1,1,21,0,'2015-04-19 04:13:42','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 00:13:52'),(1941,1,1,21,0,'2015-04-19 04:18:42','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 00:18:52'),(1942,1,1,21,0,'2015-04-19 04:23:42','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 00:23:53'),(1943,1,1,21,0,'2015-04-19 04:28:42','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 00:28:53'),(1944,1,1,21,0,'2015-04-19 04:33:43','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 00:33:53'),(1945,1,1,21,0,'2015-04-19 04:38:43','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 00:38:53'),(1946,1,1,21,0,'2015-04-19 04:43:43','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 00:43:53'),(1947,1,1,21,0,'2015-04-19 04:48:43','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 00:48:53'),(1948,1,1,21,0,'2015-04-19 04:53:43','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 00:53:54'),(1949,1,1,21,0,'2015-04-19 04:58:43','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 00:58:54'),(1950,1,1,21,0,'2015-04-19 05:03:44','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 01:03:54'),(1951,1,1,21,0,'2015-04-19 05:08:44','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 01:08:54'),(1952,1,1,21,0,'2015-04-19 05:13:44','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 01:13:54'),(1953,1,1,21,0,'2015-04-19 05:18:44','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 01:18:54'),(1954,1,1,21,0,'2015-04-19 05:23:44','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 01:23:55'),(1955,1,1,21,0,'2015-04-19 05:28:44','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 01:28:55'),(1956,1,1,21,0,'2015-04-19 05:33:45','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 01:33:55'),(1957,1,1,21,0,'2015-04-19 05:38:45','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 01:38:55'),(1958,1,1,21,0,'2015-04-19 05:43:45','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 01:43:55'),(1959,1,1,21,0,'2015-04-19 05:48:45','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 01:48:55'),(1960,1,1,21,0,'2015-04-19 05:53:45','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 01:53:55'),(1961,1,1,21,0,'2015-04-19 05:58:45','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 01:58:56'),(1962,1,1,21,0,'2015-04-19 06:03:46','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 02:03:56'),(1963,1,1,21,0,'2015-04-19 06:08:46','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 02:08:56'),(1964,1,1,21,0,'2015-04-19 06:13:46','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 02:13:56'),(1965,1,1,21,0,'2015-04-19 06:18:46','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 02:18:56'),(1966,1,1,21,0,'2015-04-19 06:23:46','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 02:23:56'),(1967,1,1,21,0,'2015-04-19 06:28:46','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 02:28:57'),(1968,1,1,21,0,'2015-04-19 06:33:46','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 02:33:57'),(1969,1,1,21,0,'2015-04-19 06:38:47','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 02:38:57'),(1970,1,1,21,0,'2015-04-19 06:43:47','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 02:43:57'),(1971,1,1,21,0,'2015-04-19 06:48:47','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 02:48:57'),(1972,1,1,21,0,'2015-04-19 06:53:47','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 02:53:57'),(1973,1,1,21,0,'2015-04-19 06:58:47','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 02:58:58'),(1974,1,1,21,0,'2015-04-19 07:03:47','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 03:03:58'),(1975,1,1,21,0,'2015-04-19 07:08:48','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 03:08:58'),(1976,1,1,21,0,'2015-04-19 07:13:48','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 03:13:58'),(1977,1,1,21,0,'2015-04-19 07:18:48','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 03:18:58'),(1978,1,1,21,0,'2015-04-19 07:23:48','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 03:23:58'),(1979,1,1,21,0,'2015-04-19 07:28:48','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 03:28:59'),(1980,1,1,21,0,'2015-04-19 07:33:48','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 03:33:59'),(1981,1,1,21,0,'2015-04-19 07:38:49','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 03:38:59'),(1982,1,1,21,0,'2015-04-19 07:43:49','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 03:43:59'),(1983,1,1,21,0,'2015-04-19 07:48:49','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 03:48:59'),(1984,1,1,21,0,'2015-04-19 07:53:49','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 03:53:59'),(1985,1,1,21,0,'2015-04-19 07:58:49','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 03:59:00'),(1986,1,1,21,0,'2015-04-19 08:03:49','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 04:04:00'),(1987,1,1,21,0,'2015-04-19 08:08:50','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 04:09:00'),(1988,1,1,21,0,'2015-04-19 08:13:50','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 04:14:00'),(1989,1,1,21,0,'2015-04-19 08:18:50','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 04:19:00'),(1990,1,1,21,0,'2015-04-19 08:23:50','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 04:24:00'),(1991,1,1,21,0,'2015-04-19 08:28:50','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 04:29:00'),(1992,1,1,21,0,'2015-04-19 08:33:50','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 04:34:01'),(1993,1,1,21,0,'2015-04-19 08:38:50','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 04:39:01'),(1994,1,1,21,0,'2015-04-19 08:43:51','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 04:44:01'),(1995,1,1,21,0,'2015-04-19 08:48:51','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 04:49:01'),(1996,1,1,21,0,'2015-04-19 08:53:51','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 04:54:01'),(1997,1,1,21,0,'2015-04-19 08:58:51','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 04:59:01'),(1998,1,1,21,0,'2015-04-19 09:03:51','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 05:04:02'),(1999,1,1,21,0,'2015-04-19 09:08:52','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 05:09:02'),(2000,1,1,21,0,'2015-04-19 09:13:52','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 05:14:02'),(2001,1,1,21,0,'2015-04-19 09:18:52','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 05:19:02'),(2002,1,1,21,0,'2015-04-19 09:23:52','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 05:24:03'),(2003,1,1,21,0,'2015-04-19 09:28:52','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 05:29:03'),(2004,1,1,21,0,'2015-04-19 09:33:53','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 05:34:03'),(2005,1,1,21,0,'2015-04-19 09:38:53','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 05:39:03'),(2006,1,1,21,0,'2015-04-19 09:43:53','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 05:44:03'),(2007,1,1,21,0,'2015-04-19 09:48:57','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 05:49:07'),(2008,1,1,21,0,'2015-04-19 09:54:01','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 05:54:11'),(2009,1,1,21,0,'2015-04-19 09:59:01','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 05:59:11'),(2010,1,1,21,0,'2015-04-19 10:04:01','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 06:04:11'),(2011,1,1,21,0,'2015-04-19 10:09:01','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 06:09:12'),(2012,1,1,21,0,'2015-04-19 10:14:01','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 06:14:12'),(2013,1,1,21,0,'2015-04-19 10:19:02','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 06:19:12'),(2014,1,1,21,0,'2015-04-19 10:24:02','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 06:24:12'),(2015,1,1,21,0,'2015-04-19 10:29:02','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 06:29:12'),(2016,1,1,21,0,'2015-04-19 10:34:02','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 06:34:12'),(2017,1,1,21,0,'2015-04-19 10:39:02','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 06:39:13'),(2018,1,1,21,0,'2015-04-19 10:44:02','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 06:44:13'),(2019,1,1,21,0,'2015-04-19 10:49:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 06:49:13'),(2020,1,1,21,0,'2015-04-19 10:54:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 06:54:13'),(2021,1,1,21,0,'2015-04-19 10:59:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 06:59:13'),(2022,1,1,21,0,'2015-04-19 11:04:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 07:04:13'),(2023,1,1,21,0,'2015-04-19 11:09:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 07:09:13'),(2024,1,1,21,0,'2015-04-19 11:14:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 07:14:14'),(2025,1,1,21,0,'2015-04-19 11:19:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 07:19:14'),(2026,1,1,21,0,'2015-04-19 11:24:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 07:24:14'),(2027,1,1,21,0,'2015-04-19 11:29:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 07:29:14'),(2028,1,1,21,0,'2015-04-19 11:34:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 07:34:14'),(2029,1,1,21,0,'2015-04-19 11:39:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 07:39:14'),(2030,1,1,21,0,'2015-04-19 11:44:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 07:44:15'),(2031,1,1,21,0,'2015-04-19 11:49:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 07:49:15'),(2032,1,1,21,0,'2015-04-19 11:54:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 07:54:15'),(2033,1,1,21,0,'2015-04-19 11:59:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 07:59:15'),(2034,1,1,21,0,'2015-04-19 12:04:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 08:04:15'),(2035,1,1,21,0,'2015-04-19 12:09:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 08:09:15'),(2036,1,1,21,0,'2015-04-19 12:14:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 08:14:16'),(2037,1,1,21,0,'2015-04-19 12:19:16','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 08:19:26'),(2038,1,1,21,0,'2015-04-19 12:24:16','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 08:24:27'),(2039,1,1,21,0,'2015-04-19 12:29:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 08:29:27'),(2040,1,1,21,0,'2015-04-19 12:34:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 08:34:27'),(2041,1,1,21,0,'2015-04-19 12:39:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 08:39:27'),(2042,1,1,21,0,'2015-04-19 12:44:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 08:44:27'),(2043,1,1,21,0,'2015-04-19 12:49:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 08:49:27'),(2044,1,1,21,0,'2015-04-19 12:54:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 08:54:28'),(2045,1,1,21,0,'2015-04-19 12:59:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 08:59:28'),(2046,1,1,21,0,'2015-04-19 13:04:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 09:04:28'),(2047,1,1,21,0,'2015-04-19 13:09:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 09:09:28'),(2048,1,1,21,0,'2015-04-19 13:14:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 09:14:28'),(2049,1,1,21,0,'2015-04-19 13:19:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 09:19:28'),(2050,1,1,21,0,'2015-04-19 13:24:18','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 09:24:29'),(2051,1,1,21,0,'2015-04-19 13:29:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 09:29:29'),(2052,1,1,21,0,'2015-04-19 13:34:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 09:34:29'),(2053,1,1,21,0,'2015-04-19 13:39:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 09:39:29'),(2054,1,1,21,0,'2015-04-19 13:44:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 09:44:29'),(2055,1,1,21,0,'2015-04-19 13:49:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 09:49:29'),(2056,1,1,21,0,'2015-04-19 13:54:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 09:54:30'),(2057,1,1,21,0,'2015-04-19 13:59:19','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 09:59:30'),(2058,1,1,21,0,'2015-04-19 14:04:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 10:04:30'),(2059,1,1,21,0,'2015-04-19 14:09:25','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 10:09:35'),(2060,1,1,21,0,'2015-04-19 14:16:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 10:16:13'),(2061,1,1,21,0,'2015-04-19 14:21:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 10:21:13'),(2062,1,1,21,0,'2015-04-19 14:26:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 10:26:14'),(2063,1,1,21,0,'2015-04-19 14:31:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 10:31:14'),(2064,1,1,21,0,'2015-04-19 14:36:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 10:36:14'),(2065,1,1,21,0,'2015-04-19 14:42:12','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 10:42:22'),(2066,1,1,21,0,'2015-04-19 14:47:56','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 10:48:06'),(2067,1,1,21,0,'2015-04-19 14:54:38','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 10:54:48'),(2068,1,1,21,0,'2015-04-19 15:00:54','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 11:01:05'),(2069,1,1,21,0,'2015-04-19 15:08:29','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 11:08:39'),(2070,1,1,21,0,'2015-04-19 15:17:14','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 11:17:24'),(2071,1,1,21,0,'2015-04-19 15:24:16','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 11:24:27'),(2072,1,1,21,0,'2015-04-19 15:37:08','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 11:37:19'),(2073,1,1,21,0,'2015-04-19 15:51:57','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 11:52:07'),(2074,1,1,21,0,'2015-04-19 16:15:20','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 12:15:30'),(2075,1,1,21,0,'2015-04-19 16:33:37','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 12:33:47'),(2076,1,1,21,0,'2015-04-19 16:53:38','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 12:53:48'),(2077,1,1,21,0,'2015-04-19 17:00:33','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 13:00:43'),(2078,1,1,21,0,'2015-04-19 17:11:21','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 13:11:31'),(2079,1,1,21,0,'2015-04-19 17:19:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 13:19:45'),(2080,1,1,21,0,'2015-04-19 17:30:02','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 13:30:12'),(2081,1,1,21,0,'2015-04-19 17:37:41','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 13:37:51'),(2082,1,1,21,0,'2015-04-19 17:48:26','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 13:48:36'),(2083,1,1,21,0,'2015-04-19 17:52:17','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 13:52:27'),(2084,1,1,21,0,'2015-04-19 17:57:23','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 13:57:33'),(2085,1,1,21,0,'2015-04-19 18:02:23','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 14:02:34'),(2086,1,1,21,0,'2015-04-19 18:07:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 14:07:45'),(2087,1,1,21,0,'2015-04-19 18:12:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 14:12:45'),(2088,1,1,21,0,'2015-04-19 18:17:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 14:17:45'),(2089,1,1,21,0,'2015-04-19 18:22:35','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 14:22:46'),(2090,1,1,21,0,'2015-04-19 18:27:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 14:27:46'),(2091,1,1,21,0,'2015-04-19 18:32:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 14:32:46'),(2092,1,1,21,0,'2015-04-19 18:37:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 14:37:46'),(2093,1,1,21,0,'2015-04-19 18:42:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 14:42:46'),(2094,1,1,21,0,'2015-04-19 18:47:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 14:47:47'),(2095,1,1,21,0,'2015-04-19 18:52:36','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 14:52:47'),(2096,1,1,21,0,'2015-04-19 18:57:37','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 14:57:47'),(2097,1,1,21,0,'2015-04-19 19:02:37','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 15:02:47'),(2098,1,1,21,0,'2015-04-19 19:07:37','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 15:07:47'),(2099,1,1,21,0,'2015-04-19 19:12:37','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 15:12:47'),(2100,1,1,21,0,'2015-04-19 19:17:37','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 15:17:48'),(2101,1,1,21,0,'2015-04-19 19:22:37','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 15:22:48'),(2102,1,1,21,0,'2015-04-19 19:27:38','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 15:27:48'),(2103,1,1,21,0,'2015-04-19 19:32:38','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 15:32:48'),(2104,1,1,21,0,'2015-04-19 19:37:38','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 15:37:48'),(2105,1,1,21,0,'2015-04-19 19:42:38','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 15:42:48'),(2106,1,1,21,0,'2015-04-19 19:47:38','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 15:47:49'),(2107,1,1,21,0,'2015-04-19 19:52:38','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 15:52:49'),(2108,1,1,21,0,'2015-04-19 19:57:39','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 15:57:49'),(2109,1,1,21,0,'2015-04-19 20:02:39','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 16:02:49'),(2110,1,1,21,0,'2015-04-19 20:07:39','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 16:07:49'),(2111,1,1,21,0,'2015-04-19 20:12:39','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 16:12:49'),(2112,1,1,21,0,'2015-04-19 20:17:39','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 16:17:50'),(2113,1,1,21,0,'2015-04-19 20:22:39','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 16:22:50'),(2114,1,1,21,0,'2015-04-19 20:27:40','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 16:27:50'),(2115,1,1,21,0,'2015-04-19 20:32:40','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 16:32:50'),(2116,1,1,21,0,'2015-04-19 20:37:40','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 16:37:50'),(2117,1,1,21,0,'2015-04-19 20:42:40','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 16:42:50'),(2118,1,1,21,0,'2015-04-19 20:47:40','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 16:47:51'),(2119,1,1,21,0,'2015-04-19 20:52:40','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 16:52:51'),(2120,1,1,21,0,'2015-04-19 20:57:41','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 16:57:51'),(2121,1,1,21,0,'2015-04-19 21:02:41','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 17:02:51'),(2122,1,1,21,0,'2015-04-19 21:07:41','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 17:07:51'),(2123,1,1,21,0,'2015-04-19 21:12:41','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 17:12:51'),(2124,1,1,21,0,'2015-04-19 21:17:41','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 17:17:52'),(2125,1,1,21,0,'2015-04-19 21:22:41','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 17:22:52'),(2126,1,1,21,0,'2015-04-19 21:27:42','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 17:27:52'),(2127,1,1,21,0,'2015-04-19 21:32:42','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 17:32:52'),(2128,1,1,21,0,'2015-04-19 21:37:42','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 17:37:52'),(2129,1,1,21,0,'2015-04-19 21:42:42','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 17:42:52'),(2130,1,1,21,0,'2015-04-19 21:47:42','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 17:47:53'),(2131,1,1,21,0,'2015-04-19 21:52:42','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 17:52:53'),(2132,1,1,21,0,'2015-04-19 21:57:43','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 17:57:53'),(2133,1,1,21,0,'2015-04-19 22:02:43','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 18:02:53'),(2134,1,1,21,0,'2015-04-19 22:07:43','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 18:07:53'),(2135,1,1,21,0,'2015-04-19 22:12:43','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 18:12:53'),(2136,1,1,21,0,'2015-04-19 22:17:43','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 18:17:54'),(2137,1,1,21,0,'2015-04-19 22:22:43','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 18:22:54'),(2138,1,1,21,0,'2015-04-19 22:27:44','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 18:27:54'),(2139,1,1,21,0,'2015-04-19 22:32:44','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 18:32:54'),(2140,1,1,21,0,'2015-04-19 22:37:44','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 18:37:54'),(2141,1,1,21,0,'2015-04-19 22:42:44','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 18:42:54'),(2142,1,1,21,0,'2015-04-19 22:47:44','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 18:47:55'),(2143,1,1,21,0,'2015-04-19 22:52:44','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 18:52:55'),(2144,1,1,21,0,'2015-04-19 22:57:45','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 18:57:55'),(2145,1,1,21,0,'2015-04-19 23:02:45','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 19:02:55'),(2146,1,1,21,0,'2015-04-19 23:07:45','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 19:07:55'),(2147,1,1,21,0,'2015-04-19 23:12:45','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 19:12:55'),(2148,1,1,21,0,'2015-04-19 23:17:45','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 19:17:55'),(2149,1,1,21,0,'2015-04-19 23:22:45','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 19:22:56'),(2150,1,1,21,0,'2015-04-19 23:27:46','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 19:27:56'),(2151,1,1,21,0,'2015-04-19 23:32:46','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 19:32:56'),(2152,1,1,21,0,'2015-04-19 23:37:46','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 19:37:56'),(2153,1,1,21,0,'2015-04-19 23:42:46','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 19:42:56'),(2154,1,1,21,0,'2015-04-19 23:47:46','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 19:47:56'),(2155,1,1,21,0,'2015-04-19 23:52:46','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 19:52:57'),(2156,1,1,21,0,'2015-04-19 23:58:47','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 19:58:57'),(2157,1,1,21,0,'2015-04-20 00:03:47','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 20:03:57'),(2158,1,1,21,0,'2015-04-20 00:08:47','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 20:08:57'),(2159,1,1,21,0,'2015-04-20 00:13:47','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 20:13:57'),(2160,1,1,21,0,'2015-04-20 00:18:47','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 20:18:57'),(2161,1,1,21,0,'2015-04-20 00:23:47','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 20:23:58'),(2162,1,1,21,0,'2015-04-20 00:28:47','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 20:28:58'),(2163,1,1,21,0,'2015-04-20 00:33:48','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 20:33:58'),(2164,1,1,21,0,'2015-04-20 00:38:48','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 20:38:58'),(2165,1,1,21,0,'2015-04-20 00:43:48','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 20:43:58'),(2166,1,1,21,0,'2015-04-20 00:48:48','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 20:48:58'),(2167,1,1,21,0,'2015-04-20 00:53:48','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 20:53:59'),(2168,1,1,21,0,'2015-04-20 00:58:48','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 20:58:59'),(2169,1,1,21,0,'2015-04-20 01:03:49','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 21:03:59'),(2170,1,1,21,0,'2015-04-20 01:08:49','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 21:08:59'),(2171,1,1,21,0,'2015-04-20 01:13:49','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 21:13:59'),(2172,1,1,21,0,'2015-04-20 01:18:49','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 21:18:59'),(2173,1,1,21,0,'2015-04-20 01:23:49','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 21:24:00'),(2174,1,1,21,0,'2015-04-20 01:28:49','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 21:29:00'),(2175,1,1,21,0,'2015-04-20 01:33:50','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 21:34:00'),(2176,1,1,21,0,'2015-04-20 01:38:50','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 21:39:00'),(2177,1,1,21,0,'2015-04-20 01:43:50','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 21:44:00'),(2178,1,1,21,0,'2015-04-20 01:48:50','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 21:49:00'),(2179,1,1,21,0,'2015-04-20 01:53:50','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 21:54:01'),(2180,1,1,21,0,'2015-04-20 01:58:50','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 21:59:01'),(2181,1,1,21,0,'2015-04-20 02:03:51','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 22:04:01'),(2182,1,1,21,0,'2015-04-20 02:08:51','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 22:09:01'),(2183,1,1,21,0,'2015-04-20 02:13:51','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 22:14:01'),(2184,1,1,21,0,'2015-04-20 02:18:51','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 22:19:01'),(2185,1,1,21,0,'2015-04-20 02:23:51','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 22:24:01'),(2186,1,1,21,0,'2015-04-20 02:28:51','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 22:29:02'),(2187,1,1,21,0,'2015-04-20 02:33:52','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 22:34:02'),(2188,1,1,21,0,'2015-04-20 02:38:52','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 22:39:02'),(2189,1,1,21,0,'2015-04-20 02:43:52','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 22:44:02'),(2190,1,1,21,0,'2015-04-20 02:48:52','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 22:49:02'),(2191,1,1,21,0,'2015-04-20 02:53:52','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 22:54:02'),(2192,1,1,21,0,'2015-04-20 02:58:52','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 22:59:03'),(2193,1,1,21,0,'2015-04-20 03:03:52','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 23:04:03'),(2194,1,1,21,0,'2015-04-20 03:08:53','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 23:09:03'),(2195,1,1,21,0,'2015-04-20 03:13:56','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 23:14:07'),(2196,1,1,21,0,'2015-04-20 03:18:57','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 23:19:07'),(2197,1,1,21,0,'2015-04-20 03:23:57','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 23:24:07'),(2198,1,1,21,0,'2015-04-20 03:28:57','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 23:29:07'),(2199,1,1,21,0,'2015-04-20 03:34:01','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 23:34:11'),(2200,1,1,21,0,'2015-04-20 03:39:01','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 23:39:11'),(2201,1,1,21,0,'2015-04-20 03:44:01','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 23:44:11'),(2202,1,1,21,0,'2015-04-20 03:49:01','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 23:49:12'),(2203,1,1,21,0,'2015-04-20 03:54:01','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 23:54:12'),(2204,1,1,21,0,'2015-04-20 03:59:02','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-19 23:59:12'),(2205,1,1,21,0,'2015-04-20 04:04:02','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 00:04:12'),(2206,1,1,21,0,'2015-04-20 04:09:02','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 00:09:12'),(2207,1,1,21,0,'2015-04-20 04:14:02','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 00:14:12'),(2208,1,1,21,0,'2015-04-20 04:19:02','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 00:19:13'),(2209,1,1,21,0,'2015-04-20 04:24:02','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 00:24:13'),(2210,1,1,21,0,'2015-04-20 04:29:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 00:29:13'),(2211,1,1,21,0,'2015-04-20 04:34:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 00:34:13'),(2212,1,1,21,0,'2015-04-20 04:39:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 00:39:13'),(2213,1,1,21,0,'2015-04-20 04:44:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 00:44:13'),(2214,1,1,21,0,'2015-04-20 04:49:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 00:49:13'),(2215,1,1,21,0,'2015-04-20 04:54:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 00:54:14'),(2216,1,1,21,0,'2015-04-20 04:59:03','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 00:59:14'),(2217,1,1,21,0,'2015-04-20 05:04:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 01:04:14'),(2218,1,1,21,0,'2015-04-20 05:09:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 01:09:14'),(2219,1,1,21,0,'2015-04-20 05:14:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 01:14:14'),(2220,1,1,21,0,'2015-04-20 05:19:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 01:19:14'),(2221,1,1,21,0,'2015-04-20 05:24:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 01:24:15'),(2222,1,1,21,0,'2015-04-20 05:29:04','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 01:29:15'),(2223,1,1,21,0,'2015-04-20 05:34:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 01:34:15'),(2224,1,1,21,0,'2015-04-20 05:39:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 01:39:15'),(2225,1,1,21,0,'2015-04-20 05:44:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 01:44:15'),(2226,1,1,21,0,'2015-04-20 05:49:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 01:49:15'),(2227,1,1,21,0,'2015-04-20 05:54:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 01:54:16'),(2228,1,1,21,0,'2015-04-20 05:59:05','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 01:59:16'),(2229,1,1,21,0,'2015-04-20 06:04:06','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 02:04:16'),(2230,1,1,21,0,'2015-04-20 06:09:06','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 02:09:16'),(2231,1,1,21,0,'2015-04-20 06:14:06','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 02:14:16'),(2232,1,1,21,0,'2015-04-20 06:19:06','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 02:19:16'),(2233,1,1,21,0,'2015-04-20 06:24:06','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 02:24:16'),(2234,1,1,21,0,'2015-04-20 06:29:06','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 02:29:17'),(2235,1,1,21,0,'2015-04-20 06:34:07','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 02:34:17'),(2236,1,1,21,0,'2015-04-20 06:39:07','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 02:39:17'),(2237,1,1,21,0,'2015-04-20 06:44:07','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 02:44:17'),(2238,1,1,21,0,'2015-04-20 06:49:07','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 02:49:17'),(2239,1,1,21,0,'2015-04-20 06:54:07','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 02:54:18'),(2240,1,1,21,0,'2015-04-20 06:59:07','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 02:59:18'),(2241,1,1,21,0,'2015-04-20 07:04:08','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 03:04:18'),(2242,1,1,21,0,'2015-04-20 07:09:08','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 03:09:18'),(2243,1,1,21,0,'2015-04-20 07:14:08','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 03:14:18'),(2244,1,1,21,0,'2015-04-20 07:19:08','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 03:19:18'),(2245,1,1,21,0,'2015-04-20 07:24:08','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 03:24:18'),(2246,1,1,21,0,'2015-04-20 07:29:08','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 03:29:19'),(2247,1,1,21,0,'2015-04-20 07:34:08','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 03:34:19'),(2248,1,1,21,0,'2015-04-20 07:39:09','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 03:39:19'),(2249,1,1,21,0,'2015-04-20 07:44:09','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 03:44:19'),(2250,1,1,21,0,'2015-04-20 07:49:09','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 03:49:19'),(2251,1,1,21,0,'2015-04-20 07:54:09','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 03:54:19'),(2252,1,1,21,0,'2015-04-20 07:59:09','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 03:59:20'),(2253,1,1,21,0,'2015-04-20 08:04:10','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 04:04:20'),(2254,1,1,21,0,'2015-04-20 08:09:10','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 04:09:20'),(2255,1,1,21,0,'2015-04-20 08:14:10','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 04:14:20'),(2256,1,1,21,0,'2015-04-20 08:19:10','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 04:19:20'),(2257,1,1,21,0,'2015-04-20 08:24:10','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 04:24:20'),(2258,1,1,21,0,'2015-04-20 08:29:10','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 04:29:21'),(2259,1,1,21,0,'2015-04-20 08:34:11','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 04:34:21'),(2260,1,1,21,0,'2015-04-20 08:39:11','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 04:39:21'),(2261,1,1,21,0,'2015-04-20 08:44:11','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 04:44:21'),(2262,1,1,21,0,'2015-04-20 08:49:11','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 04:49:21'),(2263,1,1,21,0,'2015-04-20 08:54:11','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 04:54:21'),(2264,1,1,21,0,'2015-04-20 08:59:11','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 04:59:22'),(2265,1,1,21,0,'2015-04-20 09:04:11','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 05:04:22'),(2266,1,1,21,0,'2015-04-20 09:09:12','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 05:09:22'),(2267,1,1,21,0,'2015-04-20 09:14:12','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 05:14:22'),(2268,1,1,21,0,'2015-04-20 09:19:12','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 05:19:22'),(2269,1,1,21,0,'2015-04-20 09:24:12','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 05:24:22'),(2270,1,1,21,0,'2015-04-20 09:29:12','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 05:29:23'),(2271,1,1,21,0,'2015-04-20 09:34:12','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 05:34:23'),(2272,1,1,21,0,'2015-04-20 09:39:13','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 05:39:23'),(2273,1,1,21,0,'2015-04-20 09:44:13','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 05:44:23'),(2274,1,1,21,0,'2015-04-20 09:49:13','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 05:49:23'),(2275,1,1,21,0,'2015-04-20 09:54:13','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 05:54:23'),(2276,1,1,21,0,'2015-04-20 09:59:13','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 05:59:24'),(2277,1,1,21,0,'2015-04-20 10:04:13','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 06:04:24'),(2278,1,1,21,0,'2015-04-20 10:09:14','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 06:09:24'),(2279,1,1,21,0,'2015-04-20 10:14:14','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 06:14:24'),(2280,1,1,21,0,'2015-04-20 10:19:14','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 06:19:24'),(2281,1,1,21,0,'2015-04-20 10:24:14','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 06:24:24'),(2282,1,1,21,0,'2015-04-20 10:29:14','2015-04-17 06:04:50',0.0000,0.0000,1,'2015-04-20 06:29:25'),(2283,1,1,22,0,'2015-04-20 10:29:51','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 06:30:01'),(2284,1,1,22,0,'2015-04-20 10:32:29','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 06:32:39'),(2285,1,1,22,0,'2015-04-20 10:37:25','2015-04-20 10:32:29',0.0000,0.0000,1,'2015-04-20 06:37:35'),(2286,1,1,22,0,'2015-04-20 10:42:25','2015-04-20 10:37:26',0.0000,0.0000,1,'2015-04-20 06:42:36'),(2287,1,1,22,0,'2015-04-20 10:52:26','2015-04-20 10:47:26',0.0000,0.0000,1,'2015-04-20 06:52:36'),(2288,1,1,22,0,'2015-04-20 10:57:22','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 06:57:32'),(2289,1,1,22,0,'2015-04-20 11:02:22','2015-04-20 10:57:22',0.0000,0.0000,1,'2015-04-20 07:02:33'),(2290,1,1,22,0,'2015-04-20 11:07:22','2015-04-20 11:02:23',0.0000,0.0000,1,'2015-04-20 07:07:33'),(2291,1,1,22,0,'2015-04-20 11:12:02','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 07:12:12'),(2292,1,1,22,0,'2015-04-20 11:17:02','2015-04-20 11:12:03',0.0000,0.0000,1,'2015-04-20 07:17:13'),(2293,1,1,22,0,'2015-04-20 11:22:03','2015-04-20 11:17:03',0.0000,0.0000,1,'2015-04-20 07:22:13'),(2294,1,1,22,0,'2015-04-20 11:32:03','2015-04-20 11:27:03',0.0000,0.0000,1,'2015-04-20 07:32:13'),(2295,1,1,22,0,'2015-04-20 11:37:03','2015-04-20 11:32:04',0.0000,0.0000,1,'2015-04-20 07:37:14'),(2296,1,1,22,0,'2015-04-20 11:42:04','2015-04-20 11:37:04',0.0000,0.0000,1,'2015-04-20 07:42:14'),(2297,1,1,22,0,'2015-04-20 11:47:04','2015-04-20 11:42:04',0.0000,0.0000,1,'2015-04-20 07:47:14'),(2298,1,1,22,0,'2015-04-20 11:52:04','2015-04-20 11:47:05',0.0000,0.0000,1,'2015-04-20 07:52:15'),(2299,1,1,22,0,'2015-04-20 12:02:05','2015-04-20 11:57:05',0.0000,0.0000,1,'2015-04-20 08:02:15'),(2300,1,1,22,0,'2015-04-20 12:07:05','2015-04-20 12:02:05',0.0000,0.0000,1,'2015-04-20 08:07:15'),(2301,1,1,22,0,'2015-04-20 12:12:14','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 08:12:24'),(2302,1,1,22,0,'2015-04-20 12:17:14','2015-04-20 12:12:14',0.0000,0.0000,1,'2015-04-20 08:17:24'),(2303,1,1,22,0,'2015-04-20 12:22:14','2015-04-20 12:17:14',0.0000,0.0000,1,'2015-04-20 08:22:24'),(2304,1,1,22,0,'2015-04-20 12:32:15','2015-04-20 12:27:15',0.0000,0.0000,1,'2015-04-20 08:32:25'),(2305,1,1,22,0,'2015-04-20 12:37:15','2015-04-20 12:32:15',0.0000,0.0000,1,'2015-04-20 08:37:25'),(2306,1,1,22,0,'2015-04-20 12:42:15','2015-04-20 12:37:15',0.0000,0.0000,1,'2015-04-20 08:42:26'),(2307,1,1,22,0,'2015-04-20 12:47:16','2015-04-20 12:42:16',0.0000,0.0000,1,'2015-04-20 08:47:26'),(2308,1,1,22,0,'2015-04-20 12:52:16','2015-04-20 12:47:16',0.0000,0.0000,1,'2015-04-20 08:52:26'),(2309,1,1,22,0,'2015-04-20 12:59:13','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 08:59:23'),(2310,1,1,22,0,'2015-04-20 13:00:22','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 09:00:32'),(2311,1,1,22,0,'2015-04-20 13:04:15','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 09:04:26'),(2312,1,1,22,0,'2015-04-20 13:04:47','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 09:04:57'),(2313,1,1,22,0,'2015-04-20 13:08:58','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 09:09:08'),(2314,1,1,22,0,'2015-04-20 13:13:55','2015-04-20 13:08:59',0.0000,0.0000,1,'2015-04-20 09:14:05'),(2315,1,1,22,0,'2015-04-20 13:16:39','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 09:16:49'),(2316,1,1,22,0,'2015-04-20 13:18:09','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 09:18:20'),(2317,1,1,22,0,'2015-04-20 13:23:06','2015-04-20 13:18:10',0.0000,0.0000,1,'2015-04-20 09:23:16'),(2318,1,1,22,0,'2015-04-20 13:28:07','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 09:28:18'),(2319,1,1,22,0,'2015-04-20 13:29:57','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 09:30:07'),(2320,1,1,22,0,'2015-04-20 13:32:01','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 09:32:12'),(2321,1,1,22,0,'2015-04-20 13:32:55','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 09:33:05'),(2322,1,1,22,0,'2015-04-20 13:36:50','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 09:37:00'),(2323,1,1,22,0,'2015-04-20 13:37:58','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 09:38:08'),(2324,1,1,22,0,'2015-04-20 13:38:23','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 09:38:33'),(2325,1,1,22,0,'2015-04-20 13:43:20','2015-04-20 13:38:23',0.0000,0.0000,1,'2015-04-20 09:43:30'),(2326,1,1,22,0,'2015-04-20 13:48:20','2015-04-20 13:43:20',0.0000,0.0000,1,'2015-04-20 09:48:30'),(2327,1,1,22,0,'2015-04-20 13:58:20','2015-04-20 13:53:21',0.0000,0.0000,1,'2015-04-20 09:58:31'),(2328,1,1,22,0,'2015-04-20 14:03:21','2015-04-20 13:58:21',0.0000,0.0000,1,'2015-04-20 10:03:31'),(2329,1,1,22,0,'2015-04-20 14:08:21','2015-04-20 14:03:21',0.0000,0.0000,1,'2015-04-20 10:08:31'),(2330,1,1,22,0,'2015-04-20 14:13:21','2015-04-20 14:03:21',0.0000,0.0000,1,'2015-04-20 10:13:31'),(2331,1,1,22,0,'2015-04-20 14:18:21','2015-04-20 14:13:21',0.0000,0.0000,1,'2015-04-20 10:18:31'),(2332,1,1,22,0,'2015-04-20 14:28:22','2015-04-20 14:23:22',0.0000,0.0000,1,'2015-04-20 10:28:32'),(2333,1,1,22,0,'2015-04-20 14:33:22','2015-04-20 14:28:22',0.0000,0.0000,1,'2015-04-20 10:33:32'),(2334,1,1,22,0,'2015-04-20 14:38:22','2015-04-20 14:33:22',0.0000,0.0000,1,'2015-04-20 10:38:32'),(2335,1,1,22,0,'2015-04-20 14:39:11','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 10:39:22'),(2336,1,1,22,0,'2015-04-20 14:42:34','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 10:42:45'),(2337,1,1,22,0,'2015-04-20 14:47:15','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 10:47:25'),(2338,1,1,22,0,'2015-04-20 14:48:53','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 10:49:03'),(2339,1,1,22,0,'2015-04-20 14:53:50','2015-04-20 14:53:51',0.0000,0.0000,1,'2015-04-20 10:54:00'),(2340,1,1,22,0,'2015-04-20 15:17:50','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 11:18:00'),(2341,1,1,22,0,'2015-04-20 15:18:05','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 11:18:15'),(2342,1,1,22,0,'2015-04-20 15:23:02','2015-04-20 15:22:56',0.0000,0.0000,1,'2015-04-20 11:23:12'),(2343,1,1,22,0,'2015-04-20 15:28:02','2015-04-20 15:27:55',0.0000,0.0000,1,'2015-04-20 11:28:12'),(2344,1,1,22,0,'2015-04-20 15:38:02','2015-04-20 15:37:50',0.0000,0.0000,1,'2015-04-20 11:38:13'),(2345,1,1,22,0,'2015-04-20 15:38:47','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-20 11:38:57'),(2346,1,1,22,0,'2015-04-21 11:50:23','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 07:50:33'),(2347,1,1,22,0,'2015-04-21 11:52:06','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 07:52:17'),(2348,1,1,22,0,'2015-04-21 11:57:00','2015-04-21 11:56:59',0.0000,0.0000,1,'2015-04-21 07:57:11'),(2349,1,1,22,0,'2015-04-21 12:02:00','2015-04-21 12:01:59',0.0000,0.0000,1,'2015-04-21 08:02:11'),(2350,1,1,22,0,'2015-04-21 12:07:01','2015-04-21 12:06:59',0.0000,0.0000,1,'2015-04-21 08:07:11'),(2351,1,1,22,0,'2015-04-21 12:12:01','2015-04-21 12:11:59',0.0000,0.0000,1,'2015-04-21 08:12:11'),(2352,1,1,22,0,'2015-04-21 12:17:01','2015-04-21 12:16:59',0.0000,0.0000,1,'2015-04-21 08:17:11'),(2353,1,1,22,0,'2015-04-21 12:26:21','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 08:26:31'),(2354,1,1,22,0,'2015-04-21 12:27:29','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 08:27:39'),(2355,1,1,22,0,'2015-04-21 12:28:31','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 08:28:42'),(2356,1,1,22,0,'2015-04-21 12:30:39','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 08:30:49'),(2357,1,1,22,0,'2015-04-21 12:30:55','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 08:31:06'),(2358,1,1,22,0,'2015-04-21 12:32:12','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 08:32:22'),(2359,1,1,22,0,'2015-04-21 12:37:06','2015-04-21 12:37:04',0.0000,0.0000,1,'2015-04-21 08:37:16'),(2360,1,1,22,0,'2015-04-21 12:42:06','2015-04-21 12:42:04',0.0000,0.0000,1,'2015-04-21 08:42:16'),(2361,1,1,22,0,'2015-04-21 12:47:06','2015-04-21 12:47:04',0.0000,0.0000,1,'2015-04-21 08:47:16'),(2362,1,1,22,0,'2015-04-21 12:52:06','2015-04-21 12:52:03',0.0000,0.0000,1,'2015-04-21 08:52:16'),(2363,1,1,22,0,'2015-04-21 13:02:45','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 09:02:55'),(2364,1,1,22,0,'2015-04-21 13:07:42','2015-04-21 13:07:40',0.0000,0.0000,1,'2015-04-21 09:07:53'),(2365,1,1,22,0,'2015-04-21 13:12:43','2015-04-21 13:12:41',0.0000,0.0000,1,'2015-04-21 09:12:53'),(2366,1,1,22,0,'2015-04-21 13:17:43','2015-04-21 13:17:41',0.0000,0.0000,1,'2015-04-21 09:17:53'),(2367,1,1,22,0,'2015-04-21 13:19:26','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 09:19:36'),(2368,1,1,22,0,'2015-04-21 13:24:24','2015-04-21 13:24:21',0.0000,0.0000,1,'2015-04-21 09:24:34'),(2369,1,1,22,0,'2015-04-21 13:33:26','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 09:33:36'),(2370,1,1,22,0,'2015-04-21 13:36:54','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 09:37:04'),(2371,1,1,22,0,'2015-04-21 13:38:02','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 09:38:12'),(2372,1,1,22,0,'2015-04-21 13:42:55','2015-04-21 13:42:53',0.0000,0.0000,1,'2015-04-21 09:43:06'),(2373,1,1,22,0,'2015-04-21 13:47:56','2015-04-21 13:47:53',0.0000,0.0000,1,'2015-04-21 09:48:06'),(2374,1,1,22,0,'2015-04-21 13:52:56','2015-04-21 13:52:53',0.0000,0.0000,1,'2015-04-21 09:53:06'),(2375,1,1,22,0,'2015-04-21 14:07:49','1962-07-06 14:31:48',0.0000,0.0000,1,'2015-04-21 10:07:59'),(2376,1,1,22,0,'2015-04-21 14:12:50','2015-04-21 14:12:47',0.0000,0.0000,1,'2015-04-21 10:13:00'),(2377,1,1,22,0,'2015-04-21 14:17:49','2015-04-21 14:17:47',0.0000,0.0000,1,'2015-04-21 10:18:00'),(2378,1,1,22,0,'2015-04-21 14:22:51','2015-04-21 14:22:46',0.0000,0.0000,1,'2015-04-21 10:23:01'),(2379,1,1,22,0,'2015-04-21 14:27:51','2015-04-21 14:27:48',0.0000,0.0000,1,'2015-04-21 10:28:01'),(2380,1,1,22,0,'2015-04-21 14:32:51','2015-04-21 14:32:48',0.0000,0.0000,1,'2015-04-21 10:33:01'),(2381,1,1,22,0,'2015-04-21 14:34:19','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 10:34:29'),(2382,1,1,22,0,'2015-04-21 14:35:02','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 10:35:12'),(2383,1,1,22,0,'2015-04-21 14:37:42','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 10:37:53'),(2384,1,1,22,0,'2015-04-21 14:42:14','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 10:42:24'),(2385,1,1,22,0,'2015-04-21 14:47:08','2015-04-21 14:47:06',0.0000,0.0000,1,'2015-04-21 10:47:18'),(2386,1,1,22,0,'2015-04-21 14:50:37','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-04-21 10:50:47'),(2387,1,1,22,0,'2015-05-10 14:53:37','2015-05-10 14:53:35',1.2530,0.0000,1,'2015-04-21 10:50:47'),(2388,1,1,23,0,'2015-05-10 14:56:37','2015-05-10 14:56:35',1.2530,0.0000,1,'2015-04-21 10:50:47'),(2389,1,1,22,0,'2015-05-27 17:03:13','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-05-27 13:03:23'),(2390,1,1,22,0,'2015-05-27 17:07:26','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-05-27 13:07:36'),(2391,1,1,22,0,'2015-05-27 17:12:24','2015-05-27 17:12:24',0.0000,0.0000,1,'2015-05-27 13:12:34'),(2392,1,1,22,0,'2015-05-27 17:17:24','2015-05-27 17:17:24',0.0000,0.0000,1,'2015-05-27 13:17:34'),(2393,1,1,22,0,'2015-05-27 17:18:29','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-05-27 13:18:39'),(2394,1,1,22,0,'2015-05-27 17:21:18','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-05-27 13:21:28'),(2395,1,1,22,0,'2015-05-27 17:26:16','2015-05-27 17:26:15',0.0000,0.0000,1,'2015-05-27 13:26:26'),(2396,1,1,22,0,'2015-05-27 17:31:16','2015-05-27 17:31:16',0.0000,0.0000,1,'2015-05-27 13:31:26'),(2397,1,1,22,0,'2015-05-27 17:36:06','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-05-27 13:36:16'),(2398,1,1,22,0,'2015-05-27 17:41:06','2015-05-27 17:41:05',0.0000,0.0000,1,'2015-05-27 13:41:16'),(2399,1,1,22,0,'2015-05-27 17:44:12','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-05-27 13:44:22'),(2400,1,1,22,0,'2015-05-27 17:46:08','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-05-27 13:46:18'),(2401,1,1,22,0,'2015-05-27 17:48:58','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-05-27 13:49:08'),(2402,1,1,22,0,'2015-05-27 17:52:56','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-05-27 13:53:06'),(2403,1,1,22,0,'2015-05-27 17:57:54','2015-05-27 17:57:22',0.0000,0.0000,1,'2015-05-27 13:58:04'),(2404,1,1,22,0,'2015-05-27 17:58:22','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-05-27 13:58:32'),(2405,1,1,22,0,'2015-05-27 18:00:00','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-05-27 14:00:10'),(2406,1,1,22,0,'2015-05-27 18:01:10','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-05-27 14:01:20'),(2407,1,1,22,0,'2015-05-27 18:06:08','2015-05-27 18:06:07',0.0000,0.0000,1,'2015-05-27 14:06:18'),(2408,1,1,22,0,'2015-05-27 18:11:08','2015-05-27 18:11:08',0.0000,0.0000,1,'2015-05-27 14:11:18'),(2409,1,1,22,0,'2015-05-27 18:26:09','2015-05-27 18:26:08',0.0000,0.0000,1,'2015-05-27 14:26:19'),(2410,1,1,22,0,'2015-05-27 18:31:09','2015-05-27 18:31:08',0.0000,0.0000,1,'2015-05-27 14:31:19'),(2411,1,1,22,0,'2015-05-27 18:36:09','2015-05-27 18:36:08',0.0000,0.0000,1,'2015-05-27 14:36:19'),(2412,1,1,22,0,'2015-05-27 18:41:10','2015-05-27 18:41:10',0.0000,0.0000,1,'2015-05-27 14:41:20'),(2413,1,1,22,0,'2015-05-27 18:46:10','2015-05-27 18:46:10',0.0000,0.0000,1,'2015-05-27 14:46:20'),(2414,1,1,22,0,'2015-05-27 18:56:10','2015-05-27 18:56:09',0.0000,0.0000,1,'2015-05-27 14:56:20'),(2415,1,1,22,0,'2015-05-27 19:01:11','2015-05-27 19:01:08',0.0000,0.0000,1,'2015-05-27 15:01:21'),(2416,1,1,22,0,'2015-05-27 19:06:11','2015-05-27 19:06:11',0.0000,0.0000,1,'2015-05-27 15:06:21'),(2417,1,1,22,0,'2015-05-27 19:11:12','2015-05-27 19:10:31',0.0000,0.0000,1,'2015-05-27 15:11:22'),(2418,1,1,22,0,'2015-05-27 19:16:12','2015-05-27 19:15:27',0.0000,0.0000,1,'2015-05-27 15:16:22'),(2419,1,1,22,0,'2015-05-27 19:26:12','2015-05-27 19:25:20',0.0000,0.0000,1,'2015-05-27 15:26:22'),(2420,1,1,22,0,'2015-05-27 19:31:12','2015-05-27 19:31:06',0.0000,0.0000,1,'2015-05-27 15:31:22'),(2421,1,1,22,0,'2015-05-27 19:36:13','2015-05-27 19:36:01',0.0000,0.0000,1,'2015-05-27 15:36:23'),(2422,1,1,22,0,'2015-05-27 19:41:13','2015-05-27 19:40:22',0.0000,0.0000,1,'2015-05-27 15:41:23'),(2423,1,1,22,0,'2015-05-27 19:46:13','2015-05-27 19:44:22',0.0000,0.0000,1,'2015-05-27 15:46:23'),(2424,1,1,22,0,'2015-05-27 19:56:13','2015-05-27 19:55:22',0.0000,0.0000,1,'2015-05-27 15:56:23'),(2425,1,1,22,0,'2015-05-27 20:01:14','2015-05-27 20:00:33',0.0000,0.0000,1,'2015-05-27 16:01:24'),(2426,1,1,22,0,'2015-05-27 20:06:14','2015-05-27 20:05:22',0.0000,0.0000,1,'2015-05-27 16:06:24'),(2427,1,1,22,0,'2015-05-27 20:11:14','2015-05-27 20:10:22',0.0000,0.0000,1,'2015-05-27 16:11:24'),(2428,1,1,22,0,'2015-05-27 20:16:14','2015-05-27 20:15:24',0.0000,0.0000,1,'2015-05-27 16:16:24'),(2429,1,1,22,0,'2015-05-27 20:26:15','2015-05-27 20:25:25',0.0000,0.0000,1,'2015-05-27 16:26:25'),(2430,1,1,22,0,'2015-05-27 20:31:15','2015-05-27 20:30:24',0.0000,0.0000,1,'2015-05-27 16:31:25'),(2431,1,1,22,0,'2015-05-27 20:36:15','2015-05-27 20:35:24',0.0000,0.0000,1,'2015-05-27 16:36:25'),(2432,1,1,22,0,'2015-05-27 20:41:16','2015-05-27 20:39:26',0.0000,0.0000,1,'2015-05-27 16:41:26'),(2433,1,1,22,0,'2015-05-27 20:46:17','2015-05-27 20:45:25',0.0000,0.0000,1,'2015-05-27 16:46:27'),(2434,1,1,22,0,'2015-05-27 20:56:17','2015-05-27 20:55:26',0.0000,0.0000,1,'2015-05-27 16:56:27'),(2435,1,1,22,0,'2015-05-27 21:01:17','2015-05-27 21:00:25',0.0000,0.0000,1,'2015-05-27 17:01:27'),(2436,1,1,22,0,'2015-05-27 21:06:17','2015-05-27 21:05:26',0.0000,0.0000,1,'2015-05-27 17:06:27'),(2437,1,1,22,0,'2015-05-27 21:11:18','2015-05-27 21:10:27',0.0000,0.0000,1,'2015-05-27 17:11:28'),(2438,1,1,22,0,'2015-05-27 21:16:18','2015-05-27 21:15:26',0.0000,0.0000,1,'2015-05-27 17:16:28'),(2439,1,1,22,0,'2015-05-27 21:26:18','2015-05-27 21:25:26',0.0000,0.0000,1,'2015-05-27 17:26:28'),(2440,1,1,22,0,'2015-05-27 21:31:19','2015-05-27 21:30:28',0.0000,0.0000,1,'2015-05-27 17:31:29'),(2441,1,1,22,0,'2015-05-27 21:36:19','2015-05-27 21:35:28',0.0000,0.0000,1,'2015-05-27 17:36:29'),(2442,1,1,22,0,'2015-05-27 21:46:19','2015-05-27 21:45:17',0.0000,0.0000,1,'2015-05-27 17:46:29'),(2443,1,1,22,0,'2015-05-27 21:51:19','2015-05-27 21:50:28',0.0000,0.0000,1,'2015-05-27 17:51:29'),(2444,1,1,22,0,'2015-05-27 22:01:20','2015-05-27 22:00:29',0.0000,0.0000,1,'2015-05-27 18:01:30'),(2445,1,1,22,0,'2015-05-27 22:06:20','2015-05-27 22:05:29',0.0000,0.0000,1,'2015-05-27 18:06:30'),(2446,1,1,22,0,'2015-05-27 22:11:20','2015-05-27 22:09:31',0.0000,0.0000,1,'2015-05-27 18:11:30'),(2447,1,1,22,0,'2015-05-27 22:16:21','2015-05-27 22:13:33',0.0000,0.0000,1,'2015-05-27 18:16:31'),(2448,1,1,22,0,'2015-05-27 22:21:22','2015-05-27 22:20:30',0.0000,0.0000,1,'2015-05-27 18:21:32'),(2449,1,1,22,0,'2015-05-27 22:36:22','2015-05-27 22:35:20',0.0000,0.0000,1,'2015-05-27 18:36:32'),(2450,1,1,22,0,'2015-05-27 22:41:22','2015-05-27 22:40:48',0.0000,0.0000,1,'2015-05-27 18:41:32'),(2451,1,1,22,0,'2015-05-27 22:46:23','2015-05-27 22:45:32',0.0000,0.0000,1,'2015-05-27 18:46:33'),(2452,1,1,22,0,'2015-05-27 22:51:23','2015-05-27 22:50:33',0.0000,0.0000,1,'2015-05-27 18:51:33'),(2453,1,1,22,0,'2015-05-27 22:56:23','2015-05-27 22:55:30',0.0000,0.0000,1,'2015-05-27 18:56:33'),(2454,1,1,22,0,'2015-05-27 23:06:24','2015-05-27 23:06:03',0.0000,0.0000,1,'2015-05-27 19:06:34'),(2455,1,1,22,0,'2015-05-27 23:11:24','2015-05-27 23:11:12',0.0000,0.0000,1,'2015-05-27 19:11:34'),(2456,1,1,22,0,'2015-05-27 23:16:24','2015-05-27 23:15:33',0.0000,0.0000,1,'2015-05-27 19:16:34'),(2457,1,1,22,0,'2015-05-27 23:21:24','2015-05-27 23:20:32',0.0000,0.0000,1,'2015-05-27 19:21:34'),(2458,1,1,22,0,'2015-05-27 23:26:24','2015-05-27 23:25:33',0.0000,0.0000,1,'2015-05-27 19:26:34'),(2459,1,1,22,0,'2015-05-27 23:36:25','2015-05-27 23:35:49',0.0000,0.0000,1,'2015-05-27 19:36:35'),(2460,1,1,22,0,'2015-05-27 23:41:25','2015-05-27 23:40:34',0.0000,0.0000,1,'2015-05-27 19:41:35'),(2461,1,1,22,0,'2015-05-27 23:46:25','2015-05-27 23:44:35',0.0000,0.0000,1,'2015-05-27 19:46:35'),(2462,1,1,22,0,'2015-05-27 23:51:26','2015-05-27 23:48:36',0.0000,0.0000,1,'2015-05-27 19:51:36'),(2463,1,1,22,0,'2015-05-27 23:56:27','2015-05-27 23:55:35',0.0000,0.0000,1,'2015-05-27 19:56:37'),(2464,1,1,22,0,'2015-05-28 00:06:27','2015-05-28 00:05:35',0.0000,0.0000,1,'2015-05-27 20:06:37'),(2465,1,1,22,0,'2015-05-28 00:11:27','2015-05-28 00:10:34',0.0000,0.0000,1,'2015-05-27 20:11:37'),(2466,1,1,22,0,'2015-05-28 00:16:27','2015-05-28 00:15:36',0.0000,0.0000,1,'2015-05-27 20:16:37'),(2467,1,1,22,0,'2015-05-28 00:21:28','2015-05-28 00:20:36',0.0000,0.0000,1,'2015-05-27 20:21:38'),(2468,1,1,22,0,'2015-05-28 00:26:28','2015-05-28 00:25:37',0.0000,0.0000,1,'2015-05-27 20:26:38'),(2469,1,1,22,0,'2015-05-28 00:36:28','2015-05-28 00:35:36',0.0000,0.0000,1,'2015-05-27 20:36:38'),(2470,1,1,22,0,'2015-05-28 00:41:28','2015-05-28 00:40:39',0.0000,0.0000,1,'2015-05-27 20:41:38'),(2471,1,1,22,0,'2015-05-28 00:46:29','2015-05-28 00:45:38',0.0000,0.0000,1,'2015-05-27 20:46:39'),(2472,1,1,22,0,'2015-05-28 00:51:29','2015-05-28 00:50:36',0.0000,0.0000,1,'2015-05-27 20:51:39'),(2473,1,1,22,0,'2015-05-28 00:56:29','2015-05-28 00:55:37',0.0000,0.0000,1,'2015-05-27 20:56:39'),(2474,1,1,22,0,'2015-05-28 01:06:30','2015-05-28 01:05:39',0.0000,0.0000,1,'2015-05-27 21:06:40'),(2475,1,1,22,0,'2015-05-28 01:11:30','2015-05-28 01:10:39',0.0000,0.0000,1,'2015-05-27 21:11:40'),(2476,1,1,22,0,'2015-05-28 01:16:30','2015-05-28 01:15:39',0.0000,0.0000,1,'2015-05-27 21:16:40'),(2477,1,1,22,0,'2015-05-28 01:21:30','2015-05-28 01:20:38',0.0000,0.0000,1,'2015-05-27 21:21:40'),(2478,1,1,22,0,'2015-05-28 01:26:31','2015-05-28 01:25:31',0.0000,0.0000,1,'2015-05-27 21:26:41'),(2479,1,1,22,0,'2015-05-28 01:36:31','2015-05-28 01:35:41',0.0000,0.0000,1,'2015-05-27 21:36:41'),(2480,1,1,22,0,'2015-05-28 01:41:32','2015-05-28 01:40:40',0.0000,0.0000,1,'2015-05-27 21:41:42'),(2481,1,1,22,0,'2015-05-28 01:46:32','2015-05-28 01:45:40',0.0000,0.0000,1,'2015-05-27 21:46:42'),(2482,1,1,22,0,'2015-05-28 01:51:32','2015-05-28 01:50:40',0.0000,0.0000,1,'2015-05-27 21:51:42'),(2483,1,1,22,0,'2015-05-28 01:56:32','2015-05-28 01:55:54',0.0000,0.0000,1,'2015-05-27 21:56:42'),(2484,1,1,22,0,'2015-05-28 02:06:33','2015-05-28 02:05:42',0.0000,0.0000,1,'2015-05-27 22:06:43'),(2485,1,1,22,0,'2015-05-28 02:11:33','2015-05-28 02:10:40',0.0000,0.0000,1,'2015-05-27 22:11:43'),(2486,1,1,22,0,'2015-05-28 02:16:33','2015-05-28 02:15:41',0.0000,0.0000,1,'2015-05-27 22:16:43'),(2487,1,1,22,0,'2015-05-28 02:21:34','2015-05-28 02:20:42',0.0000,0.0000,1,'2015-05-27 22:21:44'),(2488,1,1,22,0,'2015-05-28 02:26:34','2015-05-28 02:25:43',0.0000,0.0000,1,'2015-05-27 22:26:44'),(2489,1,1,22,0,'2015-05-28 02:36:34','2015-05-28 02:36:31',0.0000,0.0000,1,'2015-05-27 22:36:44'),(2490,1,1,22,0,'2015-05-28 02:41:34','2015-05-28 02:40:44',0.0000,0.0000,1,'2015-05-27 22:41:44'),(2491,1,1,22,0,'2015-05-28 02:46:35','2015-05-28 02:45:45',0.0000,0.0000,1,'2015-05-27 22:46:45'),(2492,1,1,22,0,'2015-05-28 02:51:35','2015-05-28 02:50:44',0.0000,0.0000,1,'2015-05-27 22:51:45'),(2493,1,1,22,0,'2015-05-28 02:56:35','2015-05-28 02:55:45',0.0000,0.0000,1,'2015-05-27 22:56:45'),(2494,1,1,22,0,'2015-05-28 03:06:35','2015-05-28 03:03:53',0.0000,0.0000,1,'2015-05-27 23:06:45'),(2495,1,1,22,0,'2015-05-28 03:11:36','2015-05-28 03:10:44',0.0000,0.0000,1,'2015-05-27 23:11:46'),(2496,1,1,22,0,'2015-05-28 03:16:36','2015-05-28 03:15:46',0.0000,0.0000,1,'2015-05-27 23:16:46'),(2497,1,1,22,0,'2015-05-28 03:21:37','2015-05-28 03:20:45',0.0000,0.0000,1,'2015-05-27 23:21:47'),(2498,1,1,22,0,'2015-05-28 03:26:37','2015-05-28 03:26:32',0.0000,0.0000,1,'2015-05-27 23:26:47'),(2499,1,1,22,0,'2015-05-28 03:36:37','2015-05-28 03:36:05',0.0000,0.0000,1,'2015-05-27 23:36:47'),(2500,1,1,22,0,'2015-05-28 03:41:38','2015-05-28 03:40:46',0.0000,0.0000,1,'2015-05-27 23:41:48'),(2501,1,1,22,0,'2015-05-28 03:46:38','2015-05-28 03:45:46',0.0000,0.0000,1,'2015-05-27 23:46:48'),(2502,1,1,22,0,'2015-05-28 03:51:38','2015-05-28 03:50:46',0.0000,0.0000,1,'2015-05-27 23:51:48'),(2503,1,1,22,0,'2015-05-28 04:01:38','2015-05-28 04:00:37',0.0000,0.0000,1,'2015-05-28 00:01:48'),(2504,1,1,22,0,'2015-05-28 04:11:39','2015-05-28 04:10:47',0.0000,0.0000,1,'2015-05-28 00:11:49'),(2505,1,1,22,0,'2015-05-28 04:16:39','2015-05-28 04:15:46',0.0000,0.0000,1,'2015-05-28 00:16:49'),(2506,1,1,22,0,'2015-05-28 04:21:39','2015-05-28 04:20:49',0.0000,0.0000,1,'2015-05-28 00:21:49'),(2507,1,1,22,0,'2015-05-28 04:26:40','2015-05-28 04:25:55',0.0000,0.0000,1,'2015-05-28 00:26:50'),(2508,1,1,22,0,'2015-05-28 04:31:40','2015-05-28 04:31:02',0.0000,0.0000,1,'2015-05-28 00:31:50'),(2509,1,1,22,0,'2015-05-28 04:41:41','2015-05-28 04:39:50',0.0000,0.0000,1,'2015-05-28 00:41:51'),(2510,1,1,22,0,'2015-05-28 04:46:41','2015-05-28 04:45:50',0.0000,0.0000,1,'2015-05-28 00:46:51'),(2511,1,1,22,0,'2015-05-28 04:51:42','2015-05-28 04:49:50',0.0000,0.0000,1,'2015-05-28 00:51:52'),(2512,1,1,22,0,'2015-05-28 04:56:42','2015-05-28 04:55:51',0.0000,0.0000,1,'2015-05-28 00:56:52'),(2513,1,1,22,0,'2015-05-28 05:01:42','2015-05-28 05:00:49',0.0000,0.0000,1,'2015-05-28 01:01:52'),(2514,1,1,22,0,'2015-05-28 05:11:43','2015-05-28 05:10:51',0.0000,0.0000,1,'2015-05-28 01:11:53'),(2515,1,1,22,0,'2015-05-28 05:16:43','2015-05-28 05:15:52',0.0000,0.0000,1,'2015-05-28 01:16:53'),(2516,1,1,22,0,'2015-05-28 05:21:43','2015-05-28 05:20:51',0.0000,0.0000,1,'2015-05-28 01:21:53'),(2517,1,1,22,0,'2015-05-28 05:26:43','2015-05-28 05:25:51',0.0000,0.0000,1,'2015-05-28 01:26:53'),(2518,1,1,22,0,'2015-05-28 05:31:43','2015-05-28 05:31:02',0.0000,0.0000,1,'2015-05-28 01:31:53'),(2519,1,1,22,0,'2015-05-28 05:41:44','2015-05-28 05:39:52',0.0000,0.0000,1,'2015-05-28 01:41:54'),(2520,1,1,22,0,'2015-05-28 05:46:44','2015-05-28 05:45:51',0.0000,0.0000,1,'2015-05-28 01:46:54'),(2521,1,1,22,0,'2015-05-28 05:51:44','2015-05-28 05:50:53',0.0000,0.0000,1,'2015-05-28 01:51:54'),(2522,1,1,22,0,'2015-05-28 05:56:45','2015-05-28 05:55:54',0.0000,0.0000,1,'2015-05-28 01:56:55'),(2523,1,1,22,0,'2015-05-28 06:01:45','2015-05-28 06:00:54',0.0000,0.0000,1,'2015-05-28 02:01:55'),(2524,1,1,22,0,'2015-05-28 06:11:46','2015-05-28 06:10:19',0.0000,0.0000,1,'2015-05-28 02:11:56'),(2525,1,1,22,0,'2015-05-28 06:21:47','2015-05-28 06:20:47',0.0000,0.0000,1,'2015-05-28 02:21:57'),(2526,1,1,22,0,'2015-05-28 06:26:47','2015-05-28 06:26:46',0.0000,0.0000,1,'2015-05-28 02:26:57'),(2527,1,1,22,0,'2015-05-28 06:31:47','2015-05-28 06:30:55',0.0000,0.0000,1,'2015-05-28 02:31:57'),(2528,1,1,22,0,'2015-05-28 06:36:47','2015-05-28 06:35:56',0.0000,0.0000,1,'2015-05-28 02:36:57'),(2529,1,1,22,0,'2015-05-28 06:46:48','2015-05-28 06:45:56',0.0000,0.0000,1,'2015-05-28 02:46:58'),(2530,1,1,22,0,'2015-05-28 06:51:48','2015-05-28 06:50:56',0.0000,0.0000,1,'2015-05-28 02:51:58'),(2531,1,1,22,0,'2015-05-28 06:56:48','2015-05-28 06:55:56',0.0000,0.0000,1,'2015-05-28 02:56:58'),(2532,1,1,22,0,'2015-05-28 07:01:48','2015-05-28 07:01:01',0.0000,0.0000,1,'2015-05-28 03:01:58'),(2533,1,1,22,0,'2015-05-28 07:06:49','2015-05-28 07:05:57',0.0000,0.0000,1,'2015-05-28 03:06:59'),(2534,1,1,22,0,'2015-05-28 07:16:49','2015-05-28 07:16:40',0.0000,0.0000,1,'2015-05-28 03:16:59'),(2535,1,1,22,0,'2015-05-28 07:21:49','2015-05-28 07:21:05',0.0000,0.0000,1,'2015-05-28 03:21:59'),(2536,1,1,22,0,'2015-05-28 07:26:49','2015-05-28 07:25:59',0.0000,0.0000,1,'2015-05-28 03:26:59'),(2537,1,1,22,0,'2015-05-28 07:31:50','2015-05-28 07:31:00',0.0000,0.0000,1,'2015-05-28 03:32:00'),(2538,1,1,22,0,'2015-05-28 07:36:50','2015-05-28 07:35:59',0.0000,0.0000,1,'2015-05-28 03:37:00'),(2539,1,1,22,0,'2015-05-28 07:46:51','2015-05-28 07:46:00',0.0000,0.0000,1,'2015-05-28 03:47:01'),(2540,1,1,22,0,'2015-05-28 07:51:52','2015-05-28 07:51:00',0.0000,0.0000,1,'2015-05-28 03:52:02'),(2541,1,1,22,0,'2015-05-28 07:56:52','2015-05-28 07:56:01',0.0000,0.0000,1,'2015-05-28 03:57:02'),(2542,1,1,22,0,'2015-05-28 08:06:52','2015-05-28 08:05:51',0.0000,0.0000,1,'2015-05-28 04:07:02'),(2543,1,1,22,0,'2015-05-28 08:11:52','2015-05-28 08:11:01',0.0000,0.0000,1,'2015-05-28 04:12:02'),(2544,1,1,22,0,'2015-05-28 08:21:53','2015-05-28 08:21:01',0.0000,0.0000,1,'2015-05-28 04:22:03'),(2545,1,1,22,0,'2015-05-28 08:26:53','2015-05-28 08:26:01',0.0000,0.0000,1,'2015-05-28 04:27:03'),(2546,1,1,22,0,'2015-05-28 08:31:53','2015-05-28 08:31:03',0.0000,0.0000,1,'2015-05-28 04:32:03'),(2547,1,1,22,0,'2015-05-28 08:36:54','2015-05-28 08:36:25',0.0000,0.0000,1,'2015-05-28 04:37:04'),(2548,1,1,22,0,'2015-05-28 08:41:54','2015-05-28 08:41:02',0.0000,0.0000,1,'2015-05-28 04:42:04'),(2549,1,1,22,0,'2015-05-28 08:51:54','2015-05-28 08:51:04',0.0000,0.0000,1,'2015-05-28 04:52:04'),(2550,1,1,22,0,'2015-05-28 08:56:54','2015-05-28 08:56:05',0.0000,0.0000,1,'2015-05-28 04:57:04'),(2551,1,1,22,0,'2015-05-28 09:01:55','2015-05-28 09:01:07',0.0000,0.0000,1,'2015-05-28 05:02:05'),(2552,1,1,22,0,'2015-05-28 09:06:55','2015-05-28 09:06:04',0.0000,0.0000,1,'2015-05-28 05:07:05'),(2553,1,1,22,0,'2015-05-28 09:11:56','2015-05-28 09:10:05',0.0000,0.0000,1,'2015-05-28 05:12:06'),(2554,1,1,22,0,'2015-05-28 09:21:57','2015-05-28 09:21:19',0.0000,0.0000,1,'2015-05-28 05:22:07'),(2555,1,1,22,0,'2015-05-28 09:26:57','2015-05-28 09:26:05',0.0000,0.0000,1,'2015-05-28 05:27:07'),(2556,1,1,22,0,'2015-05-28 09:31:57','2015-05-28 09:31:05',0.0000,0.0000,1,'2015-05-28 05:32:07'),(2557,1,1,22,0,'2015-05-28 09:36:57','2015-05-28 09:36:05',0.0000,0.0000,1,'2015-05-28 05:37:07'),(2558,1,1,22,0,'2015-05-28 09:41:57','2015-05-28 09:41:07',0.0000,0.0000,1,'2015-05-28 05:42:07'),(2559,1,1,22,0,'2015-05-28 09:51:58','2015-05-28 09:50:07',0.0000,0.0000,1,'2015-05-28 05:52:08'),(2560,1,1,22,0,'2015-05-28 09:56:58','2015-05-28 09:56:33',0.0000,0.0000,1,'2015-05-28 05:57:08'),(2561,1,1,22,0,'2015-05-28 10:01:58','2015-05-28 10:01:08',0.0000,0.0000,1,'2015-05-28 06:02:08'),(2562,1,1,22,0,'2015-05-28 10:06:59','2015-05-28 10:06:08',0.0000,0.0000,1,'2015-05-28 06:07:09'),(2563,1,1,22,0,'2015-05-28 10:11:59','2015-05-28 10:11:14',0.0000,0.0000,1,'2015-05-28 06:12:09'),(2564,1,1,22,0,'2015-05-28 10:21:59','2015-05-28 10:21:21',0.0000,0.0000,1,'2015-05-28 06:22:09'),(2565,1,1,22,0,'2015-05-28 10:26:59','2015-05-28 10:26:10',0.0000,0.0000,1,'2015-05-28 06:27:09'),(2566,1,1,22,0,'2015-05-28 10:32:00','2015-05-28 10:31:09',0.0000,0.0000,1,'2015-05-28 06:32:10'),(2567,1,1,22,0,'2015-05-28 10:37:00','2015-05-28 10:36:10',0.0000,0.0000,1,'2015-05-28 06:37:10'),(2568,1,1,22,0,'2015-05-28 10:42:01','2015-05-28 10:40:11',0.0000,0.0000,1,'2015-05-28 06:42:11'),(2569,1,1,22,0,'2015-05-28 10:52:02','2015-05-28 10:51:44',0.0000,0.0000,1,'2015-05-28 06:52:12'),(2570,1,1,22,0,'2015-05-28 10:57:02','2015-05-28 10:56:10',0.0000,0.0000,1,'2015-05-28 06:57:12'),(2571,1,1,22,0,'2015-05-28 11:02:02','2015-05-28 11:01:10',0.0000,0.0000,1,'2015-05-28 07:02:12'),(2572,1,1,22,0,'2015-05-28 11:07:02','2015-05-28 11:06:11',0.0000,0.0000,1,'2015-05-28 07:07:12'),(2573,1,1,22,0,'2015-05-28 11:12:02','2015-05-28 11:11:11',0.0000,0.0000,1,'2015-05-28 07:12:12'),(2574,1,1,22,0,'2015-05-28 11:22:03','2015-05-28 11:21:10',0.0000,0.0000,1,'2015-05-28 07:22:13'),(2575,1,1,22,0,'2015-05-28 11:27:03','2015-05-28 11:26:11',0.0000,0.0000,1,'2015-05-28 07:27:13'),(2576,1,1,22,0,'2015-05-28 11:32:03','2015-05-28 11:31:13',0.0000,0.0000,1,'2015-05-28 07:32:13'),(2577,1,1,22,0,'2015-05-28 11:37:04','2015-05-28 11:36:12',0.0000,0.0000,1,'2015-05-28 07:37:14'),(2578,1,1,22,0,'2015-05-28 11:42:04','2015-05-28 11:41:12',0.0000,0.0000,1,'2015-05-28 07:42:14'),(2579,1,1,22,0,'2015-05-28 11:52:04','2015-05-28 11:52:03',0.0000,0.0000,1,'2015-05-28 07:52:14'),(2580,1,1,22,0,'2015-05-28 11:57:04','2015-05-28 11:56:14',0.0000,0.0000,1,'2015-05-28 07:57:14'),(2581,1,1,22,0,'2015-05-28 12:02:05','2015-05-28 12:01:15',0.0000,0.0000,1,'2015-05-28 08:02:15'),(2582,1,1,22,0,'2015-05-28 12:07:05','2015-05-28 12:06:15',0.0000,0.0000,1,'2015-05-28 08:07:15'),(2583,1,1,22,0,'2015-05-28 12:12:06','2015-05-28 12:11:03',0.0000,0.0000,1,'2015-05-28 08:12:16'),(2584,1,1,22,0,'2015-05-28 12:22:06','2015-05-28 12:22:06',0.0000,0.0000,1,'2015-05-28 08:22:16'),(2585,1,1,22,0,'2015-05-28 12:27:07','2015-05-28 12:27:06',0.0000,0.0000,1,'2015-05-28 08:27:17'),(2586,1,1,22,0,'2015-05-28 12:32:07','2015-05-28 12:32:06',0.0000,0.0000,1,'2015-05-28 08:32:17'),(2587,1,1,22,0,'2015-05-28 12:37:07','2015-05-28 12:37:06',0.0000,0.0000,1,'2015-05-28 08:37:17'),(2588,1,1,22,0,'2015-05-28 12:42:07','2015-05-28 12:41:22',0.0000,0.0000,1,'2015-05-28 08:42:17'),(2589,1,1,22,0,'2015-05-28 12:52:11','2015-05-28 12:52:07',0.0000,0.0000,1,'2015-05-28 08:52:21'),(2590,1,1,22,0,'2015-05-28 12:57:08','2015-05-28 12:57:07',0.0000,0.0000,1,'2015-05-28 08:57:18'),(2591,1,1,22,0,'2015-05-28 13:02:08','2015-05-28 13:02:06',0.0000,0.0000,1,'2015-05-28 09:02:18'),(2592,1,1,22,0,'2015-05-28 13:07:08','2015-05-28 13:07:08',0.0000,0.0000,1,'2015-05-28 09:07:18'),(2593,1,1,22,0,'2015-05-28 13:12:09','2015-05-28 13:12:08',0.0000,0.0000,1,'2015-05-28 09:12:19'),(2594,1,1,22,0,'2015-05-28 13:22:09','2015-05-28 13:22:08',0.0000,0.0000,1,'2015-05-28 09:22:19'),(2595,1,1,22,0,'2015-05-28 13:27:09','2015-05-28 13:27:10',0.0000,0.0000,1,'2015-05-28 09:27:19'),(2596,1,1,22,0,'2015-05-28 13:30:27','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-05-28 09:30:37'),(2597,1,1,22,0,'2015-05-28 13:35:27','2015-05-28 13:35:25',0.0000,0.0000,1,'2015-05-28 09:35:37'),(2598,1,1,22,0,'2015-05-28 13:38:51','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-05-28 09:39:01'),(2599,1,1,22,0,'2015-05-28 13:43:12','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-05-28 09:43:22'),(2600,1,1,22,0,'2015-05-28 13:48:10','2015-05-28 13:48:09',0.0000,0.0000,1,'2015-05-28 09:48:20'),(2601,1,1,22,0,'2015-05-28 13:53:10','2015-05-28 13:53:08',0.0000,0.0000,1,'2015-05-28 09:53:20'),(2602,1,1,22,0,'2015-05-28 14:03:11','2015-05-28 14:03:10',0.0000,0.0000,1,'2015-05-28 10:03:21'),(2603,1,1,22,0,'2015-05-28 14:08:11','2015-05-28 14:08:11',0.0000,0.0000,1,'2015-05-28 10:08:21'),(2604,1,1,22,0,'2015-05-28 14:13:12','2015-05-28 14:13:11',0.0000,0.0000,1,'2015-05-28 10:13:22'),(2605,1,1,22,0,'2015-05-28 14:18:12','2015-05-28 14:18:10',0.0000,0.0000,1,'2015-05-28 10:18:22'),(2606,1,1,22,0,'2015-05-28 14:23:12','2015-05-28 14:23:09',0.0000,0.0000,1,'2015-05-28 10:23:22'),(2607,1,1,22,0,'2015-05-28 14:33:12','2015-05-28 14:32:38',0.0000,0.0000,1,'2015-05-28 10:33:22'),(2608,1,1,22,0,'2015-05-28 14:38:13','2015-05-28 14:37:43',0.0000,0.0000,1,'2015-05-28 10:38:23'),(2609,1,1,22,0,'2015-05-28 14:43:13','2015-05-28 14:43:07',0.0000,0.0000,1,'2015-05-28 10:43:23'),(2610,1,1,22,0,'2015-05-28 14:48:13','2015-05-28 14:48:12',0.0000,0.0000,1,'2015-05-28 10:48:23'),(2611,1,1,22,0,'2015-05-28 14:53:13','2015-05-28 14:53:13',0.0000,0.0000,1,'2015-05-28 10:53:23'),(2612,1,1,22,0,'2015-05-28 15:03:14','2015-05-28 15:03:11',0.0000,0.0000,1,'2015-05-28 11:03:24'),(2613,1,1,22,0,'2015-05-28 15:08:14','2015-05-28 15:08:12',0.0000,0.0000,1,'2015-05-28 11:08:24'),(2614,1,1,22,0,'2015-05-28 15:13:14','2015-05-28 15:13:15',0.0000,0.0000,1,'2015-05-28 11:13:24'),(2615,1,1,22,0,'2015-05-28 15:18:14','2015-05-28 15:18:14',0.0000,0.0000,1,'2015-05-28 11:18:24'),(2616,1,1,22,0,'2015-05-28 15:23:15','2015-05-28 15:23:15',0.0000,0.0000,1,'2015-05-28 11:23:25'),(2617,1,1,22,0,'2015-05-28 15:33:16','2015-05-28 15:33:13',0.0000,0.0000,1,'2015-05-28 11:33:26'),(2618,1,1,22,0,'2015-05-28 15:38:16','2015-05-28 15:38:15',0.0000,0.0000,1,'2015-05-28 11:38:26'),(2619,1,1,22,0,'2015-05-28 15:43:16','2015-05-28 15:43:16',0.0000,0.0000,1,'2015-05-28 11:43:26'),(2620,1,1,22,0,'2015-05-28 15:48:17','2015-05-28 15:48:16',0.0000,0.0000,1,'2015-05-28 11:48:27'),(2621,1,1,22,0,'2015-05-28 15:53:17','2015-05-28 15:53:04',0.0000,0.0000,1,'2015-05-28 11:53:27'),(2622,1,1,22,0,'2015-05-28 16:08:17','2015-05-28 16:08:17',0.0000,0.0000,1,'2015-05-28 12:08:27'),(2623,1,1,22,0,'2015-05-28 16:13:18','2015-05-28 16:13:17',0.0000,0.0000,1,'2015-05-28 12:13:28'),(2624,1,1,22,0,'2015-05-28 16:18:18','2015-05-28 16:18:17',0.0000,0.0000,1,'2015-05-28 12:18:28'),(2625,1,1,22,0,'2015-05-28 16:23:18','2015-05-28 16:23:18',0.0000,0.0000,1,'2015-05-28 12:23:28'),(2626,1,1,22,0,'2015-05-28 16:28:18','2015-05-28 16:28:18',0.0000,0.0000,1,'2015-05-28 12:28:28'),(2627,1,1,22,0,'2015-05-28 16:38:19','2015-05-28 16:38:17',0.0000,0.0000,1,'2015-05-28 12:38:29'),(2628,1,1,22,0,'2015-05-28 16:43:19','2015-05-28 16:43:18',0.0000,0.0000,1,'2015-05-28 12:43:29'),(2629,1,1,22,0,'2015-05-28 16:48:19','2015-05-28 16:48:20',0.0000,0.0000,1,'2015-05-28 12:48:29'),(2630,1,1,22,0,'2015-05-28 16:53:19','2015-05-28 16:53:20',0.0000,0.0000,1,'2015-05-28 12:53:29'),(2631,1,1,22,0,'2015-05-28 16:58:28','2015-05-28 16:58:19',0.0000,0.0000,1,'2015-05-28 12:58:38'),(2632,1,1,22,0,'2015-05-28 17:13:20','2015-05-28 17:13:07',0.0000,0.0000,1,'2015-05-28 13:13:30'),(2633,1,1,22,0,'2015-05-28 17:18:21','2015-05-28 17:17:30',0.0000,0.0000,1,'2015-05-28 13:18:31'),(2634,1,1,22,0,'2015-05-29 10:49:36','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-05-29 06:49:46'),(2635,1,1,22,0,'2015-05-29 10:54:36','2015-05-29 10:54:35',0.0000,0.0000,1,'2015-05-29 06:54:46'),(2636,1,1,22,0,'2015-05-29 10:59:37','2015-05-29 10:59:35',0.0000,0.0000,1,'2015-05-29 06:59:47'),(2637,1,1,22,0,'2015-05-29 11:04:37','2015-05-29 11:04:35',0.0000,0.0000,1,'2015-05-29 07:04:47'),(2638,1,1,22,0,'2015-05-29 11:09:38','2015-05-29 11:09:36',0.0000,0.0000,1,'2015-05-29 07:09:48'),(2639,1,1,22,0,'2015-05-29 11:14:37','2015-05-29 11:14:34',0.0000,0.0000,1,'2015-05-29 07:14:47'),(2640,1,1,22,0,'2015-06-01 14:15:29','1944-12-18 21:10:44',0.0000,0.0000,1,'2015-06-01 10:15:41'),(2641,1,1,31,0,'2015-06-09 12:47:34','2015-06-09 07:38:59',0.0000,0.0000,1,'2015-06-09 08:47:49'),(2642,1,1,31,0,'2015-06-09 18:44:11','2015-06-09 13:34:36',0.0000,0.0000,1,'2015-06-09 14:44:25'),(2643,1,1,31,0,'2015-06-09 18:48:32','2015-06-09 13:38:57',0.0000,0.0000,1,'2015-06-09 14:48:47'),(2644,1,1,22,0,'2015-06-09 00:00:09','2015-06-09 00:00:00',1.2530,0.0000,1,'2015-06-09 20:50:40'),(2645,1,1,22,0,'2015-06-09 00:10:09','2015-06-09 00:10:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2646,1,1,22,0,'2015-06-09 00:20:09','2015-06-09 00:20:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2647,1,1,22,0,'2015-06-09 00:30:09','2015-06-09 00:30:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2648,1,1,22,0,'2015-06-09 00:40:09','2015-06-09 00:40:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2649,1,1,22,0,'2015-06-09 00:50:09','2015-06-09 00:50:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2650,1,1,22,0,'2015-06-09 01:00:09','2015-06-09 01:00:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2651,1,1,22,0,'2015-06-09 01:10:09','2015-06-09 01:10:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2652,1,1,22,0,'2015-06-09 01:20:09','2015-06-09 01:20:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2653,1,1,22,0,'2015-06-09 01:30:09','2015-06-09 01:30:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2654,1,1,22,0,'2015-06-09 01:40:09','2015-06-09 01:40:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2655,1,1,22,0,'2015-06-09 01:50:09','2015-06-09 01:50:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2656,1,1,22,0,'2015-06-09 02:00:09','2015-06-09 02:00:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2657,1,1,22,0,'2015-06-09 02:10:09','2015-06-09 02:10:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2658,1,1,22,0,'2015-06-09 02:20:09','2015-06-09 02:20:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2659,1,1,22,0,'2015-06-09 02:30:09','2015-06-09 02:30:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2660,1,1,22,0,'2015-06-09 02:40:09','2015-06-09 02:40:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2661,1,1,22,0,'2015-06-09 02:50:09','2015-06-09 02:50:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2662,1,1,22,0,'2015-06-09 03:00:09','2015-06-09 03:00:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2663,1,1,22,0,'2015-06-09 03:10:09','2015-06-09 03:10:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2664,1,1,22,0,'2015-06-09 03:20:09','2015-06-09 03:20:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2665,1,1,22,0,'2015-06-09 03:30:09','2015-06-09 03:30:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2666,1,1,22,0,'2015-06-09 03:40:09','2015-06-09 03:40:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2667,1,1,22,0,'2015-06-09 03:50:09','2015-06-09 03:50:00',1.2540,0.0000,1,'2015-06-09 20:50:40'),(2668,1,1,22,0,'2015-06-09 04:00:09','2015-06-09 04:00:00',1.2550,0.0000,1,'2015-06-09 20:50:40'),(2669,1,1,22,0,'2015-06-09 04:10:09','2015-06-09 04:10:00',1.2550,0.0000,1,'2015-06-09 20:50:40'),(2670,1,1,22,0,'2015-06-09 04:20:09','2015-06-09 04:20:00',1.2550,0.0000,1,'2015-06-09 20:50:40'),(2671,1,1,22,0,'2015-06-09 04:30:09','2015-06-09 04:30:00',1.2550,0.0000,1,'2015-06-09 20:50:40'),(2672,1,1,22,0,'2015-06-09 04:40:09','2015-06-09 04:40:00',1.2550,0.0000,1,'2015-06-09 20:50:40'),(2673,1,1,22,0,'2015-06-09 04:50:09','2015-06-09 04:50:00',1.2550,0.0000,1,'2015-06-09 20:50:40'),(2674,1,1,22,0,'2015-06-09 05:00:09','2015-06-09 05:00:00',1.2550,0.0000,1,'2015-06-09 20:50:40'),(2675,1,1,22,0,'2015-06-09 05:10:09','2015-06-09 05:10:00',1.2550,0.0000,1,'2015-06-09 20:50:40'),(2676,1,1,22,0,'2015-06-09 05:20:09','2015-06-09 05:20:00',1.2550,0.0000,1,'2015-06-09 20:50:40'),(2677,1,1,22,0,'2015-06-09 05:30:09','2015-06-09 05:30:00',1.2550,0.0000,1,'2015-06-09 20:50:40'),(2678,1,1,22,0,'2015-06-09 05:40:09','2015-06-09 05:40:00',1.2550,0.0000,1,'2015-06-09 20:50:40'),(2679,1,1,22,0,'2015-06-09 05:50:09','2015-06-09 05:50:00',1.2550,0.0000,1,'2015-06-09 20:50:40'),(2680,1,1,22,0,'2015-06-09 06:00:09','2015-06-09 06:00:00',1.2560,0.0000,1,'2015-06-09 20:50:40'),(2681,1,1,22,0,'2015-06-09 06:10:09','2015-06-09 06:10:00',1.2560,0.0000,1,'2015-06-09 20:50:40'),(2682,1,1,22,0,'2015-06-09 06:20:09','2015-06-09 06:20:00',1.2560,0.0000,1,'2015-06-09 20:50:40'),(2683,1,1,22,0,'2015-06-09 06:30:09','2015-06-09 06:30:00',1.2560,0.0000,1,'2015-06-09 20:50:40'),(2684,1,1,22,0,'2015-06-09 06:40:09','2015-06-09 06:40:00',1.2560,0.0000,1,'2015-06-09 20:50:40'),(2685,1,1,22,0,'2015-06-09 06:50:09','2015-06-09 06:50:00',1.2560,0.0000,1,'2015-06-09 20:50:40'),(2686,1,1,22,0,'2015-06-09 07:00:09','2015-06-09 07:00:00',1.2560,0.0000,1,'2015-06-09 20:50:40'),(2687,1,1,22,0,'2015-06-09 07:10:09','2015-06-09 07:10:00',1.2560,0.0000,1,'2015-06-09 20:50:40'),(2688,1,1,22,0,'2015-06-09 07:20:09','2015-06-09 07:20:00',1.2560,0.0000,1,'2015-06-09 20:50:40'),(2689,1,1,22,0,'2015-06-09 07:30:09','2015-06-09 07:30:00',1.2570,0.0000,1,'2015-06-09 20:50:40'),(2690,1,1,22,0,'2015-06-09 07:40:09','2015-06-09 07:40:00',1.2590,0.0000,1,'2015-06-09 20:50:40'),(2691,1,1,22,0,'2015-06-09 07:50:09','2015-06-09 07:50:00',1.2600,0.0000,1,'2015-06-09 20:50:40'),(2692,1,1,22,0,'2015-06-09 08:00:09','2015-06-09 08:00:00',1.2610,0.0000,1,'2015-06-09 20:50:40'),(2693,1,1,22,0,'2015-06-09 08:10:09','2015-06-09 08:10:00',1.2610,0.0000,1,'2015-06-09 20:50:40'),(2694,1,1,22,0,'2015-06-09 08:20:09','2015-06-09 08:20:00',1.2610,0.0000,1,'2015-06-09 20:50:40'),(2695,1,1,22,0,'2015-06-09 08:30:09','2015-06-09 08:30:00',1.2610,0.0000,1,'2015-06-09 20:50:40'),(2696,1,1,22,0,'2015-06-09 08:40:09','2015-06-09 08:40:00',1.2610,0.0000,1,'2015-06-09 20:50:40'),(2697,1,1,22,0,'2015-06-09 08:50:09','2015-06-09 08:50:00',1.2610,0.0000,1,'2015-06-09 20:50:40'),(2698,1,1,22,0,'2015-06-09 09:00:09','2015-06-09 09:00:00',1.2620,0.0000,1,'2015-06-09 20:50:40'),(2699,1,1,22,0,'2015-06-09 09:10:09','2015-06-09 09:10:00',1.2650,0.0000,1,'2015-06-09 20:50:40'),(2700,1,1,22,0,'2015-06-09 09:20:09','2015-06-09 09:20:00',1.2690,0.0000,1,'2015-06-09 20:50:40'),(2701,1,1,22,0,'2015-06-09 09:30:09','2015-06-09 09:30:00',1.2740,0.0000,1,'2015-06-09 20:50:40'),(2702,1,1,22,0,'2015-06-09 09:40:09','2015-06-09 09:40:00',1.2750,0.0000,1,'2015-06-09 20:50:40'),(2703,1,1,22,0,'2015-06-09 09:50:09','2015-06-09 09:50:00',1.2750,0.0000,1,'2015-06-09 20:50:40'),(2704,1,1,22,0,'2015-06-09 10:00:09','2015-06-09 10:00:00',1.2760,0.0000,1,'2015-06-09 20:50:40'),(2705,1,1,22,0,'2015-06-09 10:10:09','2015-06-09 10:10:00',1.2770,0.0000,1,'2015-06-09 20:50:40'),(2706,1,1,22,0,'2015-06-09 10:20:09','2015-06-09 10:20:00',1.2770,0.0000,1,'2015-06-09 20:50:40'),(2707,1,1,22,0,'2015-06-09 10:30:09','2015-06-09 10:30:00',1.2770,0.0000,1,'2015-06-09 20:50:40'),(2708,1,1,22,0,'2015-06-09 10:40:09','2015-06-09 10:40:00',1.2770,0.0000,1,'2015-06-09 20:50:40'),(2709,1,1,22,0,'2015-06-09 10:50:09','2015-06-09 10:50:00',1.2770,0.0000,1,'2015-06-09 20:50:40'),(2710,1,1,22,0,'2015-06-09 11:00:09','2015-06-09 11:00:00',1.2780,0.0000,1,'2015-06-09 20:50:40'),(2711,1,1,22,0,'2015-06-09 11:10:09','2015-06-09 11:10:00',1.2790,0.0000,1,'2015-06-09 20:50:40'),(2712,1,1,22,0,'2015-06-09 11:20:09','2015-06-09 11:20:00',1.2790,0.0000,1,'2015-06-09 20:50:40'),(2713,1,1,22,0,'2015-06-09 11:30:09','2015-06-09 11:30:00',1.2790,0.0000,1,'2015-06-09 20:50:40'),(2714,1,1,22,0,'2015-06-09 11:40:09','2015-06-09 11:40:00',1.2790,0.0000,1,'2015-06-09 20:50:40'),(2715,1,1,22,0,'2015-06-09 11:50:09','2015-06-09 11:50:00',1.2840,0.0000,1,'2015-06-09 20:50:40'),(2716,1,1,22,0,'2015-06-09 12:00:09','2015-06-09 12:00:00',1.2910,0.0000,1,'2015-06-09 20:50:40'),(2717,1,1,22,0,'2015-06-09 12:10:09','2015-06-09 12:10:00',1.3010,0.0000,1,'2015-06-09 20:50:40'),(2718,1,1,22,0,'2015-06-09 12:20:09','2015-06-09 12:20:00',1.3040,0.0000,1,'2015-06-09 20:50:40'),(2719,1,1,22,0,'2015-06-09 12:30:09','2015-06-09 12:30:00',1.3050,0.0000,1,'2015-06-09 20:50:40'),(2720,1,1,22,0,'2015-06-09 12:40:09','2015-06-09 12:40:00',1.3150,0.0000,1,'2015-06-09 20:50:40'),(2721,1,1,22,0,'2015-06-09 12:50:09','2015-06-09 12:50:00',1.3160,0.0000,1,'2015-06-09 20:50:40'),(2722,1,1,22,0,'2015-06-09 13:00:09','2015-06-09 13:00:00',1.3170,0.0000,1,'2015-06-09 20:50:40'),(2723,1,1,22,0,'2015-06-09 13:10:09','2015-06-09 13:10:00',1.3170,0.0000,1,'2015-06-09 20:50:40'),(2724,1,1,22,0,'2015-06-09 13:20:09','2015-06-09 13:20:00',1.3180,0.0000,1,'2015-06-09 20:50:40'),(2725,1,1,22,0,'2015-06-09 13:30:09','2015-06-09 13:30:00',1.3190,0.0000,1,'2015-06-09 20:50:40'),(2726,1,1,22,0,'2015-06-09 13:40:09','2015-06-09 13:40:00',1.3190,0.0000,1,'2015-06-09 20:50:40'),(2727,1,1,22,0,'2015-06-09 13:50:09','2015-06-09 13:50:00',1.3190,0.0000,1,'2015-06-09 20:50:40'),(2728,1,1,22,0,'2015-06-09 14:00:09','2015-06-09 14:00:00',1.3190,0.0000,1,'2015-06-09 20:50:40'),(2729,1,1,22,0,'2015-06-09 14:10:09','2015-06-09 14:10:00',1.3200,0.0000,1,'2015-06-09 20:50:40'),(2730,1,1,22,0,'2015-06-09 14:20:09','2015-06-09 14:20:00',1.3210,0.0000,1,'2015-06-09 20:50:40'),(2731,1,1,22,0,'2015-06-09 14:30:09','2015-06-09 14:30:00',1.3210,0.0000,1,'2015-06-09 20:50:40'),(2732,1,1,22,0,'2015-06-09 14:40:09','2015-06-09 14:40:00',1.3210,0.0000,1,'2015-06-09 20:50:40'),(2733,1,1,22,0,'2015-06-09 14:50:09','2015-06-09 14:50:00',1.3210,0.0000,1,'2015-06-09 20:50:40'),(2734,1,1,22,0,'2015-06-09 15:00:09','2015-06-09 15:00:00',1.3210,0.0000,1,'2015-06-09 20:50:40'),(2735,1,1,22,0,'2015-06-09 15:10:09','2015-06-09 15:10:00',1.3220,0.0000,1,'2015-06-09 20:50:40'),(2736,1,1,22,0,'2015-06-09 15:20:09','2015-06-09 15:20:00',1.3220,0.0000,1,'2015-06-09 20:50:40'),(2737,1,1,22,0,'2015-06-09 15:30:09','2015-06-09 15:30:00',1.3220,0.0000,1,'2015-06-09 20:50:40'),(2738,1,1,22,0,'2015-06-09 15:40:09','2015-06-09 15:40:00',1.3220,0.0000,1,'2015-06-09 20:50:40'),(2739,1,1,22,0,'2015-06-09 15:50:09','2015-06-09 15:50:00',1.3220,0.0000,1,'2015-06-09 20:50:40'),(2740,1,1,22,0,'2015-06-09 16:00:09','2015-06-09 16:00:00',1.3230,0.0000,1,'2015-06-09 20:50:40'),(2741,1,1,22,0,'2015-06-09 16:10:09','2015-06-09 16:10:00',1.3230,0.0000,1,'2015-06-09 20:50:40'),(2742,1,1,22,0,'2015-06-09 16:20:09','2015-06-09 16:20:00',1.3230,0.0000,1,'2015-06-09 20:50:40'),(2743,1,1,22,0,'2015-06-09 16:30:09','2015-06-09 16:30:00',1.3230,0.0000,1,'2015-06-09 20:50:40'),(2744,1,1,22,0,'2015-06-09 16:40:09','2015-06-09 16:40:00',1.3230,0.0000,1,'2015-06-09 20:50:40'),(2745,1,1,22,0,'2015-06-09 16:50:09','2015-06-09 16:50:00',1.3240,0.0000,1,'2015-06-09 20:50:40'),(2746,1,1,22,0,'2015-06-09 17:00:09','2015-06-09 17:00:00',1.3240,0.0000,1,'2015-06-09 20:50:40'),(2747,1,1,22,0,'2015-06-09 17:10:09','2015-06-09 17:10:00',1.3240,0.0000,1,'2015-06-09 20:50:40'),(2748,1,1,22,0,'2015-06-09 17:20:09','2015-06-09 17:20:00',1.3250,0.0000,1,'2015-06-09 20:50:40'),(2749,1,1,22,0,'2015-06-09 17:30:09','2015-06-09 17:30:00',1.3260,0.0000,1,'2015-06-09 20:50:40'),(2750,1,1,22,0,'2015-06-09 17:40:09','2015-06-09 17:40:00',1.3290,0.0000,1,'2015-06-09 20:50:40'),(2751,1,1,22,0,'2015-06-09 17:50:09','2015-06-09 17:50:00',1.3340,0.0000,1,'2015-06-09 20:50:40'),(2752,1,1,22,0,'2015-06-09 18:00:09','2015-06-09 18:00:00',1.3350,0.0000,1,'2015-06-09 20:50:40'),(2753,1,1,22,0,'2015-06-09 18:10:09','2015-06-09 18:10:00',1.3360,0.0000,1,'2015-06-09 20:50:40'),(2754,1,1,22,0,'2015-06-09 18:20:09','2015-06-09 18:20:00',1.3360,0.0000,1,'2015-06-09 20:50:40'),(2755,1,1,22,0,'2015-06-09 18:30:09','2015-06-09 18:30:00',1.3370,0.0000,1,'2015-06-09 20:50:40'),(2756,1,1,22,0,'2015-06-09 18:40:09','2015-06-09 18:40:00',1.3370,0.0000,1,'2015-06-09 20:50:40'),(2757,1,1,22,0,'2015-06-09 18:50:09','2015-06-09 18:50:00',1.3380,0.0000,1,'2015-06-09 20:50:40'),(2758,1,1,22,0,'2015-06-09 19:00:09','2015-06-09 19:00:00',1.3410,0.0000,1,'2015-06-09 20:50:40'),(2759,1,1,22,0,'2015-06-09 19:10:09','2015-06-09 19:10:00',1.3440,0.0000,1,'2015-06-09 20:50:40'),(2760,1,1,22,0,'2015-06-09 19:20:09','2015-06-09 19:20:00',1.3490,0.0000,1,'2015-06-09 20:50:40'),(2761,1,1,22,0,'2015-06-09 19:30:09','2015-06-09 19:30:00',1.3500,0.0000,1,'2015-06-09 20:50:40'),(2762,1,1,22,0,'2015-06-09 19:40:09','2015-06-09 19:40:00',1.3500,0.0000,1,'2015-06-09 20:50:40'),(2763,1,1,22,0,'2015-06-09 19:50:09','2015-06-09 19:50:00',1.3500,0.0000,1,'2015-06-09 20:50:40'),(2764,1,1,22,0,'2015-06-09 20:00:09','2015-06-09 20:00:00',1.3500,0.0000,1,'2015-06-09 20:50:40'),(2765,1,1,22,0,'2015-06-09 20:10:09','2015-06-09 20:10:00',1.3500,0.0000,1,'2015-06-09 20:50:40'),(2766,1,1,22,0,'2015-06-09 20:20:09','2015-06-09 20:20:00',1.3500,0.0000,1,'2015-06-09 20:50:40'),(2767,1,1,22,0,'2015-06-09 20:30:09','2015-06-09 20:30:00',1.3500,0.0000,1,'2015-06-09 20:50:40'),(2768,1,1,22,0,'2015-06-09 20:40:09','2015-06-09 20:40:00',1.3500,0.0000,1,'2015-06-09 20:50:40'),(2769,1,1,22,0,'2015-06-09 20:50:09','2015-06-09 20:50:00',1.3510,0.0000,1,'2015-06-09 20:50:40'),(2770,1,1,22,0,'2015-06-09 21:00:09','2015-06-09 21:00:00',1.3510,0.0000,1,'2015-06-09 20:50:40'),(2771,1,1,22,0,'2015-06-09 21:10:09','2015-06-09 21:10:00',1.3510,0.0000,1,'2015-06-09 20:50:40'),(2772,1,1,22,0,'2015-06-09 21:20:09','2015-06-09 21:20:00',1.3510,0.0000,1,'2015-06-09 20:50:40'),(2773,1,1,22,0,'2015-06-09 21:30:09','2015-06-09 21:30:00',1.3520,0.0000,1,'2015-06-09 20:50:40'),(2774,1,1,22,0,'2015-06-09 21:40:09','2015-06-09 21:40:00',1.3520,0.0000,1,'2015-06-09 20:50:40'),(2775,1,1,22,0,'2015-06-09 21:50:09','2015-06-09 21:50:00',1.3520,0.0000,1,'2015-06-09 20:50:40'),(2776,1,1,22,0,'2015-06-09 22:00:09','2015-06-09 22:00:00',1.3560,0.0000,1,'2015-06-09 20:50:40'),(2777,1,1,22,0,'2015-06-09 22:10:09','2015-06-09 22:10:00',1.3570,0.0000,1,'2015-06-09 20:50:40'),(2778,1,1,22,0,'2015-06-09 22:20:09','2015-06-09 22:20:00',1.3570,0.0000,1,'2015-06-09 20:50:40'),(2779,1,1,22,0,'2015-06-09 22:30:09','2015-06-09 22:30:00',1.3570,0.0000,1,'2015-06-09 20:50:40'),(2780,1,1,22,0,'2015-06-09 22:40:09','2015-06-09 22:40:00',1.3570,0.0000,1,'2015-06-09 20:50:40'),(2781,1,1,22,0,'2015-06-09 22:50:09','2015-06-09 22:50:00',1.3570,0.0000,1,'2015-06-09 20:50:40'),(2782,1,1,22,0,'2015-06-09 23:00:09','2015-06-09 23:00:00',1.3620,0.0000,1,'2015-06-09 20:50:40'),(2783,1,1,22,0,'2015-06-09 23:10:09','2015-06-09 23:10:00',1.3690,0.0000,1,'2015-06-09 20:50:40'),(2784,1,1,22,0,'2015-06-09 23:20:09','2015-06-09 23:20:00',1.3790,0.0000,1,'2015-06-09 20:50:40'),(2785,1,1,22,0,'2015-06-09 23:30:09','2015-06-09 23:30:00',1.3830,0.0000,1,'2015-06-09 20:50:40'),(2786,1,1,22,0,'2015-06-09 23:40:09','2015-06-09 23:40:00',1.3840,0.0000,1,'2015-06-09 20:50:40'),(2787,1,1,22,0,'2015-06-09 23:50:09','2015-06-09 23:50:00',1.3940,0.0000,1,'2015-06-09 20:50:40'),(2788,1,1,22,0,'2015-06-10 00:00:09','2015-06-10 00:00:00',1.3960,0.0000,1,'2015-06-09 20:50:40'),(2789,1,1,22,0,'2015-06-10 00:10:09','2015-06-10 00:10:00',1.3960,0.0000,1,'2015-06-09 20:50:40'),(2790,1,1,22,0,'2015-06-10 00:20:09','2015-06-10 00:20:00',1.3980,0.0000,1,'2015-06-09 20:50:40'),(2791,1,1,22,0,'2015-06-10 00:30:09','2015-06-10 00:30:00',1.3980,0.0000,1,'2015-06-09 20:50:40'),(2792,1,1,22,0,'2015-06-10 00:40:09','2015-06-10 00:40:00',1.3980,0.0000,1,'2015-06-09 20:50:40'),(2793,1,1,22,0,'2015-06-10 00:50:09','2015-06-10 00:50:00',1.3980,0.0000,1,'2015-06-09 20:50:40'),(2794,1,1,22,0,'2015-06-10 01:00:09','2015-06-10 01:00:00',1.4000,0.0000,1,'2015-06-09 20:50:40'),(2795,1,1,22,0,'2015-06-10 01:10:09','2015-06-10 01:10:00',1.4000,0.0000,1,'2015-06-09 20:50:40'),(2796,1,1,22,0,'2015-06-10 01:20:09','2015-06-10 01:20:00',1.4000,0.0000,1,'2015-06-09 20:50:40'),(2797,1,1,22,0,'2015-06-10 01:30:09','2015-06-10 01:30:00',1.4000,0.0000,1,'2015-06-09 20:50:40'),(2798,1,1,22,0,'2015-06-10 01:40:09','2015-06-10 01:40:00',1.4000,0.0000,1,'2015-06-09 20:50:40'),(2799,1,1,22,0,'2015-06-10 01:50:09','2015-06-10 01:50:00',1.4000,0.0000,1,'2015-06-09 20:50:40'),(2800,1,1,22,0,'2015-06-10 02:00:09','2015-06-10 02:00:00',1.4000,0.0000,1,'2015-06-09 20:50:40'),(2801,1,1,22,0,'2015-06-10 02:10:09','2015-06-10 02:10:00',1.4000,0.0000,1,'2015-06-09 20:50:40'),(2802,1,1,22,0,'2015-06-10 02:20:09','2015-06-10 02:20:00',1.4000,0.0000,1,'2015-06-09 20:50:40'),(2803,1,1,22,0,'2015-06-10 02:30:09','2015-06-10 02:30:00',1.4000,0.0000,1,'2015-06-09 20:50:40'),(2804,1,1,22,0,'2015-06-10 02:40:09','2015-06-10 02:40:00',1.4000,0.0000,1,'2015-06-09 20:50:40'),(2805,1,1,22,0,'2015-06-10 02:50:09','2015-06-10 02:50:00',1.4000,0.0000,1,'2015-06-09 20:50:40'),(2806,1,1,22,0,'2015-06-10 03:00:09','2015-06-10 03:00:00',1.4020,0.0000,1,'2015-06-09 20:50:40'),(2807,1,1,22,0,'2015-06-10 03:10:09','2015-06-10 03:10:00',1.4020,0.0000,1,'2015-06-09 20:50:40'),(2808,1,1,22,0,'2015-06-10 03:20:09','2015-06-10 03:20:00',1.4020,0.0000,1,'2015-06-09 20:50:40'),(2809,1,1,22,0,'2015-06-10 03:30:09','2015-06-10 03:30:00',1.4020,0.0000,1,'2015-06-09 20:50:40'),(2810,1,1,22,0,'2015-06-10 03:40:09','2015-06-10 03:40:00',1.4020,0.0000,1,'2015-06-09 20:50:40'),(2811,1,1,22,0,'2015-06-10 03:50:09','2015-06-10 03:50:00',1.4020,0.0000,1,'2015-06-09 20:50:40'),(2812,1,1,22,0,'2015-06-10 04:00:09','2015-06-10 04:00:00',1.4020,0.0000,1,'2015-06-09 20:50:40'),(2813,1,1,22,0,'2015-06-10 04:10:09','2015-06-10 04:10:00',1.4020,0.0000,1,'2015-06-09 20:50:40'),(2814,1,1,22,0,'2015-06-10 04:20:09','2015-06-10 04:20:00',1.4020,0.0000,1,'2015-06-09 20:50:40'),(2815,1,1,22,0,'2015-06-10 04:30:09','2015-06-10 04:30:00',1.4020,0.0000,1,'2015-06-09 20:50:40'),(2816,1,1,22,0,'2015-06-10 04:40:09','2015-06-10 04:40:00',1.4020,0.0000,1,'2015-06-09 20:50:40'),(2817,1,1,22,0,'2015-06-10 04:50:09','2015-06-10 04:50:00',1.4020,0.0000,1,'2015-06-09 20:50:40'),(2818,1,1,22,0,'2015-06-10 05:00:09','2015-06-10 05:00:00',1.4040,0.0000,1,'2015-06-09 20:50:40'),(2819,1,1,22,0,'2015-06-10 05:10:09','2015-06-10 05:10:00',1.4040,0.0000,1,'2015-06-09 20:50:40'),(2820,1,1,22,0,'2015-06-10 05:20:09','2015-06-10 05:20:00',1.4040,0.0000,1,'2015-06-09 20:50:40'),(2821,1,1,22,0,'2015-06-10 05:30:09','2015-06-10 05:30:00',1.4040,0.0000,1,'2015-06-09 20:50:40'),(2822,1,1,22,0,'2015-06-10 05:40:09','2015-06-10 05:40:00',1.4040,0.0000,1,'2015-06-09 20:50:40'),(2823,1,1,22,0,'2015-06-10 05:50:09','2015-06-10 05:50:00',1.4040,0.0000,1,'2015-06-09 20:50:40'),(2824,1,1,22,0,'2015-06-10 06:00:09','2015-06-10 06:00:00',1.4040,0.0000,1,'2015-06-09 20:50:40'),(2825,1,1,22,0,'2015-06-10 06:10:09','2015-06-10 06:10:00',1.4040,0.0000,1,'2015-06-09 20:50:40'),(2826,1,1,22,0,'2015-06-10 06:20:09','2015-06-10 06:20:00',1.4040,0.0000,1,'2015-06-09 20:50:40'),(2827,1,1,22,0,'2015-06-10 06:30:09','2015-06-10 06:30:00',1.4040,0.0000,1,'2015-06-09 20:50:40'),(2828,1,1,22,0,'2015-06-10 06:40:09','2015-06-10 06:40:00',1.4040,0.0000,1,'2015-06-09 20:50:40'),(2829,1,1,22,0,'2015-06-10 06:50:09','2015-06-10 06:50:00',1.4040,0.0000,1,'2015-06-09 20:50:40');
/*!40000 ALTER TABLE `terminals_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `terminals_groups`
--

DROP TABLE IF EXISTS `terminals_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `terminals_groups` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_partner` int(11) unsigned NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `TERMINALSGROUP_ON_PARTNER` (`id_partner`),
  CONSTRAINT `TERMINALSGROUP_ON_PARTNER` FOREIGN KEY (`id_partner`) REFERENCES `partners` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `terminals_groups`
--

LOCK TABLES `terminals_groups` WRITE;
/*!40000 ALTER TABLE `terminals_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `terminals_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `terminals_logs`
--

DROP TABLE IF EXISTS `terminals_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `terminals_logs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_terminal` int(11) unsigned NOT NULL,
  `id_place` int(11) unsigned NOT NULL,
  `state` tinyint(3) DEFAULT '-1' COMMENT 'Изменение состояния терминала "-1"-снимаем с места, "1" - установка терминала на место, "0" - перевод терминала в нерабочее состояние, "2" - возвращение терминала в рабочее состояние, "-2" - кража терминала',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_termlogs_ON_terminals` (`id_terminal`),
  KEY `FK_termlogs_ON_palces` (`id_place`),
  CONSTRAINT `FK_termlogs_ON_palces` FOREIGN KEY (`id_place`) REFERENCES `places` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_termlogs_ON_terminals` FOREIGN KEY (`id_terminal`) REFERENCES `terminals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `terminals_logs`
--

LOCK TABLES `terminals_logs` WRITE;
/*!40000 ALTER TABLE `terminals_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `terminals_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `terminals_on_groups`
--

DROP TABLE IF EXISTS `terminals_on_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `terminals_on_groups` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_terminal` int(11) unsigned NOT NULL,
  `id_terminals_group` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_TG_ON_Terminal` (`id_terminal`),
  KEY `FK_TG_ON_TerminalsGroup` (`id_terminals_group`),
  CONSTRAINT `FK_TG_ON_Terminal` FOREIGN KEY (`id_terminal`) REFERENCES `terminals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_TG_ON_TerminalsGroup` FOREIGN KEY (`id_terminals_group`) REFERENCES `terminals_groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `terminals_on_groups`
--

LOCK TABLES `terminals_on_groups` WRITE;
/*!40000 ALTER TABLE `terminals_on_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `terminals_on_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `terminals_status`
--

DROP TABLE IF EXISTS `terminals_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `terminals_status` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_terminal` int(11) unsigned NOT NULL DEFAULT '0',
  `kup` int(11) DEFAULT '0',
  `lastActivity` datetime DEFAULT '2011-01-01 00:00:00' COMMENT 'время последней активности',
  `lastPayment` datetime DEFAULT '2011-01-01 00:00:00' COMMENT 'время и дата последнего отправленного с терминала платежа',
  `lastUpdateRequest` datetime DEFAULT '2011-01-01 00:00:00' COMMENT 'Дата и время последнего запроса обновлений',
  `UpdatingState` tinyint(3) unsigned NOT NULL DEFAULT '1' COMMENT 'Индикатор состояния обновления доп.настроек',
  `noteError` varchar(255) DEFAULT 'OK' COMMENT 'текствовое описание ошибки купюроприемника',
  `printerError` varchar(255) DEFAULT 'OK' COMMENT 'текстовое описание ошибки принтера',
  `signalLevel` int(11) DEFAULT '0' COMMENT 'уровень сигнала',
  `simBalance` double(11,2) DEFAULT '0.00' COMMENT 'баланс на симкарте',
  `DoorAlarm` int(11) DEFAULT '0' COMMENT 'счетчик тревог двери',
  `DoorOpen` int(11) DEFAULT '0' COMMENT 'счетчик открытий двери',
  `wdtEventText` varchar(255) DEFAULT '000' COMMENT 'состояние терминала',
  `machineStatus` varchar(255) DEFAULT '000' COMMENT 'набор флагов состояния терминала',
  `DateCash` datetime DEFAULT '2011-01-01 00:00:00',
  `sumCash` double(11,2) DEFAULT '0.00',
  `monet` int(11) DEFAULT '0',
  `CashInModel` varchar(255) DEFAULT '123' COMMENT 'Моделькупброприемника',
  `HDD` varchar(255) DEFAULT '123' COMMENT 'HDD',
  `CashInCapacity` int(6) DEFAULT '1000' COMMENT 'Вместимость купюроприемника',
  `ClientSoftware` varchar(255) DEFAULT '123' COMMENT 'Версия ПО терминала',
  `PrinterModel` varchar(255) DEFAULT '123' COMMENT 'Модель принтера',
  `InterfaceVersion` varchar(255) DEFAULT '123' COMMENT 'Версия интерфеса терминала',
  `IPManagerVersion` varchar(255) DEFAULT '1.0' COMMENT 'Версия системы управления Inter-Pay',
  `MobileOperatorId` varchar(255) DEFAULT '2' COMMENT 'Оператор',
  `Flags` varchar(255) DEFAULT '00000000000000' COMMENT 'набор флагов состояния',
  `Adres` varchar(255) DEFAULT '4544545' COMMENT 'Адрес терминала',
  `ip_vpn` varchar(100) DEFAULT '' COMMENT 'ip адрес терминала в VPN',
  `ip_ext` varchar(100) DEFAULT '' COMMENT 'внешний ip адрес терминала',
  PRIMARY KEY (`id`),
  KEY `FK_TSTATUS_ON_TERMINAL` (`id_terminal`),
  CONSTRAINT `FK_TSTATUS_ON_TERMINAL` FOREIGN KEY (`id_terminal`) REFERENCES `terminals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 CHECKSUM=1 DELAY_KEY_WRITE=1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `terminals_status`
--

LOCK TABLES `terminals_status` WRITE;
/*!40000 ALTER TABLE `terminals_status` DISABLE KEYS */;
/*!40000 ALTER TABLE `terminals_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `terminals_types`
--

DROP TABLE IF EXISTS `terminals_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `terminals_types` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(60) NOT NULL,
  `transit` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'Идентификатор транзитности типа терминала',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `terminals_types`
--

LOCK TABLES `terminals_types` WRITE;
/*!40000 ALTER TABLE `terminals_types` DISABLE KEYS */;
INSERT INTO `terminals_types` VALUES (0,'ReTranslater Tiva',1),(1,'Counter',0),(2,'ReTranslater USB Dongle',1),(3,'Controller',0);
/*!40000 ALTER TABLE `terminals_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transactions` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_transactions_type` int(11) unsigned NOT NULL,
  `ext_id` bigint(20) DEFAULT NULL,
  `date_init` datetime DEFAULT NULL,
  `date_fin` datetime DEFAULT NULL,
  `date_cancel` datetime DEFAULT NULL,
  `state` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `comment` varchar(255) DEFAULT NULL,
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_transactions_type` (`id_transactions_type`),
  KEY `IND_transactions_STATE` (`state`),
  KEY `IND_ext_id` (`ext_id`),
  CONSTRAINT `TRANSACTIONS_ON_TRANSACTIONS_TYPE` FOREIGN KEY (`id_transactions_type`) REFERENCES `transactions_types` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions_temp`
--

DROP TABLE IF EXISTS `transactions_temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transactions_temp` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_transactions_type` int(11) unsigned NOT NULL,
  `ext_id` bigint(20) DEFAULT NULL,
  `date_init` datetime DEFAULT NULL,
  `date_fin` datetime DEFAULT NULL,
  `date_cancel` datetime DEFAULT NULL,
  `state` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `comment` varchar(255) DEFAULT NULL,
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_transaction_type` (`id_transactions_type`),
  KEY `IND_transactions_temp_STATE` (`state`),
  KEY `IND_ext_id` (`ext_id`),
  CONSTRAINT `TRANSTEMP_ON_TRANSTYPE` FOREIGN KEY (`id_transactions_type`) REFERENCES `transactions_types` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions_temp`
--

LOCK TABLES `transactions_temp` WRITE;
/*!40000 ALTER TABLE `transactions_temp` DISABLE KEYS */;
/*!40000 ALTER TABLE `transactions_temp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions_transfers`
--

DROP TABLE IF EXISTS `transactions_transfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transactions_transfers` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `amount` double(15,4) NOT NULL DEFAULT '0.0000',
  `id_transaction` int(11) unsigned NOT NULL,
  `id_bill` int(11) unsigned NOT NULL,
  `state` tinyint(2) NOT NULL DEFAULT '0',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_transactions_transfers` (`id_transaction`),
  KEY `FK_TRANSF_ON_BILL` (`id_bill`),
  KEY `IND_transactions_transfers_STATE` (`state`),
  CONSTRAINT `FK_TRANSF_ON_BILL` FOREIGN KEY (`id_bill`) REFERENCES `bills` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_TRANSF_ON_TRANS` FOREIGN KEY (`id_transaction`) REFERENCES `transactions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions_transfers`
--

LOCK TABLES `transactions_transfers` WRITE;
/*!40000 ALTER TABLE `transactions_transfers` DISABLE KEYS */;
/*!40000 ALTER TABLE `transactions_transfers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions_transfers_temp`
--

DROP TABLE IF EXISTS `transactions_transfers_temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transactions_transfers_temp` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `amount` double(15,4) NOT NULL DEFAULT '0.0000',
  `id_transaction` int(11) unsigned NOT NULL,
  `id_bill` int(11) unsigned NOT NULL,
  `state` tinyint(2) NOT NULL DEFAULT '0',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FK_transactions_transfers` (`id_transaction`),
  KEY `id_bill` (`id_bill`),
  KEY `IND_transactions_transfers_temp_STATE` (`state`),
  CONSTRAINT `FK_TRANSFTEMP_ON_BILL` FOREIGN KEY (`id_bill`) REFERENCES `bills` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_TRANSFTEMP_ON_TRANSTEMP` FOREIGN KEY (`id_transaction`) REFERENCES `transactions_temp` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions_transfers_temp`
--

LOCK TABLES `transactions_transfers_temp` WRITE;
/*!40000 ALTER TABLE `transactions_transfers_temp` DISABLE KEYS */;
/*!40000 ALTER TABLE `transactions_transfers_temp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions_types`
--

DROP TABLE IF EXISTS `transactions_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transactions_types` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `caption` varchar(255) DEFAULT NULL,
  `description` longtext,
  `params` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions_types`
--

LOCK TABLES `transactions_types` WRITE;
/*!40000 ALTER TABLE `transactions_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `transactions_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `login` varchar(45) NOT NULL,
  `md5_pass` varchar(45) NOT NULL DEFAULT '',
  `error` int(1) unsigned DEFAULT NULL,
  `secure` varchar(45) DEFAULT NULL,
  `id_partner` int(11) unsigned DEFAULT NULL,
  `id_person` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `login` (`login`),
  UNIQUE KEY `secure` (`secure`),
  KEY `IND_partner` (`id_partner`),
  KEY `IND_person` (`id_person`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_groups`
--

DROP TABLE IF EXISTS `users_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_groups` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'идентификатор',
  `group` varchar(20) NOT NULL COMMENT 'имя группы для проверок в коде',
  `title` varchar(30) NOT NULL COMMENT 'отображаемое имя группы',
  PRIMARY KEY (`id`),
  UNIQUE KEY `group` (`group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_groups`
--

LOCK TABLES `users_groups` WRITE;
/*!40000 ALTER TABLE `users_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `users_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_roles`
--

DROP TABLE IF EXISTS `users_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_roles` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_user` int(11) unsigned NOT NULL,
  `id_users_group` int(11) unsigned NOT NULL,
  `allow` tinyint(2) unsigned NOT NULL DEFAULT '7' COMMENT 'Уровень прав к разделу',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `id_user` (`id_user`),
  KEY `id_user_group` (`id_users_group`),
  CONSTRAINT `users_roles_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id`),
  CONSTRAINT `users_roles_ibfk_2` FOREIGN KEY (`id_users_group`) REFERENCES `users_groups` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_roles`
--

LOCK TABLES `users_roles` WRITE;
/*!40000 ALTER TABLE `users_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `users_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `xml_perm`
--

DROP TABLE IF EXISTS `xml_perm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `xml_perm` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_xml_template` int(11) NOT NULL,
  `node` varchar(255) NOT NULL,
  `disabled` tinyint(1) NOT NULL DEFAULT '0',
  `add_node` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `id_xml_template` (`id_xml_template`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `xml_perm`
--

LOCK TABLES `xml_perm` WRITE;
/*!40000 ALTER TABLE `xml_perm` DISABLE KEYS */;
/*!40000 ALTER TABLE `xml_perm` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `xml_template`
--

DROP TABLE IF EXISTS `xml_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `xml_template` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_xml_type` int(11) NOT NULL,
  `id_core` int(11) NOT NULL,
  `template` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_xml_type` (`id_xml_type`),
  KEY `id_core` (`id_core`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `xml_template`
--

LOCK TABLES `xml_template` WRITE;
/*!40000 ALTER TABLE `xml_template` DISABLE KEYS */;
/*!40000 ALTER TABLE `xml_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `xml_translation`
--

DROP TABLE IF EXISTS `xml_translation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `xml_translation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `node` varchar(255) NOT NULL,
  `name_ru` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `xml_translation`
--

LOCK TABLES `xml_translation` WRITE;
/*!40000 ALTER TABLE `xml_translation` DISABLE KEYS */;
/*!40000 ALTER TABLE `xml_translation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `xml_type`
--

DROP TABLE IF EXISTS `xml_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `xml_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `xml_type`
--

LOCK TABLES `xml_type` WRITE;
/*!40000 ALTER TABLE `xml_type` DISABLE KEYS */;
/*!40000 ALTER TABLE `xml_type` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-06-13 19:50:28
