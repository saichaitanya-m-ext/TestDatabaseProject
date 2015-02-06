CREATE TABLE [dbo].[PatientDr] (
    [DrID]             [dbo].[KeyID]    NOT NULL,
    [PatientID]        [dbo].[KeyID]    NOT NULL,
    [DateKey]          INT              NOT NULL,
    [OutPutAnchorDate] DATE             NOT NULL,
    [ClaimAmt]         MONEY            NULL,
    [CreatedDate]      [dbo].[UserDate] CONSTRAINT [DF_PatientDr_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PatientDr] PRIMARY KEY CLUSTERED ([DrID] ASC, [PatientID] ASC, [DateKey] ASC),
    CONSTRAINT [FK_PatientDr_AnchorDate] FOREIGN KEY ([DateKey]) REFERENCES [dbo].[AnchorDate] ([DateKey]),
    CONSTRAINT [FK_PatientDr_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientDr_PopulationDefinition] FOREIGN KEY ([DrID]) REFERENCES [dbo].[PopulationDefinition] ([PopulationDefinitionID])
);

