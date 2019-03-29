DECLARE @itemNameTranslationTT core.itemNameTranslationTT
DECLARE @meta core.metaDataTT
DECLARE @enLanguageId [TINYINT] = (SELECT languageId FROM [core].[language] WHERE iso2Code = 'en');
DECLARE @frLanguageId [TINYINT] = (SELECT languageId FROM [core].[language] WHERE iso2Code = 'fr');

MERGE INTO [core].[itemType] AS target
USING
    (VALUES
        ('smsTemplate', 'smsTemplate', 'template for SMS'),
        ('emailSubjectSender', 'emailSubjectSender', 'template for email subject'),
        ('emailSubjectTemplate', 'emailSubjectTemplate', 'template for email subject'),
        ('emailTextTemplate', 'emailTextTemplate', 'template for email text'),
        ('emailHtmlTemplate', 'emailHtmlTemplate', 'template for email html'),
        ('pushNotificationTemplate.firebase', 'pushNotificationTemplate.firebase', 'template for push notifications')
    ) AS source (name, alias, [description])
ON target.name = source.name
WHEN NOT MATCHED BY TARGET THEN
    INSERT (name, alias, [description])
    VALUES (name, alias, [description]);

-- TRANSLATIONS SEND TEMPLATES
--sms-----------------------------------------------------------------------------------------------------------------------------
DELETE FROM @itemNameTranslationTT
INSERT INTO @itemNameTranslationTT(itemName, itemNameTranslation)
VALUES
    ('customer.self.registration.otp', 'Hello ${firstName}, kindly fill-up the code ${hash} in the application form to finalize your registration.'),
    ('customer.customer.selfAdd', 'Hello, your OTP for confirm registration is ${hash}'),
    ('customer.self.verifyPhone.otp', 'Welcome! Your code is ${hash}. Please share it with your Client Advisor for confirmation. Software Group Thank you.'),
    ('user.forgottenPassword.otp', 'Hello ${firstName}, kindly fill-up the code ${hash} to change your password.'),
    ('customer.activity.balanceCheck', 'Hello, balance bellow' + CHAR(13) + CHAR(10) + '${text}'),
    ('transaction.pending.push.approve.notify.source', 'You have successfully paid ${amount} TZS to ${destinationAccount.name} with Transaction ID ${transferId} for pending operation.'),
    ('transaction.pending.push.approve.notify.destination', 'You have successfully received ${amount} TZS from Customer ${sourceAccount.name} with Transaction ID ${transferId} for pending operation.'),
    ('transaction.pending.push.reject.notify.source', 'A Pending Transaction with ${transferId} for ${amount} TZS has been rejected from ${destinationAccount.name}.'),
    ('transaction.pending.push.reject.notify.destination', 'You have successfully received ${amount} TZS from Customer ${sourceAccount.name} with Transaction ID ${transferId} for pending operation.')


EXEC core.[itemNameTranslation.upload] @itemNameTranslationTT = @itemNameTranslationTT,
    @languageId = @enLanguageId, @organizationId = NULL, @itemType = 'smsTemplate', @meta = @meta

DELETE FROM @itemNameTranslationTT
INSERT INTO @itemNameTranslationTT(itemName, itemNameTranslation)
VALUES
    ('customer.self.registration.otp', 'Bonjour ${firstName}, merci de renseigner le code ${hash} dans l’application pour finaliser votre inscription.'),
    ('customer.self.verifyPhone.otp', 'Bienvenue! Votre code est ${hash}. Merci de le communiquer à votre conseiller clientèle pour confirmation. Software Group vous remercie.'),
    ('user.forgottenPassword.otp', 'Bonjour ${firstName}, merci de renseigner le code ${hash} pour changer votre mot de passe.'),
    ('customer.activity.balanceCheck', 'Bonjour, ci-dessous équilibrée' + CHAR(13) + CHAR(10) + '${text}')

EXEC core.[itemNameTranslation.upload] @itemNameTranslationTT = @itemNameTranslationTT,
    @languageId = @frLanguageId, @organizationId = NULL, @itemType = 'smsTemplate', @meta = @meta


