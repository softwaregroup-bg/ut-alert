CREATE TABLE [alert].[messageType] (
    [id] int IDENTITY(1,1) not null,
	[name] nvarchar(64) not null,
	CONSTRAINT [pk_alert_messageType_id] PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT [uq_alert_messageType_name] UNIQUE ([name])
)
