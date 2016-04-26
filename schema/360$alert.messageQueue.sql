CREATE TABLE [alert].[messageQueue] ( -- table that stores all the messages that are generated for send
    [id] bigint IDENTITY(1,1) not null, -- the PK of the table
    [port] varchar(255) not null, -- implementation dependant
    [channel] varchar(100) not null, -- channel is by what the message should be sent, for example "email", "sms"
    [recipient] nvarchar(255) not null, -- the number or the email address that is receiving the message
    [subject] nvarchar(1024), -- if the message is an email this is the subject 
    [content] nvarchar(max) not null,  -- the message content
    [createdBy] bigint not null, -- the user that created the message
    [createdOn] datetimeoffset not null, -- when the message is created    
    [statusId] tinyint not null, -- the status of the message
    [priority] smallint not null, -- the priority of the message
	CONSTRAINT [pk_messageQueue_id] PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT [fk_alert_message_statusId_alert_status_id] FOREIGN KEY ([statusId]) REFERENCES [alert].[status] ([id]),
	CONSTRAINT [fk_alert_message_createdBy_core_actor_id] FOREIGN KEY ([createdBy]) REFERENCES [core].[actor] ([actorId])
)
