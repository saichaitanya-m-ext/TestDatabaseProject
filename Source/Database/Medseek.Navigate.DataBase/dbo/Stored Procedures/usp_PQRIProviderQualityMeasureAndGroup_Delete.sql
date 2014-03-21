/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_PQRIProviderQualityMeasureAndGroup_Delete]   
Description   : This procedure is used to delete record from PQRIProviderQualityMeasure 
					and PQRIProviderQualityMeasureGroup tables
Created By    : NagaBabu   
Created Date  : 11-Jan-2011    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
16-Feb-2011 Rathnam removed the set statement for getting the  @i_PQRIProviderPersonalizationID values     
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_PQRIProviderQualityMeasureAndGroup_Delete]  
(  
	@i_AppUserId KeyID ,
	@i_ProviderUserID KeyID ,
    @i_ReportingYear SMALLINT ,
    @i_PQRIQualityMeasureID KeyID = NULL,
    @i_PQRIQualityMeasureGroupID KeyID = NULL
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
   ---------------Deleting data from PQRIProviderQualityMeasure,PQRIProviderQualityMeasureGroup------------        
	   DECLARE @i_PQRIProviderPersonalizationID KeyID
	   SELECT @i_PQRIProviderPersonalizationID = PQRIProviderPersonalizationID
	   FROM
	       PQRIProviderPersonalization
	   WHERE
		   ProviderUserID = @i_ProviderUserID	
	   AND ReportingYear = @i_ReportingYear 
														
	   IF @i_PQRIQualityMeasureID IS NOT NULL
		  DELETE
		  FROM
			  PQRIProviderQualityMeasure
		  WHERE
			  PQRIProviderPersonalizationID = @i_PQRIProviderPersonalizationID
		  AND PQRIQualityMeasureID = @i_PQRIQualityMeasureID	
		  
	   IF @i_PQRIQualityMeasureGroupID IS NOT NULL
		  DELETE
		  FROM
			  PQRIProviderQualityMeasuregroup
		  WHERE
			  PQRIProviderPersonalizationID = @i_PQRIProviderPersonalizationID
		  AND PQRIQualityMeasureGroupID = @i_PQRIQualityMeasureGroupID		    
			  	  	
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
    ON OBJECT::[dbo].[usp_PQRIProviderQualityMeasureAndGroup_Delete] TO [FE_rohit.r-ext]
    AS [dbo];

