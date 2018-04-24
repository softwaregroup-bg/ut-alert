DECLARE @itemSmsTemplateId INT = (SELECT [itemTypeId] FROM [core].[itemType] WHERE [name] = N'smsTemplate'),
    @itemEmailSubjectTemplateId INT = (SELECT [itemTypeId] FROM [core].[itemType] WHERE [name] = N'emailSubjectTemplate'),
    @itemEmailTextTemplateId INT = (SELECT [itemTypeId] FROM [core].[itemType] WHERE [name] = N'emailTextTemplate'),
    @itemEmailHtmlTemplateId INT = (SELECT [itemTypeId] FROM [core].[itemType] WHERE [name] = N'emailHtmlTemplate'),
    @itemPushNotificationTemplateFirebaseId INT = (SELECT [itemTypeId] FROM [core].[itemType] WHERE [name] = N'pushNotificationTemplate.firebase'),
    @smsChannelId INT = (SELECT [id] FROM [alert].[deliveryChannel] WHERE [name] = 'sms'),
    @emailChannelId INT = (SELECT [id] FROM [alert].[deliveryChannel] WHERE [name] = 'email'),
    @pushNotificationChannelId INT = (SELECT [id] FROM [alert].[deliveryChannel] WHERE [name] = 'push');

IF @itemSmsTemplateId IS NULL
BEGIN
    INSERT INTO [core].[itemType] ([alias], [name], [description])
        VALUES ('smsTemplate', N'smsTemplate', 'smsTemplate');
    SET @itemSmsTemplateId = SCOPE_IDENTITY();
END
IF @itemEmailSubjectTemplateId IS NULL
BEGIN
    INSERT INTO [core].[itemType] ([alias], [name], [description])
        VALUES ('emailSubjectTemplate', N'emailSubjectTemplate', 'emailSubjectTemplate');
    SET @itemEmailSubjectTemplateId = SCOPE_IDENTITY();
END
IF @itemEmailTextTemplateId IS NULL
BEGIN
    INSERT INTO [core].[itemType] ([alias], [name], [description])
        VALUES ('emailTextTemplate', N'emailTextTemplate', 'emailTextTemplate');
    SET @itemEmailTextTemplateId = SCOPE_IDENTITY();
END
IF @itemEmailHtmlTemplateId IS NULL
BEGIN
    INSERT INTO [core].[itemType] ([alias], [name], [description])
        VALUES ('emailHtmlTemplate', N'emailHtmlTemplate', 'emailHtmlTemplate');
    SET @itemEmailHtmlTemplateId = SCOPE_IDENTITY();
END
IF @itemPushNotificationTemplateFirebaseId IS NULL
BEGIN
    INSERT INTO [core].[itemType] ([alias], [name], [description])
        VALUES ('pushNotificationTemplate.firebase', N'pushNotificationTemplate.firebase', 'template for push notifications handled by firebase port')
    SET @itemPushNotificationTemplateFirebaseId = SCOPE_IDENTITY();
END
IF NOT EXISTS (SELECT 1 FROM [alert].[deliveryChannelItemType] WHERE [channelId] = @smsChannelId AND [itemTypeId] = @itemSmsTemplateId)
    INSERT INTO [alert].[deliveryChannelItemType] ([channelId], [itemTypeId]) VALUES (@smsChannelId, @itemSmsTemplateId);
IF NOT EXISTS (SELECT 1 FROM [alert].[deliveryChannelItemType] WHERE [channelId] = @emailChannelId AND [itemTypeId] = @itemEmailSubjectTemplateId)
    INSERT INTO [alert].[deliveryChannelItemType] ([channelId], [itemTypeId]) VALUES (@emailChannelId, @itemEmailSubjectTemplateId);
IF NOT EXISTS (SELECT 1 FROM [alert].[deliveryChannelItemType] WHERE [channelId] = @emailChannelId AND [itemTypeId] = @itemEmailTextTemplateId)
    INSERT INTO [alert].[deliveryChannelItemType] ([channelId], [itemTypeId]) VALUES (@emailChannelId, @itemEmailTextTemplateId);
IF NOT EXISTS (SELECT 1 FROM [alert].[deliveryChannelItemType] WHERE [channelId] = @emailChannelId AND [itemTypeId] = @itemEmailHtmlTemplateId)
    INSERT INTO [alert].[deliveryChannelItemType] ([channelId], [itemTypeId]) VALUES (@emailChannelId, @itemEmailHtmlTemplateId);
IF NOT EXISTS (SELECT 1 FROM [alert].[deliveryChannelItemType] WHERE [channelId] = @pushNotificationChannelId AND [itemTypeId] = @itemPushNotificationTemplateFirebaseId)
    INSERT INTO [alert].[deliveryChannelItemType] ([channelId], [itemTypeId]) VALUES (@pushNotificationChannelId, @itemPushNotificationTemplateFirebaseId);
