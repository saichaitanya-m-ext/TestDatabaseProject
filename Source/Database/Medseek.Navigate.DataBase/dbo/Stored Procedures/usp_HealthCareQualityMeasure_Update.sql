/*        
------------------------------------------------------------------------------        
Procedure Name: usp_HealthCareQualityMeasure_Update
Description   : This procedure is used to update Measure into HealthCareQualityMeasure 
                 & HealthCareQualityMeasureNrDrDefinition table    
Created By    : Pramod
Created Date  : 13-Sep-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION 
27-Sep-2010 NagaBabu Added @i_HealthCareQualityStandardId parameters AND added @l_numberOfRecordsUpdated 
						for showing error message 	
12-Oct-2010 Pramod Condition for @l_numberOfRecordsUpdated is removed
09-Nov-2010 Rathnam removed the PayorID 
17-Nov-2010 Rathnam added @i_IsCustom parameter
26-Nov-2010 Rathnam removed the delete HealthCareQualityMeasureNrDrDefinition  operation
                    and HealthCareQualityMeasureNrDrDefinition  insert operation
02-May-2011 NagaBabu Added @v_StatusCode,@i_ReportingYear,@v_ReportingPeriod,@c_AdminOrClincFlag,@v_SpecialityIDList,
						@v_ProviderIDList,@v_AdminClassificationIDList,@i_ProgramID,@i_DiseaseID Parameters
04-May-2011 NagaBabu Commmented @i_IsCustom 						
------------------------------------------------------------------------------        
*/

CREATE PROCEDURE [dbo].[usp_HealthCareQualityMeasure_Update]
(
	@i_AppUserId KEYID ,
	@i_HealthCareQualityBCategoryId KEYID = NULL,
	@v_HealthCareQualityMeasureName SHORTDESCRIPTION ,
	@i_HealthCareQualityMeasureID KEYID ,
	@i_HealthCareQualityStandardId KEYID ,
	--@i_IsCustom IsIndicator ,
	@v_StatusCode StatusCode = NULL ,
    @i_ReportingYear INT = NULL ,
    @v_ReportingPeriod VARCHAR(10) = NULL ,
    @c_AdminOrClincFlag CHAR(1) = NULL ,
    @v_SpecialityIDList LongDescription = NULL ,
    @v_ProviderIDList LongDescription = NULL ,
    @v_AdminClassificationIDList LongDescription = NULL ,
    @i_ProgramID KEYID = NULL ,
    @i_DiseaseID KEYID = NULL 
)
AS
BEGIN TRY
      SET NOCOUNT ON  
      DECLARE @i_numberOfRecordsUpdated INT  
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END    
    
---------insert operation into HealthCareQualityMeasure -----       
    
      
      UPDATE HealthCareQualityMeasure
         SET HealthCareQualityBCategoryId = @i_HealthCareQualityBCategoryId,
             HealthCareQualityMeasureName = @v_HealthCareQualityMeasureName,
             LastModifiedByUserId = @i_AppUserId,
             LastModifiedDate = GETDATE(),
             HealthCareQualityStandardId = @i_HealthCareQualityStandardId,
             --IsCustom = @i_IsCustom ,
             StatusCode = @v_StatusCode,
             ReportingYear = @i_ReportingYear,
             ReportingPeriod = @v_ReportingPeriod,
			 AdminOrClincFlag = @c_AdminOrClincFlag,
			 SpecialityIDList = @v_SpecialityIDList,
			 ProviderIDList = @v_ProviderIDList,
			 AdminClassificationIDList = @v_AdminClassificationIDList,
			 ProgramID = @i_ProgramID,
			 DiseaseID = @i_DiseaseID
	   WHERE HealthCareQualityMeasureID = @i_HealthCareQualityMeasureID
	   
	 SET @i_numberOfRecordsUpdated = @@ROWCOUNT
	 
	 IF @i_numberOfRecordsUpdated <> 1 
		RAISERROR
		(	 N'Update of HealthCareQualityMeasure table experienced invalid row count of %d'
			,17
			,1
			,@i_numberOfRecordsUpdated         
	    )      
	
         
      RETURN 0   
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
    ON OBJECT::[dbo].[usp_HealthCareQualityMeasure_Update] TO [FE_rohit.r-ext]
    AS [dbo];

