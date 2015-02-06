CREATE TABLE [dbo].[PatientEducationMaterialLibrary] (
    [PatientEducationMaterialID] INT      NOT NULL,
    [LibraryId]                  INT      NOT NULL,
    [CreatedByUserId]            INT      NOT NULL,
    [CreatedDate]                DATETIME CONSTRAINT [DF_PatientEducationMaterialLibrary_CreatetdDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PatientEducationMaterialLibrary] PRIMARY KEY CLUSTERED ([PatientEducationMaterialID] ASC, [LibraryId] ASC),
    CONSTRAINT [FK_PatientEducationMaterialLibrary_LibraryId] FOREIGN KEY ([LibraryId]) REFERENCES [dbo].[Library] ([LibraryId]),
    CONSTRAINT [FK_PatientEducationMaterialLibrary_PatientEducationMaterialID] FOREIGN KEY ([PatientEducationMaterialID]) REFERENCES [dbo].[PatientEducationMaterial] ([PatientEducationMaterialID])
);

