CREATE TABLE [dbo].[UserObstetricsHistory] (
    [UserObstetricsHistoryID] INT           IDENTITY (1, 1) NOT NULL,
    [ObstetricsHistoryID]     INT           NOT NULL,
    [PatientID]               INT           NOT NULL,
    [Year]                    SMALLINT      NULL,
    [Comments]                VARCHAR (500) NULL,
    [CreatedByUserId]         INT           NOT NULL,
    [CreatedDate]             DATETIME      CONSTRAINT [DF_UserObstetricsHistory_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]    INT           NULL,
    [LastModifiedDate]        DATETIME      NULL,
    CONSTRAINT [PK_UserObstetricsHistory] PRIMARY KEY CLUSTERED ([UserObstetricsHistoryID] ASC),
    CONSTRAINT [FK_UserObstetricsHistory_ObstetricalConditions] FOREIGN KEY ([ObstetricsHistoryID]) REFERENCES [dbo].[ObstetricalConditions] ([ObstetricalConditionsID]),
    CONSTRAINT [FK_UserObstetricsHistory_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserObstetricsHistory_ObstetricsHistoryID_PatientUserID]
    ON [dbo].[UserObstetricsHistory]([ObstetricsHistoryID] ASC, [PatientID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserObstetricsHistory', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserObstetricsHistory', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserObstetricsHistory', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserObstetricsHistory', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

