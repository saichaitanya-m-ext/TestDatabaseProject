CREATE TABLE [dbo].[aspnet_SchemaVersions] (
    [Feature]                 NVARCHAR (128) NOT NULL,
    [CompatibleSchemaVersion] NVARCHAR (128) NOT NULL,
    [IsCurrentVersion]        BIT            NOT NULL,
    CONSTRAINT [PK__aspnet_SchemaVer__08EA5793] PRIMARY KEY CLUSTERED ([Feature] ASC, [CompatibleSchemaVersion] ASC) ON [FG_Library]
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MS .NET 2.9 Security Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_SchemaVersions';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Not used', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_SchemaVersions', @level2type = N'COLUMN', @level2name = N'Feature';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Not used', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_SchemaVersions', @level2type = N'COLUMN', @level2name = N'CompatibleSchemaVersion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Not used', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_SchemaVersions', @level2type = N'COLUMN', @level2name = N'IsCurrentVersion';

