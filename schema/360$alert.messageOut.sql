CREATE TABLE [alert].[messageOut] -- table that stores all the messages that are generated for send
(
    [id] BIGINT IDENTITY(1, 1) NOT NULL, -- the PK of the table
    [port] VARCHAR(255) NOT NULL, -- implementation dependant
    [channel] VARCHAR(100) NOT NULL, -- channel is by what the message should be sent, for example "email", "sms"
    [recipient] NVARCHAR(255) NOT NULL, -- the number or the email address that is receiving the message
    [content] varbinary(MAX) NOT NULL, -- the message content
    [createdBy] BIGINT NOT NULL, -- the user that created the message
    [createdOn] DATETIMEOFFSET(7) NOT NULL, -- when the message is created
    [statusId] TINYINT NOT NULL, -- the status of the message
    [priority] SMALLINT NOT NULL, -- the priority of the message
    [messageInId] BIGINT NULL, -- in/out cross reference
    CONSTRAINT [pk_messageOut_id] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [fk_alert_messageOut_statusId_alert_status_id] FOREIGN KEY ([statusId]) REFERENCES [alert].[status] ([id]),
    CONSTRAINT [fk_alert_messageOut_createdBy_core_actor_id] FOREIGN KEY ([createdBy]) REFERENCES [core].[actor] ([actorId])
)
