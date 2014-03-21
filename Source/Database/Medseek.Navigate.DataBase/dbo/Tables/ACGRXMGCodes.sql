CREATE TABLE [dbo].[ACGRXMGCodes] (
    [RXMGCodeID]           [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [RXMGCode]             NVARCHAR (10)    NULL,
    [RXMGDescription]      NVARCHAR (100)   NULL,
    [CreatedDate]          [dbo].[UserDate] CONSTRAINT [DF_RXMGCodes_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]    NOT NULL,
    [LastModifiedDate]     [dbo].[UserDate] NULL,
    [LastModifiedByUserID] [dbo].[KeyID]    NULL,
    CONSTRAINT [PK_RXMGCodes] PRIMARY KEY CLUSTERED ([RXMGCodeID] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ACGRXMGCodes.RXMGCode]
    ON [dbo].[ACGRXMGCodes]([RXMGCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGRXMGCodes', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGRXMGCodes', @level2type = N'COLUMN', @level2name = N'CreatedByUserID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGRXMGCodes', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGRXMGCodes', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserID';

