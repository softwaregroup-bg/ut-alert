CREATE TABLE [alert].[directMessage] (
    [id] int IDENTITY(1,1) not null,
    [typeId] int not null,
    [createdBy] bigint not null,
    [createdOn] datetimeoffset not null,
    [executeOn] datetimeoffset,
    [statusId] int not null,
    [priority] smallint not null,
	CONSTRAINT [pk_alert_message_id] PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT [fk_alert_message_typeId_alert_messageType_id] FOREIGN KEY ([typeId]) REFERENCES [alert].[messageType] ([id]),
	CONSTRAINT [fk_alert_message_statusId_alert_status_id] FOREIGN KEY ([statusId]) REFERENCES [alert].[status] ([id]),
	CONSTRAINT [fk_alert_message_createdBy_core_actor_id] FOREIGN KEY ([createdBy]) REFERENCES [core].[actor] ([actorId])
)
