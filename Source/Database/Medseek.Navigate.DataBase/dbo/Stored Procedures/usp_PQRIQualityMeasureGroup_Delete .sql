/*        
------------------------------------------------------------------------------        
Procedure Name: usp_PQRIQualityMeasureGroup_Delete        
Description   : This procedure is used to delete records from PQRIQualityMeasureGroup and dependencies table    
Created By    : Rama       
Created Date  : 24-Dec-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION             
------------------------------------------------------------------------------        
*/      
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureGroup_Delete ]   
	(      
		@i_AppUserId KeyID,    
		@i_PQRIQualityMeasureGroupID KeyID     
	)      
AS      
BEGIN TRY    
	    
	  SET NOCOUNT ON           
	  -- Check if valid Application User ID is passed        
	  IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 ) 
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END        

	  DECLARE @b_TranStarted BIT = 0
	  IF( @@TRANCOUNT = 0 )  
	  BEGIN
			BEGIN TRANSACTION
			SET @b_TranStarted = 1  -- Indicator for start of transactions
	  END
	  ELSE
			SET @b_TranStarted = 0  

	  DELETE FROM PQRIQualityMeasureGroupToMeasure     
	  WHERE PQRIQualityMeasureGroupID = @i_PQRIQualityMeasureGroupID    

	  DELETE FROM PQRIQualityMeasureGroupDenominator      
	  WHERE PQRIQualityMeasureGroupID = @i_PQRIQualityMeasureGroupID    

	  DELETE FROM PQRIProviderQualityMeasureGroup
	  WHERE PQRIQualityMeasureGroupID = @i_PQRIQualityMeasureGroupID 
	   
	  DELETE FROM PQRIQualityMeasureGroupCorrelate
	  WHERE PQRIQualityMeasureGroupID = @i_PQRIQualityMeasureGroupID  
	  
	  DELETE FROM  PQRIQualityMeasureGroup     
	  WHERE PQRIQualityMeasureGroupID = @i_PQRIQualityMeasureGroupID    

	  IF( @b_TranStarted = 1 )  -- If transactions are there, then commit
	  BEGIN
		   SET @b_TranStarted = 0
		   COMMIT TRANSACTION 
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureGroup_Delete ] TO [FE_rohit.r-ext]
    AS [dbo];

