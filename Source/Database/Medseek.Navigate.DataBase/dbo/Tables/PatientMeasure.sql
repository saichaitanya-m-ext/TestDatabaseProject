CREATE TABLE [dbo].[PatientMeasure] (
    [PatientMeasureID]      [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [PatientID]             [dbo].[KeyID]       NOT NULL,
    [MeasureID]             [dbo].[KeyID]       NULL,
    [MeasureUOMId]          [dbo].[KeyID]       NULL,
    [MeasureValueText]      VARCHAR (510)       NULL,
    [MeasureValueNumeric]   DECIMAL (10, 2)     NULL,
    [Comments]              VARCHAR (MAX)       NULL,
    [DateTaken]             [dbo].[UserDate]    NULL,
    [DueDate]               [dbo].[UserDate]    NULL,
    [LabId]                 [dbo].[KeyID]       NULL,
    [DataSourceFileID]      [dbo].[KeyID]       NULL,
    [StatusCode]            [dbo].[StatusCode]  CONSTRAINT [DF_PatientMeasure_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]       [dbo].[KeyID]       NOT NULL,
    [CreatedDate]           [dbo].[UserDate]    CONSTRAINT [DF_PatientMeasure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]  [dbo].[KeyID]       NULL,
    [LastModifiedDate]      [dbo].[UserDate]    NULL,
    [LOINCCodeID]           INT                 NULL,
    [ProcedureCodeID]       INT                 NULL,
    [IsPatientAdministered] [dbo].[IsIndicator] NULL,
    [DataSourceID]          [dbo].[KeyID]       NULL,
    [RecordTag_FileID]      VARCHAR (30)        NULL,
    CONSTRAINT [PK_UserMeasure] PRIMARY KEY CLUSTERED ([PatientMeasureID] ASC),
    CONSTRAINT [FK_PatientMeasure_CodeSetLOINC] FOREIGN KEY ([LOINCCodeID]) REFERENCES [dbo].[CodeSetLoinc] ([LoincCodeId]),
    CONSTRAINT [FK_PatientMeasure_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_PatientMeasure_Labs] FOREIGN KEY ([LabId]) REFERENCES [dbo].[Labs] ([LabId]),
    CONSTRAINT [FK_PatientMeasure_Measure] FOREIGN KEY ([MeasureID]) REFERENCES [dbo].[Measure] ([MeasureId]),
    CONSTRAINT [FK_PatientMeasure_MeasureUOM] FOREIGN KEY ([MeasureUOMId]) REFERENCES [dbo].[MeasureUOM] ([MeasureUOMId]),
    CONSTRAINT [FK_PatientMeasure_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PatientMeasure_PatientMeasureID]
    ON [dbo].[PatientMeasure]([PatientID] ASC, [StatusCode] ASC, [DateTaken] ASC)
    INCLUDE([PatientMeasureID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_PatientMeasure_DateTaken]
    ON [dbo].[PatientMeasure]([DateTaken] ASC)
    INCLUDE([PatientMeasureID], [PatientID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
/*                        
---------------------------------------------------------------------        
Trigger Name: [dbo].[tr_Insert_UserMeasure]
Description:                       
When   Who    Action                        
---------------------------------------------------------------------        
29/Apr/2010  ADITYA   Created   
20-Aug-2010  Rathnam added Trim functions                     
24-Feb-2011 NagaBabu Added convert funtion to 'INSERTED.MeasureValueNumeric' and Added space before
						'MeasureUOM.UOMText' in first select statement 
10-Mar-2011  RamaChandra added  UserMeasureRange table to insert data for Measeure Range value 
11-Mar-2011 Rathnam added one more MeasureValueText parameter to MeasureRangefunction.          
14-Mar-2011 Included the where clause ( INSERTED.MeasureValueNumeric IS NOT NULL OR INSERTED.MeasureValueText IS NOT NULL) while inserting into usermeasurerange table
01-Jun-2012 NagaBabu removed where clause from the select statement inserting data into UserMeasureRange table
---------------------------------------------------------------------        
*/

CREATE TRIGGER [dbo].[tr_Insert_PatientMeasure] ON dbo.PatientMeasure
       AFTER INSERT
AS
BEGIN
      SET NOCOUNT ON
      IF
      ( SELECT
            COUNT(*)
        FROM
            INSERTED
        WHERE
            DateTaken IS NOT NULL ) > 0
         BEGIN
               INSERT INTO
                   UserTimelineLog
                   (
                     PatientID ,
                     Comments ,
                     TimelineDate ,
                     SubjectText ,
                     TimelineTypeID ,
                     CreatedByUserId
                   )
                   SELECT
                       INSERTED.PatientId ,
                       'Measure: ' + LTRIM(RTRIM(Measure.Name)) + ' was received ' + CASE
																						 WHEN INSERTED.MeasureValueNumeric IS NOT NULL THEN LTRIM(RTRIM(CAST((CONVERT(FLOAT,INSERTED.MeasureValueNumeric)) AS VARCHAR)))
																						 ELSE LTRIM(RTRIM(INSERTED.MeasureValueText))
																					 END + ' ' + LTRIM(RTRIM(MeasureUOM.UOMText)) ,
                       INSERTED.DateTaken ,
                       'Measure: ' + LTRIM(RTRIM(Measure.Name)) + ' was received ' + CASE
																						 WHEN INSERTED.MeasureValueNumeric IS NOT NULL THEN LTRIM(RTRIM(CAST((CONVERT(FLOAT,INSERTED.MeasureValueNumeric)) AS VARCHAR)))
																						 ELSE LTRIM(RTRIM(INSERTED.MeasureValueText))
																					 END + ' ' + LTRIM(RTRIM(MeasureUOM.UOMText)) ,
                       dbo.ReturnTimeLineTypeID('Measures') ,
                       INSERTED.CreatedByUserId
                   FROM
                       INSERTED
                   INNER JOIN MeasureUOM
                       ON MeasureUOM.MeasureUOMId = INSERTED.MeasureUOMId
                   INNER JOIN Measure
                       ON Measure.MeasureId = INSERTED.MeasureId


         END
		 INSERT INTO 
            PatientMeasureRange
            (
				PatientMeasureID,
				ModifiedDate,
				MeasureRange
            )
	     SELECT 
	         INSERTED.PatientMeasureID,
	         INSERTED.CreatedDate,
	         (SELECT dbo.ufn_GetPatientMeasureRange(INSERTED.MeasureId , INSERTED.PatientId , INSERTED.MeasureValueNumeric, INSERTED.MeasureValueText) AS MeasureRange)	
	     FROM INSERTED
	    --WHERE ( INSERTED.MeasureValueNumeric IS NOT NULL OR INSERTED.MeasureValueText IS NOT NULL)
END

GO
DISABLE TRIGGER [dbo].[tr_Insert_PatientMeasure]
    ON [dbo].[PatientMeasure];


GO
/*                      
---------------------------------------------------------------------      
Trigger Name: [dbo].[tr_Update_UserMeasure]                    
Description:                     
When   Who    Action                      
---------------------------------------------------------------------      
28/Apr/2010  Balla Kalyan  Created 
20-Aug-2010 Rathnam Trim Function added.                     
24-Feb-2011 NagaBabu Added convert funtion to 'INSERTED.MeasureValueNumeric' and Added space before
						'MeasureUOM.UOMText' in first select statement    
25-Mar-2011	RamaChandra added UserMeasureRange	table to get the updated data from UserMeasure table
11-Mar-2011 Rathnam added One more parameter to Measure range function.			               
14-Mar-2011 Pramod Included  IF UPDATE(MeasureValueNumeric) OR UPDATE(MeasureValueText) before the update of usermeasurerange
---------------------------------------------------------------------      
*/
CREATE TRIGGER [dbo].[tr_Update_PatientMeasure] ON dbo.PatientMeasure
       FOR UPDATE
AS
BEGIN
      SET NOCOUNT ON
      IF EXISTS ( SELECT
                      1
                  FROM
                      INSERTED
                  INNER JOIN DELETED
                      ON INSERTED.PatientMeasureId = DELETED.PatientMeasureId
                  WHERE
                      DELETED.DateTaken IS NULL
                      AND INSERTED.DateTaken IS NOT NULL )
         BEGIN
               INSERT INTO
                   UserTimelineLog
                   (
                     PatientID ,
                     Comments ,
                     TimelineDate ,
                     SubjectText ,
                     TimelineTypeID ,
                     CreatedByUserId
                   )
                   SELECT
                       INSERTED.PatientId ,
                       'Measure: ' + LTRIM(RTRIM(Measure.Name)) + ' was received ' + CASE
																						 WHEN INSERTED.MeasureValueNumeric IS NOT NULL THEN LTRIM(RTRIM(CAST((CONVERT(FLOAT,INSERTED.MeasureValueNumeric)) AS VARCHAR)))
																						 ELSE LTRIM(RTRIM(INSERTED.MeasureValueText))
																				     END + ' ' + LTRIM(RTRIM(MeasureUOM.UOMText)) ,
                       INSERTED.DateTaken ,
                       'Measure: ' + LTRIM(RTRIM(Measure.Name)) + ' was received ' + CASE
                                                                                         WHEN INSERTED.MeasureValueNumeric IS NOT NULL THEN LTRIM(RTRIM(CAST((CONVERT(FLOAT,INSERTED.MeasureValueNumeric)) AS VARCHAR)))
																						 ELSE LTRIM(RTRIM(INSERTED.MeasureValueText))
                                                                                     END + ' ' + LTRIM(RTRIM(MeasureUOM.UOMText)) ,
                       dbo.ReturnTimeLineTypeID('Measures') ,
                       INSERTED.CreatedByUserId
                   FROM
                       INSERTED
                   INNER JOIN MeasureUOM
                       ON MeasureUOM.MeasureUOMId = INSERTED.MeasureUOMId
                   INNER JOIN Measure
                       ON Measure.MeasureId = INSERTED.MeasureId

         END
         IF UPDATE(MeasureValueNumeric) OR UPDATE(MeasureValueText) 
         BEGIN
			 UPDATE  
				PatientMeasureRange 
			 SET  
				MeasureRange = (SELECT dbo.ufn_GetPatientMeasureRange(INSERTED.MeasureId , INSERTED.PatientID , INSERTED.MeasureValueNumeric, INSERTED.MeasureValueText) AS MeasureRange) 
			   ,ModifiedByUserId = INSERTED.LastModifiedByUserId  
			   ,ModifiedDate = GETDATE() 
			 FROM  
				 PatientMeasureRange  
			 INNER JOIN INSERTED  
				 ON INSERTED.PatientMeasureID = PatientMeasureRange.PatientMeasureID
		END
END

GO
DISABLE TRIGGER [dbo].[tr_Update_PatientMeasure]
    ON [dbo].[PatientMeasure];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A medical measure values for a patient (Weight, height, blood pressure, A1C,…)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the UserMeasure table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'PatientMeasureID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'PatientID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Measure table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'MeasureID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the MeasureUOM table - indicates the unit of measure for the measurement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'MeasureUOMId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Measure Value in text value (normal, abnormal, good, Yes, No , Pass, Fail,…)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'MeasureValueText';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Measure Value in numeric form', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'MeasureValueNumeric';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comments', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'Comments';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the measure was determined', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'DateTaken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The due date for the measure', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'DueDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag indicating if the measure was taken by the patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientMeasure', @level2type = N'COLUMN', @level2name = N'IsPatientAdministered';

