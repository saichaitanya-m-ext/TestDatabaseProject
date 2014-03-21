CREATE TABLE [dbo].[LabCodeGroup] (
    [PatientMeasureId] [dbo].[KeyID] NOT NULL,
    [CodeGroupingId]   [dbo].[KeyID] NOT NULL,
    CONSTRAINT [PK_LabCodeGroup] PRIMARY KEY CLUSTERED ([PatientMeasureId] ASC, [CodeGroupingId] ASC),
    CONSTRAINT [FK_LabCodeGroup_CodeGrouping] FOREIGN KEY ([CodeGroupingId]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_LabCodeGroup_PatientMeasure] FOREIGN KEY ([PatientMeasureId]) REFERENCES [dbo].[PatientMeasure] ([PatientMeasureID])
);

