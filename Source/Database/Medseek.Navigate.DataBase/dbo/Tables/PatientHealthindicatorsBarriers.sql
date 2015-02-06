CREATE TABLE [dbo].[PatientHealthindicatorsBarriers] (
    [PatientID]                     [dbo].[KeyID]      NOT NULL,
    [HealthIndicatorsAndBarriersId] [dbo].[KeyID]      NOT NULL,
    [StatusCode]                    [dbo].[StatusCode] CONSTRAINT [DF_PatientHealthindicatorsBarriers_Status] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]               [dbo].[KeyID]      NOT NULL,
    [CreatedDate]                   [dbo].[UserDate]   CONSTRAINT [DF_PatientHealthindicatorsBarriers_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]          [dbo].[KeyID]      NULL,
    [LastModifiedDate]              [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_PatientHealthindicatorsBarriers] PRIMARY KEY CLUSTERED ([PatientID] ASC, [HealthIndicatorsAndBarriersId] ASC),
    CONSTRAINT [FK_PatientHealthindicatorsBarriers_HealthIndicatorsAndBarriers] FOREIGN KEY ([HealthIndicatorsAndBarriersId]) REFERENCES [dbo].[HealthIndicatorsAndBarriers] ([HealthIndicatorsAndBarriersId]),
    CONSTRAINT [FK_PatientHealthindicatorsBarriers_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthindicatorsBarriers', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthindicatorsBarriers', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthindicatorsBarriers', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientHealthindicatorsBarriers', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

