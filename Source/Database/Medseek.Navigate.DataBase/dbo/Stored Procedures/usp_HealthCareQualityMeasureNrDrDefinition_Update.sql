/*        
------------------------------------------------------------------------------        
Procedure Name: usp_HealthCareQualityMeasureNrDrDefinition_Update       
Description   : This procedure is used to Update record into HealthCareQualityMeasureNrDrDefinition table    
Created By    : Rathnam
Created Date  : 09-Dev-2011       
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_HealthCareQualityMeasureNrDrDefinition_Update]
(
 @i_AppUserId KEYID
,@i_HealthCareQualityMeasureNrDrDefinitionID KEYID
,@i_HealthCareQualityMeasureID KEYID
,@c_NrDrIndicator CHAR(1)
,@v_CriteriaText VARCHAR(MAX)
,@v_JoinType VARCHAR(20)
,@v_JoinStatement VARCHAR(MAX)
,@v_OnClause VARCHAR(200)
,@v_WhereClause VARCHAR(MAX)
,@v_CriteriaTypeName VARCHAR(50)
)
AS
BEGIN TRY
      SET NOCOUNT ON
      DECLARE @l_numberOfRecordsUpdated INT
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END

      DECLARE @i_CohortListCriteriaTypeId KEYID
      SELECT
          @i_CohortListCriteriaTypeId = CohortListCriteriaTypeId
      FROM
          CohortListCriteriaType
      WHERE
          CohortListCriteriaType.CriteriaTypeName = @v_CriteriaTypeName

      UPDATE
          HealthCareQualityMeasureNrDrDefinition
      SET
          HealthCareQualityMeasureID = @i_HealthCareQualityMeasureID
         ,NrDrIndicator = @c_NrDrIndicator
         ,CriteriaSQL = @v_JoinType + '' +@v_JoinStatement+ '' +@v_OnClause+ '' +@v_WhereClause
         ,CriteriaText = @v_CriteriaText
         ,JoinType = @v_JoinType
		 ,JoinStatement = @v_JoinStatement 
		 ,OnClause = @v_OnClause 
		 ,WhereClause = @v_WhereClause 
         ,CriteriaTypeID = @i_CohortListCriteriaTypeId
         ,LastModifiedByUserId = @i_AppUserId
         ,LastModifiedDate = GETDATE()
      WHERE
          HealthCareQualityMeasureNrDrDefinitionID = @i_HealthCareQualityMeasureNrDrDefinitionID


      SELECT
          @l_numberOfRecordsUpdated = @@ROWCOUNT

      IF @l_numberOfRecordsUpdated <> 1
         BEGIN
               RAISERROR ( N'Invalid row count %d in Update HealthCareQualityMeasureNrDrDefinition'
               ,17
               ,1
               ,@l_numberOfRecordsUpdated )
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
    ON OBJECT::[dbo].[usp_HealthCareQualityMeasureNrDrDefinition_Update] TO [FE_rohit.r-ext]
    AS [dbo];

