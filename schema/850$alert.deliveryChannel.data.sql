IF NOT EXISTS (SELECT 1 FROM [alert].[deliveryChannel] WHERE [name] = N'sms')
    INSERT INTO [alert].[deliveryChannel] ([name]) VALUES (N'sms');
IF NOT EXISTS (SELECT 1 FROM [alert].[deliveryChannel] WHERE [name] = N'email')
    INSERT INTO [alert].[deliveryChannel] ([name]) VALUES (N'email');
