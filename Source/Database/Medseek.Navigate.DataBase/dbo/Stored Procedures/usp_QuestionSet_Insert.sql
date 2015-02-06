/*
-------------------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_QuestionSet_Insert]
Description   : This procedure is used to insert records into Questionaire table. 
Created By    :	Aditya
Created Date  : 19-Mar-2010
-------------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
20-Apr-10	Pramod	
29-Sep-2010 NagaBabu Applied Transaction to this SP
08-11-2011  Sivakrishna Changed @vc_QuestionSetName param datatype from Shortdescription to LongDescription
-------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_QuestionSet_Insert]
(
	@i_AppUserId KEYID ,
	@vc_QuestionSetName LongDescription,
	@vc_Description LongDescription,
	@i_SortOrder STID,
	@i_QuestionaireId KeyID,
	@b_IsShowPanel IsIndicator,
	@b_IsShowQuestionSetName IsIndicator,
	@o_QuestionSetId INT OUTPUT
)
AS
BEGIN TRY 

	-- Check if valid Application User ID is passed
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
    BEGIN
           RAISERROR ( N'Invalid Application User ID %d passed.' ,
           17 ,
           1 ,
           @i_AppUserId )
    END
-------- Check for DUPLICATE RECORDS --------------------------------------
--      IF EXISTS ( SELECT
--                      1
--                  FROM
--                      QuestionSet
--                  WHERE
--                      QuestionSetName = @vc_QuestionSetName )
--         BEGIN
--               RETURN 1  -- Duplicate entry
--         END
--      ELSE 

--------------------insert operation into QuestionSet table-----	
--         BEGIN
	 DECLARE @l_TranStarted BIT =0
	 IF(@@TRANCOUNT = 0)
		BEGIN
			BEGIN TRANSACTION
			SET @l_TranStarted = 1
		END
	 ELSE
		SET @l_TranStarted = 0 		 

	 INSERT INTO
		   QuestionSet
		   (
			 QuestionSetName ,
			 Description ,
			 SortOrder,
			 CreatedByUserId 
			)
	 VALUES
		   (
			 @vc_QuestionSetName ,
			 @vc_Description ,
			 @i_SortOrder,
      		 @i_AppUserId
			)
      
	 SET @o_QuestionSetId = SCOPE_IDENTITY()
	   
	 DECLARE @o_QuestionaireQuestionSetId KeyID
	 
	 EXEC usp_QuestionaireQuestionSet_Insert
		  @i_AppUserId,
		  @i_QuestionaireId,
		  @o_QuestionSetId,
		  @i_SortOrder,
		  @b_IsShowPanel,
		  @b_IsShowQuestionSetName,
		  @o_QuestionaireQuestionSetId OUTPUT
	 
	 IF( @l_TranStarted = 1 )  -- If transactions are there then commit  
		BEGIN  
			SET @l_TranStarted = 0  
			COMMIT TRANSACTION   
		END
	  ELSE
		  BEGIN
			  ROLLBACK TRANSACTION
		  END   	  

	 RETURN 0

         --END
END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_QuestionSet_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

