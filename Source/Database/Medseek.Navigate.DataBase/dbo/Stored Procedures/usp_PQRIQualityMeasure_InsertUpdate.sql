/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_PQRIQualityMeasure_InsertUpdate]    
Description   : This procedure used to insert the records into PQRIQualityMeasure,
                PQRIQualityMeasureGroupToMeasure table or update the records into
                PQRIQualityMeasure table.
Created By    : Rathnam
Created Date  : 15-Dec-2010
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION   
25-Dec-2010 Rama Raplaced PQRIQualityMeasuretoMeasureGroup by  PQRIQualityMeasureGroupToMeasure table
07-Jan-2011 NagaBabu Added if exists conditions 
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasure_InsertUpdate]
       (
        @i_AppUserId KEYID
       ,@i_PQRIMeasureID KEYID
       ,@v_Name SHORTDESCRIPTION
       ,@v_Description LONGDESCRIPTION
       ,@v_StatusCode STATUSCODE
       ,@i_ReportingYear SMALLINT
       ,@i_ReportingPeriod SMALLINT
       ,@v_ReportingPeriodType VARCHAR(1)
       ,@i_PerformancePeriod SMALLINT
       ,@v_PerformancePeriodType VARCHAR(1)
       ,@b_IsBFFS ISINDICATOR
       ,@i_DocumentLibraryID KEYID
       ,@i_DocumentStartPage INT
       ,@v_SubmissionMethod VARCHAR(2)
       ,@v_ReportingMethod VARCHAR(20)
       ,@v_Note VARCHAR(200)
       ,@t_PQRIQualityMeasureGroupID TTYPEKEYID READONLY
       ,@o_PQRIQualityMeasureID KEYID OUTPUT
       ,@i_PQRIQualityMeasureID KEYID = NULL
       ,@o_ErrorNumber KEYID OUTPUT
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
      DECLARE @b_TranStarted BIT = 0
      IF ( @@TRANCOUNT = 0 )
         BEGIN
               BEGIN TRANSACTION
               SET @b_TranStarted = 1  -- Indicator for start of transactions
         END
      ELSE
         SET @b_TranStarted = 0

      IF @i_PQRIQualityMeasureID IS NOT NULL 
         BEGIN
			 IF EXISTS( SELECT 
							1
						FROM
							PQRIQualityMeasure
						WHERE
							PQRIMeasureID = @i_PQRIMeasureID 
						AND ReportingYear = @i_ReportingYear 
						AND PQRIQualityMeasureID <> @i_PQRIQualityMeasureID)
				  	
				  SELECT @o_ErrorNumber = 1		
				   
			 ELSE
				BEGIN					 	  	 
				   UPDATE
					   PQRIQualityMeasure
				   SET
					   PQRIMeasureID = @i_PQRIMeasureID
					  ,Name = @v_Name
					  ,Description = @v_Description
					  ,StatusCode = @v_StatusCode
					  ,ReportingYear = @i_ReportingYear
					  ,ReportingPeriod = @i_ReportingPeriod
					  ,ReportingPeriodType = @v_ReportingPeriodType
					  ,PerformancePeriod = @i_PerformancePeriod
					  ,PerformancePeriodType = @v_PerformancePeriodType
					  ,IsBFFS = @b_IsBFFS
					  ,DocumentLibraryID = @i_DocumentLibraryID
					  ,DocumentStartPage = @i_DocumentStartPage
					  ,SubmissionMethod = @v_SubmissionMethod
					  ,ReportingMethod = @v_ReportingMethod
					  ,Note = @v_Note
					  ,LastModifiedByUserId = @i_AppUserId
					  ,LastModifiedDate = GETDATE()
				   WHERE
					   PQRIQualityMeasureID = @i_PQRIQualityMeasureID

				   INSERT INTO
					   PQRIQualityMeasureGroupToMeasure
					   (
						PQRIQualityMeasureGroupId
					   ,PQRIQualityMeasureID
					   ,CreatedByUserId
					   )
					   SELECT
						   tblPQRIMGID.tKeyId
						  ,@i_PQRIQualityMeasureID
						  ,@i_AppUserId
					   FROM
						   @t_PQRIQualityMeasureGroupID tblPQRIMGID
					   WHERE
						   NOT EXISTS ( SELECT
											1
										FROM
											PQRIQualityMeasureGroupToMeasure
										WHERE
											PQRIQualityMeasureID = @i_PQRIQualityMeasureID
										   AND PQRIQualityMeasureGroupId = tblPQRIMGID.tKeyId )
				END
         END
      ELSE
         BEGIN
			 IF EXISTS( SELECT 
							1
						FROM
							PQRIQualityMeasure
						WHERE
							PQRIMeasureID = @i_PQRIMeasureID 
						AND ReportingYear = @i_ReportingYear )
				  
				  SELECT @o_ErrorNumber = 1	
				  
			 ELSE				
				BEGIN				
			 						
				   INSERT INTO
					   PQRIQualityMeasure
					   (
						 PQRIMeasureID
					   ,Name
					   ,Description
					   ,StatusCode
					   ,ReportingYear
					   ,ReportingPeriod
					   ,ReportingPeriodType
					   ,PerformancePeriod
					   ,PerformancePeriodType
					   ,IsBFFS
					   ,DocumentLibraryID
					   ,DocumentStartPage
					   ,SubmissionMethod
					   ,ReportingMethod
					   ,CreatedByUserId
					   ,Note
					   )
				   VALUES
					   (
						@i_PQRIMeasureID
					   ,@v_Name
					   ,@v_Description
					   ,@v_StatusCode
					   ,@i_ReportingYear
					   ,@i_ReportingPeriod
					   ,@v_ReportingPeriodType
					   ,@i_PerformancePeriod
					   ,@v_PerformancePeriodType
					   ,@b_IsBFFS
					   ,@i_DocumentLibraryID
					   ,@i_DocumentStartPage
					   ,@v_SubmissionMethod
					   ,@v_ReportingMethod
					   ,@i_AppUserId
					   ,@v_Note
					   )

				   SELECT
					   @o_PQRIQualityMeasureID = SCOPE_IDENTITY()

				   INSERT INTO
					   PQRIQualityMeasureGroupToMeasure
					   (
						PQRIQualityMeasureGroupId
					   ,PQRIQualityMeasureID
					   ,CreatedByUserId
					   )
					   SELECT
						   tblPQRIMGID.tKeyId
						  ,@o_PQRIQualityMeasureID
						  ,@i_AppUserId
					   FROM
						   @t_PQRIQualityMeasureGroupID tblPQRIMGID
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasure_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