--pushNotification-----------------------------------------------------------------------------------------------------------------------------
DELETE FROM @itemNameTranslationTT
INSERT INTO @itemNameTranslationTT(itemName, itemNameTranslation)
VALUES
    ('session.expired', '{"data": {"notificationData": {"type": "session.expired","params": {}}}}'),
    ('oob.uuid', '{"data": {"notificationData": {"type": "oob.uuid","params": {"uuid": "${uuid}"}}}}'),
    ('device.encryption.key', '{"data": {"notificationData": {"type": "device.totp.encryption.key","params": {"encryptionKey": "${encryptionKey}"}}}}'),
    ('transaction.pending.pull.create.notify.source', '{"data": {"notificationData": {"type": "pending.transaction","params": {"message": {"title": "Pending Transaction received","message": "A Pending Transaction with ID ${transferId} has been sent to you. For more info click here."},"messageSensitive": {"title": "Pending Transaction received","message": "You have successfully received pending transaction for ${amount} TZS from Agent/Merchant ${destinationAccount.name} with Transaction ID ${transferId}. For more information click here."}, "transferId": "${transferId}","transferType": "${transferType}"}}}}'),
    ('transaction.pending.push.approve.notify.source', '{"data":{"notificationData": {"type": "pending.transaction","params": {"message": {"title": "Pending Transaction Confirmed","message": "A Pending Transaction with ID ${transferId} has been paid. For more info click here."},"messageSensitive": {"title": "Pending Transaction Confirmed","message": "You have successfully paid ${amount} TZS to ${destinationAccount.name} with Transaction ID ${transferId} for pending operation."},"transferId": "${transferId}","transferType": "${transferType}"}}}}'),
    ('transaction.pending.push.approve.notify.destination', '{ "data":{"notificationData": {"type": "pending.transaction","params": {"message": {"title": "Pending Transaction Confirmed","message": "A Pending Transaction with ID ${transferId} has been paid. For more info click here."},"messageSensitive": {"title": "Pending Transaction Confirmed","message": "You have successfully received ${amount} TZS from Customer ${sourceAccount.name} with Transaction ID ${transferId} for pending operation."},"transferId": "${transferId}","transferType": "${transferType}"}}}}'),
    ('transaction.pending.push.reject.notify.source', '{"data":{"notificationData": {"type": "pending.transaction","params": {"message": {"title": "Pending Transaction Rejected","message": "A Pending Transaction with ID ${transferId} has been rejected. For more info click here."},"messageSensitive": {"title": "Pending Transaction Rejected","message": "A Pending Transaction with ${transferId} for ${amount} TZS has been rejected to ${destinationAccount.name}."},"transferId": "${transferId}","transferType": "${transferType}"}}}}'),
    ('transaction.pending.push.reject.notify.destination', '{"data":{"notificationData": {"type": "pending.transaction","params": {"message": {"title": "Pending Transaction Rejected","message": "A Pending Transaction with ID ${transferId} has been rejected. For more info click here."},"messageSensitive": {"title": "Pending Transaction Rejected","message": "A Pending Transaction with ${transferId} for ${amount} TZS has been rejected from ${sourceAccount.name}."},"transferId": "${transferId}", "transferType": "${transferType}"}}}}')

EXEC core.[itemNameTranslation.upload] @itemNameTranslationTT = @itemNameTranslationTT,
    @languageId = @enLanguageId, @organizationId = NULL, @itemType = 'pushNotificationTemplate.firebase', @meta = @meta

--email-----------------------------------------------------------------------------------------------------------------------------
------@itemTypeIdEmailSender
DELETE FROM @itemNameTranslationTT
INSERT INTO @itemNameTranslationTT(itemName, itemNameTranslation)
VALUES
    ('user.makerChecker', 'Software Group support'),
    ('user.forgottenPassword.otp', 'Software Group support'),
    ('user.updatePassword.new', 'Software Group support'),
    ('user.updatePassword.reset', 'Software Group support'),
    ('user.sendOtp', 'Software Group support')

EXEC core.[itemNameTranslation.upload] @itemNameTranslationTT = @itemNameTranslationTT,
    @languageId = @enLanguageId, @organizationId = NULL, @itemType = 'emailSubjectSender', @meta = @meta

DELETE FROM @itemNameTranslationTT
INSERT INTO @itemNameTranslationTT(itemName, itemNameTranslation)
VALUES
    ('user.makerChecker', 'Software Group support'),
    ('user.forgottenPassword.otp', 'Software Group support')
EXEC core.[itemNameTranslation.upload] @itemNameTranslationTT = @itemNameTranslationTT,
    @languageId = @frLanguageId, @organizationId = NULL, @itemType = 'emailSubjectSender', @meta = @meta

------@itemTypeIdEmailSubject
DELETE FROM @itemNameTranslationTT
INSERT INTO @itemNameTranslationTT(itemName, itemNameTranslation)
VALUES
    ('user.makerChecker', '${firstName} ${lastName} account awaiting for your validation'),
    ('user.forgottenPassword.otp', 'Code to reset your Tune password'),
    ('user.updatePassword.new', 'Credentials for ${firstName} ${lastName}'),
    ('user.updatePassword.reset', '${firstName} ${lastName} your password was reset'),
    ('user.sendOtp', 'Login code for ${firstName} ${lastName}')

EXEC core.[itemNameTranslation.upload] @itemNameTranslationTT = @itemNameTranslationTT,
    @languageId = @enLanguageId, @organizationId = NULL, @itemType = 'emailSubjectTemplate', @meta = @meta

DELETE FROM @itemNameTranslationTT
INSERT INTO @itemNameTranslationTT(itemName, itemNameTranslation)
VALUES
    ('user.makerChecker', '${firstName} ${lastName} profil d''utilisateur en attente de validation'),
    ('user.forgottenPassword.otp', N'Code pour changement de mot de passe Tune')

