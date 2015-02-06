CREATE TABLE [dbo].[ClaimLineReasonCode] (
    [ClaimLineReasonCodeID] INT              IDENTITY (1, 1) NOT NULL,
    [ClaimLineId]           INT              NOT NULL,
    [ReasonCodeId]          INT              NOT NULL,
    [CreatedByUserId]       [dbo].[KeyID]    NOT NULL,
    [CreatedDate]           [dbo].[UserDate] CONSTRAINT [DF_ClaimLineReasonCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ClaimLineReasonCode] PRIMARY KEY CLUSTERED ([ClaimLineReasonCodeID] ASC),
    CONSTRAINT [FK_ClaimLineReasonCode_ClaimLine] FOREIGN KEY ([ClaimLineId]) REFERENCES [dbo].[ClaimLine] ([ClaimLineID]) ON DELETE CASCADE,
    CONSTRAINT [FK_ClaimLineReasonCode_ReasonCode] FOREIGN KEY ([ReasonCodeId]) REFERENCES [dbo].[ReasonCode] ([ReasonCodeID]) ON DELETE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimLineReasonCode', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClaimLineReasonCode', @level2type = N'COLUMN', @level2name = N'CreatedDate';

