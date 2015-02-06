/*    
------------------------------------------------------------------------------    
Procedure Name: Usp_CommunicationTemplate_Update    
Description   : This procedure is used to update the Communication Templates.    
Created By    : Aditya    
Created Date  : 30-Apr-2010    
-------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
28-July-2010 NagaBabu Added TaskId,TasktypeCommunicationID fields to the Update statement					
06-Aug-2010  NagaBabu  Deleted TaskId,TasktypeCommunicationID fields from the update statement
25-Sep-2010 NagaBabu Modified the SP to correct @i_numberOfRecordsUpdated > 1 to <> 1
-------------------------------------------------------------------------------    
*/    
    
CREATE PROCEDURE [dbo].[usp_CommunicationTemplate_Update]    
  (    
	 @i_AppUserId KeyID ,    
	 @i_CommunicationTemplateId KeyID,    
	 @i_UserID KeyID,    
	 @v_TemplateName ShortDescription,    
	 @v_Description LongDescription,    
	 @i_CommunicationTypeId KeyID,    
	 @v_SubjectText VARCHAR(200),    
	 @v_SenderEmailAddress VARCHAR(256),    
	 @v_StatusCode StatusCode,    
	 @b_IsDraft IsIndicator,    
	 @i_NotifyCommunicationTemplateId KeyID,    
	 @vb_CommunicationText NVARCHAR(MAX),    
	 @d_SubmittedDate UserDate,    
	 @v_ApprovalState VARCHAR(30),
	 --@i_TaskId KeyID ,
	 --@i_TasktypeCommunicationID KeyID ,
	 @t_LibraryID ttypeKeyID Readonly    
  )    
AS    
BEGIN TRY    
       SET NOCOUNT ON    
    
       DECLARE @i_numberOfRecordsUpdated INT    
    
 -- Check if valid Application User ID is passed    
       IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )    
       BEGIN    
               RAISERROR ( N'Invalid Application User ID %d passed ' ,    
               17 ,    
               1 ,    
               @i_AppUserId )    
       END    
    
		DECLARE @l_TranStarted BIT = 0    
		IF( @@TRANCOUNT = 0 )      
			BEGIN    
				BEGIN TRANSACTION    
				SET @l_TranStarted = 1  -- Indicator for start of transactions    
			END    
		ELSE    
			SET @l_TranStarted = 0      
     
------------    Updation operation takes place   --------------------------    
    
    UPDATE    
          CommunicationTemplate    
       SET     
		  TemplateName = @v_TemplateName,    
		  Description = @v_Description,    
		  CommunicationTypeId = @i_CommunicationTypeId,    
		  SubjectText = @v_SubjectText,    
		  SenderEmailAddress = @v_SenderEmailAddress,    
		  StatusCode = @v_StatusCode,    
		  IsDraft = @b_IsDraft,    
		  NotifyCommunicationTemplateId = @i_NotifyCommunicationTemplateId,    
		  CommunicationText = @vb_CommunicationText,    
		  SubmittedDate = @d_SubmittedDate,    
		  ApprovalState = @v_ApprovalState,    
		  Lastmodifieddate = GETDATE() ,    
		  LastModifiedByUserId = @i_AppUserId
		  --TaskId = @i_TaskId,
		  --TasktypeCommunicationID = @i_TasktypeCommunicationID 
     WHERE    
          CommunicationTemplateId = @i_CommunicationTemplateId    
    
       SET @i_numberOfRecordsUpdated = @@ROWCOUNT    
    
       IF @i_numberOfRecordsUpdated <> 1    
             RAISERROR     
             ( N'Update of CommunicationTemplate table experienced invalid row count of %d' ,    
                  17 ,    
                  1 ,    
                  @i_numberOfRecordsUpdated     
             )    
    
	  DELETE FROM CommunicationTemplateAttachments    
	   WHERE CommunicationTemplateId = @i_CommunicationTemplateId    
	       
			INSERT INTO CommunicationTemplateAttachments ( LibraryId, CommunicationTemplateId, CreatedByUserId )     
			SELECT tKeyId, @i_CommunicationTemplateId, @i_AppUserId    
			  FROM @t_LibraryID    
	    
		 IF( @l_TranStarted = 1 )  -- If transactions are there, then commit    
	       BEGIN    
			   SET @l_TranStarted = 0    
		       COMMIT TRANSACTION     
	       END    
		 ELSE    
	         BEGIN    
				   ROLLBACK TRANSACTION    
			 END    
	         
		RETURN 0    
	    
END TRY     
------------ Exception Handling --------------------------------    
BEGIN CATCH    
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CommunicationTemplate_Update] TO [FE_rohit.r-ext]
    AS [dbo];

