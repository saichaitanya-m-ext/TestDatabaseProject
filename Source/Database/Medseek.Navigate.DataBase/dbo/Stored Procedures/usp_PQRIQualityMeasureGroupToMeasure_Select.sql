/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_PQRIQualityMeasureGroupToMeasure_Select]    
Description   : This procedure is used to Get PQRIQualityMeasureID from PQRIQualityMeasureGroupTOMeasure table
Created By    : NagaBabu
Created Date  : 03-Jan-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
08-Dec-2011 NagaBabu Added JOIN condition for PQRIQualityMeasureGroupToMeasure to getting PQRIMeasureID field
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureGroupToMeasure_Select]
(  
	@i_AppUserId KEYID,
	@i_PQRIQualityMeasureGroupId KEYID ,
	@i_PQRIQualityMeasureGroupCorrelateID KEYID
)  
AS  
BEGIN TRY

	SET NOCOUNT ON  
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR 
		   ( N'Invalid Application User ID %d passed.' ,  
		     17 ,  
		     1 ,  
		     @i_AppUserId
		   )  
	END  
	     SELECT
			 PQMG.PQRIQualityMeasureID ,
			 PQRIQualityMeasure.PQRIMeasureID
	     FROM 
			 PQRIQualityMeasureGroupToMeasure PQMG WITH(NOLOCK)
		 INNER JOIN PQRIQualityMeasure WITH(NOLOCK)
			 ON PQRIQualityMeasure.PQRIQualityMeasureID = PQMG.PQRIQualityMeasureID	  
		 WHERE 
		     PQRIQualityMeasureGroupId = @i_PQRIQualityMeasureGroupId
		     
   ------------------------------------------------------------------------------
         SELECT
			 PQRIQualityMeasureGroupCorrelateID ,
			 PQRIQualityMeasureGroupID ,
			 PQRIQualityMeasureCorrelateIDList ,
			 AgeFrom ,
			 AgeTo ,
			 Gender ,
			 BMIFrom ,
			 BMITo 
		 FROM
			 PQRIQualityMeasureGroupCorrelate
		 WHERE
			 PQRIQualityMeasureGroupCorrelateID = @i_PQRIQualityMeasureGroupCorrelateID	 	 		     
	
    RETURN 0 
  
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureGroupToMeasure_Select] TO [FE_rohit.r-ext]
    AS [dbo];

