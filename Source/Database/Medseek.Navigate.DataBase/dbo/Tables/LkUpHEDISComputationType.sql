CREATE TABLE [dbo].[LkUpHEDISComputationType] (
    [HEDISComputationTypeID]   [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [HEDISComputationTypeCode] VARCHAR (3)              NOT NULL,
    [HEDISComputationTypeName] [dbo].[ShortDescription] NOT NULL,
    [TypeDescription]          [dbo].[LongDescription]  NULL,
    [StatusCode]               [dbo].[StatusCode]       CONSTRAINT [DF_LkUpHEDISComputationType_StatusCode] DEFAULT ((1)) NOT NULL,
    [CreatedByUserID]          [dbo].[KeyID]            NOT NULL,
    [CreatedDate]              [dbo].[UserDate]         CONSTRAINT [DF_LkUpHEDISComputationType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]     [dbo].[KeyID]            NULL,
    [LastModifiedDate]         [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_LkUpHEDISComputationType] PRIMARY KEY CLUSTERED ([HEDISComputationTypeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_LkUpHEDISComputationType_LastProvider] FOREIGN KEY ([LastModifiedByUserID]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_LkUpHEDISComputationType_Provider] FOREIGN KEY ([CreatedByUserID]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_LkUpHEDISComputationType_HEDISComputationTypeCode]
    ON [dbo].[LkUpHEDISComputationType]([HEDISComputationTypeCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_LkUpHEDISComputationType_HEDISComputationTypeName]
    ON [dbo].[LkUpHEDISComputationType]([HEDISComputationTypeName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The "Primary Key" of the table in the database; the column uniquely identifies the record in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpHEDISComputationType', @level2type = N'COLUMN', @level2name = N'HEDISComputationTypeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Code of the HEDIS Computation Type.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpHEDISComputationType', @level2type = N'COLUMN', @level2name = N'HEDISComputationTypeCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Name of the HEDIS Computation Type.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpHEDISComputationType', @level2type = N'COLUMN', @level2name = N'HEDISComputationTypeName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description of the HEDIS Computation Type.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpHEDISComputationType', @level2type = N'COLUMN', @level2name = N'TypeDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status of the HEDIS Computation Type.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpHEDISComputationType', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpHEDISComputationType', @level2type = N'COLUMN', @level2name = N'CreatedByUserID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpHEDISComputationType', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpHEDISComputationType', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpHEDISComputationType', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

