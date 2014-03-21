/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_PQRIQualityMeasureGroup_InsertUpdate]    
Description   : This procedure used to insert the records into PQRIQualityMeasureGroup,
                PQRIQualityMeasureGroupTOMeasure table or update the records into
                PQRIQualityMeasureGroup table.
Created By    : Rathnam
Created Date  : 15-Dec-2010
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
07-Jan-2011 NagaBabu Added if exists conditions 
12-Jan-2011 NagaBabu Added MigratedPQRIQualityMeasureGroupID,IsAllowEdit to Insert,Update statements
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureGroup_InsertUpdate]
       (
        @i_AppUserId KEYID
       ,@v_PQRIMeasureGroupID SHORTDESCRIPTION
       ,@v_Name SHORTDESCRIPTION
       ,@v_Description LONGDESCRIPTION
       ,@v_StatusCode STATUSCODE
       ,@i_ReportingYear SMALLINT
       ,@i_ReportingPeriod SMALLINT
       ,@v_ReportingPeriodType VARCHAR(1)
       ,@i_PerformancePeriod SMALLINT
       ,@v_PerformancePeriodType VARCHAR(1)
       ,@v_GCode VARCHAR(5)
       ,@v_CompositeGCode VARCHAR(5)
       ,@b_IsBFFS ISINDICATOR
       ,@i_DocumentLibraryID KEYID
       ,@i_DocumentStartPage INT
       ,@v_SubmissionMethod VARCHAR(2)
       ,@v_ReportingMethod VARCHAR(20)
       ,@v_Note VARCHAR(200)
       ,@t_PQRIQualityMeasureID TTYPEKEYID READONLY
       ,@o_PQRIQualityMeasureGroupID KEYID OUTPUT
       ,@i_PQRIQualityMeasureGroupID KEYID = NULL
       ,@o_ErrorNumber KEYID OUTPUT
       ,@i_MigratedPQRIQualityMeasureGroupID KEYID = NULL 
       ,@b_IsAllowEdit ISINDICATOR
       )
