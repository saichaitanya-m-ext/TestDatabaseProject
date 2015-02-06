/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_PQRIQualityMeasureGroupToMeasure_Delete]    
Description   : This procedure is used to Delete record from PQRIQualityMeasureGroupTOMeasure table
Created By    : Rathnam
Created Date  : 15-Dec-2010  
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
   
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureGroupToMeasure_Delete]  
(  
	@i_AppUserId KEYID,
	@i_PQRIQualityMeasureGroupId KEYID,
	@t_PQRIQualityMeasureID TTYPEKEYID READONLY
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
	
	DELETE FROM PQRIQualityMeasureGroupToMeasure
	WHERE PQRIQualityMeasureGroupId = @i_PQRIQualityMeasureGroupId
	AND EXISTS (SELECT 1 FROM @t_PQRIQualityMeasureID tblQMID WHERE tblQMID.tKeyId = PQRIQualityMeasureID)
	--AND PQRIQualityMeasureID IN  (SELECT tblQMID.tKeyId FROM @t_PQRIQualityMeasureID tblQMID )
		
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureGroupToMeasure_Delete] TO [FE_rohit.r-ext]
    AS [dbo];

