REVOKE INSERT, UPDATE, DELETE ON cluster IN SCHEMA public FROM archive_db_writer;
ALTER TABLE cluster ALTER COLUMN status SET NOT NULL;
ALTER TABLE cluster ALTER COLUMN version SET NOT NULL;
