CREATE TABLE [dbo].[LineOfCoverage] (
    [LineOfCoverageId]   SMALLINT                 IDENTITY (1, 1) NOT NULL,
    [LineOfCoverageCode] SMALLINT                 NOT NULL,
    [Description]        [dbo].[ShortDescription] NOT NULL,
    [CreatedByUserId]    [dbo].[KeyID]            NOT NULL,
    [CreatedDate]        [dbo].[UserDate]         CONSTRAINT [DF_LineOfCoverage_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_LineOfCoverage] PRIMARY KEY CLUSTERED ([LineOfCoverageId] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ LineOfCoverage.LineOfCoverageCode]
    ON [dbo].[LineOfCoverage]([LineOfCoverageCode] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LineOfCoverage', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LineOfCoverage', @level2type = N'COLUMN', @level2name = N'CreatedDate';

