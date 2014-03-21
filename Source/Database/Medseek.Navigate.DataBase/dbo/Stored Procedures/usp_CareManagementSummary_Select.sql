
/*          
------------------------------------------------------------------------------------------          
Procedure Name: [usp_CareManagementSummary_Select] 23,267,30,128,3
Description   : This procedure is used to populate reports based on the given selection
Created By    : Santosh          
Created Date  : 12-August-2013
------------------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION  
27-08-2013 Modified By Mohan added new column Reminders and in where condition 
11-Sep-2013 NagaBabu Added two colums CareTeamId , CareTeamName to the resultset 
-------------------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_CareManagementSummary_Select] (
    @i_AppUserId               KEYID,
    @i_managedPopulationID     KEYID = NULL,
    @i_taskbundleID            KEYID = NULL,
    @i_taskID                  KEYID = NULL,
    @i_ReminderID              Keyid = NULL
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
	        N'Invalid Application User ID %d passed.',
	        17,
	        1,
	        @i_AppUserId
	    )
	END;
	
	WITH CTE
	AS (
	    SELECT DISTINCT Program.ProgramId,
	           Program.ProgramName,
	           Program.Description     AS ProgramDescription,
	           TaskBundle.TaskBundleId,
	           TaskBundle.TaskBundleName,
	           TaskBundle.Description  AS TaskBundleDescription,
	           [dbo].[ufn_GetTypeNamesByTypeId](
	               CASE TaskType
	                    WHEN 'E' THEN 'Patient Education Material'
	                    WHEN 'O' THEN 'Other Tasks'
	                    WHEN 'P' THEN 'Schedule Procedure'
	                    WHEN 'Q' THEN 'Questionnaire'
	               END,
	               ISNULL(@i_taskID, ProgramTaskTypeCommunication.GeneralizedID)
	           )                       AS TaskName,
	           CareTeam.CareTeamId ,
	           CareTeam.CareTeamName ,
	           (
	               SELECT CommunicationTypeId
	               FROM   CommunicationType
	               WHERE  CommunicationTypeId = ProgramTaskTypeCommunication.CommunicationTypeId
	           )                       AS ReminderID,
	           (
	               SELECT CommunicationType
	               FROM   CommunicationType
	               WHERE  CommunicationTypeId = ProgramTaskTypeCommunication.CommunicationTypeId
	           )                       AS ReminderType,
	           (
	               SELECT TemplateName
	               FROM   CommunicationTemplate
	               WHERE  CommunicationTemplateId = ProgramTaskTypeCommunication.CommunicationTemplateID
	           )                       AS ReminderName,
	           (
	               SELECT CommunicationText
	               FROM   CommunicationTemplate
	               WHERE  CommunicationTemplateId = ProgramTaskTypeCommunication.CommunicationTemplateID
	           )                       AS TemplateName,
	           CASE 
	                WHEN RemainderState = 'A'
	    AND (
	            SELECT CommunicationTypeId
	            FROM   CommunicationType
	            WHERE  CommunicationTypeId = ProgramTaskTypeCommunication.CommunicationTypeId
	        ) IS NULL
	        THEN 'Missed Opp.'
	        WHEN RemainderState = 'A'
	    AND (
	            SELECT CommunicationTypeId
	            FROM   CommunicationType
	            WHERE  CommunicationTypeId = ProgramTaskTypeCommunication.CommunicationTypeId
	        ) IS NOT NULL
	        THEN 'After' 
	        WHEN RemainderState = 'B'
	        THEN 'Prior'
	        END AS RemainderDescription,
	    CASE 
	         WHEN ProgramTaskTypeCommunication.RemainderState = 'B' THEN '-' + 
	              CAST(
	                  ProgramTaskTypeCommunication.CommunicationAttemptDays AS 
	                  VARCHAR(5)
	              )
	         WHEN ProgramTaskTypeCommunication.RemainderState = 'A'
	    AND (
	            SELECT CommunicationTypeId
	            FROM   CommunicationType
	            WHERE  CommunicationTypeId = ProgramTaskTypeCommunication.CommunicationTypeId
	        ) IS NOT NULL
	        THEN '+' + CAST(
	            ProgramTaskTypeCommunication.CommunicationAttemptDays AS VARCHAR(5)
	        )
	        WHEN ProgramTaskTypeCommunication.RemainderState = 'A'
	    AND (
	            SELECT CommunicationTypeId
	            FROM   CommunicationType
	            WHERE  CommunicationTypeId = ProgramTaskTypeCommunication.CommunicationTypeId
	        ) IS NULL 
	        THEN '+' + CAST(
	            ProgramTaskTypeCommunication.NoOfDaysBeforeTaskClosedIncomplete 
	            AS VARCHAR(5)
	        )
	        END Reminders
	        FROM ProgramTaskBundle
	        INNER JOIN Program ON Program.ProgramId = ProgramTaskBundle.ProgramID
	        LEFT JOIN ProgramCareTeam PC
				ON PC.ProgramId = Program.ProgramId
			LEFT JOIN CareTeam
				ON CareTeam.CareTeamId = PC.CareTeamId	
	        LEFT JOIN TaskBundle ON TaskBundle.TaskBundleId = ProgramTaskBundle.TaskBundleID
	        LEFT JOIN ProgramTaskTypeCommunication ON 
	        ProgramTaskTypeCommunication.ProgramID = Program.ProgramId
	    AND ProgramTaskBundle.ProgramTaskBundleID = ProgramTaskTypeCommunication.ProgramTaskBundleID
	        WHERE (
	            ProgramTaskBundle.ProgramID = @i_managedPopulationID
	            OR @i_managedPopulationID IS NULL
	        )
	    AND (
	            ProgramTaskBundle.TaskBundleID = @i_taskbundleID
	            OR @i_taskbundleID IS NULL
	        )
	    AND (
	            ProgramTaskTypeCommunication.CommunicationTypeID = @i_ReminderID
	            OR @i_ReminderID IS NULL
	        )
	    AND Program.StatusCode = 'A'
	        --AND TaskBundle.StatusCode = 'A'
	        --AND ProgramTaskTypeCommunication.StatusCode = 'A'
	    AND (
	            ProgramTaskTypeCommunication.GeneralizedID = @i_taskID
	            OR @i_taskID IS NULL
	        )
	    AND (
	            ProgramTaskBundle.GeneralizedID = @i_taskID
	            OR @i_taskID IS NULL
	        ) 
	        --SELECT * FROM ProgramTaskTypeCommunication
	)
	SELECT ProgramId,
	       ProgramName,
	       ProgramDescription,
	       TaskBundleId,
	       TaskBundleName,
	       TaskBundleDescription,
	       TaskName,
	       CareTeamId ,
	       CareTeamName ,
	       ReminderID,
	       ReminderType,
	       ReminderName,
	       TemplateName,
	       RemainderDescription,
	       Reminders
	FROM   CTE
	--GROUP BY
	--       ProgramId,
	--       ProgramName,
	--       ProgramDescription,
	--       TaskBundleId,
	--       TaskBundleName,
	--       TaskBundleDescription,
	--       TaskName,
	--       ReminderID,
	--       ReminderType,
	--       ReminderName,
	--       TemplateName,
	--       RemainderDescription,
	--       Reminders
	ORDER BY
	       ProgramName,
	       Taskname,
	       CareTeamName ,
	       CASE WHEN RemainderDescription = 'Prior' THEN 1
				WHEN RemainderDescription = 'After' THEN 2
				WHEN RemainderDescription = 'Missed Opp.' THEN 3
				ELSE 4
			END ASC
	       
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
    ON OBJECT::[dbo].[usp_CareManagementSummary_Select] TO [FE_rohit.r-ext]
    AS [dbo];

