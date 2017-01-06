IF NOT EXISTS (SELECT 1 FROM [alert].[status] WHERE [name] = N'REQUESTED')
    INSERT INTO [alert].[status] ([name]) VALUES (N'REQUESTED');
IF NOT EXISTS (SELECT 1 FROM [alert].[status] WHERE [name] = N'QUEUED')
    INSERT INTO [alert].[status] ([name]) VALUES (N'QUEUED');
IF NOT EXISTS (SELECT 1 FROM [alert].[status] WHERE [name] = N'PROCESSING')
    INSERT INTO [alert].[status] ([name]) VALUES (N'PROCESSING');
IF NOT EXISTS (SELECT 1 FROM [alert].[status] WHERE [name] = N'DELIVERED')
    INSERT INTO [alert].[status] ([name]) VALUES (N'DELIVERED');
IF NOT EXISTS (SELECT 1 FROM [alert].[status] WHERE [name] = N'FAILED')
    INSERT INTO [alert].[status] ([name]) VALUES (N'FAILED');
IF NOT EXISTS (SELECT 1 FROM [alert].[status] WHERE [name] = N'CANCELED')
    INSERT INTO [alert].[status] ([name]) VALUES (N'CANCELED');
IF NOT EXISTS (SELECT 1 FROM [alert].[status] WHERE [name] = N'RESUBMITTED')
    INSERT INTO [alert].[status] ([name]) VALUES (N'RESUBMITTED');
IF NOT EXISTS (SELECT 1 FROM [alert].[status] WHERE [name] = N'UNAPPROVED')
    INSERT INTO [alert].[status] ([name]) VALUES (N'UNAPPROVED');
