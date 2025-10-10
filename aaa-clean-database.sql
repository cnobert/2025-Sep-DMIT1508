/* ============================================================
   DROP ALL VIEWS AND TABLES IN CURRENT DATABASE
   Works in: Azure Data Studio, DBeaver, SQL Server Management Studio
   ============================================================ */

DECLARE @sql NVARCHAR(MAX);

/* ---- 1) Drop all user-defined views ---- */
SET @sql = N'';

SELECT @sql += 'DROP VIEW ' + QUOTENAME(s.name) + '.' + QUOTENAME(v.name) + ';' + CHAR(13)
FROM sys.views AS v
JOIN sys.schemas AS s ON v.schema_id = s.schema_id;

IF @sql <> N''
BEGIN
    PRINT 'Dropping all views...';
    EXEC sp_executesql @sql;
END
ELSE
BEGIN
    PRINT 'No views found.';
END

/* ---- 2) Drop all user-defined tables ---- */
SET @sql = N'';

SELECT @sql += 'DROP TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ';' + CHAR(13)
FROM sys.tables AS t
JOIN sys.schemas AS s ON t.schema_id = s.schema_id
ORDER BY t.object_id DESC;   -- drops children before parents

IF @sql <> N''
BEGIN
    PRINT 'Dropping all tables...';
    EXEC sp_executesql @sql;
END
ELSE
BEGIN
    PRINT 'No tables found.';
END