AS
BEGIN TRY
      SET NOCOUNT ON
	-- Check if valid Application User ID is passed 
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END
      DECLARE @b_TranStarted BIT = 0
      IF ( @@TRANCOUNT = 0 )
         BEGIN
               BEGIN TRANSACTION
               SET @b_TranStarted = 1  -- Indicator for start of transactions
         END
      ELSE
         SET @b_TranStarted = 0
         
      IF @i_PQRIQualityMeasureGroupID IS NOT NULL
         BEGIN
			 IF EXISTS( SELECT 
							1
						FROM
							PQRIQualityMeasureGroup
						WHERE
							PQRIMeasureGroupID = @v_PQRIMeasureGroupID 
						AND ReportingYear = @i_ReportingYear 
						AND PQRIQualityMeasureGroupID <> @i_PQRIQualityMeasureGroupID)
						
				  SELECT @o_ErrorNumber = 1	
				  	 
			 ELSE
				 BEGIN	  
					   UPDATE
						   PQRIQualityMeasureGroup
					   SET
						   PQRIMeasureGroupID = @v_PQRIMeasureGroupID
						  ,Name = @v_Name
						  ,Description = @v_Description
						  ,StatusCode = @v_StatusCode
						  ,ReportingYear = @i_ReportingYear
						  ,ReportingPeriod = @i_ReportingPeriod
						  ,ReportingPeriodType = @v_ReportingPeriodType
						  ,PerformancePeriod = @i_PerformancePeriod
						  ,PerformancePeriodType = @v_PerformancePeriodType
						  ,GCode = @v_GCode
						  ,CompositeGCode = @v_CompositeGCode
						  ,IsBFFS = @b_IsBFFS
						  ,DocumentLibraryID = @i_DocumentLibraryID
						  ,DocumentStartPage = @i_DocumentStartPage
						  ,SubmissionMethod = @v_SubmissionMethod
						  ,ReportingMethod = @v_ReportingMethod
						  ,Note = @v_Note
						  ,LastModifiedByUserId = @i_AppUserId
						  ,LastModifiedDate = GETDATE()
						  ,MigratedPQRIQualityMeasureGroupID = @i_MigratedPQRIQualityMeasureGroupID
						  ,IsAllowEdit = @b_IsAllowEdit
					   WHERE
						   PQRIQualityMeasureGroupID = @i_PQRIQualityMeasureGroupID
		                   
					   INSERT INTO
						   PQRIQualityMeasureGroupToMeasure
						   (
							PQRIQualityMeasureGroupId
						   ,PQRIQualityMeasureID
						   ,CreatedByUserId
						   )
						   SELECT
							   @i_PQRIQualityMeasureGroupID
							  ,tblPQRIMID.tKeyId
							  ,@i_AppUserId
						   FROM
							   @t_PQRIQualityMeasureID tblPQRIMID
						   WHERE
							   NOT EXISTS ( SELECT
												1
											FROM
												PQRIQualityMeasureGroupToMeasure
											WHERE
												PQRIQualityMeasureID = tblPQRIMID.tKeyId
											AND PQRIQualityMeasureGroupId = @i_PQRIQualityMeasureGroupID )  
                 END   
         END
      ELSE
         BEGIN
			 IF EXISTS( SELECT 
							1
						FROM
							PQRIQualityMeasureGroup
						WHERE
							PQRIMeasureGroupID = @v_PQRIMeasureGroupID 
						AND ReportingYear = @i_ReportingYear )
						
				 SELECT @o_ErrorNumber = 1
				 		  
			 ELSE	 	
			 	BEGIN 	
				   INSERT INTO
					   PQRIQualityMeasureGroup
					   (
						PQRIMeasureGroupID
					   ,Name
					   ,Description
					   ,StatusCode
					   ,ReportingYear
					   ,ReportingPeriod
					   ,ReportingPeriodType
					   ,PerformancePeriod
					   ,PerformancePeriodType
					   ,GCode
					   ,CompositeGCode
					   ,IsBFFS
					   ,DocumentLibraryID
					   ,DocumentStartPage
					   ,SubmissionMethod
					   ,ReportingMethod
					   ,CreatedByUserId
					   ,Note
					   ,MigratedPQRIQualityMeasureGroupID 
					   ,IsAllowEdit 
					   )
				   VALUES
					   (
						@v_PQRIMeasureGroupID
					   ,@v_Name
					   ,@v_Description
					   ,@v_StatusCode
					   ,@i_ReportingYear
					   ,@i_ReportingPeriod
					   ,@v_ReportingPeriodType
					   ,@i_PerformancePeriod
					   ,@v_PerformancePeriodType
					   ,@v_GCode
					   ,@v_CompositeGCode
					   ,@b_IsBFFS
					   ,@i_DocumentLibraryID
					   ,@i_DocumentStartPage
					   ,@v_SubmissionMethod
					   ,@v_ReportingMethod
					   ,@i_AppUserId
					   ,@v_Note
					   ,@i_MigratedPQRIQualityMeasureGroupID 
					   ,@b_IsAllowEdit 
					   )

				   SELECT
					   @o_PQRIQualityMeasureGroupID = SCOPE_IDENTITY()

				   INSERT INTO
					   PQRIQualityMeasureGroupToMeasure
					   (
						PQRIQualityMeasureGroupId
					   ,PQRIQualityMeasureID
					   ,CreatedByUserId
					   )
					   SELECT
						   @o_PQRIQualityMeasureGroupID
						  ,tblPQRIMID.tKeyId
						  ,@i_AppUserId
					   FROM
						   @t_PQRIQualityMeasureID tblPQRIMID
					   --WHERE NOT EXISTS ( SELECT
					   --                     1
					   --                 FROM
					   --                     PQRIQualityMeasureGroupToMeasure
					   --                 WHERE
					   --                     PQRIQualityMeasureID = tblPQRIMID.tKeyId
					   --                 AND PQRIQualityMeasureGroupId = @o_PQRIQualityMeasureGroupID )  
                END  
         END
         
      IF ( @b_TranStarted = 1 )  -- If transactions are there, then commit
         BEGIN
               SET @b_TranStarted = 0
               COMMIT TRANSACTION
         END
      ELSE
         BEGIN
               ROLLBACK TRANSACTION
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureGroup_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

