CREATE TABLE [dbo].[RevenueCode] (
    [RevenueCodeID]        [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [RevenueCode]          VARCHAR (10)            NOT NULL,
    [Description]          [dbo].[LongDescription] NOT NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_RevenueCode_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]           NOT NULL,
    [CreatedDate]          [dbo].[UserDate]        CONSTRAINT [DF_RevenueCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]           NULL,
    [LastModifiedDate]     [dbo].[UserDate]        NULL,
    [BeginDate]            DATE                    CONSTRAINT [DF_RevenueCode_BeginDate] DEFAULT ('01/01/2000') NULL,
    [EndDate]              DATE                    CONSTRAINT [DF_RevenueCode_EndDate] DEFAULT ('01/01/2020') NULL,
    [DataSourceID]         [dbo].[KeyID]           NULL,
    [DataSourceFileID]     [dbo].[KeyID]           NULL,
    CONSTRAINT [PK_RevenueCode] PRIMARY KEY CLUSTERED ([RevenueCodeID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_RevenueCode_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_RevenueCode_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UK_RevenueCode_RevenueCode] UNIQUE NONCLUSTERED ([RevenueCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Transactional_NCX]
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RevenueCode', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RevenueCode', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RevenueCode', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RevenueCode', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

