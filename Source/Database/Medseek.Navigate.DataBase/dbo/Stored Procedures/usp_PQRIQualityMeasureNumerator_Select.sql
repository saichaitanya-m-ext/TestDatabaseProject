/*  
--------------------------------------------------------------------------------  
Procedure Name: [usp_PQRIQualityMeasureNumerator_Select]  
Description   : This procedure is used to get the details of PQRIQualityMeasureNumerator  
                based on PQRIQualityMeasureGroupID.  
Created By    : Rama  
Created Date  : 21-Dec-2010  
---------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
---------------------------------------------------------------------------------  
*/     
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureNumerator_Select]  
       (  
        @i_AppUserId KEYID  
       ,@i_PQRIQualityMeasureID KEYID  
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
           
      SELECT  
          PQRIQualityMeasureID  
         ,PerformanceType  
         ,CriteriaText  
         ,CriteriaSQL  
         ,CreatedByUserId  
         ,CreatedDate  
         ,LastModifiedByUserId  
         ,LastModifiedDate  
      FROM  
          PQRIQualityMeasureNumerator  
      WHERE  
          PQRIQualityMeasureID = @i_PQRIQualityMeasureID   
          
        
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureNumerator_Select] TO [FE_rohit.r-ext]
    AS [dbo];

