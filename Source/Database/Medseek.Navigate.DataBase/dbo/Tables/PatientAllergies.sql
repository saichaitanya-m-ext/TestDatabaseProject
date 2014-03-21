CREATE TABLE [dbo].[PatientAllergies] (
    [PatientAllergiesID]   [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [PatientID]            [dbo].[KeyID]            NOT NULL,
    [Reaction]             [dbo].[ShortDescription] NULL,
    [Severity]             [dbo].[Unit]             NULL,
    [Comments]             [dbo].[LongDescription]  NULL,
    [CreatedByUserId]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_UserAlergies_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_UserAlergies_StatusCode] DEFAULT ('A') NOT NULL,
    [UserAllergiesDate]    DATE                     NULL,
    [DataSourceID]         INT                      NULL,
    [AllergiesID]          [dbo].[KeyID]            NULL,
    CONSTRAINT [PK_UserAlergies] PRIMARY KEY CLUSTERED ([PatientAllergiesID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientAllergies_LastProvider] FOREIGN KEY ([LastModifiedByUserId]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_PatientAllergies_Provider] FOREIGN KEY ([CreatedByUserId]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_UserAllergies_Allergies] FOREIGN KEY ([AllergiesID]) REFERENCES [dbo].[Allergies] ([AllergiesID]),
    CONSTRAINT [FK_UserAllergies_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A list of allergies for a specific patient cross reference between patients and Allergies', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientAllergies';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the patient UserAllergies table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientAllergies', @level2type = N'COLUMN', @level2name = N'PatientAllergiesID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table (Patient user ID )', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientAllergies', @level2type = N'COLUMN', @level2name = N'PatientID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Free Form field used to describe the reaction', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientAllergies', @level2type = N'COLUMN', @level2name = N'Reaction';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'M = Mild reaction, S = Severe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientAllergies', @level2type = N'COLUMN', @level2name = N'Severity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comments', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientAllergies', @level2type = N'COLUMN', @level2name = N'Comments';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientAllergies', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientAllergies', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientAllergies', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientAllergies', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientAllergies', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientAllergies', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientAllergies', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientAllergies', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientAllergies', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date of the Allergy', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientAllergies', @level2type = N'COLUMN', @level2name = N'UserAllergiesDate';

