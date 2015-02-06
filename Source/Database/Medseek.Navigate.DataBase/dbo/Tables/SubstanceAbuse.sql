CREATE TABLE [dbo].[SubstanceAbuse] (
    [SubstanceAbuseId]     INT          IDENTITY (1, 1) NOT NULL,
    [Name]                 VARCHAR (50) NOT NULL,
    [StatusCode]           VARCHAR (1)  CONSTRAINT [DF_SubstanceAbuse_Statuscode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT          NOT NULL,
    [CreatedDate]          DATETIME     CONSTRAINT [DF_SubstanceAbuse_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT          NULL,
    [LastModifiedDate]     DATETIME     NULL,
    CONSTRAINT [PK_SubstanceAbuse] PRIMARY KEY CLUSTERED ([SubstanceAbuseId] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_SubstanceAbuse]
    ON [dbo].[SubstanceAbuse]([Name] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SubstanceAbuse', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SubstanceAbuse', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SubstanceAbuse', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

