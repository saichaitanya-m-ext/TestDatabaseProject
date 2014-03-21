/*      
-------------------------------------------------------------------------------------      
Procedure Name: usp_Question_Select
Description   : This procedure is used to select records from Question table
Created By    : Pramod
Created Date  : 31-Mar-2010
-------------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      

-------------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_Question_Select]    
(    
	@i_AppUserId KeyID,
	@i_QuestionId KeyID,
    @v_StatusCode StatusCode = NULL
)    
AS    
BEGIN TRY  

	SET NOCOUNT ON    
	DECLARE @l_numberOfRecordsChanged INT

	-- Check if valid Application User ID is passed      
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )    
	BEGIN    
	 RAISERROR   
	 ( N'Invalid Application User ID %d passed.' ,    
	   17 ,    
	   1 ,    
	   @i_AppUserId  
	 )    
	END    
  
	SELECT 
			Question.QuestionId
			,Question.QuestionTypeID
			,Question.Description
			,Question.QuestionText
			,Question.AnswerTypeId
			,Question.ImageNameAndPath
			,Question.ImageContentType
			,Question.UsercontrolName
			,CreatedByUserId
			,CreatedDate
			,LastModifiedByUserId
			,LastModifiedDate
			,StatusCode
			,Question.DataSource
	  FROM Question WITH(NOLOCK)
	 WHERE QuestionId = @i_QuestionId
	   AND ( @v_StatusCode IS NULL or Question.StatusCode = @v_StatusCode )

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
    ON OBJECT::[dbo].[usp_Question_Select] TO [FE_rohit.r-ext]
    AS [dbo];

