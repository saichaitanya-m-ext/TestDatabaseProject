CREATE TABLE [dbo].[UserSubstanceAbuse] (
    [UserSubstanceAbuseId] INT           IDENTITY (1, 1) NOT NULL,
    [SubstanceAbuseId]     INT           NOT NULL,
    [PatientId]            INT           NOT NULL,
    [SubstanceUse]         CHAR (1)      NULL,
    [NoOfYears]            SMALLINT      NULL,
    [Comments]             VARCHAR (100) NULL,
    [StatusCode]           VARCHAR (1)   CONSTRAINT [DF_UserSubstanceAbuse_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT           NOT NULL,
    [CreatedDate]          DATETIME      CONSTRAINT [DF_UserSubstanceAbuse_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT           NULL,
    [LastModifiedDate]     DATETIME      NULL,
    [DataSourceId]         [dbo].[KeyID] NULL,
    CONSTRAINT [PK_UserSubstanceAbuse] PRIMARY KEY CLUSTERED ([UserSubstanceAbuseId] ASC),
    CONSTRAINT [FK_UserSubstanceAbuse_DataSourceId] FOREIGN KEY ([DataSourceId]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_UserSubstanceAbuse_Patient] FOREIGN KEY ([PatientId]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_UserSubstanceAbuse_SubstanceAbuse] FOREIGN KEY ([SubstanceAbuseId]) REFERENCES [dbo].[SubstanceAbuse] ([SubstanceAbuseId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_UserSubstanceAbuse_PatientSubstanceAbuse]
    ON [dbo].[UserSubstanceAbuse]([SubstanceAbuseId] ASC, [PatientId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserSubstanceAbuse', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserSubstanceAbuse', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserSubstanceAbuse', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserSubstanceAbuse', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

