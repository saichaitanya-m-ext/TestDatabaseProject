/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_PQRIQualityMeasuretoMeasureGroup_Delete]    
Description   : This procedure is used to Delete record from PQRIQualityMeasureGroupToMeasure  table
Created By    : Rathnam
Created Date  : 13-Dec-2010  
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY  DESCRIPTION    
25-Dec-2010		Rama replaced PQRIQualityMeasuretoMeasureGroup by PQRIQualityMeasureGroupToMeasure   
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasuretoMeasureGroup_Delete]  
(  
	@i_AppUserId KEYID,
	@i_PQRIQualityMeasureID KEYID,
    @t_PQRIQualityMeasureGroupID TTYPEKEYID READONLY
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
	WHERE PQRIQualityMeasureID = @i_PQRIQualityMeasureID
	AND EXISTS (
				SELECT 
					1 
	             FROM @t_PQRIQualityMeasureGroupID tblGroupID 
	             WHERE tblGroupID.tKeyId = PQRIQualityMeasureGroupId
	            )
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasuretoMeasureGroup_Delete] TO [FE_rohit.r-ext]
    AS [dbo];

