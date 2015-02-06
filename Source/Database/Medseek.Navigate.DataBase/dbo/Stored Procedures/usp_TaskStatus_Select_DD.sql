/*  
---------------------------------------------------------------------------------------  
Procedure Name: usp_TaskStatus_Select_DD  
Description   : This procedure is used to get the list for the Dropdown from TaskStatus.
Created By    : Aditya
Created Date  : 05-May-2010  
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
19-Aug-2010  NagaBabu Added WHERE clause,ORDER BY clause to the select statement  
18-Oct-2010  Rathnam removed the order by clause.    
---------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_TaskStatus_Select_DD]
(
	@i_AppUserId keyid
)
AS
BEGIN TRY
      SET NOCOUNT ON   
 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END
-------------------------------------------------------- 
      SELECT
          TaskStatusId,
		  TaskStatusText    
      FROM
          TaskStatus
      WHERE
		  IsActive = 1
      
END TRY  
--------------------------------------------------------   
BEGIN CATCH  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_TaskStatus_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

