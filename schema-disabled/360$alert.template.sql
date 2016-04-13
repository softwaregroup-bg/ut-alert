CREATE TABLE [alert].[template] (
    [id] int IDENTITY(1,1) not null,
	[name] nvarchar(255) not null,
	[channelId] int not null,
	[createdBy] bigint not null,
	[createdOn] datetimeoffset not null,
	[updatedBy] bigint,
	[updatedOn] datetimeoffset,
	[deletedOn] datetimeoffset,
	CONSTRAINT [pk_alert_template_id] PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT [fk_alert_template_channelId_alert_deliveryChannel_id] FOREIGN KEY ([channelId]) REFERENCES [alert].[deliveryChannel] ([id]),
	CONSTRAINT [fk_alert_template_createdBy_core_actor_id] FOREIGN KEY ([createdBy]) REFERENCES [core].[actor] ([actorId]),
	CONSTRAINT [fk_alert_template_updatedBy_core_actor_id] FOREIGN KEY ([updatedBy]) REFERENCES [core].[actor] ([actorId])
)
