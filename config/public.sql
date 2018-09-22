/*
Navicat PGSQL Data Transfer

Source Server         : billy
Source Server Version : 90505
Source Host           : localhost:5432
Source Database       : billy
Source Schema         : public

Target Server Type    : PGSQL
Target Server Version : 90505
File Encoding         : 65001

Date: 2017-05-10 11:48:05
*/


-- ----------------------------
-- Sequence structure for city_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."city_id_seq";
CREATE SEQUENCE "public"."city_id_seq"
 INCREMENT 1
 MINVALUE 1
 MAXVALUE 9223372036854775807
 START 32
 CACHE 1;
SELECT setval('"public"."city_id_seq"', 32, true);

-- ----------------------------
-- Sequence structure for client_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."client_id_seq";
CREATE SEQUENCE "public"."client_id_seq"
 INCREMENT 1
 MINVALUE 1
 MAXVALUE 9223372036854775807
 START 411
 CACHE 1;
SELECT setval('"public"."client_id_seq"', 411, true);

-- ----------------------------
-- Sequence structure for country_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."country_id_seq";
CREATE SEQUENCE "public"."country_id_seq"
 INCREMENT 1
 MINVALUE 1
 MAXVALUE 9223372036854775807
 START 7
 CACHE 1;
SELECT setval('"public"."country_id_seq"', 7, true);

-- ----------------------------
-- Sequence structure for district_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."district_id_seq";
CREATE SEQUENCE "public"."district_id_seq"
 INCREMENT 1
 MINVALUE 1
 MAXVALUE 9223372036854775807
 START 20
 CACHE 1;
SELECT setval('"public"."district_id_seq"', 20, true);

-- ----------------------------
-- Sequence structure for item_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."item_id_seq";
CREATE SEQUENCE "public"."item_id_seq"
 INCREMENT 1
 MINVALUE 1
 MAXVALUE 9223372036854775807
 START 183
 CACHE 1;
SELECT setval('"public"."item_id_seq"', 183, true);

-- ----------------------------
-- Sequence structure for ledger_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."ledger_id_seq";
CREATE SEQUENCE "public"."ledger_id_seq"
 INCREMENT 1
 MINVALUE 1
 MAXVALUE 9223372036854775807
 START 2
 CACHE 1;
SELECT setval('"public"."ledger_id_seq"', 2, true);

-- ----------------------------
-- Sequence structure for photo_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."photo_id_seq";
CREATE SEQUENCE "public"."photo_id_seq"
 INCREMENT 1
 MINVALUE 1
 MAXVALUE 9223372036854775807
 START 1
 CACHE 1;

-- ----------------------------
-- Sequence structure for product_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."product_id_seq";
CREATE SEQUENCE "public"."product_id_seq"
 INCREMENT 1
 MINVALUE 1
 MAXVALUE 9223372036854775807
 START 43
 CACHE 1;
SELECT setval('"public"."product_id_seq"', 43, true);

-- ----------------------------
-- Sequence structure for rank_buyer_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."rank_buyer_id_seq";
CREATE SEQUENCE "public"."rank_buyer_id_seq"
 INCREMENT 1
 MINVALUE 1
 MAXVALUE 9223372036854775807
 START 11
 CACHE 1;
SELECT setval('"public"."rank_buyer_id_seq"', 11, true);

-- ----------------------------
-- Sequence structure for sess_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sess_id_seq";
CREATE SEQUENCE "public"."sess_id_seq"
 INCREMENT 1
 MINVALUE 1
 MAXVALUE 9223372036854775807
 START 20
 CACHE 1;
SELECT setval('"public"."sess_id_seq"', 20, true);

-- ----------------------------
-- Sequence structure for trade_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."trade_id_seq";
CREATE SEQUENCE "public"."trade_id_seq"
 INCREMENT 1
 MINVALUE 1
 MAXVALUE 9223372036854775807
 START 221
 CACHE 1;
SELECT setval('"public"."trade_id_seq"', 221, true);

