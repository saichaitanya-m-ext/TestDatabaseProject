CREATE TABLE [dbo].[Program] (
    [ProgramId]              [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [ProgramName]            [dbo].[ShortDescription] NOT NULL,
    [Description]            [dbo].[LongDescription]  NULL,
    [CreatedByUserId]        [dbo].[KeyID]            NOT NULL,
    [CreatedDate]            [dbo].[UserDate]         CONSTRAINT [DF_Program_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   [dbo].[KeyID]            NULL,
    [LastModifiedDate]       [dbo].[UserDate]         NULL,
    [StatusCode]             [dbo].[StatusCode]       CONSTRAINT [DF_Program_StatusCode] DEFAULT ('A') NOT NULL,
    [AllowAutoEnrollment]    [dbo].[IsIndicator]      CONSTRAINT [DF_Program_AllowAutoEnrollment] DEFAULT ((0)) NULL,
    [PopulationDefinitionID] INT                      NULL,
    [ConflictType]           VARCHAR (1)              NULL,
    [DefinitionVersion]      VARCHAR (5)              CONSTRAINT [DF_Program_DefinitionVersion] DEFAULT ('1.0') NULL,
    [IsAutomaticTermination] [dbo].[IsIndicator]      CONSTRAINT [DF_Program_IsAutomaticTermination] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Program] PRIMARY KEY CLUSTERED ([ProgramId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_Program_PopulationDefinition] FOREIGN KEY ([PopulationDefinitionID]) REFERENCES [dbo].[PopulationDefinition] ([PopulationDefinitionID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Program]
    ON [dbo].[Program]([ProgramName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A Medical program that is designed to help a collection of patients with like medical conditions', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Program';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the Program Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Program', @level2type = N'COLUMN', @level2name = N'ProgramId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Program name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Program', @level2type = N'COLUMN', @level2name = N'ProgramName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for Program table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Program', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Program', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Program', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Program', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Program', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Program', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Program', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Program', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Program', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Program', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag to indicate if the program supports auto enrollment', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Program', @level2type = N'COLUMN', @level2name = N'AllowAutoEnrollment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cohort list that defines the criteria for the program', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Program', @level2type = N'COLUMN', @level2name = N'PopulationDefinitionID';

