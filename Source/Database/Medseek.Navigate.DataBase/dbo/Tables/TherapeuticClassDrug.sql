CREATE TABLE [dbo].[TherapeuticClassDrug] (
    [TherapeuticID]   [dbo].[KeyID]    NOT NULL,
    [DrugCodeID]      [dbo].[KeyID]    NOT NULL,
    [CreatedByUserID] [dbo].[KeyID]    NOT NULL,
    [CreatedDate]     [dbo].[UserDate] CONSTRAINT [DF_TherapeuticClassDrugs_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_TherapeuticClassDrug] PRIMARY KEY CLUSTERED ([TherapeuticID] ASC, [DrugCodeID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_TherapeuticClassDrug_CodeSetDrug] FOREIGN KEY ([DrugCodeID]) REFERENCES [dbo].[CodeSetDrug] ([DrugCodeId]),
    CONSTRAINT [FK_TherapeuticClassDrug_TherapeuticClass] FOREIGN KEY ([TherapeuticID]) REFERENCES [dbo].[TherapeuticClass] ([TherapeuticID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A specific drup that belongs to a therapeutic Class Cross reference between TherapeuticClass and Drugs', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClassDrug';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the TherapeuticClass table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClassDrug', @level2type = N'COLUMN', @level2name = N'TherapeuticID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the CodeSetDrug table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClassDrug', @level2type = N'COLUMN', @level2name = N'DrugCodeID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClassDrug', @level2type = N'COLUMN', @level2name = N'CreatedByUserID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClassDrug', @level2type = N'COLUMN', @level2name = N'CreatedByUserID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClassDrug', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TherapeuticClassDrug', @level2type = N'COLUMN', @level2name = N'CreatedDate';

