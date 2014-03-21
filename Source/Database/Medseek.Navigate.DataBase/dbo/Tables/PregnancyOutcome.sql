CREATE TABLE [dbo].[PregnancyOutcome] (
    [PregnancyOutcomeId] INT           IDENTITY (1, 1) NOT NULL,
    [PregnancyOutcome]   VARCHAR (100) NOT NULL,
    [CreatedDate]        DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedByUserId]    [dbo].[KeyID] NOT NULL,
    [ModifiedDate]       DATETIME      NULL,
    [ModifiedByUserId]   [dbo].[KeyID] NULL,
    CONSTRAINT [PK_PregnancyOutcome] PRIMARY KEY CLUSTERED ([PregnancyOutcomeId] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_PregnancyOutcome.PregnancyOutcome]
    ON [dbo].[PregnancyOutcome]([PregnancyOutcome] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PregnancyOutcome', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PregnancyOutcome', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';

