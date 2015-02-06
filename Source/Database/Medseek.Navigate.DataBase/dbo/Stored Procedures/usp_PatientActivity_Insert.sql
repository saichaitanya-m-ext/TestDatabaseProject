/*        
------------------------------------------------------------------------------        
Procedure Name: usp_PatientActivity_Insert        
Description   : This procedure is used to insert record into PatientActivity table    
Created By    : Aditya        
Created Date  : 29-Apr-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
23-Feb-2012 Rathnam added IsAdhoc column to the PatientActivity table 
28-Feb-2012 NagaBabu Replaced input parameter @i_ActivityId by @t_Activity       
------------------------------------------------------------------------------        
*/      
CREATE PROCEDURE [dbo].[usp_PatientActivity_Insert]   
(      
 @i_AppUserId KeyId,    
 --@i_ActivityId KeyID,  
 @t_Activity ttypeKeyID READONLY,  
 @i_PatientGoalId KeyID,  
 @vc_Description LongDescription = NULL ,  
 @vc_StatusCode StatusCode,  
 @o_PatientActivityId KeyID OUTPUT,
 @b_IsAdhoc IsIndicator = NULL    
)      
AS      
BEGIN TRY      
	 SET NOCOUNT ON      
	 DECLARE @l_numberOfRecordsInserted INT       
	 -- Check if valid Application User ID is passed        
	 IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )      
	 BEGIN      
		 RAISERROR ( N'Invalid Application User ID %d passed.' ,      
		 17 ,      
		 1 ,      
		 @i_AppUserId )      
	 END      
	    
	 INSERT INTO PatientActivity    
		 (     
		   ActivityId,    
		   PatientGoalId,  
		   Description,  
		   StatusCode,   
		   CreatedByUserId,
		   IsAdhoc    
		 )    
	 SELECT    
		   tKeyId ,    
		   @i_PatientGoalId,  
		   @vc_Description,  
		   @vc_StatusCode,  
		   @i_AppUserId ,
		   @b_IsAdhoc
	FROM @t_Activity	    
	         
	 SELECT @l_numberOfRecordsInserted = @@ROWCOUNT,    
			@o_PatientActivityId = SCOPE_IDENTITY()    
	              
	          
	 IF @l_numberOfRecordsInserted < 1              
	 BEGIN              
		  RAISERROR          
		   (  N'Invalid row count %d in Insert PatientActivity'    
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
    ON OBJECT::[dbo].[usp_PatientActivity_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

