-- Revert AppCore:setup/table/forms from pg

BEGIN;

DROP TABLE setup.forms;

COMMIT;
