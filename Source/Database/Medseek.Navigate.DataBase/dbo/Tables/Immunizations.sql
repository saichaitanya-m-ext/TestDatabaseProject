CREATE TABLE [dbo].[Immunizations] (
    [ImmunizationID]          [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [Name]                    VARCHAR (100)           NOT NULL,
    [Description]             [dbo].[LongDescription] NULL,
    [SortOrder]               [dbo].[STID]            NULL,
    [CreatedByUserId]         [dbo].[KeyID]           NOT NULL,
    [CreatedDate]             [dbo].[UserDate]        CONSTRAINT [DF_Immunizations_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]    [dbo].[KeyID]           NULL,
    [LastModifiedDate]        [dbo].[UserDate]        NULL,
    [StatusCode]              [dbo].[StatusCode]      CONSTRAINT [DF_Immunizations_StatusCode] DEFAULT ('A') NOT NULL,
    [Route]                   VARCHAR (50)            NULL,
    [ProcedureID]             [dbo].[KeyID]           NULL,
    [DependentImmunizationID] [dbo].[KeyID]           NULL,
    [DaysBetweenImmunization] INT                     NULL,
    [Strength]                VARCHAR (30)            NULL,
    CONSTRAINT [PK_Immunizations] PRIMARY KEY CLUSTERED ([ImmunizationID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_Immunizations_CodeSetProcedure] FOREIGN KEY ([ProcedureID]) REFERENCES [dbo].[CodeSetProcedure] ([ProcedureCodeID]),
    CONSTRAINT [FK_Immunizations_DependentImmunizations] FOREIGN KEY ([DependentImmunizationID]) REFERENCES [dbo].[Immunizations] ([ImmunizationID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ImmunizationsName]
    ON [dbo].[Immunizations]([Name] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'List of standard Immunizations', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Immunizations';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the Immunizations Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Immunizations', @level2type = N'COLUMN', @level2name = N'ImmunizationID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Immunizations Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Immunizations', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for Immunizations table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Immunizations', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alternate Sort order for Immunizations table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Immunizations', @level2type = N'COLUMN', @level2name = N'SortOrder';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Immunizations', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Immunizations', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Immunizations', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Immunizations', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Immunizations', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Immunizations', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Immunizations', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Immunizations', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Immunizations', @level2type = N'COLUMN', @level2name = N'StatusCode';

