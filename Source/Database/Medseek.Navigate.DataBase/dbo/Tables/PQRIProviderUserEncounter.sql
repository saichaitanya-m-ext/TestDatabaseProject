CREATE TABLE [dbo].[PQRIProviderUserEncounter] (
    [PQRIProviderUserEncounterID]   [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [PQRIProviderPersonalizationID] [dbo].[KeyID]           NOT NULL,
    [PatientUserId]                 [dbo].[KeyID]           NOT NULL,
    [ClaimNum]                      VARCHAR (50)            NULL,
    [DateOfService]                 DATETIME                NULL,
    [PQRIMeasureIDList]             [dbo].[LongDescription] NULL,
    [UserEncounterIDList]           VARCHAR (MAX)           NULL,
    [UserDiagnosisIDList]           VARCHAR (MAX)           NULL,
    [UserProcedureIDList]           VARCHAR (MAX)           NULL,
    [TransactionStatus]             VARCHAR (10)            CONSTRAINT [DF_PQRIProviderUserEncounter_TransactionStatus] DEFAULT ('Open') NULL,
    [CreatedByUserId]               [dbo].[KeyID]           NOT NULL,
    [CreatedDate]                   [dbo].[UserDate]        CONSTRAINT [DF_PQRIProviderEncounter_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]          [dbo].[KeyID]           NULL,
    [LastModifiedDate]              [dbo].[UserDate]        NULL,
    CONSTRAINT [PK_PQRIProviderUserEncounter] PRIMARY KEY CLUSTERED ([PQRIProviderUserEncounterID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PQRIProviderUserEncounter_PQRIProviderPersonalization] FOREIGN KEY ([PQRIProviderPersonalizationID]) REFERENCES [dbo].[PQRIProviderPersonalization] ([PQRIProviderPersonalizationID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderUserEncounter', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderUserEncounter', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderUserEncounter', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderUserEncounter', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

