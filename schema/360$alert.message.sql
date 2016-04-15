CREATE TABLE [alert].[message] (
    [id] int IDENTITY(1,1) not null,
    [port] nvarchar(255) not null,
    [address] nvarchar(255),
    [content] nvarchar(max),
    [createdBy] bigint not null,
    [createdOn] datetimeoffset not null,
    [executeOn] datetimeoffset,
    [statusId] int not null,
    [priority] smallint not null,
    [retryOn] datetimeoffset,
	CONSTRAINT [pk_alert_message_id] PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT [fk_alert_message_statusId_alert_status_id] FOREIGN KEY ([statusId]) REFERENCES [alert].[status] ([id]),
	CONSTRAINT [fk_alert_message_createdBy_core_actor_id] FOREIGN KEY ([createdBy]) REFERENCES [core].[actor] ([actorId])
)
