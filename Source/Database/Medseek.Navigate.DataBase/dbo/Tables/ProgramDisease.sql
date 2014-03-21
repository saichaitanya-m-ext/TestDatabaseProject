CREATE TABLE [dbo].[ProgramDisease] (
    [ProgramDiseaseId]     [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [ProgramId]            [dbo].[KeyID]      NULL,
    [DiseaseId]            [dbo].[KeyID]      NULL,
    [CreatedByUserId]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_ProgramDisease_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [StatusCode]           [dbo].[StatusCode] DEFAULT ('A') NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_ProgramDisease] PRIMARY KEY CLUSTERED ([ProgramDiseaseId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_ProgramDisease_Disease] FOREIGN KEY ([DiseaseId]) REFERENCES [dbo].[Disease] ([DiseaseId]),
    CONSTRAINT [FK_ProgramDisease_Program] FOREIGN KEY ([ProgramId]) REFERENCES [dbo].[Program] ([ProgramId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ProgramDisease]
    ON [dbo].[ProgramDisease]([ProgramId] ASC, [DiseaseId] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cross reference table relating Program to the diseases it is design to manage', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramDisease';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the ProgamDisease table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramDisease', @level2type = N'COLUMN', @level2name = N'ProgramDiseaseId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Program Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramDisease', @level2type = N'COLUMN', @level2name = N'ProgramId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Disease Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramDisease', @level2type = N'COLUMN', @level2name = N'DiseaseId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramDisease', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramDisease', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramDisease', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramDisease', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramDisease', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramDisease', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

