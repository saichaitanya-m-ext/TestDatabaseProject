CREATE TABLE [dbo].[GrouperDisease] (
    [GrouperDiseaseId]     [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [Name]                 [dbo].[LongDescription] NOT NULL,
    [DxCAT]                VARCHAR (50)            NULL,
    [GrouperSystemID]      [dbo].[KeyID]           NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_GrouperDisease_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]           NOT NULL,
    [CreatedDate]          [dbo].[UserDate]        CONSTRAINT [DF_GrouperDisease_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]           NULL,
    [LastModifiedDate]     [dbo].[UserDate]        NULL,
    CONSTRAINT [PK_GrouperDisease] PRIMARY KEY CLUSTERED ([GrouperDiseaseId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_GrouperDisease_GrouperSystem] FOREIGN KEY ([GrouperSystemID]) REFERENCES [dbo].[GrouperSystem] ([GrouperSystemId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GrouperDisease', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GrouperDisease', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GrouperDisease', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GrouperDisease', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

