/* ===========================================
   Drop all tables in the current database
   Works in SQL Server from DBeaver
   =========================================== */

DECLARE @sql NVARCHAR(MAX) = N'';

-- Build DROP TABLE statements for all user tables
SELECT @sql += 'DROP TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ';' + CHAR(13)
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
ORDER BY t.object_id DESC;   -- drop children before parents

-- Execute the dynamic SQL
EXEC sp_executesql @sql;