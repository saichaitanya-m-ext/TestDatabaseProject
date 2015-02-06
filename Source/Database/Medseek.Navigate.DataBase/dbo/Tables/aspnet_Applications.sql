CREATE TABLE [dbo].[aspnet_Applications] (
    [ApplicationName]        NVARCHAR (256)   NOT NULL,
    [LoweredApplicationName] NVARCHAR (256)   NOT NULL,
    [ApplicationId]          UNIQUEIDENTIFIER CONSTRAINT [DF__aspnet_Ap__Appli__014935CB] DEFAULT (newid()) NOT NULL,
    [Description]            NVARCHAR (256)   NULL,
    CONSTRAINT [PK__aspnet_Applicati__7E6CC920] PRIMARY KEY NONCLUSTERED ([ApplicationId] ASC) WITH (FILLFACTOR = 25) ON [FG_Library_NCX],
    CONSTRAINT [UQ__aspnet_Applicati__00551192] UNIQUE NONCLUSTERED ([ApplicationName] ASC) WITH (FILLFACTOR = 25) ON [FG_Library_NCX],
    CONSTRAINT [UQ__aspnet_Applicati__7F60ED59] UNIQUE NONCLUSTERED ([LoweredApplicationName] ASC) WITH (FILLFACTOR = 25) ON [FG_Library_NCX]
);


GO
CREATE CLUSTERED INDEX [aspnet_Applications_Index]
    ON [dbo].[aspnet_Applications]([LoweredApplicationName] ASC) WITH (FILLFACTOR = 25);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MS .NET 2.9 Security Table - List of Application', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Applications';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Application name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Applications', @level2type = N'COLUMN', @level2name = N'ApplicationName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Application Name lower case', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Applications', @level2type = N'COLUMN', @level2name = N'LoweredApplicationName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Application ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Applications', @level2type = N'COLUMN', @level2name = N'ApplicationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for aspnet_Applications table values', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Applications', @level2type = N'COLUMN', @level2name = N'Description';

