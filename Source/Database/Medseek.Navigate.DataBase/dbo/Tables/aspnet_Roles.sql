CREATE TABLE [dbo].[aspnet_Roles] (
    [ApplicationId]   UNIQUEIDENTIFIER NOT NULL,
    [RoleId]          UNIQUEIDENTIFIER CONSTRAINT [DF__aspnet_Ro__RoleI__34C8D9D1] DEFAULT (newid()) NOT NULL,
    [RoleName]        NVARCHAR (256)   NOT NULL,
    [LoweredRoleName] NVARCHAR (256)   NOT NULL,
    [Description]     NVARCHAR (256)   NULL,
    CONSTRAINT [PK__aspnet_Roles__32E0915F] PRIMARY KEY NONCLUSTERED ([RoleId] ASC) WITH (FILLFACTOR = 25) ON [FG_Transactional_NCX],
    CONSTRAINT [FK__aspnet_Ro__Appli__33D4B598] FOREIGN KEY ([ApplicationId]) REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
);


GO
CREATE UNIQUE CLUSTERED INDEX [aspnet_Roles_index1]
    ON [dbo].[aspnet_Roles]([ApplicationId] ASC, [LoweredRoleName] ASC) WITH (FILLFACTOR = 25);


GO
CREATE TRIGGER [dbo].[utr_aspnet_Roles_Insert] ON [dbo].[aspnet_Roles]
AFTER INSERT
AS
BEGIN
	DECLARE @i_ReturnNoOfRecordsInserted INT

	------------------- Insert into SecurityRole table when the aspnetrole record is inserted--------       
	INSERT INTO SecurityRole (
		RoleName
		,RoleDescription
		)
	SELECT INS.RoleName
		,ISNULL(INS.Description, INS.RoleName)
	FROM INSERTED INS
	WHERE INS.RoleName NOT IN (
			SELECT RoleName
			FROM SecurityRole
			)

	SET @i_ReturnNoOfRecordsInserted = @@ROWCOUNT

	IF @i_ReturnNoOfRecordsInserted <= 0
		RAISERROR (
				N'No records got inserted into aspnet_Roles table, record count %d'
				,17
				,1
				,@i_ReturnNoOfRecordsInserted
				)
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MS .NET 2.9 Security Table - User Roles', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Roles';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ApplicationId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Roles', @level2type = N'COLUMN', @level2name = N'ApplicationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'RoleId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Roles', @level2type = N'COLUMN', @level2name = N'RoleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'RoleName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Roles', @level2type = N'COLUMN', @level2name = N'RoleName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'LoweredRoleName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Roles', @level2type = N'COLUMN', @level2name = N'LoweredRoleName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for aspnet_Roles table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Roles', @level2type = N'COLUMN', @level2name = N'Description';

