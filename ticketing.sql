CREATE TABLE "users" (
  "id" varchar(36) PRIMARY KEY,
  "username" varchar(50) UNIQUE NOT NULL,
  "email" varchar(100) UNIQUE NOT NULL,
  "password_hash" varchar(255) NOT NULL,
  "full_name" varchar(100) NOT NULL,
  "role" enum(admin,operator,user) NOT NULL DEFAULT 'user',
  "is_active" boolean DEFAULT true,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "terminals" (
  "id" varchar(10) PRIMARY KEY,
  "name" varchar(100) NOT NULL,
  "location" varchar(255) NOT NULL,
  "latitude" decimal(10,8),
  "longitude" decimal(11,8),
  "is_active" boolean DEFAULT true,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "gates" (
  "id" varchar(20) PRIMARY KEY,
  "terminal_id" varchar(10),
  "name" varchar(50) NOT NULL,
  "type" enum(entry,exit,both) NOT NULL,
  "is_active" boolean DEFAULT true,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "cards" (
  "id" varchar(36) PRIMARY KEY,
  "card_number" varchar(20) UNIQUE NOT NULL,
  "card_type" enum(regular,student,senior,disabled) DEFAULT 'regular',
  "balance" decimal(10,2) DEFAULT 0,
  "is_active" boolean DEFAULT true,
  "is_blocked" boolean DEFAULT false,
  "issued_at" timestamp DEFAULT (now()),
  "last_used_at" timestamp,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "fare_matrix" (
  "id" varchar(36) PRIMARY KEY,
  "origin_terminal_id" varchar(10),
  "destination_terminal_id" varchar(10),
  "base_fare" decimal(10,2) NOT NULL,
  "student_fare" decimal(10,2),
  "senior_fare" decimal(10,2),
  "disabled_fare" decimal(10,2),
  "is_active" boolean DEFAULT true,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "transactions" (
  "id" varchar(36) PRIMARY KEY,
  "card_id" varchar(36),
  "transaction_type" enum(checkin,checkout,topup,refund) NOT NULL,
  "origin_terminal_id" varchar(10),
  "destination_terminal_id" varchar(10),
  "origin_gate_id" varchar(20),
  "destination_gate_id" varchar(20),
  "amount" decimal(10,2) NOT NULL DEFAULT 0,
  "balance_before" decimal(10,2) NOT NULL,
  "balance_after" decimal(10,2) NOT NULL,
  "journey_id" varchar(36),
  "status" enum(pending,completed,failed,cancelled) DEFAULT 'pending',
  "is_offline" boolean DEFAULT false,
  "processed_at" timestamp DEFAULT (now()),
  "synced_at" timestamp,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "journeys" (
  "id" varchar(36) PRIMARY KEY,
  "card_id" varchar(36),
  "origin_terminal_id" varchar(10),
  "destination_terminal_id" varchar(10),
  "origin_gate_id" varchar(20),
  "destination_gate_id" varchar(20),
  "checkin_at" timestamp NOT NULL,
  "checkout_at" timestamp,
  "fare_charged" decimal(10,2),
  "status" enum(active,completed,expired,cancelled) DEFAULT 'active',
  "is_offline" boolean DEFAULT false,
  "synced_at" timestamp,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "card_top_ups" (
  "id" varchar(36) PRIMARY KEY,
  "card_id" varchar(36),
  "amount" decimal(10,2) NOT NULL,
  "balance_before" decimal(10,2) NOT NULL,
  "balance_after" decimal(10,2) NOT NULL,
  "payment_method" enum(cash,bank_transfer,ewallet,card) NOT NULL,
  "payment_reference" varchar(100),
  "terminal_id" varchar(10),
  "processed_by" varchar(36),
  "processed_at" timestamp DEFAULT (now()),
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "system_configs" (
  "id" varchar(36) PRIMARY KEY,
  "config_key" varchar(100) UNIQUE NOT NULL,
  "config_value" text NOT NULL,
  "description" varchar(255),
  "is_active" boolean DEFAULT true,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "audit_logs" (
  "id" varchar(36) PRIMARY KEY,
  "table_name" varchar(50) NOT NULL,
  "record_id" varchar(36) NOT NULL,
  "action" enum(create,update,delete) NOT NULL,
  "old_values" jsonb,
  "new_values" jsonb,
  "changed_by" varchar(36),
  "changed_at" timestamp DEFAULT (now())
);

CREATE TABLE "sync_logs" (
  "id" varchar(36) PRIMARY KEY,
  "terminal_id" varchar(10),
  "sync_type" enum(manual,auto,scheduled) NOT NULL,
  "table_name" varchar(50) NOT NULL,
  "records_count" integer DEFAULT 0,
  "status" enum(success,failed,partial) NOT NULL,
  "error_message" text,
  "sync_started_at" timestamp NOT NULL,
  "sync_completed_at" timestamp,
  "created_at" timestamp DEFAULT (now())
);

COMMENT ON TABLE "users" IS 'User management for system access';

COMMENT ON COLUMN "users"."id" IS 'UUID primary key';

COMMENT ON TABLE "terminals" IS 'Terminal/Station master data';

COMMENT ON COLUMN "terminals"."id" IS 'T001, T002, T003, T004, T005';

COMMENT ON TABLE "gates" IS 'Gate/validator devices per terminal';

COMMENT ON COLUMN "gates"."id" IS 'G001, G002, etc';

COMMENT ON TABLE "cards" IS 'Prepaid card master data';

COMMENT ON COLUMN "cards"."id" IS 'UUID primary key';

COMMENT ON COLUMN "cards"."card_number" IS 'Physical card number';

COMMENT ON TABLE "fare_matrix" IS 'Fare pricing matrix between terminals';

COMMENT ON COLUMN "fare_matrix"."id" IS 'UUID primary key';

COMMENT ON TABLE "transactions" IS 'All transaction records';

COMMENT ON COLUMN "transactions"."id" IS 'UUID primary key';

COMMENT ON COLUMN "transactions"."journey_id" IS 'Link checkin and checkout';

COMMENT ON TABLE "journeys" IS 'Journey tracking from checkin to checkout';

COMMENT ON COLUMN "journeys"."id" IS 'UUID primary key';

COMMENT ON TABLE "card_top_ups" IS 'Card balance top-up records';

COMMENT ON COLUMN "card_top_ups"."id" IS 'UUID primary key';

COMMENT ON TABLE "system_configs" IS 'System configuration parameters';

COMMENT ON COLUMN "system_configs"."id" IS 'UUID primary key';

COMMENT ON TABLE "audit_logs" IS 'Audit trail for important data changes';

COMMENT ON COLUMN "audit_logs"."id" IS 'UUID primary key';

COMMENT ON TABLE "sync_logs" IS 'Synchronization logs between terminals and central server';

COMMENT ON COLUMN "sync_logs"."id" IS 'UUID primary key';

ALTER TABLE "gates" ADD FOREIGN KEY ("terminal_id") REFERENCES "terminals" ("id");

ALTER TABLE "fare_matrix" ADD FOREIGN KEY ("origin_terminal_id") REFERENCES "terminals" ("id");

ALTER TABLE "fare_matrix" ADD FOREIGN KEY ("destination_terminal_id") REFERENCES "terminals" ("id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("card_id") REFERENCES "cards" ("id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("origin_terminal_id") REFERENCES "terminals" ("id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("destination_terminal_id") REFERENCES "terminals" ("id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("origin_gate_id") REFERENCES "gates" ("id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("destination_gate_id") REFERENCES "gates" ("id");

ALTER TABLE "journeys" ADD FOREIGN KEY ("card_id") REFERENCES "cards" ("id");

ALTER TABLE "journeys" ADD FOREIGN KEY ("origin_terminal_id") REFERENCES "terminals" ("id");

ALTER TABLE "journeys" ADD FOREIGN KEY ("destination_terminal_id") REFERENCES "terminals" ("id");

ALTER TABLE "journeys" ADD FOREIGN KEY ("origin_gate_id") REFERENCES "gates" ("id");

ALTER TABLE "journeys" ADD FOREIGN KEY ("destination_gate_id") REFERENCES "gates" ("id");

ALTER TABLE "card_top_ups" ADD FOREIGN KEY ("card_id") REFERENCES "cards" ("id");

ALTER TABLE "card_top_ups" ADD FOREIGN KEY ("terminal_id") REFERENCES "terminals" ("id");

ALTER TABLE "card_top_ups" ADD FOREIGN KEY ("processed_by") REFERENCES "users" ("id");

ALTER TABLE "audit_logs" ADD FOREIGN KEY ("changed_by") REFERENCES "users" ("id");

ALTER TABLE "sync_logs" ADD FOREIGN KEY ("terminal_id") REFERENCES "terminals" ("id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("journey_id") REFERENCES "journeys" ("id");
