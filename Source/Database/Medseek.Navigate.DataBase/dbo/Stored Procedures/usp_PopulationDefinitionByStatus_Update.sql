/*    
-----------------------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_CohortListByStatus_Update]    
Description   : This procedure is used to update the Status into CohortList    
Created By    : NagaBabu
Created Date  : 21-Dec-2011
------------------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION  
15-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added PopulationDefinitionID in 
            the place of CohortListID  
------------------------------------------------------------------------------------------------    
*/  
  
CREATE PROCEDURE [dbo].[usp_PopulationDefinitionByStatus_Update]  
(  
 @i_AppUserId KeyID ,  
 @i_PopulationDefinitionId KeyId,  
 @vc_StatusCode Statuscode
 )  
AS  
BEGIN TRY  
  
      SET NOCOUNT ON     
 -- Check if valid Application User ID is passed    
      DECLARE @i_numberOfRecordsUpdated INT  
      IF ( @i_AppUserId IS NULL )  
      OR ( @i_AppUserId <= 0 )  
  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.' ,  
               17 ,  
               1 ,  
               @i_AppUserId )  
         END    
------------ Status  Updation operation takes place   --------------------------    
  
      UPDATE  
          PopulationDefinition  
      SET  
		  StatusCode = @vc_StatusCode
      WHERE  
          PopulationDefinitionId = @i_PopulationDefinitionId 
      
      IF @vc_StatusCode = 'I'
		  BEGIN
			DELETE FROM PopulationDefinitionUsers WHERE PopulationDefinitionId = @i_PopulationDefinitionId
		  END         
       
END TRY     
------------ Exception Handling --------------------------------    
BEGIN CATCH  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
      RETURN @i_ReturnedErrorID  
END CATCH    
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinitionByStatus_Update] TO [FE_rohit.r-ext]
    AS [dbo];

