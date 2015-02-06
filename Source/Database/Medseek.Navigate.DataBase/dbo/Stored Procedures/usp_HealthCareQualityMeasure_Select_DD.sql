/*        
---------------------------------------------------------------------------------        
Procedure Name: [dbo].[usp_HealthCareQualityMeasure_Select_DD]  223,129
Description   : This procedure used the get the HealthCareQualityMeasure List    
Created By    : NagaBabu        
Created Date  : 07-Nov-2010       
----------------------------------------------------------------------------------        
Log History   :         
DD-Mon-YYYY  BY  DESCRIPTION        
----------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_HealthCareQualityMeasure_Select_DD]
(
   @i_AppUserId KEYID,
   @i_HealthCareQualityMeasureID KeyId = NULL	
)
AS
BEGIN TRY
      SET NOCOUNT ON             
-- Check if valid Application User ID is passed          

      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END
         
      IF @i_HealthCareQualityMeasureID IS NULL         
		  SELECT
			  HealthCareQualityMeasure.HealthCareQualityMeasureID AS MeasureID
			 ,HealthCareQualityMeasure.HealthCareQualityMeasureName AS MeasureName
		  FROM
			  HealthCareQualityMeasure WITH(NOLOCK)
		  WHERE ( HealthCareQualityMeasure.StatusCode = 'A' )
	ELSE
		BEGIN
			SELECT
			  NrDrIndicator ,
			  ( SELECT
					CriteriaTypeName
				FROM
					CohortListCriteriaType
				WHERE
					CohortListCriteriaTypeId = HealthCareQualityMeasureNrDrDefinition.CriteriaTypeID ) AS CriteriaTypeName ,
			  CriteriaSQL ,
			  CriteriaText AS CohortCriteriaText,
			  JoinType,
			  JoinStatement,
			  OnClause,
			  WhereClause
		  FROM
			  HealthCareQualityMeasureNrDrDefinition  WITH(NOLOCK)
		  WHERE
			  HealthCareQualityMeasureID = @i_HealthCareQualityMeasureID
		  AND NrDrIndicator = 'N' 
		  
		  SELECT
			  NrDrIndicator ,
			  ( SELECT
					CriteriaTypeName
				FROM
					CohortListCriteriaType
				WHERE
					CohortListCriteriaTypeId = HealthCareQualityMeasureNrDrDefinition.CriteriaTypeID ) AS CriteriaTypeName ,
			  CriteriaSQL ,
			  CriteriaText AS CohortCriteriaText,
			  JoinType,
			  JoinStatement,
			  OnClause,
			  WhereClause
		  FROM
			  HealthCareQualityMeasureNrDrDefinition  WITH(NOLOCK)
		  WHERE
			  HealthCareQualityMeasureID = @i_HealthCareQualityMeasureID
		  AND NrDrIndicator = 'D' 
      END   	  
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
    ON OBJECT::[dbo].[usp_HealthCareQualityMeasure_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

