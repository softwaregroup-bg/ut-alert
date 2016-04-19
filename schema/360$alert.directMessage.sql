CREATE TABLE [alert].[directMessage] (
    [id] int IDENTITY(1,1) not null,
    [messageId] int not null,
    [port] nvarchar(255) not null,
    [address] nvarchar(255),
    [content] nvarchar(max),
	CONSTRAINT [pk_alert_directMessage_id] PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT [fk_alert_directMessage_messageId_alert_message_id] FOREIGN KEY ([messageId]) REFERENCES [alert].[message] ([id])
)
