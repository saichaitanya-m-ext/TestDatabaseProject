CREATE TABLE [dbo].[CoverageTier] (
    [CoverageTierId]   [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [CoverageTierCode] VARCHAR (2)              NOT NULL,
    [Description]      [dbo].[ShortDescription] NOT NULL,
    [StatusCode]       [dbo].[StatusCode]       CONSTRAINT [DF_CoverageTier_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]  [dbo].[KeyID]            NOT NULL,
    [CreatedDate]      [dbo].[UserDate]         CONSTRAINT [DF_CoverageTier_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_CoverageTier] PRIMARY KEY CLUSTERED ([CoverageTierId] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_CoverageTierCode_DisabilityType]
    ON [dbo].[CoverageTier]([CoverageTierCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoverageTier', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoverageTier', @level2type = N'COLUMN', @level2name = N'CreatedDate';

