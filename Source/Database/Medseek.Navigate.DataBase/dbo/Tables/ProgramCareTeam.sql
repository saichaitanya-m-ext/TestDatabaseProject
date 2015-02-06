CREATE TABLE [dbo].[ProgramCareTeam] (
    [ProgramId]       [dbo].[KeyID]       NOT NULL,
    [CareTeamId]      [dbo].[KeyID]       NOT NULL,
    [IsPopulation]    [dbo].[IsIndicator] DEFAULT ((0)) NULL,
    [CreatedByUserId] [dbo].[KeyID]       NOT NULL,
    [CreatedDate]     [dbo].[UserDate]    CONSTRAINT [DF_ProgramCareTeam_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ProgramCareTeam] PRIMARY KEY CLUSTERED ([ProgramId] ASC, [CareTeamId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_ProgramCareTeam_CareTeam] FOREIGN KEY ([CareTeamId]) REFERENCES [dbo].[CareTeam] ([CareTeamId]),
    CONSTRAINT [FK_ProgramCareTeam_Program] FOREIGN KEY ([ProgramId]) REFERENCES [dbo].[Program] ([ProgramId])
);


GO
CREATE NONCLUSTERED INDEX [IX_ProgramCareTeam_ProgramID_Include]
    ON [dbo].[ProgramCareTeam]([ProgramId] ASC, [CareTeamId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramCareTeam', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramCareTeam', @level2type = N'COLUMN', @level2name = N'CreatedDate';

