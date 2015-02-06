/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserQuestionaire_Insert    
Description   : This procedure is used to insert record into UserQuestionaire table
Created By    : Aditya    
Created Date  : 26-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION  
09-Jun-2011 Rathnam added @i_DiseaseId  , @b_IsPreventive parameters
09-Nov-2011 NagaBabu Added @i_ProgramId as input parameter
03-feb-2011 Sivakrishna Added @b_IsAdhoc paramete  to maintain the adhoc task records in  UserQuestionaire table 
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_UserQuestionaire_Insert]  
(  
	@i_AppUserId KeyID,  
	@i_UserId KeyID,
	@i_QuestionaireId KeyID,
	@dt_DateTaken UserDate,
	@dt_DateDue UserDate,
	@dt_DateAssigned UserDate,
	@vc_Comments VARCHAR(4000),
	@o_UserQuestionaireId KeyID OUTPUT,
	@i_DiseaseId KeyID = NULL,
	@b_IsPreventive IsIndicator = 0,
	@i_ProgramId KeyID = NULL ,
	@b_IsAdhoc BIT = 0,
	@i_AssignedCareProviderId keyid = NULL 
	
)  
AS  
BEGIN TRY
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsInserted INT   
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

	INSERT INTO PatientQuestionaire
	   ( 
			PatientId,
			QuestionaireId,
			DateTaken,
			DateDue,
			DateAssigned,
			Comments,
			CreatedByUserId,
			--DiseaseId,
			IsPreventive,
			ProgramId ,
			IsAdhoc ,
			AssignedCareProviderId
	   )
	VALUES
	   (
			@i_UserId,
			@i_QuestionaireId,
			@dt_DateTaken,
			@dt_DateDue,
			@dt_DateAssigned,
			@vc_Comments,
			@i_AppUserId,
			--@i_DiseaseId,
			@b_IsPreventive,
			@i_ProgramId ,
			@b_IsAdhoc,
			@i_AssignedCareProviderId
	   )
	   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_UserQuestionaireId = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert document Type'
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
    ON OBJECT::[dbo].[usp_UserQuestionaire_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

