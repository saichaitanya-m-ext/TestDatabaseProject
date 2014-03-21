CREATE TABLE [dbo].[CodeSetCMSPlaceOfService] (
    [PlaceOfServiceCodeID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [PlaceOfServiceCode]   VARCHAR (3)        NOT NULL,
    [PlaceOfServiceName]   VARCHAR (150)      NULL,
    [Description]          VARCHAR (4000)     NULL,
    [BeginDate]            DATE               NOT NULL,
    [EndDate]              DATE               CONSTRAINT [DF_CodeSetCMSPlaceOfService_EndDate] DEFAULT ('01-01-2100') NOT NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_CodeSetCMSPlaceOfService_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          DATETIME           CONSTRAINT [DF_CodeSetCMSPlaceOfService_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_CodeSetCMSPlaceOfService] PRIMARY KEY CLUSTERED ([PlaceOfServiceCodeID] ASC) ON [FG_Codesets]
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetCMSPlaceOfService', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetCMSPlaceOfService', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetCMSPlaceOfService', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetCMSPlaceOfService', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

