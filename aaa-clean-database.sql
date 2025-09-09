-- Disable FK checks first
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all";

-- Drop all tables
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql = STRING_AGG('DROP TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ';', CHAR(13))
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id;

EXEC sp_executesql @sql;