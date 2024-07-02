-- Revert AppCore:core/table/forms from pg

BEGIN;

DROP TABLE core.forms;

COMMIT;
