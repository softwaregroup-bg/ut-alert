IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_messageOut_statusId')
    CREATE INDEX [IX_messageOut_statusId] ON [alert].[messageOut] ([port], [statusId]) INCLUDE ([priority])
ELSE
BEGIN
    IF (SELECT c.name
        FROM sys.indexes i
        JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        JOIN sys.columns c ON C.object_id = I.object_id AND C.column_id = ic.column_id AND IC.is_included_column = 0
        WHERE i.name = 'IX_messageOut_statusId' AND ic.index_column_id = 1) != 'port'
    OR (SELECT c.name
        FROM sys.indexes i
        JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        JOIN sys.columns c ON C.object_id = I.object_id AND C.column_id = ic.column_id AND IC.is_included_column = 0
        WHERE i.name = 'IX_messageOut_statusId' AND ic.index_column_id = 2) != 'statusId'
    OR NOT EXISTS (
        SELECT c.name
        FROM sys.indexes i
        JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        JOIN sys.columns c ON C.object_id = I.object_id AND C.column_id = ic.column_id AND IC.is_included_column = 1
        WHERE i.name = 'IX_messageOut_statusId' AND c.name = 'priority')
    BEGIN
        DROP INDEX [IX_messageOut_statusId] ON [alert].[messageOut]

        CREATE INDEX [IX_messageOut_statusId] ON [alert].[messageOut] ([port], [statusId]) INCLUDE ([priority])
    END
END
