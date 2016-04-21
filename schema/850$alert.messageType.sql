IF NOT EXISTS (SELECT 1 FROM [alert].[messageType] WHERE [name] = N'SystemMessage')
    INSERT INTO [alert].[messageType] ([name]) VALUES (N'SystemMessage');
