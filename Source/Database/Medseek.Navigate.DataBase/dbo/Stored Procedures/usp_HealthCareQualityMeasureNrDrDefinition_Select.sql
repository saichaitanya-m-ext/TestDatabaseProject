/*
---------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_HealthCareQualityMeasureNrDrDefinition_Select]
Description	  : This procedure is used to select the HealthCareQualityMeasureNrDrDefinition 
				records for particular HealthCareQualityMeasureID
Created By    :	NagaBabu
Created Date  : 23-Aug-2010
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
27-Aug-2010   Rathnam   Enhanced the select statement.
15-Sep-10 Pramod CriteriaText Alias changed to CohortCriteriaText
----------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_HealthCareQualityMeasureNrDrDefinition_Select]
(
 @i_AppUserId KEYID ,
 @i_HealthCareQualityMeasureID KEYID )
AS
BEGIN TRY 

	-- Check if valid Application User ID is passed
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END
---------------- All the HealthCareQualityMeasureNrDrDefinition records are retrieved --------
      SELECT
          HealthCareQualityMeasureNrDrDefinitionID ,
          NrDrIndicator ,
          CriteriaTypeID ,
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
		  WhereClause,
          CreatedByUserId ,
          CreatedDate ,
          LastModifiedByUserId ,
          LastModifiedDate
      FROM
          HealthCareQualityMeasureNrDrDefinition WITH(NOLOCK)
      WHERE
          HealthCareQualityMeasureID = @i_HealthCareQualityMeasureID
END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HealthCareQualityMeasureNrDrDefinition_Select] TO [FE_rohit.r-ext]
    AS [dbo];

