CREATE TABLE [dbo].[CodeSetBloodType] (
    [BloodTypeId]      [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [BloodType]        [dbo].[SourceName]      NOT NULL,
    [CreatedByUserId]  [dbo].[KeyID]           NOT NULL,
    [CreatedDate]      [dbo].[UserDate]        NOT NULL,
    [Statuscode]       [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetBloodType_StatusCode] DEFAULT ('A') NOT NULL,
    [DataSourceID]     [dbo].[KeyID]           NULL,
    [DataSourceFileID] [dbo].[KeyID]           NULL,
    [Description]      [dbo].[LongDescription] NULL,
    CONSTRAINT [PK_BloodTypes] PRIMARY KEY CLUSTERED ([BloodTypeId] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetBloodType_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_BloodTypes_BloodType]
    ON [dbo].[CodeSetBloodType]([BloodType] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetBloodType', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetBloodType', @level2type = N'COLUMN', @level2name = N'CreatedDate';

