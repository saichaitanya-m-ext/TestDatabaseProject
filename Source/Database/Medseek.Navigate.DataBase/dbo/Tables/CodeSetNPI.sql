CREATE TABLE [dbo].[CodeSetNPI] (
    [NPINumberID]                        [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [NPINumber]                          VARCHAR (80)        NOT NULL,
    [EntityTypeID]                       [dbo].[KeyID]       NOT NULL,
    [ReplacementNPI]                     VARCHAR (80)        NULL,
    [TaxID_EIN_SSN]                      VARCHAR (10)        NULL,
    [OrganizationName]                   VARCHAR (70)        NULL,
    [LastName]                           VARCHAR (35)        NULL,
    [FirstName]                          VARCHAR (20)        NULL,
    [MiddleName]                         VARCHAR (20)        NULL,
    [NamePrefixID]                       [dbo].[KeyID]       NULL,
    [NameSuffixID]                       [dbo].[KeyID]       NULL,
    [Credential]                         VARCHAR (20)        NULL,
    [GenderID]                           [dbo].[KeyID]       NULL,
    [OtherOrganizationName]              VARCHAR (70)        NULL,
    [OtherOrganizationNameTypeID]        VARCHAR (1)         NULL,
    [OtherLastName]                      VARCHAR (35)        NULL,
    [OtherFirstName]                     VARCHAR (20)        NULL,
    [OtherMiddleName]                    VARCHAR (20)        NULL,
    [OtherNamePrefixID]                  [dbo].[KeyID]       NULL,
    [OtherNameSuffixID]                  [dbo].[KeyID]       NULL,
    [OtherCredential]                    VARCHAR (20)        NULL,
    [OtherLastNameTypeID]                VARCHAR (1)         NULL,
    [MailingAddress1]                    VARCHAR (55)        NULL,
    [MailingAddress2]                    VARCHAR (55)        NULL,
    [MailingAddressCity]                 VARCHAR (40)        NULL,
    [MailingAddressStateID]              [dbo].[KeyID]       NULL,
    [MailingAddressPostalCode]           VARCHAR (40)        NULL,
    [MailingAddressCountryID]            [dbo].[KeyID]       NULL,
    [MailingAddressPhoneNumber]          VARCHAR (20)        NULL,
    [MailingAddressFaxNumber]            VARCHAR (20)        NULL,
    [PracticeLocationAddress1]           VARCHAR (55)        NULL,
    [PracticeLocationAddress2]           VARCHAR (55)        NULL,
    [PracticeLocationCity]               VARCHAR (40)        NULL,
    [PracticeLocationStateID]            [dbo].[KeyID]       NULL,
    [PracticeLocationPostalCode]         VARCHAR (20)        NULL,
    [PracticeLocationCountryID]          [dbo].[KeyID]       NULL,
    [PracticeLocationPhoneNumber]        VARCHAR (20)        NULL,
    [PracticeLocationFaxNumber]          VARCHAR (20)        NULL,
    [ProviderEnumerationDate]            [dbo].[UserDate]    NULL,
    [LastUpdateDate]                     [dbo].[UserDate]    NULL,
    [NPIDeactivationReasonCodeID]        INT                 NULL,
    [NPIDeactivationDate]                [dbo].[UserDate]    NULL,
    [NPIReactivationDate]                [dbo].[UserDate]    NULL,
    [AuthorizedOfficialLastName]         VARCHAR (35)        NULL,
    [AuthorizedOfficialFirstName]        VARCHAR (20)        NULL,
    [AuthorizedOfficialMiddleName]       VARCHAR (20)        NULL,
    [AuthorizedOfficialTitlePosition]    VARCHAR (35)        NULL,
    [Authorized OfficialTelephoneNumber] VARCHAR (20)        NULL,
    [IsSoleProprietor]                   [dbo].[IsIndicator] NULL,
    [IsOrganizationSubpart]              [dbo].[IsIndicator] NULL,
    [ParentOrganizationLBN]              VARCHAR (70)        NULL,
    [ParentOrganizationTIN]              VARCHAR (10)        NULL,
    [AuthorizedOfficialNamePrefixID]     [dbo].[KeyID]       NULL,
    [AuthorizedOfficialNameSuffixID]     [dbo].[KeyID]       NULL,
    [AuthorizedOfficialCredential]       VARCHAR (20)        NULL,
    [DataSourceID]                       [dbo].[KeyID]       NULL,
    [DataSourceFileID]                   [dbo].[KeyID]       NULL,
    [StatusCode]                         [dbo].[StatusCode]  CONSTRAINT [DF_CodeSetNPI_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]                    [dbo].[KeyID]       NOT NULL,
    [CreatedDate]                        [dbo].[UserDate]    CONSTRAINT [DF_CodeSetNPI_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]               [dbo].[KeyID]       NULL,
    [LastModifiedDate]                   [dbo].[UserDate]    NULL,
    CONSTRAINT [PK_CodeSetNPI] PRIMARY KEY CLUSTERED ([NPINumberID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetNPI_CodeSetCountry] FOREIGN KEY ([MailingAddressCountryID]) REFERENCES [dbo].[CodeSetCountry] ([CountryID]),
    CONSTRAINT [FK_CodeSetNPI_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetNPI_CodeSetEntityType] FOREIGN KEY ([EntityTypeID]) REFERENCES [dbo].[CodeSetEntityType] ([EntityTypeID]),
    CONSTRAINT [FK_CodeSetNPI_CodeSetGender] FOREIGN KEY ([GenderID]) REFERENCES [dbo].[CodeSetGender] ([GenderID]),
    CONSTRAINT [FK_CodeSetNPI_CodeSetNamePrefix] FOREIGN KEY ([NamePrefixID]) REFERENCES [dbo].[CodeSetNamePrefix] ([NamePrefixID]),
    CONSTRAINT [FK_CodeSetNPI_CodeSetNameSuffix] FOREIGN KEY ([NameSuffixID]) REFERENCES [dbo].[CodeSetNameSuffix] ([NameSuffixID]),
    CONSTRAINT [FK_CodeSetNPI_CodeSetNPIDeactivationReasonID] FOREIGN KEY ([NPIDeactivationReasonCodeID]) REFERENCES [dbo].[CodeSetNPIDeactivationReason] ([DeactivationReasonCodeID]),
    CONSTRAINT [FK_CodeSetNPI_CodeSetState] FOREIGN KEY ([PracticeLocationStateID]) REFERENCES [dbo].[CodeSetState] ([StateID]),
    CONSTRAINT [FK_CodeSetNPI_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_CodeSetNPI_MailingAddress] FOREIGN KEY ([MailingAddressStateID]) REFERENCES [dbo].[CodeSetState] ([StateID]),
    CONSTRAINT [FK_CodeSetNPI_NamePrefix] FOREIGN KEY ([AuthorizedOfficialNamePrefixID]) REFERENCES [dbo].[CodeSetNamePrefix] ([NamePrefixID]),
    CONSTRAINT [FK_CodeSetNPI_NameSuffix] FOREIGN KEY ([AuthorizedOfficialNameSuffixID]) REFERENCES [dbo].[CodeSetNameSuffix] ([NameSuffixID]),
    CONSTRAINT [FK_CodeSetNPI_OtherNamePrefix] FOREIGN KEY ([OtherNamePrefixID]) REFERENCES [dbo].[CodeSetNamePrefix] ([NamePrefixID]),
    CONSTRAINT [FK_CodeSetNPI_OtherNameSuffix] FOREIGN KEY ([OtherNameSuffixID]) REFERENCES [dbo].[CodeSetNameSuffix] ([NameSuffixID]),
    CONSTRAINT [FK_CodeSetNPI_PracticeLocation] FOREIGN KEY ([PracticeLocationStateID]) REFERENCES [dbo].[CodeSetState] ([StateID]),
    CONSTRAINT [FK_CodeSetNPI_PracticeLocationCountry] FOREIGN KEY ([PracticeLocationCountryID]) REFERENCES [dbo].[CodeSetCountry] ([CountryID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetNPI_NPINumber]
    ON [dbo].[CodeSetNPI]([NPINumber] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'0', @value = N'No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetNPI', @level2type = N'COLUMN', @level2name = N'IsSoleProprietor';


GO
EXECUTE sp_addextendedproperty @name = N'1', @value = N'Yes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetNPI', @level2type = N'COLUMN', @level2name = N'IsSoleProprietor';


GO
EXECUTE sp_addextendedproperty @name = N'NULL', @value = N'Not Disclosed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetNPI', @level2type = N'COLUMN', @level2name = N'IsSoleProprietor';


GO
EXECUTE sp_addextendedproperty @name = N'0', @value = N'No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetNPI', @level2type = N'COLUMN', @level2name = N'IsOrganizationSubpart';


GO
EXECUTE sp_addextendedproperty @name = N'1', @value = N'Yes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetNPI', @level2type = N'COLUMN', @level2name = N'IsOrganizationSubpart';


GO
EXECUTE sp_addextendedproperty @name = N'NULL', @value = N'Un Disclosed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetNPI', @level2type = N'COLUMN', @level2name = N'IsOrganizationSubpart';

