CREATE TABLE [dbo].[MedicalCondition] (
    [MedicalConditionID]   [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [DiseaseId]            [dbo].[KeyID]      NOT NULL,
    [Condition]            VARCHAR (256)      NOT NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_MedicalCondition_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_MedicalCondition_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_MedicalCondition] PRIMARY KEY CLUSTERED ([MedicalConditionID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_MedicalCondition_DiseaseId] FOREIGN KEY ([DiseaseId]) REFERENCES [dbo].[Disease] ([DiseaseId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_MedicalCondition_DiseasesID]
    ON [dbo].[MedicalCondition]([DiseaseId] ASC, [Condition] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalCondition', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalCondition', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalCondition', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MedicalCondition', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

