/*      
------------------------------------------------------------------------------      
Procedure Name: [usp_Dashboard_UserProcedureFrequency_InsertUpdate]  
Description   : This Procedure is used to   
Created By    : NagaBabu  
Created Date  : 01-Jun-2012  
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION    
11-17-2012  Aradhana ProgramId is passed as column while inserting 
20-11-2012 Rathnam added ProgramId to the userprocedure table and removed from userprocedurefrequency table
03-March-2012 Rathnam added IF @i_ProgramId = 0 OR @i_ProgramId IS NULL condition for avoiding the FK conflict errors when programid is 0
18-Mar-2013 P.V.P.Mohan changed Table name for userProcedureFrequency to PatientProcedureGroupFrequency,
			UserProcedureCodes to PatientProcedure and Modified PatientID in place of UserID.
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_Dashboard_UserProcedureFrequency_InsertUpdate]
(
 @i_AppUserId KEYID
,@i_UserId KEYID
,@i_CodeGroupingId KEYID
,@v_StatusCode VARCHAR(1)
,@i_FrequencyNumber INT
,@v_Frequency VARCHAR(1)
,@b_NeverSchedule BIT
,@vc_ExclusionReason SHORTDESCRIPTION
,@i_LabTestId KEYID = NULL
,@d_EffectiveStartDate USERDATE
,@d_EffectiveEndDate USERDATE = NULL
,@i_ProgramId INT
)
AS
BEGIN TRY

      SET NOCOUNT ON
      DECLARE @l_numberOfRecordsUpdated INT     
   
 -- Check if valid Application User ID is passed      
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END
      IF @i_ProgramId = 0 OR @i_ProgramId IS NULL
		BEGIN
			SELECT TOP 1
                @i_ProgramId = p.ProgramId  
            FROM  
				Program p WITH(NOLOCK)
			INNER JOIN ProgramCareTeam pct WITH(NOLOCK)
			    ON pct.ProgramId = p.ProgramId
			INNER JOIN CareTeamMembers ctm WITH(NOLOCK)
			    ON ctm.CareTeamId = pct.CareTeamId    	  
            WHERE  
                p.StatusCode = 'A'  
            AND ctm.StatusCode = 'A'
            AND ctm.ProviderID = @i_AppUserId  
        END   
      IF EXISTS ( SELECT
                      1
                  FROM
                      PatientProcedureGroupFrequency
                  WHERE
                      PatientId = @i_UserId
                      AND CodeGroupingId = @i_CodeGroupingId )
         BEGIN
               UPDATE
                   PatientProcedureGroupFrequency
               SET
                   StatusCode = @v_StatusCode
                  ,FrequencyNumber = @i_FrequencyNumber
                  ,Frequency = @v_Frequency
                  ,NeverSchedule = @b_NeverSchedule
                  ,ExclusionReason = @vc_ExclusionReason
                  ,LabTestId = @i_LabTestId
                  ,EffectiveStartDate = @d_EffectiveStartDate
                  ,EffectiveEndDate = @d_EffectiveEndDate
               WHERE
                   PatientId = @i_UserId
                   AND CodeGroupingId = @i_CodeGroupingId
         END
      ELSE

         BEGIN
               INSERT INTO
                   PatientProcedureGroupFrequency
                   (
                     PatientId
                   ,CodeGroupingId
                   ,StatusCode
                   ,FrequencyNumber
                   ,Frequency
                   ,CreatedByUserId
                   ,NeverSchedule
                   ,ExclusionReason
                   ,LabTestId
                   ,EffectiveStartDate
                   ,EffectiveEndDate
                   )
               VALUES
                   (
                     @i_UserId
                   ,@i_CodeGroupingId
                   ,@v_StatusCode
                   ,@i_FrequencyNumber
                   ,@v_Frequency
                   ,@i_AppUserId
                   ,@b_NeverSchedule
                   ,@vc_ExclusionReason
                   ,@i_LabTestId
                   ,@d_EffectiveStartDate
                   ,@d_EffectiveEndDate
                   )
               INSERT INTO
                   PatientProcedureGroup
                   (
                    PatientID
                   ,CodeGroupingID
                   ,Commments
                   ,DueDate
                   ,CreatedByUserId
                   ,StatusCode
                   ,ProgramId
                   )
                   SELECT
                       @i_UserId
                      ,@i_CodeGroupingId
                      ,'Data inserted from Dashboard'
                      ,GETDATE() + ( SELECT
                                         ScheduledDays
                                     FROM
                                         TaskType
                                     WHERE
                                         TaskTypeName = 'Schedule Procedure' )
                      ,@i_AppUserId
                      ,@v_StatusCode
                      ,CASE WHEN @i_ProgramId = 0 THEN NULL ELSE @i_ProgramId END

         END

      RETURN 0
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
    ON OBJECT::[dbo].[usp_Dashboard_UserProcedureFrequency_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

