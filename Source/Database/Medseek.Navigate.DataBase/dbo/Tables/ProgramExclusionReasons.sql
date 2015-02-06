CREATE TABLE [dbo].[ProgramExclusionReasons] (
    [ProgramExcludeID]     [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [ProgramTypeID]        [dbo].[KeyID]            NOT NULL,
    [ExclusionReason]      [dbo].[ShortDescription] NULL,
    [Description]          [dbo].[LongDescription]  NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_ProgramExclusionReasons_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_ProgramExclusionReasons_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_ProgramExclusionReasons] PRIMARY KEY CLUSTERED ([ProgramExcludeID] ASC),
    CONSTRAINT [FK_ProgramExclusionReasons_ProgramType] FOREIGN KEY ([ProgramTypeID]) REFERENCES [dbo].[ProgramType] ([ProgramTypeId])
);


GO
CREATE NONCLUSTERED INDEX [IX_ProgramExclusionReasons_ExclusionReason]
    ON [dbo].[ProgramExclusionReasons]([ExclusionReason] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_ProgramExclusionReasons_ProgramTypeID]
    ON [dbo].[ProgramExclusionReasons]([ProgramTypeID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ProgramExclusionReasons_ProgramTypeID_ExclusionReason]
    ON [dbo].[ProgramExclusionReasons]([ProgramTypeID] ASC, [ExclusionReason] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramExclusionReasons', @level2type = N'COLUMN', @level2name = N'CreatedByUserID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramExclusionReasons', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramExclusionReasons', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramExclusionReasons', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

