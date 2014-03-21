CREATE TABLE [dbo].[PatientDrugReactions] (
    [PatientDrugReactionId]     [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [PatientID]                 [dbo].[KeyID]            NOT NULL,
    [DrugCodeId]                [dbo].[KeyID]            NOT NULL,
    [Reaction]                  [dbo].[ShortDescription] NULL,
    [Severity]                  CHAR (1)                 NULL,
    [Commments]                 [dbo].[LongDescription]  NULL,
    [StatusCode]                [dbo].[StatusCode]       CONSTRAINT [DF_PatientDrugReactions_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]           [dbo].[KeyID]            NOT NULL,
    [CreatedDate]               [dbo].[UserDate]         CONSTRAINT [DF_PatientDrugReactions_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]      [dbo].[KeyID]            NULL,
    [LastModifiedDate]          [dbo].[UserDate]         NULL,
    [DrugReactionReportingDate] DATE                     NULL,
    [DataSourceId]              [dbo].[KeyID]            NULL,
    CONSTRAINT [PK_PatientDrugReactions] PRIMARY KEY CLUSTERED ([PatientDrugReactionId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientDrugReactions_DataSourceId] FOREIGN KEY ([DataSourceId]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientDrugReactions_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO

 /*                      
---------------------------------------------------------------------      
Trigger Name: [dbo].[tr_Insert_UserDrugReactions] 
Description:                     
When   Who    Action                      
---------------------------------------------------------------------      
29/Apr/2010  ADITYA   Created 
20-Aug-2010 Rathnam Trim Functions added.                     
24-Feb-2010 NagaBabu Added case statement to 'INSERTED.Severity' field               
---------------------------------------------------------------------      
*/
CREATE TRIGGER [dbo].[tr_Insert_UserDrugReactions] ON [dbo].[PatientDrugReactions]
       AFTER INSERT
AS
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
              INSERTED.PatientID ,
              'Patient had a  ' + CASE WHEN INSERTED.Severity = 'M' THEN 'Mild' WHEN INSERTED.Severity = 'S' THEN 'Severe ' END + ' reaction to Drug: ' + LTRIM(RTRIM(CodeSetDrug.Drugname)) ,
              INSERTED.DrugReactionReportingDate ,
              'Patient had a  ' + CASE WHEN INSERTED.Severity = 'M' THEN 'Mild' WHEN INSERTED.Severity = 'S' THEN 'Severe ' END + ' reaction to Drug: ' + LTRIM(RTRIM(CodeSetDrug.Drugname)) + ' Details: ' + LTRIM(RTRIM(INSERTED.Commments)) ,
              dbo.ReturnTimeLineTypeID('Drugs') ,
              INSERTED.CreatedByUserId
          FROM
              INSERTED
          INNER JOIN CodeSetDrug
              ON CodeSetDrug.DrugCodeId = INSERTED.DrugCodeId

END



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Durg reactions suffered by patients when they take specific medications cross reference between patients and drugs.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the UserDrugReactions table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions', @level2type = N'COLUMN', @level2name = N'PatientDrugReactionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table - identifies the patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions', @level2type = N'COLUMN', @level2name = N'PatientID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the CodeSetDrugs table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions', @level2type = N'COLUMN', @level2name = N'DrugCodeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Free Form text to describe the reaction', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions', @level2type = N'COLUMN', @level2name = N'Reaction';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'M = mild , S = Severe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions', @level2type = N'COLUMN', @level2name = N'Severity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comments', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions', @level2type = N'COLUMN', @level2name = N'Commments';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the reaction was reported or occurred', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientDrugReactions', @level2type = N'COLUMN', @level2name = N'DrugReactionReportingDate';

