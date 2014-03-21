CREATE TABLE [dbo].[ReasonCode] (
    [ReasonCodeID]         [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [ReasonCode]           VARCHAR (4)             NOT NULL,
    [Description]          [dbo].[LongDescription] NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]           NOT NULL,
    [CreatedDate]          [dbo].[UserDate]        CONSTRAINT [DF_ReasonCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]           NULL,
    [LastModifiedDate]     [dbo].[UserDate]        NULL,
    [BeginDate]            DATE                    NULL,
    [EndDate]              DATE                    CONSTRAINT [DF_ReasonCode_EndDate] DEFAULT ('01-01-2100') NULL,
    CONSTRAINT [PK_ReasonCode] PRIMARY KEY CLUSTERED ([ReasonCodeID] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ReasonCode_ReasonCode]
    ON [dbo].[ReasonCode]([ReasonCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReasonCode', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReasonCode', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReasonCode', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReasonCode', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'First Date on which the Procedure Reason code is valid for use., alter the column to not permit NULL values.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReasonCode', @level2type = N'COLUMN', @level2name = N'BeginDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'First Date on which the Drug code is valid for use.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReasonCode', @level2type = N'COLUMN', @level2name = N'BeginDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Last Date on which the Procedure Reason code is valid for use., alter the column to not permit NULL values.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReasonCode', @level2type = N'COLUMN', @level2name = N'EndDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Last Date on which the Drug code is valid for use.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReasonCode', @level2type = N'COLUMN', @level2name = N'EndDate';

