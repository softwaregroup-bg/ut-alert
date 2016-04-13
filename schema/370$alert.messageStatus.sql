CREATE TABLE [alert].[messageStatus] (
    [id] int IDENTITY(1,1) not null,
    [messageId] int not null,
    [statusId] int not null,
    [updatedOn] datetimeoffset not null,
	CONSTRAINT [pk_alert_messageStatus_id] PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT [fk_alert_messageStatus_messageId_alert_message_id] FOREIGN KEY ([messageId]) REFERENCES [alert].[message] ([id]),
	CONSTRAINT [fk_alert_messageStatus_statusId_alert_status_id] FOREIGN KEY ([statusId]) REFERENCES [alert].[status] ([id])
)
