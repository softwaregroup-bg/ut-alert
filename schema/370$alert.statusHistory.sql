CREATE TABLE [alert].[directMessageStatusHistory] (
    [id] bigint IDENTITY(1,1) not null,
    [messageId] int not null,
    [statusId] int not null,
--    [attempts] int not null default 1,
    [updatedBy] bigint not null,
    [updatedOn] datetimeoffset not null,
	CONSTRAINT [pk_alert_directMessageStatusHistory_id] PRIMARY KEY CLUSTERED ([messageId, statusId, attempts]),
	CONSTRAINT [fk_alert_directMessageStatusHistory_messageId_alert_message_id] FOREIGN KEY ([messageId]) REFERENCES [alert].[message] ([id]),
	CONSTRAINT [fk_alert_directMessageStatusHistory_statusId_alert_status_id] FOREIGN KEY ([statusId]) REFERENCES [alert].[status] ([id]),
	CONSTRAINT [fk_alert_directMessageStatusHistory_updatedBy_core_actor_id] FOREIGN KEY ([updatedBy]) REFERENCES [core].[actor] ([actorId])
)

-- Current status: MAX(updateOn), messageId = X
-- All statuses: messageId = X
-- Count: message = X, statusId = Y

-- SELECT statusId FROM ... WHERE messageId = ? AND MAX(updateOn)
-- SELECT statusId, updatedOn FROM ... WHERE messageId = ?
-- SELECT COUNT(id) FROM ... WHERE messageId = ? AND statusId = 5
