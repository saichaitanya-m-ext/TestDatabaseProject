CREATE TABLE [dbo].[PatientEducationMaterialDocuments] (
    [PatientEducationMaterialDocumentsID] INT             IDENTITY (1, 1) NOT NULL,
    [PatientEducationMaterialID]          INT             NOT NULL,
    [DcoumentName]                        VARCHAR (100)   NOT NULL,
    [Content]                             VARBINARY (MAX) NOT NULL,
    [CreatedByUserId]                     INT             NOT NULL,
    [CreatedDate]                         DATETIME        CONSTRAINT [DF_PatientEducationMaterialDocuments_CreatetdDate] DEFAULT (getdate()) NOT NULL,
    [MimeType]                            VARCHAR (20)    NULL,
    CONSTRAINT [PK_PatientEducationMaterialDocuments] PRIMARY KEY CLUSTERED ([PatientEducationMaterialDocumentsID] ASC),
    CONSTRAINT [FK_PatientEducationMaterialDocuments_PatientEducationMaterialID] FOREIGN KEY ([PatientEducationMaterialID]) REFERENCES [dbo].[PatientEducationMaterial] ([PatientEducationMaterialID])
);

