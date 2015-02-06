/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_PQRIProviderPersonalization_InsertUpdate]    
Description   : This procedure is used to insert record into PQRIProviderPersonalization table
Created By    : Rathnam
Created Date  : 16-Dec-2010
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION
11-Jan-2011 NagaBabu Added 'IF NOT EXISTS' statement at the top of first insert statement
						and modified where clause in first update statement
12-Jan-2011 NagaBabu Deleted @v_SampleType and Added @v_QualityMeasureReportingMethod,@v_QualityMeasureGroupReportingMethod						
16-Feb-2011 Rathnam @i_PQRIProviderPersonalizationID commented becoz it will not used as input parameter
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_PQRIProviderPersonalization_InsertUpdate]
       (
        @i_AppUserId KEYID
       ,@i_ProviderUserID KEYID
       ,@i_ReportingYear SMALLINT
       ,@i_ReportingPeriod VARCHAR(1)
       ,@v_SubmissionMethod VARCHAR(2)
       ,@v_QualityMeasureReportingMethod VARCHAR(20)
       ,@v_QualityMeasureGroupReportingMethod VARCHAR(50)
       ,@b_IsAllowEdit ISINDICATOR
       ,@v_StatusCode STATUSCODE
       ,@t_PQRIQualityMeasureID TTYPEKEYID READONLY
       ,@t_PQRIQualityMeasureGroupID TTYPEKEYID READONLY
       --,@i_PQRIProviderPersonalizationID KEYID = NULL
       ,@o_PQRIProviderPersonalizationID KEYID OUTPUT
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

	--------- Insert Operation into PQRIProviderPersonalization starts here -------------------
      DECLARE @b_TranStarted BIT = 0
      IF ( @@TRANCOUNT = 0 )
         BEGIN
               BEGIN TRANSACTION
               SET @b_TranStarted = 1  -- Indicator for start of transactions
         END
      ELSE
         SET @b_TranStarted = 0
     
      IF NOT EXISTS ( SELECT
                          1
                      FROM
                          PQRIProviderPersonalization
                      WHERE
                          ProviderUserID = @i_ProviderUserID
                          AND ReportingYear = @i_ReportingYear 
                    )

         BEGIN
               INSERT INTO
                   PQRIProviderPersonalization
                   (
                    ProviderUserID
                   ,ReportingYear
                   ,ReportingPeriod
                   ,SubmissionMethod
                   ,QualityMeasureReportingMethod
                   ,QualityMeasureGroupReportingMethod
                   ,IsAllowEdit
                   ,StatusCode
                   ,CreatedByUserId
                   )
               VALUES
                   (
                    @i_ProviderUserID
                   ,@i_ReportingYear
                   ,@i_ReportingPeriod
                   ,@v_SubmissionMethod
                   ,@v_QualityMeasureReportingMethod
                   ,@v_QualityMeasureGroupReportingMethod
                   ,@b_IsAllowEdit
                   ,@v_StatusCode
                   ,@i_AppUserId
                   )

               SET @o_PQRIProviderPersonalizationID = SCOPE_IDENTITY()

               IF EXISTS ( SELECT
                               1
                           FROM
                               @t_PQRIQualityMeasureID 
                         )
                  BEGIN
                        INSERT INTO
                            PQRIProviderQualityMeasure
                            (
                              PQRIProviderPersonalizationID
                            ,PQRIQualityMeasureID
                            ,CreatedByUserId
                            )
                            SELECT
                                @o_PQRIProviderPersonalizationID
                               ,tblQMID.tKeyId
                               ,@i_AppUserId
                            FROM
                                @t_PQRIQualityMeasureID tblQMID

                  END

               IF EXISTS ( SELECT
                               1
                           FROM
                               @t_PQRIQualityMeasureGroupID 
                         )
                  BEGIN
                        INSERT INTO
                            PQRIProviderQualityMeasureGroup
                            (
                              PQRIProviderPersonalizationID
                            ,PQRIQualityMeasureGroupID
                            ,CreatedByUserId
                            )
                            SELECT
                                @o_PQRIProviderPersonalizationID
                               ,tblQMGID.tKeyId
                               ,@i_AppUserId
                            FROM
                                @t_PQRIQualityMeasureGroupID tblQMGID

                  END
         END
      ELSE
         BEGIN
               UPDATE
                   PQRIProviderPersonalization
               SET
                   ProviderUserID = @i_ProviderUserID
                  ,ReportingYear = @i_ReportingYear
                  ,ReportingPeriod = @i_ReportingPeriod
                  ,SubmissionMethod = @v_SubmissionMethod
                  ,QualityMeasureReportingMethod = @v_QualityMeasureReportingMethod
                  ,QualityMeasureGroupReportingMethod = @v_QualityMeasureGroupReportingMethod
                  ,IsAllowEdit = @b_IsAllowEdit
                  ,StatusCode = @v_StatusCode
                  ,LastModifiedByUserId = @i_AppUserId
                  ,LastModifiedDate = GETDATE()
               WHERE
                   ProviderUserID = @i_ProviderUserID
                   AND ReportingYear = @i_ReportingYear

               DECLARE @i_PQRIProviderPersonalizationID KEYID
               SELECT @i_PQRIProviderPersonalizationID = PQRIProviderPersonalizationID
               FROM
                   PQRIProviderPersonalization
               WHERE
                   ProviderUserID = @i_ProviderUserID
                   AND ReportingYear = @i_ReportingYear 


               IF EXISTS ( SELECT
                               1
                           FROM
                               @t_PQRIQualityMeasureID 
                         )
                  BEGIN
                        INSERT INTO
                            PQRIProviderQualityMeasure
                            (
                             PQRIProviderPersonalizationID
                            ,PQRIQualityMeasureID
                            ,CreatedByUserId
                            )
                            SELECT
                                @i_PQRIProviderPersonalizationID
                               ,tblQMID.tKeyId
                               ,@i_AppUserId
                            FROM
                                @t_PQRIQualityMeasureID tblQMID
                            WHERE
                                NOT EXISTS ( SELECT
                                                 1
                                             FROM
                                                 PQRIProviderQualityMeasure
                                             WHERE
                                                 PQRIProviderPersonalizationID = @i_PQRIProviderPersonalizationID
                                                 AND PQRIQualityMeasureID = tblQMID.tKeyId 
                                            )

                  END

               IF EXISTS ( SELECT
                               1
                           FROM
                               @t_PQRIQualityMeasureGroupID 
                         )
                  BEGIN
                        INSERT INTO
                            PQRIProviderQualityMeasureGroup
                            (
                             PQRIProviderPersonalizationID
                            ,PQRIQualityMeasureGroupID
                            ,CreatedByUserId
                            )
                            SELECT
                                @i_PQRIProviderPersonalizationID
                               ,tblQMGID.tKeyId
                               ,@i_AppUserId
                            FROM
                                @t_PQRIQualityMeasureGroupID tblQMGID
                            WHERE
                                NOT EXISTS ( SELECT
                                                 1
                                             FROM
                                                 PQRIProviderQualityMeasureGroup
                                             WHERE
                                                 PQRIProviderPersonalizationID = @i_PQRIProviderPersonalizationID
                                                 AND PQRIQualityMeasureGroupID = tblQMGID.tKeyId 
                                           )

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
    ON OBJECT::[dbo].[usp_PQRIProviderPersonalization_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

