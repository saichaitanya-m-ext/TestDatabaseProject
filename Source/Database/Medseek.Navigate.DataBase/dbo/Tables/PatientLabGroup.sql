CREATE TABLE [dbo].[PatientLabGroup] (
    [PatientMeasureID] [dbo].[KeyID]      NOT NULL,
    [CodeGroupingID]   [dbo].[KeyID]      NOT NULL,
    [StatusCode]       [dbo].[StatusCode] CONSTRAINT [DF_PatientLabGroup_StatusCode] DEFAULT ('A') NULL,
    [CreatedByUserId]  [dbo].[KeyID]      NOT NULL,
    [CreatedDate]      [dbo].[UserDate]   CONSTRAINT [DF_PatientLabGroup_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PatientLabGroup] PRIMARY KEY CLUSTERED ([PatientMeasureID] ASC, [CodeGroupingID] ASC),
    CONSTRAINT [FK_PatientLabGroup_CodeGrouping] FOREIGN KEY ([CodeGroupingID]) REFERENCES [dbo].[CodeGrouping] ([CodeGroupingID]),
    CONSTRAINT [FK_PatientLabGroup_PatientMeasure] FOREIGN KEY ([PatientMeasureID]) REFERENCES [dbo].[PatientMeasure] ([PatientMeasureID])
);

