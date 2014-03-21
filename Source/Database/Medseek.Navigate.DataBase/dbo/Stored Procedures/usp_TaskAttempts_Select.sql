/*      
------------------------------------------------------------------------------      
Procedure Name: usp_TaskAttempts_Select      
Description   : This procedure is used to get the details from TaskAttempts table     
Created By    : Aditya      
Created Date  : 04-May-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
28-July-2010 NagaBabu Added TasktypeCommunicationID,CommunicationTemplateID fields   
                             And Deleted CommunicationSequence,TaskTypeId fields   
                             And Modified FROM clause also 
24-Aug-2010 NagaBabu Added TemplateName field to this Select statement   
02-Jun-2010 Rathnam replaced the left join instead of using inner join at communication template       
24-feb-2012  Sivakrishna added communicationtypeid,CommunicationSequnce Columns to select Statement                           
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_TaskAttempts_Select]
(    
 @i_AppUserId KEYID,    
 @i_TaskId KEYID  
)    
AS    
BEGIN TRY    
      SET NOCOUNT ON       
-- Check if valid Application User ID is passed    
    
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )    
      BEGIN    
           RAISERROR ( N'Invalid Application User ID %d passed.' ,    
           17 ,    
           1 ,    
           @i_AppUserId )    
      END    
    
      SELECT      
		   TaskAttempts.UserId,    
		   TaskAttempts.TaskId,    
		   --TaskAttempts.CommunicationSequence,    
		   TaskTypeCommunications.CommunicationTypeID,    
		   CommunicationType.CommunicationType as ContactType,    
		   TaskTypeCommunications.CommunicationSequence,    
		   --TaskAttempts.TaskTypeId,    
		   TaskAttempts.AttemptedContactDate,    
		   TaskAttempts.Comments,    
		   TaskAttempts.NextContactDate,    
		   TaskAttempts.TaskTerminationDate,  
		   TaskAttempts.TasktypeCommunicationID,  
		   TaskAttempts.CommunicationTemplateID,
		   CommunicationTemplate.TemplateName ,    
		   TaskAttempts.CommunicationSequence ,
		   TaskAttempts.CommunicationTypeId
       FROM    
           TaskAttempts    WITH(NOLOCK)
       INNER JOIN TaskTypeCommunications    WITH(NOLOCK) 
           ON TaskTypeCommunications.TasktypeCommunicationID = TaskAttempts.TasktypeCommunicationID    
             --AND TaskTypeCommunications.CommunicationSequence = TaskAttempts.CommunicationSequence  
       INNER JOIN CommunicationType  WITH(NOLOCK)   
           ON CommunicationType.CommunicationTypeID = TaskTypeCommunications.CommunicationTypeID
       LEFT JOIN CommunicationTemplate WITH(NOLOCK)
		   ON CommunicationTemplate.CommunicationTemplateId	= TaskAttempts.CommunicationTemplateID        
       WHERE TaskId = @i_TaskId  
                    
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
    ON OBJECT::[dbo].[usp_TaskAttempts_Select] TO [FE_rohit.r-ext]
    AS [dbo];

