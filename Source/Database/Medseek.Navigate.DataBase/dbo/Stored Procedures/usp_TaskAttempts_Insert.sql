/*      
------------------------------------------------------------------------------      
Procedure Name: usp_TaskAttempts_Insert      
Description   : This procedure is used to insert record into TaskAttempts table  
Created By    : Aditya      
Created Date  : 04-May-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
28-July-2010 NagaBabu Added TasktypeCommunicationID,CommunicationTemplateID fields   
                             And Deleted CommunicationSequence,TaskTypeId fields 
21-Sep-2010 NagaBabu Modified @vc_Comments Datatype as Varchar(100) 
11-May-2011 Rathnam Placed the @i_AppUserId instead of sending the patient userid for attempts information 
21-feb-2012 Siva Added    @i_CommunicationSequence,@i_CommunicationTypeId parameters to insert the newly added   
			CommunicationSequence,CommunicationTypeId                             
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_TaskAttempts_Insert]    
(    
 @i_AppUserId KeyID,  
 @i_TaskId KeyID,  
 --@i_CommunicationSequence KeyID,  
 --@i_TaskTypeId KeyID,  
 @dt_AttemptedContactDate UserDate,  
 @vc_Comments Varchar(100),  
 @i_UserId KeyID,  
 @dt_NextContactDate UserDate,  
 @i_TaskTerminationDate UserDate,  
 @i_TasktypeCommunicationID KeyID,  
 @i_CommunicationTemplateID KeyID,
 @i_CommunicationSequence KeyID,
 @i_CommunicationTypeId KeyId
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
	  
	 INSERT INTO TaskAttempts  
		  (   
		   TaskId,  
		   AttemptedContactDate,  
		   Comments,  
		   UserId,  
		   NextContactDate,  
		   TaskTerminationDate,  
		   TasktypeCommunicationID,  
		   CommunicationTemplateID,
		   CommunicationSequence,
		   CommunicationTypeId
		  )  
	 VALUES  
		  (   
		   @i_TaskId,  
		   @dt_AttemptedContactDate,  
		   @vc_Comments,  
		   @i_AppUserId,  
		   @dt_NextContactDate,  
		   @i_TaskTerminationDate,  
		   @i_TasktypeCommunicationID,  
		   @i_CommunicationTemplateID,
		   @i_CommunicationSequence,
		   @i_CommunicationTypeId
		  )  
	       
		SELECT @l_numberOfRecordsInserted = @@ROWCOUNT  
		IF @l_numberOfRecordsInserted <> 1            
		 BEGIN            
			  RAISERROR        
			   (  N'Invalid row count %d in insert TaskAttempts'  
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
    ON OBJECT::[dbo].[usp_TaskAttempts_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

