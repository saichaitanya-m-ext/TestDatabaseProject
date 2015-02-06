CREATE TABLE [dbo].[SystemConfiguration] (
    [CCMURL]                       [dbo].[ShortDescription] NULL,
    [CustomerURL]                  [dbo].[ShortDescription] NULL,
    [LibraryDBPath]                VARCHAR (100)            NULL,
    [LibraryAppPath]               VARCHAR (100)            NULL,
    [CustomerName]                 VARCHAR (200)            NULL,
    [CustomerLogoLowRes]           VARBINARY (MAX)          NULL,
    [CustomerLogoHighRes]          VARBINARY (MAX)          NULL,
    [PrintingFileServiceDirectory] VARCHAR (100)            NULL,
    [PQRIStartYear]                SMALLINT                 NULL,
    [SystemConfigurationId]        INT                      IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_SystemConfiguration_SystemConfigurationId] PRIMARY KEY CLUSTERED ([SystemConfigurationId] ASC) ON [FG_Library]
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A single row table to store application attributes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SystemConfiguration';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'URL for the System', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SystemConfiguration', @level2type = N'COLUMN', @level2name = N'CCMURL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Customer URL this is used to provide a hyperlink to the users web site and as a token in communications', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SystemConfiguration', @level2type = N'COLUMN', @level2name = N'CustomerURL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Not Used', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SystemConfiguration', @level2type = N'COLUMN', @level2name = N'LibraryDBPath';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Not Used', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SystemConfiguration', @level2type = N'COLUMN', @level2name = N'LibraryAppPath';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Customer name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SystemConfiguration', @level2type = N'COLUMN', @level2name = N'CustomerName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Customer low res logo file will be used in communications', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SystemConfiguration', @level2type = N'COLUMN', @level2name = N'CustomerLogoLowRes';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Customer hi-res logo file will be used in communications', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SystemConfiguration', @level2type = N'COLUMN', @level2name = N'CustomerLogoHighRes';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Printing File Service Directory', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SystemConfiguration', @level2type = N'COLUMN', @level2name = N'PrintingFileServiceDirectory';

