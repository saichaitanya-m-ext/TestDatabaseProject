CREATE TABLE [dbo].[ACGPatientRXMGCodes] (
    [ACGResultsID]         [dbo].[KeyID]    NOT NULL,
    [RXMGCodeID]           [dbo].[KeyID]    NOT NULL,
    [CreatedDate]          [dbo].[UserDate] CONSTRAINT [DF_PatientRXMGCodes_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]    NOT NULL,
    [LastModifiedDate]     [dbo].[UserDate] NULL,
    [LastModifiedByUserID] [dbo].[KeyID]    NULL,
    CONSTRAINT [PK_PatientRXMGCodes] PRIMARY KEY CLUSTERED ([ACGResultsID] ASC, [RXMGCodeID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientRXMGCodes_PatientACGResults] FOREIGN KEY ([ACGResultsID]) REFERENCES [dbo].[ACGPatientResults] ([ACGResultsID]),
    CONSTRAINT [FK_PatientRXMGCodes_RXMGCodes] FOREIGN KEY ([RXMGCodeID]) REFERENCES [dbo].[ACGRXMGCodes] ([RXMGCodeID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGPatientRXMGCodes', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGPatientRXMGCodes', @level2type = N'COLUMN', @level2name = N'CreatedByUserID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGPatientRXMGCodes', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGPatientRXMGCodes', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserID';

