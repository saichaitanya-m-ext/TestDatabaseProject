CREATE TABLE [dbo].[Labs] (
    [LabId]                [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [LabName]              [dbo].[ShortDescription] NOT NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_Labs_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUseriD]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_Labs_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_Labs] PRIMARY KEY CLUSTERED ([LabId] ASC) ON [FG_Library],
    CONSTRAINT [UQ_Labs_LabName] UNIQUE NONCLUSTERED ([LabName] ASC) WITH (FILLFACTOR = 100) ON [FG_Library_NCX]
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Labs', @level2type = N'COLUMN', @level2name = N'CreatedByUseriD';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Labs', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Labs', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Labs', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

