CREATE TABLE [dbo].[ACGPatientConditions] (
    [ACGResultsID]         [dbo].[KeyID]    NOT NULL,
    [ACGConditionsID]      [dbo].[KeyID]    NOT NULL,
    [Rxgaps]               DECIMAL (10, 2)  NULL,
    [MPR]                  DECIMAL (10, 2)  NULL,
    [CSA]                  DECIMAL (10, 2)  NULL,
    [UntreatedRx]          NVARCHAR (50)    NULL,
    [ConditionCode]        NVARCHAR (50)    NULL,
    [CreatedByUserId]      [dbo].[KeyID]    NOT NULL,
    [CreatedDate]          [dbo].[UserDate] CONSTRAINT [DF_PatientACGConditions_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]    NULL,
    [LastModifiedDate]     [dbo].[UserDate] NULL,
    CONSTRAINT [PK_PatientACGConditions] PRIMARY KEY CLUSTERED ([ACGResultsID] ASC, [ACGConditionsID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientACGConditions_ACGConditions] FOREIGN KEY ([ACGConditionsID]) REFERENCES [dbo].[ACGConditions] ([ACGConditionsID]),
    CONSTRAINT [FK_PatientACGConditions_PatientACGResults] FOREIGN KEY ([ACGResultsID]) REFERENCES [dbo].[ACGPatientResults] ([ACGResultsID]),
    CONSTRAINT [FK_PatientACGConditions_UntreatedRx] FOREIGN KEY ([UntreatedRx]) REFERENCES [dbo].[UntreatedRx] ([UntreatedRxCode])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGPatientConditions', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGPatientConditions', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGPatientConditions', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGPatientConditions', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

