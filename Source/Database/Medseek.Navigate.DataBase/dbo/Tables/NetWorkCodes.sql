CREATE TABLE [dbo].[NetWorkCodes] (
    [NetworkCodeId]        [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [NetworkCode]          VARCHAR (20)             NOT NULL,
    [Description]          [dbo].[ShortDescription] NULL,
    [HealthPlan]           VARCHAR (10)             NULL,
    [IPAName]              [dbo].[ShortDescription] NULL,
    [IPAAccronym]          VARCHAR (10)             NULL,
    [IPANumber]            VARCHAR (20)             NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_NetWorkCodes_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          DATETIME                 CONSTRAINT [DF_NetWorkCodes_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByuserId] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_NetWorkCodes] PRIMARY KEY CLUSTERED ([NetworkCodeId] ASC) ON [FG_Library],
    CONSTRAINT [IX_ProviderNetWorkType_ProviderNetWorkCode] UNIQUE NONCLUSTERED ([NetworkCodeId] ASC) WITH (FILLFACTOR = 100) ON [FG_Library_NCX]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_NetWorkCodes.NetworkCode]
    ON [dbo].[NetWorkCodes]([NetworkCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NetWorkCodes', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NetWorkCodes', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NetWorkCodes', @level2type = N'COLUMN', @level2name = N'LastModifiedByuserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NetWorkCodes', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

