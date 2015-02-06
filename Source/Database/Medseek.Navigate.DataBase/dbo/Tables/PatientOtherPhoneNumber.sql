CREATE TABLE [dbo].[PatientOtherPhoneNumber] (
    [PatientPhoneID]        INT          IDENTITY (1, 1) NOT NULL,
    [PatientID]             INT          NOT NULL,
    [ContactName]           VARCHAR (60) NULL,
    [ContactRelationshipID] INT          NULL,
    [PhoneTypeID]           INT          NOT NULL,
    [PhoneNumber]           VARCHAR (15) NOT NULL,
    [PhoneNumberExtension]  VARCHAR (20) NOT NULL,
    [RankOrder]             TINYINT      NOT NULL,
    [DataSourceID]          INT          NULL,
    [DataSourceFileID]      INT          NULL,
    [RecordTagFileID]       VARCHAR (30) NULL,
    [StatusCode]            VARCHAR (1)  CONSTRAINT [DF_PatientOtherPhone_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]       INT          NOT NULL,
    [CreatedDate]           DATETIME     CONSTRAINT [DF_PatientOtherPhone_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]  INT          NULL,
    [LastModifiedDate]      DATETIME     NULL,
    CONSTRAINT [PK_PatientOtherPhone] PRIMARY KEY CLUSTERED ([PatientID] ASC, [PhoneTypeID] ASC, [PhoneNumber] ASC, [PhoneNumberExtension] ASC),
    CONSTRAINT [FK_PatientOtherPhone_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientOtherPhone_CodeSetRelation] FOREIGN KEY ([ContactRelationshipID]) REFERENCES [dbo].[CodeSetRelation] ([RelationId]),
    CONSTRAINT [FK_PatientOtherPhone_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_PatientOtherPhone_LkUpPhoneType] FOREIGN KEY ([PhoneTypeID]) REFERENCES [dbo].[LkUpPhoneType] ([PhoneTypeID]),
    CONSTRAINT [FK_PatientOtherPhone_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_PatientOtherPhone_PatientID]
    ON [dbo].[PatientOtherPhoneNumber]([PatientID] ASC)
    INCLUDE([PhoneTypeID], [RankOrder]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

