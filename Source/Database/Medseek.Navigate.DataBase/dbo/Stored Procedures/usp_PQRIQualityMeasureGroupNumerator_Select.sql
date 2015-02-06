
  
/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_PQRIQualityMeasureGroupNumerator_Select] 
Description   : This Procedure is used to get the QMNumarator details for a particular Group.
Created By    : Rathnam    
Created Date  : 5-Jan-2011 
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION  
25-Nov-2011 NagaBabu Added PQRIMeasureID field in First Resultset  
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureGroupNumerator_Select]
(  
	@i_AppUserId KEYID,  
	@i_PQRIQualityMeasureGroupID KEYID
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
  
      SELECT 
		  PQRIQualityMeasure.PQRIQualityMeasureID,
		  PQRIQualityMeasure.Name,
		  PQRIQualityMeasureNumerator.PerformanceType,
		  PQRIQualityMeasureNumerator.CriteriaText,
		  PQRIQualityMeasureNumerator.CriteriaSQL,
		  PQRIQualityMeasure.PQRIMeasureID
	  INTO #tblNumarators
      FROM 
          PQRIQualityMeasure WITH(NOLOCK)
      INNER JOIN PQRIQualityMeasureNumerator WITH(NOLOCK)
          ON PQRIQualityMeasureNumerator.PQRIQualityMeasureID = PQRIQualityMeasure.PQRIQualityMeasureID
      INNER JOIN PQRIQualityMeasureGroupToMeasure WITH(NOLOCK)
          ON PQRIQualityMeasureGroupToMeasure.PQRIQualityMeasureID = PQRIQualityMeasureNumerator.PQRIQualityMeasureID
      WHERE   
          PQRIQualityMeasureGroupToMeasure.PQRIQualityMeasureGroupId = @i_PQRIQualityMeasureGroupID 
          AND PQRIQualityMeasure.StatusCode = 'A' 
          AND PQRIQualityMeasureNumerator.StatusCode = 'A'
      
      SELECT DISTINCT 
          PQRIQualityMeasureID,
          Name,
          PQRIMeasureID
      FROM  
          #tblNumarators  Numarators 
                  
      SELECT 
           PQRIQualityMeasureID,
           Name,
           PerformanceType,
           CriteriaText, 
           CriteriaSQL
      FROM  
          #tblNumarators  Numarators         
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureGroupNumerator_Select] TO [FE_rohit.r-ext]
    AS [dbo];

