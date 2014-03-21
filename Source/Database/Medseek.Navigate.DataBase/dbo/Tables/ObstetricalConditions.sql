CREATE TABLE [dbo].[ObstetricalConditions] (
    [ObstetricalConditionsID] [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [ObstetricalName]         [dbo].[SourceName]      NOT NULL,
    [Comments]                [dbo].[LongDescription] NULL,
    [StatusCode]              [dbo].[StatusCode]      CONSTRAINT [DF_ObstetricalConditions_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]         [dbo].[KeyID]           NOT NULL,
    [CreatedDate]             [dbo].[UserDate]        CONSTRAINT [DF_ObstetricalConditions_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]    [dbo].[KeyID]           NULL,
    [LastModifiedDate]        [dbo].[UserDate]        NULL,
    CONSTRAINT [PK_ObstetricalConditions] PRIMARY KEY CLUSTERED ([ObstetricalConditionsID] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ObstetricalConditions_ObstetricalName]
    ON [dbo].[ObstetricalConditions]([ObstetricalName] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ObstetricalConditions', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ObstetricalConditions', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ObstetricalConditions', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ObstetricalConditions', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

