CREATE TABLE [alert].[deliveryPort] (
    [id] int IDENTITY(1,1) not null,
	[name] int not null,
	[channelId] int not null,
	CONSTRAINT [pk_alert_deliveryChannel_id] PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT [uq_alert_deliveryChannel_name] UNIQUE ([name]),
	CONSTRAINT [fk_alert_deliveryPort_channelId_alert_deliveryChannel_id] FOREIGN KEY ([channelId]) REFERENCES [alert].[deliveryChannel] ([id])
)
