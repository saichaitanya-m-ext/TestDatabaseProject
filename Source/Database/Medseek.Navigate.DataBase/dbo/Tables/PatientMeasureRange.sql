CREATE TABLE [dbo].[PatientMeasureRange] (
    [PatientMeasureRangeID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [PatientMeasureID]      [dbo].[KeyID]    NOT NULL,
    [MeasureRange]          VARCHAR (10)     NULL,
    [CreatedByUserId]       [dbo].[KeyID]    NULL,
    [CreatedDate]           [dbo].[UserDate] CONSTRAINT [DF_UserMeasureRange_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedByUserID]      [dbo].[KeyID]    NULL,
    [ModifiedDate]          [dbo].[UserDate] NULL,
    CONSTRAINT [PK_UserMeasureRange] PRIMARY KEY CLUSTERED ([PatientMeasureRangeID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientMeasureRange_PatientMeasure] FOREIGN KEY ([PatientMeasureID]) REFERENCES [dbo].[PatientMeasure] ([PatientMeasureID])
);


GO
CREATE NONCLUSTERED INDEX [IX_UserMeasureRange_UserMeasureID]
    ON [dbo].[PatientMeasureRange]([PatientMeasureID] ASC, [PatientMeasureRangeID] ASC)
    INCLUDE([MeasureRange]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasureRange', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasureRange', @level2type = N'COLUMN', @level2name = N'CreatedDate';

