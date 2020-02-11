DECLARE @itemNameTranslationTT core.itemNameTranslationTT
DECLARE @meta core.metaDataTT


DECLARE @enLanguageId [TINYINT] = (SELECT languageId FROM [core].[language] WHERE iso2Code = 'en');
DECLARE @frLanguageId [TINYINT] = (SELECT languageId FROM [core].[language] WHERE iso2Code = 'fr');

DECLARE @businessUnit BIGINT = (SELECT actorId FROM customer.organization WHERE organizationName = 'Bulgaria')

IF NOT EXISTS (SELECT * FROM [core].[itemType] WHERE [name] = 'smsTemplate')
BEGIN
    INSERT INTO [core].[itemType]([alias], [name], [description])
    VALUES('smsTemplate', 'smsTemplate', 'smsTemplate')
END
/*
--EN language
INSERT INTO @itemNameTranslationTT(itemName, itemNameTranslation) VALUES ('mWallet.sms.sendOTP', 'Your mWallet verification code is: ${hash} valid in the next ${time} minutes. If you did not request a verification code please contact support at ${number}.')

EXEC core.[itemNameTranslation.upload]
    @itemNameTranslationTT = @itemNameTranslationTT,
    @languageId = @enLanguageId,
    @organizationId = NULL,
    @itemType = 'smsTemplate',
    @meta = @meta

--FR language
DELETE @itemNameTranslationTT
INSERT INTO @itemNameTranslationTT(itemName, itemNameTranslation) VALUES ('mWallet.sms.sendOTP', 'fr - Your mWallet verification code is: ${hash} valid in the next ${time} minutes. If you did not request a verification code please contact support at ${number}.')

EXEC core.[itemNameTranslation.upload]
    @itemNameTranslationTT = @itemNameTranslationTT,
    @languageId = @enLanguageId,
    @organizationId = NULL,
    @itemType = 'smsTemplate',
    @meta = @meta
*/
--EN language wiht BU
DELETE @itemNameTranslationTT
INSERT INTO @itemNameTranslationTT(itemName, itemNameTranslation) VALUES ('mWallet.sms.sendOTP', 'Your mWallet verification code is: ${hash} valid in the next ${time} minutes. If you did not request a verification code please contact support at ${number}.')

EXEC core.[itemNameTranslation.upload]
    @itemNameTranslationTT = @itemNameTranslationTT,
    @languageId = @enLanguageId,
    @organizationId = @businessUnit,
    @itemType = 'smsTemplate',
    @meta = @meta

--fr language wiht BU
DELETE @itemNameTranslationTT
INSERT INTO @itemNameTranslationTT(itemName, itemNameTranslation) VALUES ('mWallet.sms.sendOTP', 'Your mWallet verification code is: ${hash} valid in the next ${time} minutes. If you did not request a verification code please contact support at ${number}.')

EXEC core.[itemNameTranslation.upload]
    @itemNameTranslationTT = @itemNameTranslationTT,
    @languageId = @enLanguageId,
    @organizationId = @businessUnit,
    @itemType = 'smsTemplate',
    @meta = @meta
