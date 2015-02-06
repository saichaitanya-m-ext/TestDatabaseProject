CREATE TABLE [dbo].[DiseaseTherapeuticClass] (
    [DiseaseID]       [dbo].[KeyID]    NOT NULL,
    [TherapeuticID]   [dbo].[KeyID]    NOT NULL,
    [CreatedByUserId] [dbo].[KeyID]    NOT NULL,
    [CreatedDate]     [dbo].[UserDate] CONSTRAINT [DF_DiseaseTherapeuticClasses_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_DiseaseTherapeuticClass] PRIMARY KEY CLUSTERED ([DiseaseID] ASC, [TherapeuticID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_DiseaseTherapeuticClass_Disease] FOREIGN KEY ([DiseaseID]) REFERENCES [dbo].[Disease] ([DiseaseId]),
    CONSTRAINT [FK_DiseaseTherapeuticClass_TherapeuticClass] FOREIGN KEY ([TherapeuticID]) REFERENCES [dbo].[TherapeuticClass] ([TherapeuticID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Group of therapeutic classes associated with a Disease', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseTherapeuticClass';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Disease Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseTherapeuticClass', @level2type = N'COLUMN', @level2name = N'DiseaseID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Part of the Primary Key for the DiseaseTherapeuticClass table and Foreign key to the TherapeuticClass table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseTherapeuticClass', @level2type = N'COLUMN', @level2name = N'TherapeuticID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseTherapeuticClass', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseTherapeuticClass', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseTherapeuticClass', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DiseaseTherapeuticClass', @level2type = N'COLUMN', @level2name = N'CreatedDate';

