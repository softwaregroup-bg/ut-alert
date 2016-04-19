IF NOT EXISTS (SELECT 1 FROM [alert].[messageType] WHERE [name] = N'DirectMessage')
    INSERT INTO [alert].[messageType] ([name]) VALUES (N'DirectMessage');
