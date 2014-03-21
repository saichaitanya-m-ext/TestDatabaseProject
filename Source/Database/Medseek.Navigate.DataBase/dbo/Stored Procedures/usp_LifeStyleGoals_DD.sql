/*  
----------------------------------------------------------------------------------------  
Procedure Name: usp_LifeStyleGoals_DD  23
Description   : This procedure is used for the Questions dropdown from the LifeStyleGoals 
			    table.  
Created By    : Gurumoorthy.V   
Created Date  : 28-Feb-2012
-----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
  
-----------------------------------------------------------------------------------------  
*/

CREATE PROCEDURE [dbo].[usp_LifeStyleGoals_DD]
(
 @i_AppUserId KEYID )
AS
BEGIN TRY   
  
 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END  
  
------------ Selection from LifeStyleGoals table starts here ------------  
      SELECT
          LifeStyleGoalId,
		  LifeStyleGoal
      FROM
          LifeStyleGoals
      WHERE
          StatusCode = 'A'
      ORDER BY
		  LifeStyleGoal    
     
END TRY
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LifeStyleGoals_DD] TO [FE_rohit.r-ext]
    AS [dbo];

