CREATE TABLE [alert].[messageIn] ( -- table that stores all the messages that are generated for send
    [id] BIGINT IDENTITY(1, 1) NOT NULL, -- the PK of the table
    [port] VARCHAR(255) NOT NULL, -- implementation dependant
    [channel] VARCHAR(100) NOT NULL, -- channel is by what the message should be sent, for example "email", "sms"
    [sender] NVARCHAR(255) NOT NULL, -- the number or the email address of the sender
    [content] NVARCHAR(MAX) NOT NULL, -- the message content
    [createdOn] DATETIMEOFFSET(7) NOT NULL, -- when the message is created
    [statusId] TINYINT NOT NULL, -- the status of the message
    [priority] SMALLINT NOT NULL, -- the priority of the message
    [messageOutId] BIGINT NULL, -- in/out cross reference
    CONSTRAINT [pk_alert_messageIn_id] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [fk_alert_messageIn_statusId_alert_status_id] FOREIGN KEY ([statusId]) REFERENCES [alert].[status] ([id])
)
