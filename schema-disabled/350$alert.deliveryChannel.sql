CREATE TABLE [alert].[deliveryChannel] (
    [id] int IDENTITY(1,1) not null,
	[name] int not null,
	CONSTRAINT [pk_alert_deliveryChannel_id] PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT [uq_alert_deliveryChannel_name] UNIQUE ([name])
)