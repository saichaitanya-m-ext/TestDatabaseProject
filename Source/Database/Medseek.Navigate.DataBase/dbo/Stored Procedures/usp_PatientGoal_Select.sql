/*            
------------------------------------------------------------------------------            
Procedure Name: usp_PatientGoal_Select  23,null,null,'A',144145
Description   : This procedure is used to get the list of details from PatientGoal        
    table        
Created By    : Aditya            
Created Date  : 29-Apr-2010            
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION            
16-June-2010 NagaBabu Added PatientUserID perameter And replaced INNER JOIN with LEFT OUTER JOIN
08-Oct-2010  Rathnam  Added @i_PatientGoalProgressLogId parameter and Pickup the PatientGoalId  based on PatientGoalProgressLogId           
28-Feb-2012 NagaBabu Added LifeStyleGoal,GoalCompletedDate,GoalStatus To the select grid while this fields are newly added to this table 
29-Feb-2012 NagaBabu Added 'AND PatientGoal.Isadhoc = 1' in where clause 
07-Mar-2012	Gurumoorthy Added Attempts column in select Statement and join the AdhocTaskSchduledAttempts table in join clause
21-Jun-2012 Nagababu Added order by clause for getting latest followupdate
14-Nov-2012 P.V.P.MOhan Added Parameter   @i_AssignedCareProviderId in PatientGoal table
10-Jan-2013 Praveen Added Programid as onemore column
25-Mar-2013 P.V.P.MOhan Modified PatientID in place of UserID for PatientGoal table
------------------------------------------------------------------------------            
*/
CREATE PROCEDURE [dbo].[usp_PatientGoal_Select]--1,null,null,null,23

(
 @i_AppUserId KEYID
,@i_PatientGoalProgressLogId KEYID = NULL
,@i_PatientGoalId KEYID = NULL
,@v_StatusCode STATUSCODE = NULL
,@i_PatientUserID KEYID = NUL
)
AS
BEGIN TRY
      SET NOCOUNT ON             
 -- Check if valid Application User ID is passed            
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END

      SELECT DISTINCT
          ISNULL(( SELECT
                       PatientGoalprogresslog.PatientGoalId
                   FROM
                       PatientGoalprogresslog
                   WHERE
                       PatientGoalprogresslogId = @i_PatientGoalProgressLogId
                 ) , '') AS SelectedPatientGoalId
         ,PatientGoal.PatientGoalId
         ,PatientGoal.PatientId UserId
         ,PatientGoal.Description
         ,SUBSTRING(PatientGoal.Description , 0 , 50) AS ShortDescription
         ,CASE PatientGoal.DurationUnits
            WHEN 'D' THEN 'Days'
            WHEN 'W' THEN 'Weeks'
            WHEN 'M' THEN 'Months'
            WHEN 'Q' THEN 'Quarters'
            WHEN 'Y' THEN 'Years'
            ELSE ''
          END DurationUnits
         ,PatientGoal.DurationTimeline
         ,CASE PatientGoal.DurationUnits
            WHEN 'D' THEN CAST(PatientGoal.DurationTimeline AS VARCHAR) + '' + ' Days'
            WHEN 'W' THEN CAST(PatientGoal.DurationTimeline AS VARCHAR) + '' + ' Weeks'
            WHEN 'M' THEN CAST(PatientGoal.DurationTimeline AS VARCHAR) + '' + ' Months'
            WHEN 'Q' THEN CAST(PatientGoal.DurationTimeline AS VARCHAR) + '' + ' Quarters'
            WHEN 'Y' THEN CAST(PatientGoal.DurationTimeline AS VARCHAR) + '' + ' Years'
            ELSE ''
          END Duration
         ,CASE PatientGoal.ContactFrequencyUnits
            WHEN 'D' THEN 'Days'
            WHEN 'W' THEN 'Weeks'
            WHEN 'M' THEN 'Months'
            WHEN 'Q' THEN 'Quarters'
            WHEN 'Y' THEN 'Years'
            ELSE ''
          END ContactFrequencyUnits
         ,PatientGoal.ContactFrequency
         ,CASE PatientGoal.ContactFrequencyUnits
            WHEN 'D' THEN CAST(PatientGoal.ContactFrequency AS VARCHAR) + '' + ' Days'
            WHEN 'W' THEN CAST(PatientGoal.ContactFrequency AS VARCHAR) + '' + ' Weeks'
            WHEN 'M' THEN CAST(PatientGoal.ContactFrequency AS VARCHAR) + '' + ' Months'
            WHEN 'Q' THEN CAST(PatientGoal.ContactFrequency AS VARCHAR) + '' + ' Quarters'
            WHEN 'Y' THEN CAST(PatientGoal.ContactFrequency AS VARCHAR) + '' + ' Years'
            ELSE ''
          END ContactFrequencyDuration
         --,PatientGoal.CommunicationTypeId
         --,CommunicationType.CommunicationType AS CommunicationTypeName
         --,PatientGoal.CancellationReason
         ,PatientGoal.Comments
         ,CASE PatientGoal.StatusCode
            WHEN 'A' THEN 'Active'
            WHEN 'I' THEN 'InActive'
          END AS StatusDescription
         ,PatientGoal.StartDate
         ,PatientGoal.LifeStyleGoalId
         ,LifeStyleGoals.LifeStyleGoal
         ,PatientGoal.GoalCompletedDate
         ,PatientGoal.ProgramId
         ,CASE PatientGoal.GoalStatus
            WHEN 'C' THEN 'Complete'
            WHEN 'D' THEN 'Discontinue'
            WHEN 'I' THEN 'In-progress'
          END AS GoalStatus
         ,PatientGoal.CreatedByUserId
         ,PatientGoal.CreatedDate
         ,PatientGoal.LastModifiedByUserId
         ,PatientGoal.LastModifiedDate
         ,Dbo.ufn_GetUserNameByID(PatientGoal.AssignedCareProviderId) AS AssignedTo
         ,( SELECT TOP 1
                PatientGoalprogresslog.FollowUpDate
            FROM
                PatientGoalprogresslog
            WHERE
                PatientGoalId = PatientGoal.PatientGoalId
            ORDER BY
                PatientGoalProgressLogId DESC
          ) AS FollowUpDate
          ,PatientGoal.ProgramId
          ,PatientGoal.AssignedCareProviderId
      FROM
          PatientGoal WITH(NOLOCK)
     INNER JOIN LifeStyleGoals WITH(NOLOCK)
          ON LifeStyleGoals.LifeStyleGoalId = PatientGoal.LifeStyleGoalId
      WHERE
          ( PatientGoal.PatientGoalId = @i_PatientGoalId
          OR @i_PatientGoalId IS NULL
          )
          AND ( @v_StatusCode IS NULL
                OR PatientGoal.StatusCode = @v_StatusCode
              )
          AND ( PatientGoal.PatientId = @i_PatientUserID
                OR @i_PatientUserID IS NULL
              )
      ORDER BY
          PatientGoal.StartDate DESC
END TRY            
--------------------------------------------------------             
BEGIN CATCH            
    -- Handle exception            
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH 





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PatientGoal_Select] TO [FE_rohit.r-ext]
    AS [dbo];

