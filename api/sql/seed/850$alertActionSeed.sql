MERGE INTO [user].[actionCategory] AS target
USING
    (VALUES
        ('general', NULL, NULL, NULL)
    ) AS source (name, [table], keyColumn, displayColumn)
ON target.name = source.name
WHEN NOT MATCHED BY TARGET THEN
INSERT (name, [table], keyColumn, displayColumn)
VALUES (name, [table], keyColumn, displayColumn);

DECLARE @generalActionCategoryId INT = (SELECT actionCategoryId FROM [user].[actionCategory] WHERE name = 'general')

MERGE INTO [user].[action] AS target
USING
    (VALUES
        ('alert.queueOut.push', @generalActionCategoryId, 'alert.queueOut.push', '{}')
    ) AS source (actionId, actionCategoryId, [description], valueMap)
ON target.actionId = source.actionId
WHEN MATCHED AND target.[description] <> source.[description] THEN
    UPDATE SET target.[description] = source.[description]
WHEN NOT MATCHED BY TARGET THEN
    INSERT (actionId, actionCategoryId, [description], valueMap)
    VALUES (actionId, actionCategoryId, [description], valueMap);
