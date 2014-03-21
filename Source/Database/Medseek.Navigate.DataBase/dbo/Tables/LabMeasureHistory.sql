CREATE TABLE [dbo].[LabMeasureHistory] (
    [LabMeasureHistoryId]           [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [LabMeasureId]                  [dbo].[KeyID]       NOT NULL,
    [MeasureId]                     [dbo].[KeyID]       NOT NULL,
    [IsGoodControl]                 [dbo].[IsIndicator] NOT NULL,
    [Operator1forGoodControl]       VARCHAR (20)        NULL,
    [Operator1Value1forGoodControl] DECIMAL (12, 2)     NULL,
    [Operator1Value2forGoodControl] DECIMAL (12, 2)     NULL,
    [Operator2forGoodControl]       VARCHAR (20)        NULL,
    [Operator2Value1forGoodControl] DECIMAL (12, 2)     NULL,
    [Operator2Value2forGoodControl] DECIMAL (12, 2)     NULL,
    [TextValueForGoodControl]       [dbo].[SourceName]  NULL,
    [IsFairControl]                 [dbo].[IsIndicator] NOT NULL,
    [Operator1forFairControl]       VARCHAR (20)        NULL,
    [Operator1Value1forFairControl] DECIMAL (12, 2)     NULL,
    [Operator1Value2forFairControl] DECIMAL (12, 2)     NULL,
    [Operator2forFairControl]       VARCHAR (20)        NULL,
    [Operator2Value1forFairControl] DECIMAL (12, 2)     NULL,
    [Operator2Value2forFairControl] DECIMAL (12, 2)     NULL,
    [TextValueForFairControl]       [dbo].[SourceName]  NULL,
    [IsPoorControl]                 [dbo].[IsIndicator] NOT NULL,
    [Operator1forPoorControl]       VARCHAR (20)        NULL,
    [Operator1Value1forPoorControl] DECIMAL (12, 2)     NULL,
    [Operator1Value2forPoorControl] DECIMAL (12, 2)     NULL,
    [Operator2forPoorControl]       VARCHAR (20)        NULL,
    [Operator2Value1forPoorControl] DECIMAL (12, 2)     NULL,
    [Operator2Value2forPoorControl] DECIMAL (12, 2)     NULL,
    [TextValueForPoorControl]       [dbo].[SourceName]  NULL,
    [MeasureUOMId]                  [dbo].[KeyID]       NULL,
    [ProgramId]                     [dbo].[KeyID]       NULL,
    [PatientUserID]                 [dbo].[KeyID]       NULL,
    [CreatedByUserId]               [dbo].[KeyID]       NOT NULL,
    [CreatedDate]                   [dbo].[UserDate]    CONSTRAINT [DF_LabMeasureHistory_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]          [dbo].[KeyID]       NULL,
    [LastModifiedDate]              [dbo].[UserDate]    NULL,
    [StartDate]                     [dbo].[UserDate]    NULL,
    [EndDate]                       [dbo].[UserDate]    NULL,
    [ReminderDaysBeforeEnddate]     INT                 NULL,
    CONSTRAINT [PK_LabMeasureHistory_1] PRIMARY KEY CLUSTERED ([LabMeasureHistoryId] ASC),
    CONSTRAINT [FK_LabMeasureHistory_LabMeasure] FOREIGN KEY ([LabMeasureId]) REFERENCES [dbo].[LabMeasure] ([LabMeasureId]),
    CONSTRAINT [FK_LabMeasureHistory_Measure] FOREIGN KEY ([MeasureId]) REFERENCES [dbo].[Measure] ([MeasureId]),
    CONSTRAINT [FK_LabMeasureHistory_MeasureUOM] FOREIGN KEY ([MeasureUOMId]) REFERENCES [dbo].[MeasureUOM] ([MeasureUOMId]),
    CONSTRAINT [FK_LabMeasureHistory_Program] FOREIGN KEY ([ProgramId]) REFERENCES [dbo].[Program] ([ProgramId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasureHistory', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasureHistory', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasureHistory', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasureHistory', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