-- ----------------------------
-- Table structure for city
-- ----------------------------
DROP TABLE IF EXISTS "public"."city";
CREATE TABLE "public"."city" (
"id" int4 DEFAULT nextval('city_id_seq'::regclass) NOT NULL,
"latin" varchar COLLATE "default",
"russian" varchar(255) COLLATE "default" NOT NULL,
"country" int2 NOT NULL
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for client
-- ----------------------------
DROP TABLE IF EXISTS "public"."client";
CREATE TABLE "public"."client" (
"id" int4 DEFAULT nextval('client_id_seq'::regclass) NOT NULL,
"tele" int4 NOT NULL,
"username" varchar COLLATE "default" NOT NULL,
"created" timestamp(6) DEFAULT now(),
"description" text COLLATE "default",
"autoshop" int2 DEFAULT 1 NOT NULL,
"wallet" text COLLATE "default",
"country" int2,
"city" int2,
"commission" int2 DEFAULT 5 NOT NULL,
"escrow" int2 DEFAULT 0 NOT NULL,
"title" text COLLATE "default"
)
WITH (OIDS=FALSE)

;
COMMENT ON COLUMN "public"."client"."description" IS 'description';

-- ----------------------------
-- Table structure for country
-- ----------------------------
DROP TABLE IF EXISTS "public"."country";
CREATE TABLE "public"."country" (
"id" int4 DEFAULT nextval('country_id_seq'::regclass) NOT NULL,
"code" varchar COLLATE "default" NOT NULL,
"latin" varchar(255) COLLATE "default",
"russian" varchar(255) COLLATE "default"
)
WITH (OIDS=FALSE)

;


DROP TABLE IF EXISTS "public"."config";
CREATE TABLE "public"."config" (
"id" serial primary key,
"key" varchar COLLATE "default" NOT NULL,
"value" varchar(255) COLLATE "default"
)

-- ----------------------------
-- Table structure for district
-- ----------------------------
DROP TABLE IF EXISTS "public"."district";
CREATE TABLE "public"."district" (
"id" int4 DEFAULT nextval('district_id_seq'::regclass) NOT NULL,
"title" text COLLATE "default",
"russian" varchar(255) COLLATE "default" NOT NULL,
"city" int2
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for item
-- ----------------------------
DROP TABLE IF EXISTS "public"."item";
CREATE TABLE "public"."item" (
"id" int4 DEFAULT nextval('item_id_seq'::regclass) NOT NULL,
"price" int4,
"details" text COLLATE "default",
"status" int4 DEFAULT 0 NOT NULL,
"created" timestamp(6) DEFAULT now(),
"product" int2,
"qnt" varchar(32) COLLATE "default",
"city" int2,
"district" int2,
"client" int2,
"sold" timestamp(6) DEFAULT now(),
"full" text COLLATE "default",
"escrow" int2 DEFAULT 30
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for ledger
-- ----------------------------
DROP TABLE IF EXISTS "public"."ledger";
CREATE TABLE "public"."ledger" (
"id" int4 DEFAULT nextval('ledger_id_seq'::regclass) NOT NULL,
"trade" int4,
"debit" int4,
"credit" int4,
"amount" int4 NOT NULL,
"details" text COLLATE "default",
"status" text COLLATE "default" NOT NULL,
"created" text COLLATE "default" DEFAULT 'current_timestamp'::text
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for photo
-- ----------------------------
DROP TABLE IF EXISTS "public"."photo";
CREATE TABLE "public"."photo" (
"id" int4 DEFAULT nextval('photo_id_seq'::regclass) NOT NULL,
"item" int4,
"tid" varchar COLLATE "default",
"status" int4 DEFAULT 0
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for product
-- ----------------------------
DROP TABLE IF EXISTS "public"."product";
CREATE TABLE "public"."product" (
"id" int4 DEFAULT nextval('product_id_seq'::regclass) NOT NULL,
"title" text COLLATE "default" NOT NULL,
"russian" text COLLATE "default",
"icon" varchar(255) COLLATE "default"
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for rank
-- ----------------------------
DROP TABLE IF EXISTS "public"."rank";
CREATE TABLE "public"."rank" (
"id" int4 DEFAULT nextval('rank_buyer_id_seq'::regclass) NOT NULL,
"trade" int4,
"rank" int4 DEFAULT 0 NOT NULL,
"created" timestamp(6) DEFAULT now()
)
WITH (OIDS=FALSE)
;

DROP TABLE IF EXISTS "public"."ref";
CREATE TABLE "public"."ref" (
"id" serial primary key,
"client" int4 NOT NULL,
"client2" int4 NOT NULL,
"created" timestamp DEFAULT CURRENT_TIMESTAMP
)


DROP TABLE IF EXISTS "public"."dispute";
CREATE TABLE "public"."dispute" (
"id" serial primary key,
"trade" int4 NOT NULL,
"created" timestamp DEFAULT CURRENT_TIMESTAMP
)

-- ----------------------------
-- Table structure for sess
-- ----------------------------
DROP TABLE IF EXISTS "public"."sess";
CREATE TABLE "public"."sess" (
"id" int4 DEFAULT nextval('sess_id_seq'::regclass) NOT NULL,
"sid" text COLLATE "default" NOT NULL,
"data" "public"."hstore"
)
WITH (OIDS=FALSE)

;

-- ----------------------------
-- Table structure for trade
-- ----------------------------
DROP TABLE IF EXISTS "public"."trade";
CREATE TABLE "public"."trade" (
"id" int4 DEFAULT nextval('trade_id_seq'::regclass) NOT NULL,
"item" int4,
"seller" int4,
"escrow" int8 DEFAULT 5 NOT NULL,
"status" int4 DEFAULT 0 NOT NULL,
"created" timestamp(6) DEFAULT now() NOT NULL,
"closed" timestamp(6) DEFAULT now(),
"buyer" int2,
"amount" int8,
"commission" int8
)
WITH (OIDS=FALSE)

;

DROP TABLE IF EXISTS "public"."bot";
CREATE TABLE "public"."bot" (
"id" serial primary key,
"tele" text,
"token" text
)

DROP TABLE IF EXISTS "public"."team";
CREATE TABLE "public"."team" (
"id" serial primary key,
"bot" int,
"client" int,
"role" int
)

DROP TABLE IF EXISTS "public"."try";
CREATE TABLE "public"."try" (
"id" serial primary key,
"client" int,
"tried" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

DROP TABLE IF EXISTS "public"."method";
CREATE TABLE "public"."method" (
"id" serial primary key,
"title" text,
'russian' text
)

DROP TABLE IF EXISTS "public"."price";
CREATE TABLE "public"."price" (
"id" serial primary key,
"product" int,
'bot' int,
'amount'
)

CREATE TABLE "public"."invoice" (
"id" serial primary key,
"code" varchar
)

CREATE TABLE "public"."го" (
"id" serial primary key,
"code" varchar
)

CREATE TABLE "public"."image" (
"id" serial primary key,
kind int default 0,
"text" varchar
status int default 0
)



-- ----------------------------
-- Alter Sequences Owned By 
-- ----------------------------
ALTER SEQUENCE "public"."city_id_seq" OWNED BY "city"."id";
ALTER SEQUENCE "public"."client_id_seq" OWNED BY "client"."id";
ALTER SEQUENCE "public"."country_id_seq" OWNED BY "country"."id";
ALTER SEQUENCE "public"."district_id_seq" OWNED BY "district"."id";
ALTER SEQUENCE "public"."item_id_seq" OWNED BY "item"."id";
ALTER SEQUENCE "public"."ledger_id_seq" OWNED BY "ledger"."id";
ALTER SEQUENCE "public"."product_id_seq" OWNED BY "product"."id";
ALTER SEQUENCE "public"."rank_buyer_id_seq" OWNED BY "rank"."id";
ALTER SEQUENCE "public"."trade_id_seq" OWNED BY "trade"."id";

-- ----------------------------
-- Uniques structure for table city
-- ----------------------------
ALTER TABLE "public"."city" ADD UNIQUE ("latin", "russian", "country");

-- ----------------------------
-- Primary Key structure for table city
-- ----------------------------
ALTER TABLE "public"."city" ADD PRIMARY KEY ("id");

-- ----------------------------
-- Uniques structure for table client
-- ----------------------------
ALTER TABLE "public"."client" ADD UNIQUE ("tele", "username");

-- ----------------------------
-- Primary Key structure for table client
-- ----------------------------
ALTER TABLE "public"."client" ADD PRIMARY KEY ("id");

-- ----------------------------
-- Uniques structure for table country
-- ----------------------------
ALTER TABLE "public"."country" ADD UNIQUE ("code");

-- ----------------------------
-- Primary Key structure for table country
-- ----------------------------
ALTER TABLE "public"."country" ADD PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table district
-- ----------------------------
ALTER TABLE "public"."district" ADD PRIMARY KEY ("id");

-- ----------------------------
-- Uniques structure for table item
-- ----------------------------
ALTER TABLE "public"."item" ADD UNIQUE ("id");

-- ----------------------------
-- Primary Key structure for table item
-- ----------------------------
ALTER TABLE "public"."item" ADD PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table ledger
-- ----------------------------
ALTER TABLE "public"."ledger" ADD PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table product
-- ----------------------------
ALTER TABLE "public"."product" ADD PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table rank
-- ----------------------------
ALTER TABLE "public"."rank" ADD PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table trade
-- ----------------------------
ALTER TABLE "public"."trade" ADD PRIMARY KEY ("id");

-- ----------------------------
-- Foreign Key structure for table "public"."city"
-- ----------------------------
ALTER TABLE "public"."city" ADD FOREIGN KEY ("country") REFERENCES "public"."country" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Key structure for table "public"."client"
-- ----------------------------
ALTER TABLE "public"."client" ADD FOREIGN KEY ("country") REFERENCES "public"."city" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Key structure for table "public"."district"
-- ----------------------------
ALTER TABLE "public"."district" ADD FOREIGN KEY ("city") REFERENCES "public"."city" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- ----------------------------
-- Foreign Key structure for table "public"."item"
-- ----------------------------
ALTER TABLE "public"."item" ADD FOREIGN KEY ("client") REFERENCES "public"."client" ("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "public"."item" ADD FOREIGN KEY ("district") REFERENCES "public"."district" ("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "public"."item" ADD FOREIGN KEY ("product") REFERENCES "public"."product" ("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "public"."item" ADD FOREIGN KEY ("city") REFERENCES "public"."city" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- ----------------------------
-- Foreign Key structure for table "public"."ledger"
-- ----------------------------
ALTER TABLE "public"."ledger" ADD FOREIGN KEY ("trade") REFERENCES "public"."trade" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "public"."ledger" ADD FOREIGN KEY ("debit") REFERENCES "public"."client" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "public"."ledger" ADD FOREIGN KEY ("credit") REFERENCES "public"."client" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE INITIALLY DEFERRED;

-- ----------------------------
-- Foreign Key structure for table "public"."rank"
-- ----------------------------
ALTER TABLE "public"."rank" ADD FOREIGN KEY ("trade") REFERENCES "public"."trade" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- ----------------------------
-- Foreign Key structure for table "public"."trade"
-- ----------------------------
ALTER TABLE "public"."trade" ADD FOREIGN KEY ("seller") REFERENCES "public"."client" ("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "public"."trade" ADD FOREIGN KEY ("item") REFERENCES "public"."item" ("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "public"."trade" ADD FOREIGN KEY ("buyer") REFERENCES "public"."client" ("id") ON DELETE CASCADE ON UPDATE CASCADE;
