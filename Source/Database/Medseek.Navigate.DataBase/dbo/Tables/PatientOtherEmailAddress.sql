CREATE TABLE [dbo].[PatientOtherEmailAddress] (
    [PatientEmailAddressID] INT          IDENTITY (1, 1) NOT NULL,
    [PatientID]             INT          NOT NULL,
    [ContactName]           VARCHAR (60) NULL,
    [ContactRelationshipID] INT          NULL,
    [EmailAddressTypeID]    INT          NOT NULL,
    [EmailAddress]          VARCHAR (15) NOT NULL,
    [RankOrder]             TINYINT      NOT NULL,
    [DataSourceID]          INT          NULL,
    [DataSourceFileID]      INT          NULL,
    [RecordTagFileID]       INT          NULL,
    [StatusCode]            VARCHAR (1)  CONSTRAINT [DF_PatientOtherEmailAddress_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]       INT          NOT NULL,
    [CreatedDate]           DATETIME     CONSTRAINT [DF_PatientOtherEmailAddress_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]  INT          NULL,
    [LastModifiedDate]      DATETIME     NULL,
    CONSTRAINT [PK_PatientOtherEmailAddress] PRIMARY KEY CLUSTERED ([PatientID] ASC, [EmailAddressTypeID] ASC, [EmailAddress] ASC),
    CONSTRAINT [FK_PatientOtherEmailAddress_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientOtherEmailAddress_CodeSetRelation] FOREIGN KEY ([ContactRelationshipID]) REFERENCES [dbo].[CodeSetRelation] ([RelationId]),
    CONSTRAINT [FK_PatientOtherEmailAddress_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_PatientOtherEmailAddress_LkUpEmailAddressType] FOREIGN KEY ([EmailAddressTypeID]) REFERENCES [dbo].[LkUpEmailAddressType] ([EmailAddressTypeID]),
    CONSTRAINT [FK_PatientOtherEmailAddress_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_PatientOtherEmailAddress_PatientID]
    ON [dbo].[PatientOtherEmailAddress]([PatientID] ASC)
    INCLUDE([EmailAddressTypeID], [RankOrder]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

