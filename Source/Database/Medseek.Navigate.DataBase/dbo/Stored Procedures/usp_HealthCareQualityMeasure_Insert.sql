/*          
------------------------------------------------------------------------------          
Procedure Name: usp_HealthCareQualityMeasure_Insert          
Description   : This procedure is used to insert Measure into HealthCareQualityMeasure   
Created By    : Rathnam          
Created Date  : 23-Aug-2010          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION   
25-Aug-2010 NagaBabu Converted HealthCareQualityMeasureID AS OUTPUT perameter   
27-Sep-2010 NagaBabu Added @i_HealthCareQualityStandardId parameters AND Added @l_numberOfRecordsInserted    
      for showing error message      
29-Oct-10 Pramod raise error condition removed  
09-Nov-2010 Rathnam removed the PayorID  
12-Nov-2010 Rathnam removed the Insert condition for HealthCareQualityMeasureNrDrDefinition  
17-Nov-2010 Rathnam added @i_IsCustom parameter  
02-May-2011 NagaBabu Added @v_StatusCode,@i_ReportingYear,@v_ReportingPeriod,@c_AdminOrClincFlag,@v_SpecialityIDList,  
      @v_ProviderIDList,@v_AdminClassificationIDList,@i_ProgramID,@i_DiseaseID Parameters  
04-May-2011 NagaBabu Commmented @d_NumeratorValue,@d_DenominatorValue,@i_IsCustom   
08-Nov-2011 NagaBabu Added @t_HealthCareCriteriaSQLTest as Parameter and added second Insert statement  
09-Nov-2011 NagaBabu Added @v_CloneMeasureName,@c_CopyType as input parameters  
------------------------------------------------------------------------------          
*/  
  
CREATE PROCEDURE [dbo].[usp_HealthCareQualityMeasure_Insert]  
(  
 @i_AppUserId KEYID ,  
 @i_HealthCareQualityBCategoryId KEYID =NULL,  
 @v_HealthCareQualityMeasureName SHORTDESCRIPTION ,  
 --@d_NumeratorValue DECIMAL(10,2) = NULL ,  
 --@d_DenominatorValue DECIMAL(10,2) = NULL ,  
 @i_HealthCareQualityMeasureID KEYID  OUTPUT ,  
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
 @i_DiseaseID KEYID = NULL ,  
 @t_HealthCareCriteriaSQLTest HealthCareCriteriaSQLTest READONLY ,  
 @v_CloneMeasureName ShortDescription = NULL ,  
 @c_CopyType CHAR(1) = NULL  
)  
AS  
BEGIN TRY  
      SET NOCOUNT ON    
      DECLARE @l_numberOfRecordsInserted INT    
 -- Check if valid Application User ID is passed          
      IF ( @i_AppUserId IS NULL )  
      OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.' ,  
               17 ,  
               1 ,  
               @i_AppUserId )  
         END      
      
---------insert operation into HealthCareQualityMeasure  table-----         
      INSERT INTO  
          HealthCareQualityMeasure  
          (  
			HealthCareQualityBCategoryId ,  
			HealthCareQualityMeasureName ,  
			CreatedByUserId ,  
			HealthCareQualityStandardId ,  
			StatusCode ,  
			ReportingYear ,  
			ReportingPeriod ,  
			AdminOrClincFlag ,  
			SpecialityIDList ,  
			ProviderIDList ,  
			AdminClassificationIDList ,  
			ProgramID ,  
			DiseaseID ,  
			CloneMeasureName ,  
			CopyType  
          )  
      VALUES  
          (  
			@i_HealthCareQualityBCategoryId ,  
			@v_HealthCareQualityMeasureName ,  
			@i_AppUserId ,  
			@i_HealthCareQualityStandardId ,  
			@v_StatusCode ,  
			@i_ReportingYear ,  
			@v_ReportingPeriod ,  
			@c_AdminOrClincFlag ,  
			@v_SpecialityIDList ,  
			@v_ProviderIDList ,  
			@v_AdminClassificationIDList ,  
			@i_ProgramID ,  
			@i_DiseaseID ,  
			@v_CloneMeasureName ,  
			@c_CopyType			 
          )  
  
      SET @i_HealthCareQualityMeasureID = SCOPE_IDENTITY()  
        
      INSERT INTO HealthCareQualityMeasureNrDrDefinition  
      (  
			  HealthCareQualityMeasureID ,  
			  NrDrIndicator ,  
			  CriteriaSQL ,  
			  CriteriaText , 
			  JoinType,
			  JoinStatement,
			  OnClause,
			  WhereClause ,
			  CriteriaTypeID ,  
			  CreatedByUserId  
	   )   
		SELECT   
			  @i_HealthCareQualityMeasureID ,  
			  Criteria.NrDrIndicator ,  
			  Criteria.CriteriaSQL ,  
			  Criteria.CriteriaText ,
			  Criteria.JoinType,
			  Criteria.JoinStatement,
			  Criteria.OnClause,
			  Criteria.WhereClause ,
		( 
		  SELECT  
                    CohortListCriteriaTypeId  
			FROM  
                    CohortListCriteriaType  
            WHERE  
                    CohortListCriteriaType.CriteriaTypeName = Criteria.CriteriaTypeName   
        ) ,  
        @i_AppUserId  
		FROM @t_HealthCareCriteriaSQLTest Criteria  
        
      SET @l_numberOfRecordsInserted = @@ROWCOUNT  
   IF @l_numberOfRecordsInserted < 1  
     BEGIN  
   RAISERROR  
    ( N'Invalid row count %d in insert HealthCareQualityMeasureNrDrDefinition'  
       ,17        
       ,1        
       ,@l_numberOfRecordsInserted                   
       )   
     END   
                          
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
    ON OBJECT::[dbo].[usp_HealthCareQualityMeasure_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

