CREATE TABLE [dbo].[LabMeasure] (
    [LabMeasureId]                  [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
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
    [CreatedDate]                   [dbo].[UserDate]    CONSTRAINT [DF_LabMeasure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]          [dbo].[KeyID]       NULL,
    [LastModifiedDate]              [dbo].[UserDate]    NULL,
    [StartDate]                     [dbo].[UserDate]    NULL,
    [EndDate]                       [dbo].[UserDate]    NULL,
    [ReminderDaysBeforeEnddate]     INT                 NULL,
    CONSTRAINT [PK_LabMeasure] PRIMARY KEY CLUSTERED ([LabMeasureId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_LabMeasure_Measure] FOREIGN KEY ([MeasureId]) REFERENCES [dbo].[Measure] ([MeasureId]),
    CONSTRAINT [FK_LabMeasure_MeasureUOM] FOREIGN KEY ([MeasureUOMId]) REFERENCES [dbo].[MeasureUOM] ([MeasureUOMId]),
    CONSTRAINT [FK_LabMeasure_Program] FOREIGN KEY ([ProgramId]) REFERENCES [dbo].[Program] ([ProgramId])
);


GO
CREATE NONCLUSTERED INDEX [IX_LabMeasure_CoveringIndex]
    ON [dbo].[LabMeasure]([MeasureId] ASC, [PatientUserID] ASC, [ProgramId] ASC)
    INCLUDE([Operator1forGoodControl], [Operator1Value1forGoodControl], [Operator1Value2forGoodControl], [Operator2forGoodControl], [Operator2Value1forGoodControl], [Operator2Value2forGoodControl], [Operator1forFairControl], [Operator1Value1forFairControl], [Operator1Value2forFairControl], [Operator2forFairControl], [Operator2Value1forFairControl], [Operator2Value2forFairControl], [Operator1forPoorControl], [Operator1Value1forPoorControl], [Operator1Value2forPoorControl], [Operator2forPoorControl], [Operator2Value1forPoorControl], [Operator2Value2forPoorControl]) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_MeasureIdPatientUserIdProgramId]
    ON [dbo].[LabMeasure]([MeasureId] ASC, [PatientUserID] ASC, [ProgramId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
/*                 
---------------------------------------------------------------------      
Trigger Name: [dbo].[tr_Update_	LabMeasure]                    
Description:                     
When   Who    Action                      
---------------------------------------------------------------------      
10-Mar-2011 Ramachandra  Created  
11-Mar-2011 RamaChandra added one more MeasureValueText parameter to MeasureRange Function   
08-Sep-2011 Rathnam added [LabMeasureHistory] insert condition
20-Sep-2011 NagaBabu Added Where clause and added CASE statement for EndDate field for insertind data into 
						[LabMeasureHistory] table 
---------------------------------------------------------------------      
*/
CREATE TRIGGER [dbo].[tr_Update_LabMeasure] ON [dbo].[LabMeasure]
       AFTER UPDATE
AS
BEGIN
		SET NOCOUNT ON
		IF UPDATE(Operator1forGoodControl) OR UPDATE(Operator1Value1forGoodControl)OR UPDATE(Operator1Value2forGoodControl) OR UPDATE(Operator2forGoodControl)OR UPDATE(Operator2Value1forGoodControl)OR UPDATE(Operator2Value2forGoodControl)OR UPDATE(TextValueForGoodControl)
		OR UPDATE(Operator1forFairControl) OR UPDATE(Operator1Value1forFairControl)OR UPDATE(Operator1Value2forFairControl) OR UPDATE(Operator2forFairControl)OR UPDATE(Operator2Value1forFairControl)OR UPDATE(Operator2Value2forFairControl)OR UPDATE(TextValueForFairControl)
		OR UPDATE(Operator1forPoorControl) OR UPDATE(Operator1Value1forPoorControl)OR UPDATE(Operator1Value2forPoorControl) OR UPDATE(Operator2forPoorControl)OR UPDATE(Operator2Value1forPoorControl)OR UPDATE(Operator2Value2forPoorControl)OR UPDATE(TextValueForPoorControl)
		
		BEGIN
			UPDATE  
				PatientUserMeasureRange 
			SET  
				 MeasureRange =  (SELECT dbo.ufn_GetPatientMeasureRange(INSERTED.MeasureId , INSERTED.PatientUserId , PatientMeasure.MeasureValueNumeric,PatientMeasure.MeasureValueText) AS MeasureRange) 
				,ModifiedByUserId = INSERTED.LastModifiedByUserId  
				,ModifiedDate = GETDATE() 
			FROM  
				PatientUserMeasureRange  
			 INNER JOIN PatientMeasure
				 ON  PatientUserMeasureRange.PatientMeasureRangeID = PatientMeasure.PatientMeasureID
			 INNER JOIN INSERTED  
				 ON INSERTED.MeasureId =  PatientMeasure.MeasureID  
		END
		IF UPDATE(Operator1forGoodControl) OR UPDATE(Operator1Value1forGoodControl)OR UPDATE(Operator1Value2forGoodControl) OR UPDATE(Operator2forGoodControl)OR UPDATE(Operator2Value1forGoodControl)OR UPDATE(Operator2Value2forGoodControl)OR UPDATE(TextValueForGoodControl)
		OR UPDATE(Operator1forFairControl) OR UPDATE(Operator1Value1forFairControl)OR UPDATE(Operator1Value2forFairControl) OR UPDATE(Operator2forFairControl)OR UPDATE(Operator2Value1forFairControl)OR UPDATE(Operator2Value2forFairControl)OR UPDATE(TextValueForFairControl)
		OR UPDATE(Operator1forPoorControl) OR UPDATE(Operator1Value1forPoorControl)OR UPDATE(Operator1Value2forPoorControl) OR UPDATE(Operator2forPoorControl)OR UPDATE(Operator2Value1forPoorControl)OR UPDATE(Operator2Value2forPoorControl)OR UPDATE(TextValueForPoorControl)
		OR UPDATE(EndDate)
			BEGIN
				INSERT INTO [LabMeasureHistory]
					   ([LabMeasureId]
					   ,[MeasureId]
					   ,[IsGoodControl]
					   ,[Operator1forGoodControl]
					   ,[Operator1Value1forGoodControl]
					   ,[Operator1Value2forGoodControl]
					   ,[Operator2forGoodControl]
					   ,[Operator2Value1forGoodControl]
					   ,[Operator2Value2forGoodControl]
					   ,[TextValueForGoodControl]
					   ,[IsFairControl]
					   ,[Operator1forFairControl]
					   ,[Operator1Value1forFairControl]
					   ,[Operator1Value2forFairControl]
					   ,[Operator2forFairControl]
					   ,[Operator2Value1forFairControl]
					   ,[Operator2Value2forFairControl]
					   ,[TextValueForFairControl]
					   ,[IsPoorControl]
					   ,[Operator1forPoorControl]
					   ,[Operator1Value1forPoorControl]
					   ,[Operator1Value2forPoorControl]
					   ,[Operator2forPoorControl]
					   ,[Operator2Value1forPoorControl]
					   ,[Operator2Value2forPoorControl]
					   ,[TextValueForPoorControl]
					   ,[MeasureUOMId]
					   ,[ProgramId]
					   ,[PatientUserID]
					   ,[CreatedByUserId]
					   ,[CreatedDate]
					   ,[StartDate]
					   ,[EndDate]
					   ,[ReminderDaysBeforeEnddate])
				 SELECT DELETED.[LabMeasureId]
						,DELETED.[MeasureId]
						,DELETED.[IsGoodControl]
						,DELETED.[Operator1forGoodControl]
						,DELETED.[Operator1Value1forGoodControl]
						,DELETED.[Operator1Value2forGoodControl]
						,DELETED.[Operator2forGoodControl]
						,DELETED.[Operator2Value1forGoodControl]
						,DELETED.[Operator2Value2forGoodControl]
						,DELETED.[TextValueForGoodControl]
						,DELETED.[IsFairControl]
						,DELETED.[Operator1forFairControl]
						,DELETED.[Operator1Value1forFairControl]
						,DELETED.[Operator1Value2forFairControl]
						,DELETED.[Operator2forFairControl]
						,DELETED.[Operator2Value1forFairControl]
						,DELETED.[Operator2Value2forFairControl]
						,DELETED.[TextValueForFairControl]
						,DELETED.[IsPoorControl]
						,DELETED.[Operator1forPoorControl]
						,DELETED.[Operator1Value1forPoorControl]
						,DELETED.[Operator1Value2forPoorControl]
						,DELETED.[Operator2forPoorControl]
						,DELETED.[Operator2Value1forPoorControl]
						,DELETED.[Operator2Value2forPoorControl]
						,DELETED.[TextValueForPoorControl]
						,DELETED.[MeasureUOMId]
						,DELETED.[ProgramId]
						,DELETED.[PatientUserID]
						,INSERTED.[LastModifiedByUserId]
						,GETDATE()
						,DELETED.[StartDate]
						,CASE WHEN INSERTED.EndDate < DELETED.EndDate THEN INSERTED.EndDate
							  ELSE DELETED.[EndDate]
						 END	  
						,DELETED.[ReminderDaysBeforeEnddate]
					 FROM 
						DELETED
					 INNER JOIN INSERTED
						ON DELETED.LabMeasureId = INSERTED.LabMeasureId 
					 WHERE  DELETED.EndDate <> INSERTED.EndDate
						OR  DELETED.Operator1forGoodControl <> INSERTED.Operator1forGoodControl
						OR	DELETED.Operator1Value1forGoodControl <> INSERTED.Operator1Value1forGoodControl
						OR	DELETED.Operator1Value2forGoodControl <> INSERTED.Operator1Value2forGoodControl
						OR	DELETED.Operator2forGoodControl <> INSERTED.Operator2forGoodControl
						OR	DELETED.Operator2Value1forGoodControl <> INSERTED.Operator2Value1forGoodControl
						OR	DELETED.Operator2Value2forGoodControl <> INSERTED.Operator2Value2forGoodControl
						OR	DELETED.TextValueForGoodControl <> INSERTED.TextValueForGoodControl
						OR	DELETED.Operator1forFairControl <> INSERTED.Operator1forFairControl
						OR	DELETED.Operator1Value1forFairControl <> INSERTED.Operator1Value1forFairControl
						OR	DELETED.Operator1Value2forFairControl <> INSERTED.Operator1Value2forFairControl
						OR	DELETED.Operator2forFairControl <> INSERTED.Operator2forFairControl
						OR	DELETED.Operator2Value1forFairControl <> INSERTED.Operator2Value1forFairControl
						OR	DELETED.Operator2Value2forFairControl <> INSERTED.Operator2Value2forFairControl
						OR	DELETED.TextValueForFairControl <>  INSERTED.TextValueForFairControl
						OR	DELETED.Operator1forPoorControl <> INSERTED.Operator1forPoorControl
						OR	DELETED.Operator1Value1forPoorControl <> INSERTED.Operator1Value1forPoorControl
						OR	DELETED.Operator1Value2forPoorControl <> INSERTED.Operator1Value2forPoorControl
						OR	DELETED.Operator2forPoorControl <> INSERTED.Operator2forPoorControl
						OR	DELETED.Operator2Value1forPoorControl <> INSERTED.Operator2Value1forPoorControl
						OR	DELETED.Operator2Value2forPoorControl <> INSERTED.Operator2Value2forPoorControl
						OR	DELETED.TextValueForPoorControl <> INSERTED.TextValueForPoorControl
					 	
			END
END



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'LabMeasure hold the measure goals for the Organization, program and specific patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the Labmeasure table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'LabMeasureId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Measure table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'MeasureId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a good control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator1forGoodControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a good control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator1Value1forGoodControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a good control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator1Value2forGoodControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a good control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator2forGoodControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a good control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator2Value1forGoodControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a good control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator2Value2forGoodControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sometime the measure is defined in a text value (normal, abnormal, good, bad, pass, fail,…)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'TextValueForGoodControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a fair control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator1forFairControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a fair control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator1Value1forFairControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a fair control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator1Value2forFairControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a fair control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator2forFairControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a fair control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator2Value1forFairControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a fair control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator2Value2forFairControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sometime the measure is defined in a text value (normal, abnormal, good, bad, pass, fail,…)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'TextValueForFairControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a poor control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator1forPoorControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a poor control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator1Value1forPoorControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a poor control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator1Value2forPoorControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a poor control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator2forPoorControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a poor control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator2Value1forPoorControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator use to define the domain for a poor control (>, < , = , =<…) operators are stores in the operator table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'Operator2Value2forPoorControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sometime the measure is defined in a text value (normal, abnormal, good, bad, pass, fail,…)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'TextValueForPoorControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the measure UOM table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'MeasureUOMId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Program Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'ProgramId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'PatientUserID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LabMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

