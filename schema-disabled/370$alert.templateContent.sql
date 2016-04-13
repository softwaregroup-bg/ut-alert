CREATE TABLE [alert].[templateContent] (
    [id] int IDENTITY(1,1) not null,
	[templateId] int not null,
    [localeId] varchar(20) not null,
	[content] nvarchar(max) not null,
	CONSTRAINT [pk_alert_templateContent_id] PRIMARY KEY CLUSTERED ([id]),
	CONSTRAINT [fk_alert_templateContent_templateId_alert_messageTemplate_id] FOREIGN KEY ([localeId]) REFERENCES [core].[locale] ([localeId])
	CONSTRAINT [fk_alert_templateContent_localeId_core_locale_id] FOREIGN KEY ([localeId]) REFERENCES [core].[locale] ([localeId])
)
