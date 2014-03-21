/*  
--------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_DashBoard_MissedOpportunity]  
Description   : This proc is used to retrive the Patient specific missedopportunity records from task table  
Created By    : Rathnam  
Created Date  : 20-Jan-2013
---------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
---------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_DashBoard_MissedOpportunity]

(
 @i_AppUserId KEYID
,@i_PatientUserID KEYID
)
AS
BEGIN
      BEGIN TRY   
     -- Check if valid Application User ID is passed  
            IF ( @i_AppUserId IS NULL )
            OR ( @i_AppUserId <= 0 )
               BEGIN
                     RAISERROR ( N'Invalid Application User ID %d passed.'
                     ,17
                     ,1
                     ,@i_AppUserId )
               END
            SELECT
                t.TaskId
               ,ty.TaskTypeName
               ,ISNULL(dbo.ufn_GetTypeNamesByTypeId(ty.TaskTypeName , t.TypeID), t.ManualTaskName) TaskName
               ,ISNULL(DATEADD(DD , t.TerminationDays , t.TaskDueDate) ,TaskDueDate) MissedOpportunityDate
               ,pd.PopulationDefinitionName
               ,t.TaskDueDate
            FROM
                Task t WITH(NOLOCK)
            INNER JOIN TaskStatus ts WITH(NOLOCK)
                ON t.TaskStatusId = ts.TaskStatusId
            INNER JOIN TaskType ty WITH(NOLOCK)
                ON t.TaskTypeId = ty.TaskTypeId
            INNER JOIN Program p WITH(NOLOCK)
                ON p.ProgramId = t.ProgramID
            INNER JOIN PopulationDefinition pd WITH(NOLOCK)
                ON pd.PopulationDefinitionID = p.PopulationDefinitionID
            WHERE
                ts.TaskStatusText = 'Closed Incomplete'
                AND t.PatientId = @i_PatientUserID
                --AND pd.DefinitionType = 'C'
      END TRY  
---------------------------------------------------------------------------------------------------------------------------------  
      BEGIN CATCH  
    -- Handle exception  
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

            RETURN @i_ReturnedErrorID
      END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_DashBoard_MissedOpportunity] TO [FE_rohit.r-ext]
    AS [dbo];

