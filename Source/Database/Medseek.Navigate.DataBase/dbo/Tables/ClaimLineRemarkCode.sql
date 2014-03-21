CREATE TABLE [dbo].[ClaimLineRemarkCode] (
    [ClaimLineRemarkCodeID] INT              IDENTITY (1, 1) NOT NULL,
    [ClaimLineId]           INT              NOT NULL,
    [RemarkCodeId]          INT              NOT NULL,
    [CreatedByUserId]       [dbo].[KeyID]    NOT NULL,
    [CreatedDate]           [dbo].[UserDate] CONSTRAINT [DF_ClaimLineRemarkCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ClaimLineRemarkCode] PRIMARY KEY CLUSTERED ([ClaimLineRemarkCodeID] ASC),
    CONSTRAINT [FK_ClaimLineRemarkCode_ClaimLine] FOREIGN KEY ([ClaimLineId]) REFERENCES [dbo].[ClaimLine] ([ClaimLineID]) ON DELETE CASCADE,
    CONSTRAINT [FK_ClaimLineRemarkCode_RemarkCode] FOREIGN KEY ([RemarkCodeId]) REFERENCES [dbo].[RemarkCode] ([RemarkCodeID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ClaimLineRemarkCode_ClaimLineId]
    ON [dbo].[ClaimLineRemarkCode]([ClaimLineId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ClaimLineRemarkCode_RemarkCodeID]
    ON [dbo].[ClaimLineRemarkCode]([RemarkCodeId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'The "Primary Key" of the table in the database; the column uniquely identifies the record in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimLineRemarkCode', @level2type = N'COLUMN', @level2name = N'ClaimLineRemarkCodeID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "ClaimLine" table (column ''ClaimLineId'').', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimLineRemarkCode', @level2type = N'COLUMN', @level2name = N'ClaimLineId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimLineRemarkCode', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimLineRemarkCode', @level2type = N'COLUMN', @level2name = N'CreatedDate';

