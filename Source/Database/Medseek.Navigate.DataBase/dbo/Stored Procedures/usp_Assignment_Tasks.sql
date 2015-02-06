
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Assignment_Tasks 1,248
Description   : This procedure is used to get the tasks from the program  
Created By    : Rathnam  
Created Date  : 01-Oct-2012  
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Assignment_Tasks] (
	@i_AppUserId KEYID
	,@i_ProgramID KEYID
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	-- Check if valid Application User ID is passed  
	IF (@i_AppUserId IS NULL)
		OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR (
				N'Invalid Application User ID %d passed.'
				,17
				,1
				,@i_AppUserId
				)
	END

	SELECT ProgramTaskBundleID
		,TaskType
		,GeneralizedID
		,dbo.ufn_Program_GetTypeNamesByGeneralizedId(TaskType, GeneralizedID) TaskName
		,CASE 
			WHEN StatusCode = 'A'
				THEN 'Active'
			WHEN StatusCode = 'I'
				THEN 'InActive'
			END AS StatusCode
		,CASE 
			WHEN TaskType = 'E'
				THEN STUFF((
							SELECT DISTINCT ', ' + l.NAME
							FROM Library l
							INNER JOIN EducationMaterialLibrary eml ON eml.LibraryId = l.LibraryId
							WHERE eml.EducationMaterialID = ProgramTaskBundle.GeneralizedID
								AND ProgramTaskBundle.TaskBundleID = eml.TaskBundleID
							FOR XML PATH('')
							), 1, 2, '')
			ELSE 'Once Every ' + CONVERT(VARCHAR, FrequencyNumber) + CASE 
					WHEN Frequency = 'W'
						THEN ' Week(s)'
					WHEN Frequency = 'D'
						THEN ' Day(s)'
					WHEN Frequency = 'M'
						THEN ' Month(s)'
					WHEN Frequency = 'Y'
						THEN ' Year(s)'
					END
			END FrequencyTitration
		,CASE 
			WHEN ProgramTaskBundle.TaskType = 'O'
				THEN (
						SELECT ScheduledDays
						FROM TaskType
						WHERE TaskTypeName = 'Other Tasks'
						)
			WHEN ProgramTaskBundle.TaskType = 'P'
				THEN (
						SELECT ScheduledDays
						FROM TaskType
						WHERE TaskTypeName = 'Schedule Procedure'
						)
			WHEN ProgramTaskBundle.TaskType = 'Q'
				THEN (
						SELECT ScheduledDays
						FROM TaskType
						WHERE TaskTypeName = 'Questionnaire'
						)
			WHEN ProgramTaskBundle.TaskType = 'E'
				THEN (
						SELECT ScheduledDays
						FROM TaskType
						WHERE TaskTypeName = 'Patient Education Material'
						)
			END ScheduledDays
	FROM ProgramTaskBundle
	WHERE ProgramID = @i_ProgramID
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
    ON OBJECT::[dbo].[usp_Assignment_Tasks] TO [FE_rohit.r-ext]
    AS [dbo];

