/*        
---------------------------------------------------------------------------------        
Procedure Name: [dbo].[usp_HealthCareQualityStandardCategoryMeasure_Select]        
Description   : This procedure used the get the StandardCategoryMeasures     
Created By    : Rathnam        
Created Date  : 08-Nov-2010       
----------------------------------------------------------------------------------        
Log History   :         
DD-Mon-YYYY  BY  DESCRIPTION        
11-Nov-10 Pramod Included condition to show if criteria present or not and Iscustom field
25-Nov-10 Rathnam added casestatement for Iscustom.
02-May-2011 NagaBabu Added StatusCode,ReportingYear,ReportingPeriod,AdminOrClincFlag,SpecialityIDList,ProviderIDList,
						AdminClassificationIDList,ProgramID,DiseaseID
04-May-2011 NagaBabu Commented IsCustom field and added case statement to AdminOrClincFlag field
05-July-2011 Gurumoorthy added @v_StatusCode  parameter
09-Nov-2011 Nagababu Added CloneMeasureName,CopyType fields for resultset
09-Dec-2011 NagaBabu Replaced INNER JOIN by LEFT OUTER JOIN 
----------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_HealthCareQualityStandardCategoryMeasure_Select]--1
(
   @i_AppUserId KEYID,
   @v_StatusCode StatusCode = NULL
	
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
      SELECT
          HealthCareQualityMeasure.HealthCareQualityMeasureID AS MeasureID
         ,HealthCareQualityMeasure.HealthCareQualityMeasureName AS MeasureName
         ,HealthCareQualityMeasure.HealthCareQualityStandardID AS StandardID
         ,HealthCareQualityStandard.HealthCareQualityStandardName AS StandardName
         ,HealthCareQualityCategory.HealthCareQualityCategoryID AS CategoryID
         ,HealthCareQualityCategory.HealthCareQualityCategoryName AS CategoryName
         ,HealthCareQualityMeasure.HealthCareQualityBCategoryId AS BCategoryId
         ,HealthCareQualityBCategory.HealthCareQualityBCategoryName AS BCategoryName
         --,CASE WHEN HealthCareQualityMeasure.IsCustom = 1 THEN 'YES' ELSE 'NO' END AS IsCustom
         ,CASE WHEN
			(ISNULL((SELECT TOP 1 1
						 FROM HealthCareQualityMeasureNrDrDefinition
						WHERE HealthCareQualityMeasureNrDrDefinition.HealthCareQualityMeasureID 
								= HealthCareQualityMeasure.HealthCareQualityMeasureID
						  AND HealthCareQualityMeasureNrDrDefinition.NrDrIndicator = 'N'
						  ),0)
					   +
					   ISNULL((SELECT TOP 1 1
						 FROM HealthCareQualityMeasureNrDrDefinition
						WHERE HealthCareQualityMeasureNrDrDefinition.HealthCareQualityMeasureID 
								= HealthCareQualityMeasure.HealthCareQualityMeasureID
						  AND HealthCareQualityMeasureNrDrDefinition.NrDrIndicator = 'D'
					  ),0)
			) = 2 THEN 1
			ELSE 0
		  END AS IsNrDrCriteria
         ,HealthCareQualityMeasure.CreatedByUserId
		 ,HealthCareQualityMeasure.CreatedDate
		 ,HealthCareQualityMeasure.LastModifiedByUserId
		 ,HealthCareQualityMeasure.LastModifiedDate
		 ,CASE HealthCareQualityMeasure.StatusCode
			  WHEN 'A' THEN 'Active'
			  WHEN 'I' THEN 'Inactive'
			  ELSE ''
		  END AS StatusCode
		 ,HealthCareQualityMeasure.ReportingYear
		 ,HealthCareQualityMeasure.ReportingPeriod
		 ,CASE HealthCareQualityMeasure.AdminOrClincFlag
			  WHEN 'A' THEN 'Admin'
			  WHEN 'C' THEN 'Clinical'
		  END AS AdminOrClincFlag 	  
		 ,HealthCareQualityMeasure.SpecialityIDList
		 ,HealthCareQualityMeasure.ProviderIDList
		 ,HealthCareQualityMeasure.AdminClassificationIDList
		 ,HealthCareQualityMeasure.ProgramID
		 ,HealthCareQualityMeasure.DiseaseID
		 ,HealthCareQualityMeasure.CloneMeasureName
		 ,HealthCareQualityMeasure.CopyType,
		 CustomMeasureType 	  
      FROM
          HealthCareQualityStandard  WITH (NOLOCK) 
      INNER JOIN HealthCareQualityMeasure  WITH (NOLOCK) 
          ON HealthCareQualityMeasure.HealthCareQualityStandardId = HealthCareQualityStandard.HealthCareQualityStandardId
      LEFT OUTER JOIN HealthCareQualityBCategory  WITH (NOLOCK) 
          ON HealthCareQualityBCategory.HealthCareQualityBCategoryId = HealthCareQualityMeasure.HealthCareQualityBCategoryId
      LEFT OUTER JOIN HealthCareQualityCategory  WITH (NOLOCK) 
          ON HealthCareQualityCategory.HealthCareQualityCategoryID = HealthCareQualityBCategory.HealthCareQualityCategoryId
          WHERE
          ( HealthCareQualityMeasure.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL   )
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
    ON OBJECT::[dbo].[usp_HealthCareQualityStandardCategoryMeasure_Select] TO [FE_rohit.r-ext]
    AS [dbo];

