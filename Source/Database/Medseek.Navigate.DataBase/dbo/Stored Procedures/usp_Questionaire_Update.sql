/*
-------------------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_Questionaire_Update]
Description   : This procedure is used to update records into Questionaire table. 
Created By    :	Balla Kalyan 
Created Date  : 15-Mar-2010
-------------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
29-June-2010 NagaBabu  Deleted ProgramId firld in Update Statement   
28-Sep-2011	Gurumoorthy.V Added @i_MaxScore parameter,and included in insert statement

-------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_Questionaire_Update]
(
 @i_AppUserId KEYID ,
 @i_QuestionaireId KEYID ,
 @vc_QuestionaireName SHORTDESCRIPTION ,
 @vc_Description LONGDESCRIPTION ,
 @i_QuestionaireTypeId KEYID ,
 @i_DiseaseID KEYID ,
 --@i_ProgramID KEYID = NULL ,
 @i_MaxScore INT,
 @vc_StatusCode STATUSCODE 
 
)
AS
BEGIN TRY 

	DECLARE @l_numberOfRecordsUpdated INT
	
	-- Check if valid Application User ID is passed
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END
-------- Check for DUPLICATE RECORDS --------------------------------------
      IF EXISTS ( SELECT
                      1
                  FROM
                      Questionaire
                  WHERE
                      QuestionaireName = @vc_QuestionaireName 
					AND QuestionaireId <> @i_QuestionaireId )
         BEGIN
               RETURN 1 -- Duplicate entry
         END
      ELSE 

------------------Update operation for Questionaire table  -----	
         BEGIN

               UPDATE
                   Questionaire
               SET
                   QuestionaireName = @vc_QuestionaireName ,
                   Description = @vc_Description ,
                   QuestionaireTypeId = @i_QuestionaireTypeId ,
                   DiseaseID = @i_DiseaseID ,
                   --ProgramID = @i_ProgramID ,
                   LastModifiedByUserId = @i_AppUserId ,
                   LastModifiedDate = GETDATE() ,
                   StatusCode = @vc_StatusCode,
				   MaxScore=@i_MaxScore
               WHERE
                   Questionaire.QuestionaireId = @i_QuestionaireId
                   
              SET @l_numberOfRecordsUpdated = @@ROWCOUNT

              IF @l_numberOfRecordsUpdated <> 1
              BEGIN
                    RAISERROR ( N'Invalid Row count %d passed to update Questionaire Details' ,
                    17 ,
                    1 ,
                    @l_numberOfRecordsUpdated )
              END
              RETURN 0

         END
END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Questionaire_Update] TO [FE_rohit.r-ext]
    AS [dbo];

