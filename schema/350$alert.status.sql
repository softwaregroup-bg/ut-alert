CREATE TABLE [alert].[status] (
    [id] int IDENTITY(1,1) not null,
	[name] nvarchar(64) not null,
	CONSTRAINT [pk_alert_status_id] PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT [uq_alert_status_name] UNIQUE ([name])
)
