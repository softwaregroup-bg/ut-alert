CREATE TABLE [alert].[message] (
    [id] int IDENTITY(1,1) not null,
    [portKey] nvarchar(255) not null,
    [sourceAddress] nvarchar(255),
    [destinationAddress] nvarchar(255),
    [content] nvarchar(max),
    [createdBy] bigint not null,
    [createdOn] datetimeoffset not null,
    [statusId] int not null,
    [priority] smallint not null,
    [retryAfter] datetimeoffset,
	CONSTRAINT [pk_alert_message_id] PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT [fk_alert_message_statusId_alert_status_id] FOREIGN KEY ([statusId]) REFERENCES [alert].[status] ([id]),
	CONSTRAINT [fk_alert_message_createdBy_core_actor_id] FOREIGN KEY ([createdBy]) REFERENCES [core].[actor] ([actorId])
)
