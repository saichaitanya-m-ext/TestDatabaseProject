CREATE TABLE [dbo].[InsuranceGroup] (
    [InsuranceGroupID]            [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [GroupName]                   [dbo].[SourceName]       NOT NULL,
    [Website]                     [dbo].[ShortDescription] NULL,
    [AddressLine1]                [dbo].[Address]          NULL,
    [AddressLine2]                [dbo].[Address]          NULL,
    [City]                        [dbo].[City]             NULL,
    [StateCode]                   [dbo].[State]            NULL,
    [ZipCode]                     [dbo].[ZipCode]          NULL,
    [PhoneNumber]                 [dbo].[Phone]            NULL,
    [PhoneNumberExtension]        [dbo].[PhoneExt]         NULL,
    [Fax]                         [dbo].[Fax]              NULL,
    [ContactName]                 [dbo].[SourceName]       NULL,
    [ContactPhoneNumber]          [dbo].[Phone]            NULL,
    [ContactPhoneNumberExtension] [dbo].[PhoneExt]         NULL,
    [InternalID]                  VARCHAR (50)             NULL,
    [IsMedicare]                  [dbo].[IsIndicator]      NULL,
    [StatusCode]                  [dbo].[StatusCode]       CONSTRAINT [DF_InsuranceGroup_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]             [dbo].[KeyID]            NOT NULL,
    [CreatedDate]                 [dbo].[UserDate]         CONSTRAINT [DF_InsuranceGroup_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]        [dbo].[KeyID]            NULL,
    [LastModifiedDate]            [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_InsuranceGroup] PRIMARY KEY CLUSTERED ([InsuranceGroupID] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_InsuranceGroup_GroupName]
    ON [dbo].[InsuranceGroup]([GroupName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_InsuranceGroup_GroupName_StatusCode]
    ON [dbo].[InsuranceGroup]([InsuranceGroupID] ASC, [GroupName] ASC, [StatusCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Library_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_InsuranceGroup_StatusCode]
    ON [dbo].[InsuranceGroup]([StatusCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Insurance Group Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the Insurance group - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'InsuranceGroupID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of a insurance group', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'GroupName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The URL for the Insurance Group', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'Website';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Address Line one for insurance group', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'AddressLine1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Address Line two for insurance group', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'AddressLine2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Insurance Group City', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'City';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The State for the Insurance Group', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'StateCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Zip Code for Insurance Group', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'ZipCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The general phone number for a Insurance group', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'PhoneNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The general phone number ext  for a Insurance group', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'PhoneNumberExtension';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fax Number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'Fax';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A contact name at the insurance group', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'ContactName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The contact phone number for a insurance group', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'ContactPhoneNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The contact phone number ext  for a insurance group', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'ContactPhoneNumberExtension';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroup', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

