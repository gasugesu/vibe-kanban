-- Remove UNIQUE constraint from git_repo_path to allow duplicate projects with same git path
-- This is useful for monorepo scenarios where multiple projects can share the same repository

-- SQLite doesn't support ALTER TABLE DROP CONSTRAINT, so we need to recreate the table
-- First, create a new table without the UNIQUE constraint
CREATE TABLE projects_new (
    id            BLOB PRIMARY KEY,
    name          TEXT NOT NULL,
    git_repo_path TEXT NOT NULL DEFAULT '',
    child_path    TEXT DEFAULT NULL,
    setup_script  TEXT DEFAULT '',
    dev_script    TEXT DEFAULT '',
    cleanup_script TEXT DEFAULT '',
    created_at    TEXT NOT NULL DEFAULT (datetime('now', 'subsec')),
    updated_at    TEXT NOT NULL DEFAULT (datetime('now', 'subsec'))
);

-- Copy all data from the old table to the new table
INSERT INTO projects_new 
SELECT 
    id,
    name,
    git_repo_path,
    child_path,
    setup_script,
    dev_script,
    COALESCE(cleanup_script, '') as cleanup_script,
    created_at,
    updated_at
FROM projects;

-- Drop the old table
DROP TABLE projects;

-- Rename the new table to the original name
ALTER TABLE projects_new RENAME TO projects;

-- Recreate the trigger for updated_at
CREATE TRIGGER projects_updated_at
    AFTER UPDATE
    ON projects
    FOR EACH ROW
BEGIN
    UPDATE projects
    SET updated_at = datetime('now', 'subsec')
    WHERE id = NEW.id;
END;