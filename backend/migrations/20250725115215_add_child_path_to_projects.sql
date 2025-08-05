-- Add child_path column to projects table for monorepo support
ALTER TABLE projects ADD COLUMN child_path TEXT DEFAULT NULL;