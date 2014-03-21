CREATE TABLE [dbo].[UserObstetricalConditions] (
    [UserObstetricalConditionsID] INT           IDENTITY (1, 1) NOT NULL,
    [ObstetricalConditionsID]     INT           NOT NULL,
    [PatientID]                   INT           NOT NULL,
    [Comments]                    VARCHAR (500) NULL,
    [StartDate]                   DATETIME      NULL,
    [EndDate]                     DATETIME      NULL,
    [StatusCode]                  VARCHAR (1)   CONSTRAINT [DF_UserObstetricalConditions_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]             INT           NOT NULL,
    [CreatedDate]                 DATETIME      CONSTRAINT [DF_UserObstetricalConditions_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]        INT           NULL,
    [LastModifiedDate]            DATETIME      NULL,
    [DataSourceId]                [dbo].[KeyID] NULL,
    CONSTRAINT [PK_UserObstetricalConditions] PRIMARY KEY CLUSTERED ([UserObstetricalConditionsID] ASC),
    CONSTRAINT [FK_UserObstetricalConditions_DataSourceId] FOREIGN KEY ([DataSourceId]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_UserObstetricalConditions_ObstetricalConditionsID] FOREIGN KEY ([ObstetricalConditionsID]) REFERENCES [dbo].[ObstetricalConditions] ([ObstetricalConditionsID]),
    CONSTRAINT [FK_UserObstetricalConditions_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_UserObstetricalConditions]
    ON [dbo].[UserObstetricalConditions]([ObstetricalConditionsID] ASC, [PatientID] ASC, [StartDate] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserObstetricalConditions', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserObstetricalConditions', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserObstetricalConditions', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserObstetricalConditions', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

