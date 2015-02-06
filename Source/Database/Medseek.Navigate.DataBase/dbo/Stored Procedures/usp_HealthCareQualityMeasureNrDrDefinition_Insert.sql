/*          
------------------------------------------------------------------------------          
Procedure Name: [usp_HealthCareQualityMeasureNrDrDefinition_Insert]          
Description   : This procedure is used to insert the data into HealthCareQualityMeasureNrDrDefinition table      
Created By    : Rathnam          
Created Date  : 12-Nov-2010          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION   
09-Dec-2011 Rathnam Removed the table type parameter  
23-Dec-2011	Gurumoorthy.V Added Parameters @v_JoinType,@v_JoinStatement,@v_OnClause,@v_WhereClause and included in Insert statement
------------------------------------------------------------------------------          
*/

CREATE PROCEDURE [dbo].[usp_HealthCareQualityMeasureNrDrDefinition_Insert]
(
 @i_AppUserId KEYID
,@i_HealthCareQualityMeasureID KEYID
,@c_NrDrIndicator CHAR(1)
,@v_CriteriaText VARCHAR(MAX)
,@v_JoinType VARCHAR(20)
,@v_JoinStatement VARCHAR(MAX)
,@v_OnClause VARCHAR(200)
,@v_WhereClause VARCHAR(MAX)
,@v_CriteriaTypeName VARCHAR(50)
,@o_HealthCareQualityMeasureNrDrDefinitionID KEYID OUTPUT
)
AS
BEGIN
      BEGIN TRY
            SET NOCOUNT ON
            DECLARE @i_NumberOfRecordsInserted INT    
 -- Check if valid Application User ID is passed          
            IF ( @i_AppUserId IS NULL )
            OR ( @i_AppUserId <= 0 )
               BEGIN
                     RAISERROR ( N'Invalid Application User ID %d passed.'
                     ,17
                     ,1
                     ,@i_AppUserId )
               END      
      
---------Insert operation HealthCareQualityMeasureNrDrDefinition table-----         
            INSERT INTO
                HealthCareQualityMeasureNrDrDefinition
                (
                 HealthCareQualityMeasureID
                ,NrDrIndicator
                ,CriteriaSQL
                ,CriteriaText
                ,JoinType
				,JoinStatement
				,OnClause
				,WhereClause
                ,CriteriaTypeID
                ,CreatedByUserId
                )
            VALUES
                (
                 @i_HealthCareQualityMeasureID
                ,@c_NrDrIndicator
                ,@v_JoinType + '' +@v_JoinStatement+ '' +@v_OnClause+ '' +@v_WhereClause
                ,@v_CriteriaText
                ,@v_JoinType
				,@v_JoinStatement
				,@v_OnClause
				,@v_WhereClause
                ,( SELECT
                       CohortListCriteriaTypeId
                   FROM
                       CohortListCriteriaType
                   WHERE
                       CohortListCriteriaType.CriteriaTypeName = @v_CriteriaTypeName )
                ,@i_AppUserId
                )

            SELECT
                @i_NumberOfRecordsInserted = @@ROWCOUNT
               ,@o_HealthCareQualityMeasureNrDrDefinitionID = SCOPE_IDENTITY()

            IF @i_NumberOfRecordsInserted < 1
               BEGIN
                     RAISERROR ( N'Invalid row count %d in insert HealthCareQualityMeasureNrDrDefinition'
                     ,17
                     ,1
                     ,@i_NumberOfRecordsInserted )
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
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HealthCareQualityMeasureNrDrDefinition_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