EXEC core.[itemNameTranslation.upload] @itemNameTranslationTT = @itemNameTranslationTT,
    @languageId = @frLanguageId, @organizationId = NULL, @itemType = 'emailSubjectTemplate', @meta = @meta

------@itemTypeIdEmailText
DELETE FROM @itemNameTranslationTT
INSERT INTO @itemNameTranslationTT(itemName, itemNameTranslation)
VALUES
    ('user.makerChecker', 'Dear ${firstName} ${lastName}, \n\n A new request for validation has been created for ${username} by ${makerFirstName} ${makerLastName}. \n Please validate the changes. \n\n Your support team'),
    ('user.forgottenPassword.otp', 'Dear ${firstName}\n Find here the code you requested to reset your Tune Baobab password : ${hash}.\n Entering this code you will be asked to define a new password.\n This code is valid until midnight, 12:00pm today.\n Have a good day'),
    ('user.updatePassword.new', 'Dear ${firstName} ${lastName}, \n\n A new account has been created for you. \n Your credentials are: \n username: ${username} \n password: ${hash} \n. \n\n Your support team'),
    ('user.updatePassword.reset', 'Dear ${firstName} ${lastName}\n Your password has been reset. \n Your new password is: ${hash}'),
    ('user.sendOtp', 'Dear ${firstName} ${lastName}\nYour code for login is ${hash} \n. \n\n Your support team')

EXEC core.[itemNameTranslation.upload] @itemNameTranslationTT = @itemNameTranslationTT,
    @languageId = @enLanguageId, @organizationId = NULL, @itemType = 'emailTextTemplate', @meta = @meta

DELETE FROM @itemNameTranslationTT
INSERT INTO @itemNameTranslationTT(itemName, itemNameTranslation)
VALUES
    ('user.makerChecker', N'Cher(e) ${firstName} ${lastName}, \n\n Une nouvelle demande de validation a été créée pour ${username} par ${makerFirstName} ${makerLastName}. \n Veuillez valider les modifications. \n\n Votre équipe de support'),
    ('user.forgottenPassword.otp', N'${firstName} ${lastName}\n Voici le code qui vous permet de réinitialiser votre mot de passe sur Tune Baobab : ${hash}.\n Ce code est valide jusqu’à minuit, 00h, aujourd’hui.\n Bonne journée')

EXEC core.[itemNameTranslation.upload] @itemNameTranslationTT = @itemNameTranslationTT,
    @languageId = @frLanguageId, @organizationId = NULL, @itemType = 'emailTextTemplate', @meta = @meta

------@itemTypeIdEmailHtml
DELETE FROM @itemNameTranslationTT
INSERT INTO @itemNameTranslationTT(itemName, itemNameTranslation)
VALUES
    ('user.makerChecker', 'Dear ${firstName} ${lastName},<br/><br/>A new request for validation has been created for ${username} by ${makerFirstName} ${makerLastName}.<br/>Please validate the changes.<br/><br/>Your support team'),
    ('user.forgottenPassword.otp', 'Dear ${firstName}<br/> Find here the code you requested to reset your Tune Baobab password : ${hash}.<br/> Entering this code you will be asked to define a new password.<br/> This code is valid until midnight, 12:00pm today.<br/> Have a good day'),
    ('user.updatePassword.new', 'Dear ${firstName} ${lastName},<br/><br/>A new account has been created for you.<br/>Your credentials are: <br/> username: ${username}<br/> password: ${hash}<br/><br/>Your support team'),
    ('user.updatePassword.reset', 'Dear ${firstName} ${lastName}<br/> Your password has been reset.<br/> Your new password is: ${hash}'),
    ('user.sendOtp', 'Dear ${firstName} ${lastName},<br/><br/>Your code for login is ${hash}<br/><br/>Your support team')

EXEC core.[itemNameTranslation.upload] @itemNameTranslationTT = @itemNameTranslationTT,
    @languageId = @enLanguageId, @organizationId = NULL, @itemType = 'emailHtmlTemplate', @meta = @meta

DELETE FROM @itemNameTranslationTT
INSERT INTO @itemNameTranslationTT(itemName, itemNameTranslation)
VALUES
    ('user.makerChecker', N'Cher(e) ${firstName} ${lastName}, <br/><br/>Une nouvelle demande de validation a été créée pour ${username} par ${makerFirstName} ${makerLastName}. <br/>Veuillez valider les modifications.<br/><br/>Votre équipe de support'),
    ('user.forgottenPassword.otp', N'${firstName} ${lastName}<br/> Voici le code qui vous permet de réinitialiser votre mot de passe sur Tune Baobab : ${hash}.<br/> Ce code est valide jusqu’à minuit, 00h, aujourd’hui.<br/> Bonne journée')

EXEC core.[itemNameTranslation.upload] @itemNameTranslationTT = @itemNameTranslationTT,
    @languageId = @frLanguageId, @organizationId = NULL, @itemType = 'emailHtmlTemplate', @meta = @meta
