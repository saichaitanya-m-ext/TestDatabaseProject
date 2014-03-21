/*
---------------------------------------------------------------------------------
Procedure Name: Usp_CommunicationTemplate_Insert
Description	  : This procedure is used to insert all the Communication Templates.
Created By    :	Balla Kalyan
Created Date  : 30-Apr-2010
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION

----------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_CommunicationTemplate_Insert]
(	@i_AppUserId KeyID ,
	@i_CommunicationTemplateId KeyID OUT,
	@i_UserId KeyID,
	@v_TemplateName ShortDescription,
	@v_Description	LongDescription,
	@i_CommunicationTypeId	KeyID,
	@v_SubjectText	VARCHAR(200),
	@v_SenderEmailAddress VARCHAR(256),
	@v_StatusCode StatusCode,
	@b_IsDraft	IsIndicator,
	@i_NotifyCommunicationTemplateId KeyID,
	@vb_CommunicationText NVARCHAR(MAX),
	@d_SubmittedDate UserDate,
	@v_ApprovalState VARCHAR(30),
	@t_LibraryID ttypeKeyID Readonly 
)	
AS
BEGIN TRY

       SET NOCOUNT ON	
       DECLARE @l_numberOfRecordsInserted INT
	-- Check if valid Application User ID is passed
       IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
       BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed to insert CommunicationTemplate.' ,
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

	------------ Insert operation takes place here---------------
       INSERT INTO CommunicationTemplate
          ( TemplateName,
			Description,
			CommunicationTypeId,
			SubjectText,
			SenderEmailAddress,
			StatusCode,
			IsDraft,
			NotifyCommunicationTemplateId,
			CommunicationText,
			SubmittedDate,
			ApprovalState,
			CreatedByUserId
          )
       VALUES
          (
			@v_TemplateName ,
			@v_Description	,
			@i_CommunicationTypeId	,
			@v_SubjectText ,
			@v_SenderEmailAddress ,
			@v_StatusCode ,
			@b_IsDraft,
			@i_NotifyCommunicationTemplateId ,
			@vb_CommunicationText ,
			@d_SubmittedDate ,
			@v_ApprovalState,
            @i_AppUserId 
          )

		SET @l_numberOfRecordsInserted = @@ROWCOUNT
		SET @i_CommunicationTemplateId = SCOPE_IDENTITY()
		
		IF @l_numberOfRecordsInserted <> 1          
		BEGIN          
			RAISERROR
				(  N'Invalid row count %d in insert into CommunicationTemplate Table'
					,17
					,1
					,@l_numberOfRecordsInserted
				)
		END
		       
        INSERT INTO CommunicationTemplateAttachments
         ( LibraryId, CommunicationTemplateId, CreatedByUserId ) 
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
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CommunicationTemplate_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

