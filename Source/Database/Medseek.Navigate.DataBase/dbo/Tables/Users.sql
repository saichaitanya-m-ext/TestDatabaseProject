CREATE TABLE [dbo].[Users] (
    [UserId]                     [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [UserLoginName]              NVARCHAR (256)      NULL,
    [IsPatient]                  [dbo].[IsIndicator] CONSTRAINT [DF_Users_IsPatient] DEFAULT ((0)) NULL,
    [IsProvider]                 [dbo].[IsIndicator] CONSTRAINT [DF_Users_IsProvider] DEFAULT ((0)) NULL,
    [AccountStatusCode]          VARCHAR (20)        CONSTRAINT [DF_Users_AccountStatusCode] DEFAULT ('A') NOT NULL,
    [AgreedToTermsAndConditions] [dbo].[IsIndicator] CONSTRAINT [DF_Users_AgreedToTermsAndConditions] DEFAULT ((0)) NULL,
    [AvatarInfo]                 [dbo].[SourceName]  NULL,
    [ThemeColorInfo]             [dbo].[SourceName]  NULL,
    [UserBySkin]                 VARCHAR (15)        CONSTRAINT [DF_Users_UserBySkin] DEFAULT ('Office2010Black') NULL,
    [StartDate]                  [dbo].[UserDate]    NULL,
    [EndDate]                    [dbo].[UserDate]    NULL,
    [Comments]                   VARCHAR (1000)      NULL,
    [LastGoodLoginDateTime]      [dbo].[UserDate]    NULL,
    [CreatedByUserId]            [dbo].[KeyID]       NULL,
    [CreatedDate]                [dbo].[UserDate]    CONSTRAINT [DF_Users_CreatedDate] DEFAULT (getdate()) NULL,
    [LastModifiedByUserId]       [dbo].[KeyID]       NULL,
    [LastModifiedDate]           [dbo].[UserDate]    NULL,
    CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([UserId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_Users_LastProvider] FOREIGN KEY ([LastModifiedByUserId]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_Users_LkUpAccountStatus] FOREIGN KEY ([AccountStatusCode]) REFERENCES [dbo].[LkUpAccountStatus] ([AccountStatusCode]),
    CONSTRAINT [FK_Users_Provider] FOREIGN KEY ([CreatedByUserId]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Users_UserLoginName]
    ON [dbo].[Users]([UserLoginName] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
/*                      
--------------------------------------------------------------------------------------------------------------------------      
Trigger Name: [dbo].[tr_Update_Users] 
Description:                     
When   Who    Action                      
---------------------------------------------------------------------------------------------------------------------------      
20-March-2013 Rathnam Created

----------------------------------------------------------------------------------------------------------------------------      
*/
CREATE TRIGGER [dbo].[tr_Update_Users] ON dbo.Users
       AFTER UPDATE
AS
BEGIN
      IF TRIGGER_NESTLEVEL() > 1
         BEGIN
               RETURN
         END
      
		UPDATE
			aspnet_Membership
		SET
			aspnet_Membership.IsLockedOut = 0,
			aspnet_Membership.FailedPasswordAttemptCount=0
		FROM
			aspnet_Membership
	    INNER JOIN aspnet_users
			ON aspnet_users.UserId = aspnet_Membership.UserId
		INNER JOIN INSERTED
			ON INSERTED.UserLoginName = aspnet_users.UserName
		INNER JOIN DELETED
			ON DELETED.UserID = INSERTED.UserID
		WHERE
			DELETED.AccountStatusCode = 'L'
		AND INSERTED.AccountStatusCode = 'A'
		



END
