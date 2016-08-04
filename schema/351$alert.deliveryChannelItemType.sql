CREATE TABLE [alert].[deliveryChannelItemType] (
	[channelId] int not null,
	[itemTypeId] int not null,
	CONSTRAINT [ph_alert_deliveryChannel_channelId_itemTypeId] PRIMARY KEY CLUSTERED ([channelId], [itemTypeId]),
	CONSTRAINT [fk_alert_deliveryChannelItemType_channelId_alert_deliveryChannel_id] FOREIGN KEY ([channelId]) REFERENCES [alert].[deliveryChannel] ([id]),
	CONSTRAINT [fk_alert_deliveryChannelItemType_itemTypeId_core_itemType_id] FOREIGN KEY ([itemTypeId]) REFERENCES [core].[itemType] ([itemTypeId])
)
