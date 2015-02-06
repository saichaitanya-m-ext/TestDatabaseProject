CREATE TABLE [dbo].[PatientCareTeam] (
    [PatientID]            INT         NOT NULL,
    [CareTeamID]           INT         NOT NULL,
    [ProgramID]            INT         NOT NULL,
    [StatusCode]           VARCHAR (1) CONSTRAINT [DF_PatientCareTeam_Status] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT         NOT NULL,
    [CreatedDate]          DATETIME    CONSTRAINT [DF_PatientCareTeam_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT         NULL,
    [LastModifiedDate]     DATETIME    NULL,
    CONSTRAINT [PK_PatientCareTeam] PRIMARY KEY CLUSTERED ([PatientID] ASC, [CareTeamID] ASC, [ProgramID] ASC),
    CONSTRAINT [FK_PatientCareTeam_CareTeam] FOREIGN KEY ([CareTeamID]) REFERENCES [dbo].[CareTeam] ([CareTeamId]),
    CONSTRAINT [FK_PatientCareTeam_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientCareTeam_Program] FOREIGN KEY ([ProgramID]) REFERENCES [dbo].[Program] ([ProgramId])
);


GO
CREATE NONCLUSTERED INDEX [IX_PatientCareTeam_PatientUserID]
    ON [dbo].[PatientCareTeam]([PatientID] ASC, [ProgramID] ASC)
    INCLUDE([CareTeamID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

