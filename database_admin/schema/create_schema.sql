-- ---------------------------------------------------------------------------
-- Functions
-- ---------------------------------------------------------------------------

-- empty
CREATE OR REPLACE FUNCTION empty(t TEXT)
    RETURNS BOOLEAN AS
$empty$
BEGIN
    RETURN t ~ '^[[:space:]]*$';
END;
$empty$ LANGUAGE 'plpgsql';

-- ---------------------------------------------------------------------------
-- Types
-- ---------------------------------------------------------------------------
DO
$$
    BEGIN
        CREATE TYPE severity AS ENUM ('NotSet', 'None', 'Low', 'Medium', 'Moderate', 'Important', 'High', 'Critical');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END
$$;

-- ----------------------------------------------------------------------------
-- Tables
-- ----------------------------------------------------------------------------

-- account
CREATE TABLE IF NOT EXISTS account
(
    id   BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE CHECK (NOT empty(name))
) TABLESPACE pg_default;

GRANT SELECT, INSERT, UPDATE ON account TO archive_db_writer;


-- cluster
CREATE TABLE IF NOT EXISTS cluster
(
    id                  BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    uuid                UUID NOT NULL UNIQUE,
    status              TEXT NOT NULL CHECK (NOT empty(status)),
    version             TEXT NOT NULL CHECK (NOT empty(version)),
    provider            TEXT,
    account_id          BIGINT  NOT NULL REFERENCES account (id),
    cve_cache_critical  INT  NOT NULL DEFAULT 0,
    cve_cache_important INT  NOT NULL DEFAULT 0,
    cve_cache_moderate  INT  NOT NULL DEFAULT 0,
    cve_cache_low       INT  NOT NULL DEFAULT 0
) TABLESPACE pg_default;

CREATE INDEX ON cluster (account_id);

GRANT SELECT, INSERT, UPDATE ON cluster TO archive_db_writer;


-- image
CREATE TABLE IF NOT EXISTS image
(
    id           BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    digest       TEXT NOT NULL UNIQUE,
    health_index CHAR NOT NULL
) TABLESPACE pg_default;

-- cve
CREATE TABLE IF NOT EXISTS cve
(
    id            BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name          TEXT                     NOT NULL UNIQUE CHECK (NOT empty(name)),
    description   TEXT                     NOT NULL CHECK (NOT empty(description)),
    severity      severity                 NOT NULL,
    cvss3_score   NUMERIC(5, 3),
    cvss3_metrics TEXT,
    cvss2_score   NUMERIC(5, 3),
    cvss2_metrics TEXT,
    public_date   TIMESTAMP WITH TIME ZONE NULL,
    modified_date TIMESTAMP WITH TIME ZONE NULL,
    redhat_url    TEXT,
    secondary_url TEXT
) TABLESPACE pg_default;

CREATE INDEX ON cve (severity);
CREATE INDEX ON cve (cvss3_score);
CREATE INDEX ON cve (cvss2_score);

-- image_cve
CREATE TABLE IF NOT EXISTS image_cve
(
    image_id BIGINT NOT NULL REFERENCES image (id),
    cve_id   BIGINT NOT NULL REFERENCES cve (id),
    UNIQUE (image_id, cve_id)
) TABLESPACE pg_default;

-- cluster_image
CREATE TABLE IF NOT EXISTS cluster_image
(
    cluster_id BIGINT NOT NULL REFERENCES cluster (id),
    image_id   BIGINT NOT NULL REFERENCES image (id),
    UNIQUE (cluster_id, image_id)
) TABLESPACE pg_default;


GRANT SELECT, INSERT, UPDATE ON cluster_image TO archive_db_writer;

-- cluster_cve_cache
CREATE TABLE IF NOT EXISTS cluster_cve_cache
(
    cluster_id  BIGINT NOT NULL REFERENCES cluster (id),
    cve_id      BIGINT NOT NULL REFERENCES cve (id),
    image_count INT NOT NULL DEFAULT 0,
    UNIQUE (cluster_id, cve_id)
) TABLESPACE pg_default;

-- account_cve_cache
CREATE TABLE IF NOT EXISTS account_cve_cache
(
    account_id    BIGINT NOT NULL REFERENCES account (id),
    cve_id        BIGINT NOT NULL REFERENCES cve (id),
    cluster_count INT NOT NULL DEFAULT 0,
    image_count   INT NOT NULL DEFAULT 0,
    UNIQUE (account_id, cve_id)
) TABLESPACE pg_default;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO archive_db_writer;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO archive_db_writer;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO pyxis_gatherer;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO pyxis_gatherer;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO vmaas_gatherer;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO vmaas_gatherer;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO cve_aggregator;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO cve_aggregator;