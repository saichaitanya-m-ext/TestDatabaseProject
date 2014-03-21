/*  
--------------------------------------------------------------------------------  
Procedure Name: [usp_PQRIQualityMeasureNumerator_MultiSelect]  
Description   : This procedure is used to get the details of usp_PQRIQualityMeasureNumerator  
                based on PQRIQualityMeasureGroupID AND PerformanceTypes.  
Created By    : Rama
Created Date  : 21-Dec-2010  
---------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
---------------------------------------------------------------------------------  
*/     
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureNumerator_MultiSelect]   
       (  
        @i_AppUserId KEYID,  
		@i_PQRIQualityMeasureID KEYID  
       )  
AS  
BEGIN TRY   
  
 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
         BEGIN  
           RAISERROR ( N'Invalid Application User ID %d passed.'  
           ,17  
           ,1  
           ,@i_AppUserId )  
         END  
       
        
  SELECT  * FROM [dbo].[udf_QualityMeasureSelect](@i_AppUserId,@i_PQRIQualityMeasureID,'MEP')  
  SELECT  * FROM [dbo].[udf_QualityMeasureSelect](@i_AppUserId,@i_PQRIQualityMeasureID,'MPE')  
  SELECT  * FROM [dbo].[udf_QualityMeasureSelect](@i_AppUserId,@i_PQRIQualityMeasureID,'PPE')  
  SELECT  * FROM [dbo].[udf_QualityMeasureSelect](@i_AppUserId,@i_PQRIQualityMeasureID,'SPE')  
  SELECT  * FROM [dbo].[udf_QualityMeasureSelect](@i_AppUserId,@i_PQRIQualityMeasureID,'OPE')  
  SELECT  * FROM [dbo].[udf_QualityMeasureSelect](@i_AppUserId,@i_PQRIQualityMeasureID,'PNM')  
                 
        
END TRY  
---------------------------------------------------------------------------------------------------------------  
BEGIN CATCH  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureNumerator_MultiSelect] TO [FE_rohit.r-ext]
    AS [dbo];

