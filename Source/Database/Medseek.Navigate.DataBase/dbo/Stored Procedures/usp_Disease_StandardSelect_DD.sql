/*  
---------------------------------------------------------------------------------------  
Procedure Name: [usp_Disease_StandardSelect_DD]
Description   : This Procedure used to get the Diseases mapped to CustomMeasures 
Created By    : NagaBabu
Created Date  : 16-Mar-2012
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
  
---------------------------------------------------------------------------------------  
*/  
CREATE PROCEDURE [dbo].[usp_Disease_StandardSelect_DD] 
(
 @i_AppUserId INT,
 @i_HealthCareQualityStandardId INT = NULL 
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
-------------------------------------------------------- 
      SELECT DISTINCT
          Disease.DiseaseId ,
          Name    
      FROM
          Disease
      INNER JOIN HealthCareQualityMeasure  
		  ON Disease.DiseaseId = HealthCareQualityMeasure.DiseaseId   
      WHERE
          Disease.StatusCode = 'A'
      AND HealthCareQualityMeasure.StatusCode = 'A'
      AND (HealthCareQualityMeasure.HealthCareQualityStandardId = @i_HealthCareQualityStandardId 
      OR @i_HealthCareQualityStandardId IS NULL)   
      ORDER BY
		  Name
  	  
	  	  
      
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
    ON OBJECT::[dbo].[usp_Disease_StandardSelect_DD] TO [FE_rohit.r-ext]
    AS [dbo];

