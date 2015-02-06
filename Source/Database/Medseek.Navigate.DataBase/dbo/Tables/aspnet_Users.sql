CREATE TABLE [dbo].[aspnet_Users] (
    [ApplicationId]    UNIQUEIDENTIFIER NOT NULL,
    [UserId]           UNIQUEIDENTIFIER CONSTRAINT [DF__aspnet_Us__UserI__0519C6AF] DEFAULT (newid()) NOT NULL,
    [UserName]         NVARCHAR (256)   NOT NULL,
    [LoweredUserName]  NVARCHAR (256)   NOT NULL,
    [MobileAlias]      NVARCHAR (16)    CONSTRAINT [DF__aspnet_Us__Mobil__060DEAE8] DEFAULT (NULL) NULL,
    [IsAnonymous]      BIT              CONSTRAINT [DF__aspnet_Us__IsAno__07020F21] DEFAULT ((0)) NOT NULL,
    [LastActivityDate] DATETIME         NOT NULL,
    CONSTRAINT [PK__aspnet_Users__03317E3D] PRIMARY KEY NONCLUSTERED ([UserId] ASC) WITH (FILLFACTOR = 25) ON [FG_Transactional_NCX],
    CONSTRAINT [FK__aspnet_Us__Appli__0425A276] FOREIGN KEY ([ApplicationId]) REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
);


GO
CREATE UNIQUE CLUSTERED INDEX [aspnet_Users_Index]
    ON [dbo].[aspnet_Users]([ApplicationId] ASC, [LoweredUserName] ASC) WITH (FILLFACTOR = 25);


GO
CREATE NONCLUSTERED INDEX [aspnet_Users_Index2]
    ON [dbo].[aspnet_Users]([ApplicationId] ASC, [LastActivityDate] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
CREATE TRIGGER [dbo].[utr_aspnet_Users_Insert]
ON [dbo].[aspnet_Users]  
AFTER INSERT
AS
BEGIN

DECLARE @i_ReturnNoOfRecordsInserted INT

------------------- Insert into users table when the aspnetuser record is inserted--------	
	INSERT INTO	Users (UserLoginName)
	SELECT INS.UserName
	  FROM INSERTED INS
	
END






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MS .NET 2.9 Security Table - Users', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Users';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Application ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Users', @level2type = N'COLUMN', @level2name = N'ApplicationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'User ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Users', @level2type = N'COLUMN', @level2name = N'UserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'User name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Users', @level2type = N'COLUMN', @level2name = N'UserName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'User name (lowercase)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Users', @level2type = N'COLUMN', @level2name = N'LoweredUserName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Users mobile alias (currently not used)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Users', @level2type = N'COLUMN', @level2name = N'MobileAlias';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Anonymous user, 0=Not an anonymous user', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Users', @level2type = N'COLUMN', @level2name = N'IsAnonymous';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date and time of last activity by this user', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Users', @level2type = N'COLUMN', @level2name = N'LastActivityDate';

