/*        
--------------------------------------------------------------------------------------------------------------        
Procedure Name: [dbo].[usp_AdhocTasksAttempts_Delete]
Description   : This proc is used to Change the status of the deleted tasks
Created By    : Rathnam     
Created Date  : 06-March-2012  
---------------------------------------------------------------------------------------------------------------        
Log History   :         
DD-Mon-YYYY  BY  DESCRIPTION  
19-Mar-2013 P.V.P.Moahn Modified  PatientProgamID to  UserProgramId parameter and 
			Modified table UsersEncounters to PatientEncounters,PatientEncounters to PatientDrugCodes,
			UserProcedure to PatientProcedure,UserCommunication to PatientCommunication
----------------------------------------------------------------------------------------------------------------        
 */
CREATE PROCEDURE [dbo].[usp_AdhocTasksAttempts_Delete]
(
 @i_AppUserId KEYID
,@i_TaskTypeID KEYID 
,@i_TaskGeneralizedID KEYID
)
AS
BEGIN
      BEGIN TRY
            SET NOCOUNT ON        
-- Check if valid Application User ID is passed        
            IF ( @i_AppUserId IS NULL )OR ( @i_AppUserId <= 0 )
               BEGIN
                     RAISERROR ( N'Invalid Application User ID %d passed.'
                     ,17
                     ,1
                     ,@i_AppUserId )
               END

			IF @i_TaskTypeID = 1
               UPDATE
                   PatientGoal
               SET
                   StatusCode = 'I'
                  ,LastModifiedDate = GETDATE()
                  ,LastModifiedByUserId = @i_AppUserId
               WHERE
                   PatientGoalId = @i_TaskGeneralizedID
			ELSE IF @i_TaskTypeID = 2

					UPDATE
						PatientProgram
					SET
						StatusCode = 'I'
					   ,LastModifiedDate = GETDATE()
					   ,LastModifiedByUserId = @i_AppUserId
					WHERE
						PatientProgramID = @i_TaskGeneralizedID
			ELSE IF @i_TaskTypeID IN ( 3,7 )

					UPDATE
						PatientQuestionaire
					SET
						StatusCode = 'I'
					   ,LastModifiedDate = GETDATE()
					   ,LastModifiedByUserId = @i_AppUserId
					WHERE
						PatientQuestionaireId = @i_TaskGeneralizedID
			ELSE IF @i_TaskTypeID = 4

					UPDATE
						PatientEncounters
					SET
						StatusCode = 'I'
					   ,LastModifiedDate = GETDATE()
					   ,LastModifiedByUserId = @i_AppUserId
					WHERE
						PatientEncounterID = @i_TaskGeneralizedID
			ELSE IF @i_TaskTypeID = 5

					UPDATE
						PatientProcedure
					SET
						StatusCode = 'I'
					   ,LastModifiedDate = GETDATE()
					   ,LastModifiedByUserId = @i_AppUserId
					WHERE
						PatientProcedureID = @i_TaskGeneralizedID
			ELSE IF @i_TaskTypeID = 6


					UPDATE
						 PatientImmunizations
					SET
						 StatusCode = 'I'
						,LastModifiedDate = GETDATE()
						,LastModifiedByUserId = @i_AppUserId
					WHERE
						PatientImmunizationID = @i_TaskGeneralizedID
			ELSE  IF @i_TaskTypeID = 8

					UPDATE
						PatientDrugCodes
					SET
						StatusCode = 'I'
					   ,LastModifiedDate = GETDATE()
					   ,LastModifiedByUserId = @i_AppUserId
					WHERE
						PatientDrugId = @i_TaskGeneralizedID
			
			ELSE IF @i_TaskTypeID = 9

					UPDATE
						PatientCommunication
					SET
						StatusCode = 'I'
					   ,LastModifiedDate = GETDATE()
					   ,LastModifiedByUserId = @i_AppUserId
					WHERE
						PatientCommunicationId = @i_TaskGeneralizedID
						
			ELSE IF @i_TaskTypeID IS NULL
					UPDATE
						Task
					SET TaskStatusId = 4, --> Closed Incomplete for Manual Tasks
						LastModifiedByUserId = @i_AppUserId,
						LastModifiedDate = GETDATE()
					WHERE TaskId = @i_TaskGeneralizedID						
      END TRY
      BEGIN CATCH        
----------------------------------------------------------------------------------------------------------       
    -- Handle exception        
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

            RETURN @i_ReturnedErrorID
      END CATCH
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_AdhocTasksAttempts_Delete] TO [FE_rohit.r-ext]
    AS [dbo];

