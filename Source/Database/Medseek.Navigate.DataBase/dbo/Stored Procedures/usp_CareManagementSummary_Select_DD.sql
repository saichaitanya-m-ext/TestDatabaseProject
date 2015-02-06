
/*   

------------------------------------------------------------------------------------------          
Procedure Name: [usp_CareManagementSummary_Select_DD] 23,NULL,18,684,41
Description   : This procedure is used to select all the codegroupers and 
Created By    : Santosh          
Created Date  : 19-August-2013
------------------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION      
-------------------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_CareManagementSummary_Select_DD] (
	@i_AppUserId KeyId
	,@i_ProgramId KeyId = NULL
	,@i_TaskBundleId KeyId = NULL
	,@i_TaskGeneralisedId KeyId = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @i_numberOfRecordsSelected INT

	----- Check if valid Application User ID is passed--------------          
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

	SELECT ProgramId
		,ProgramName
	FROM Program
	WHERE StatusCode = 'A'
	ORDER BY ProgramName

	SELECT DISTINCT T.TaskBundleId
		,TaskBundleName
	FROM TaskBundle T
	WHERE T.StatusCode = 'A'
	ORDER BY TaskBundleName

	SELECT DISTINCT GeneralizedID
		,[dbo].[ufn_GetTypeNamesByTypeId](CASE TaskType
				WHEN 'E'
					THEN 'Patient Education Material'
				WHEN 'O'
					THEN 'Other Tasks'
				WHEN 'P'
					THEN 'Schedule Procedure'
				WHEN 'Q'
					THEN 'Questionnaire'
				END, GeneralizedID) AS GeneralizedName
		,t.TaskBundleId --,P.ProgramId
	FROM ProgramTaskBundle PTB
	INNER JOIN TaskBundle T ON T.TaskBundleId = PTB.TaskBundleId
	WHERE T.TaskBundleId = @i_TaskBundleId
		AND PTB.StatusCode = 'A'
	ORDER BY GeneralizedName

	--  SELECT DISTINCT
	--	  TT.CommunicationTypeID AS RemainderID,
	--	  (SELECT CommunicationType FROM CommunicationType WHERE CommunicationTypeId = TT.CommunicationTypeID) AS RemainderType
	--FROM ProgramTaskBundle PTB
	----INNER JOIN TaskTypeCommunications TT
	----    ON TT.TaskTypeGeneralizedID = PTB.GeneralizedID	
	----    AND CASE WHEN PTB.TaskType = 'O' THEN (SELECT TaskTypeId FROM TASKTYPE WHERE TaskTypeName = 'Other Tasks')
	----         WHEN PTB.TaskType = 'E' THEN (SELECT TaskTypeId FROM TASKTYPE WHERE TaskTypeName = 'Patient Education Material')
	----         WHEN PTB.TaskType = 'Q' THEN (SELECT TaskTypeId FROM TASKTYPE WHERE TaskTypeName = 'Questionnaire')
	----         WHEN PTB.TaskType = 'P' THEN (SELECT TaskTypeId FROM TASKTYPE WHERE TaskTypeName = 'Schedule Procedure') END
	----         = TT.TaskTypeID
	--INNER JOIN ProgramTaskTypeCommunication TT
	-- ON TT.ProgramID = PTB.ProgramId
	--	WHERE
	--   PTB.StatusCode = 'A'
	--  AND TT.CommunicationTypeID IS NOT NULL
	SELECT CommunicationTypeId AS RemainderID
		,CommunicationType AS RemainderType
	FROM CommunicationType
	WHERE StatusCode = 'A'
	ORDER BY CommunicationType
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
    ON OBJECT::[dbo].[usp_CareManagementSummary_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

