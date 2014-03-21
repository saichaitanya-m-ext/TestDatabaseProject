/*      
------------------------------------------------------------------------------      
Procedure Name: usp_ProgramExclusionReasons_Insert      
Description   : This procedure is used to insert record into ProgramExclusionReasons table  
Created By    : NagaBabu   
Created Date  : 16-Mar-2011      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
      
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_ProgramExclusionReasons_Insert]    
(    
 @i_AppUserId KeyId ,  
 @i_ProgramTypeID KeyId ,
 @vc_ExclusionReason ShortDescription ,
 @vc_Description LongDescription ,
 @vc_StatusCode StatusCode ,
 @o_ProgramExcludeID KeyId OUTPUT
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
	  
		 INSERT INTO ProgramExclusionReasons
			(   
			   ProgramTypeID ,  
			   ExclusionReason,  
			   Description,  
			   StatusCode,  
			   CreatedByUserID
			)  
		 VALUES  
			(   
			   @i_ProgramTypeID ,  
			   @vc_ExclusionReason ,
			   @vc_Description ,
			   @vc_StatusCode ,
			   @i_AppUserId  
			)  
		       
		 SELECT @l_numberOfRecordsInserted = @@ROWCOUNT,  
			    @o_ProgramExcludeID = SCOPE_IDENTITY()  
		            
		        
		 IF @l_numberOfRecordsInserted <> 1            
	     BEGIN            
			  RAISERROR        
			   (  N'Invalid row count %d in Insert ProgramExclusionReasons'  
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
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException   
     @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ProgramExclusionReasons_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

