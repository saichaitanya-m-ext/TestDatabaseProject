CREATE TABLE [dbo].[CodeSetProcedure] (
    [ProcedureCodeID]           INT                 IDENTITY (1, 1) NOT NULL,
    [ProcedureCode]             VARCHAR (10)        NOT NULL,
    [ProcedureName]             VARCHAR (500)       NULL,
    [CreatedByUserId]           [dbo].[KeyID]       NULL,
    [CreatedDate]               [dbo].[UserDate]    CONSTRAINT [DF_CodeSetProcedure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]      [dbo].[KeyID]       NULL,
    [LastModifiedDate]          [dbo].[UserDate]    NULL,
    [IsLabTest]                 [dbo].[IsIndicator] CONSTRAINT [DF_CodeSetProcedure_IsLabTest] DEFAULT ((0)) NULL,
    [LeadtimeDays]              INT                 NULL,
    [BeginDate]                 DATE                NULL,
    [EndDate]                   DATE                CONSTRAINT [DF_CodeSetProcedure_EndDate] DEFAULT ('01-01-2100') NULL,
    [StatusCode]                VARCHAR (1)         CONSTRAINT [DF_CodeSetProcedure_StatusCode] DEFAULT ('A') NOT NULL,
    [CodeTypeID]                [dbo].[KeyID]       NULL,
    [DataSourceID]              [dbo].[KeyID]       NULL,
    [DataSourceFileID]          [dbo].[KeyID]       NULL,
    [ProcedureShortDescription] VARCHAR (1000)      NULL,
    [ProcedureLongDescription]  VARCHAR (4000)      NULL,
    [VaccineProcedureID]        INT                 NULL,
    CONSTRAINT [PK_CodeSetProcedure] PRIMARY KEY CLUSTERED ([ProcedureCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetProcedure_CodeSetVaccineProcedure] FOREIGN KEY ([VaccineProcedureID]) REFERENCES [dbo].[CodeSetVaccineProcedure] ([VaccineProcedureID])
);


GO
CREATE NONCLUSTERED INDEX [IX_CodeSetProcedure_VaccineProcedureID]
    ON [dbo].[CodeSetProcedure]([VaccineProcedureID] ASC)
    INCLUDE([ProcedureCodeID]) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Procedure or CPT codes each code is uses to report a specific medical procedure done on a patient. Provided by the AMA', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the CodeSetProcedure table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'ProcedureCodeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CPT Procedure Code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'ProcedureCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Procedure Code Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'ProcedureName';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag indicating if the Procedure code is a Lab test', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'IsLabTest';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'First Date on which the Procedure code is valid for use.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'BeginDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'First Date on which the Drug code is valid for use.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'BeginDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Last Date on which the Procedure code is valid for use. And also, alter the column to not permit NULL values.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'EndDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Last Date on which the Drug code is valid for use.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'EndDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Procedure Code Description', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetProcedure', @level2type = N'COLUMN', @level2name = N'ProcedureShortDescription';

