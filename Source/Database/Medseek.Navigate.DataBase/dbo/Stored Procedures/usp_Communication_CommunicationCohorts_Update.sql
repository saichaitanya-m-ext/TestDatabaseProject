/*
------------------------------------------------------------------------------
Procedure Name: Usp_Communication_CommunicationCohorts_Update
Description	  : This procedure is used to update the Communication and cohort detail
Created By    :	Pramod
Created Date  : 04-May-2010
-------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
26-May-2010     NagaBabu    Included a parameter @d_PrintDate UserDate to this procedure while its newly
                            updated column in  [dbo].[Communication] table  
2-Jul-10 Pramod Included the condition IF @v_ApprovalState = 'Ready to Approve'
				  before delete
19-Aug-10 Pramod modified the approval state logic and created a new variable @v_Derived_ApprovalState for that
28-Sep-10 Pramod Modified the derived state logic to include phonetype like 'Phone%'
15-Dec-10 Rathnam Added @i_CommunicationTypeId parameter for updating the communication table.
19-Dec-11 Rama added UserCommunication table before deleting the corresponding data in CommunicationCohorts table.
25-Jan-2011 NagaBabu Added statement Delete UserCommunicationAttachment 
28-Apr-2011 Rama Commented Transation script
30-June-2011 NagaBabu Added Replaced CommunicationTemplate table by Communication for select statement 
						'@v_Derived_ApprovalState'
01-July-2011 NagaBabu Replaced 'Ready To Sent' by 'Sent'
08-July-2011 NagaBabu Added CommunicationSentDate = @d_SubmittedDate in Update Statement 
						and update statement applied by IF ELSE condition
03-APR-2013 Mohan Modified PopulationDefinitionUsers to PopulationDefinitionPatients  Tables.    
								
-------------------------------------------------------------------------------
*/
 
CREATE PROCEDURE [dbo].[usp_Communication_CommunicationCohorts_Update]
 (
	@i_AppUserId KeyID ,
	@i_CommunicationId KeyID,
	@i_CommunicationTemplateId KeyID,
	@v_SenderEmailAddress VARCHAR(256),
	@b_IsDraft	IsIndicator,
	@d_SubmittedDate UserDate,
	@v_ApprovalState VARCHAR(30),
	@d_ApprovalDate UserDate,
	@v_StatusCode StatusCode,
	@d_PrintDate UserDate,
	@t_CohortlistID ttypeKeyID Readonly,
	@i_CommunicationTypeID KEYID
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
	
	   DECLARE @v_Derived_ApprovalState VARCHAR(30)
	   
	   IF @v_ApprovalState = 'Submit'
		   SELECT @v_Derived_ApprovalState 
					= CASE 
						WHEN CommunicationType.CommunicationType = 'Letter' THEN 'Ready to Print'
						WHEN CommunicationType.CommunicationType LIKE 'Phone%' THEN 'Ready To Call'
						WHEN CommunicationType.CommunicationType IN ( 'SMS', 'Email','Fax') THEN 'Sent'
						ELSE ''
					  END
			FROM Communication
				LEFT OUTER JOIN CommunicationType 
					ON CommunicationType.CommunicationTypeId = Communication.CommunicationTypeId  	
		   WHERE Communication.CommunicationTemplateId = @i_CommunicationTemplateId
		   AND Communication.CommunicationTypeId = @i_CommunicationTypeID 		
	   ELSE
		   SET @v_Derived_ApprovalState = @v_ApprovalState

	  -- DECLARE @l_TranStarted BIT = 0
	  -- IF( @@TRANCOUNT = 0 )  
	  -- BEGIN
			--BEGIN TRANSACTION
			--SET @l_TranStarted = 1  -- Indicator for start of transactions
	  -- END
	  -- ELSE
			--SET @l_TranStarted = 0  
	
------------    Updation operation takes place   --------------------------
	   IF @v_Derived_ApprovalState = 'Sent'	
	   BEGIN
		   UPDATE
				Communication
			  SET 
				CommunicationTemplateId = @i_CommunicationTemplateId,
				SenderEmailAddress = @v_SenderEmailAddress,
				IsDraft = @b_IsDraft,
				SubmittedDate = @d_SubmittedDate,
				ApprovalState = @v_Derived_ApprovalState,
				ApprovalDate = @d_ApprovalDate,
				StatusCode = @v_StatusCode,
				Lastmodifieddate = GETDATE(),
				LastModifiedByUserId = @i_AppUserId,
				PrintDate = @d_PrintDate,
				CommunicationTypeId = @i_CommunicationTypeID,
				CommunicationSentDate = @d_SubmittedDate
		   WHERE
				CommunicationId = @i_CommunicationId

		   SET @i_numberOfRecordsUpdated = @@ROWCOUNT

		   IF @i_numberOfRecordsUpdated <> 1
				 RAISERROR 
				 ( N'Update of Communication table experienced invalid row count of %d' ,
					  17 ,
					  1 ,
					  @i_numberOfRecordsUpdated 
				 )
      END  
      ELSE
		  BEGIN
			   UPDATE
					Communication
				  SET 
					CommunicationTemplateId = @i_CommunicationTemplateId,
					SenderEmailAddress = @v_SenderEmailAddress,
					IsDraft = @b_IsDraft,
					SubmittedDate = @d_SubmittedDate,
					ApprovalState = @v_Derived_ApprovalState,
					ApprovalDate = @d_ApprovalDate,
					StatusCode = @v_StatusCode,
					Lastmodifieddate = GETDATE(),
					LastModifiedByUserId = @i_AppUserId,
					PrintDate = @d_PrintDate,
					CommunicationTypeId = @i_CommunicationTypeID
			   WHERE
					CommunicationId = @i_CommunicationId

			   SET @i_numberOfRecordsUpdated = @@ROWCOUNT

			   IF @i_numberOfRecordsUpdated <> 1
					 RAISERROR 
					 ( N'Update of Communication table experienced invalid row count of %d' ,
						  17 ,
						  1 ,
						  @i_numberOfRecordsUpdated 
					 )
		  END  	
           
	  IF @v_ApprovalState = 'Ready to Approve'
	  BEGIN
		IF EXISTS ( SELECT 1 FROM @t_CohortlistID )
		BEGIN
			DELETE FROM PatientCommunicationAttachment
			WHERE PatientCommunicationID IN (SELECT PatientCommunicationId 
										 FROM PatientCommunication
										 WHERE CommunicationId = @i_CommunicationId ) 
			DELETE FROM PatientCommunication
			WHERE CommunicationId = @i_CommunicationId
				
			DELETE FROM CommunicationCohorts
			 WHERE CommunicationId = @i_CommunicationId

			INSERT INTO CommunicationCohorts 
			 ( PopulationDefinitionID, CommunicationId, UserID, CreatedByUserId, IsExcludedByPreference ) 
			SELECT tKeyId, @i_CommunicationId, CohortListUsers.PatientID, @i_AppUserId, 1
			  FROM @t_CohortlistID 
				   INNER JOIN PopulationDefinitionPatients CohortListUsers
					  ON tKeyId = CohortListUsers.PopulationDefinitionID
		END
	  END
	  -- IF( @l_TranStarted = 1 )  -- If transactions are there, then commit
			--BEGIN
	  -- 		   SET @l_TranStarted = 0
			--   COMMIT TRANSACTION 
			--END
	  --  ELSE
			--BEGIN
   --            ROLLBACK TRANSACTION
   --         END
	    
   --     RETURN 0

END TRY 
------------ Exception Handling --------------------------------
BEGIN CATCH
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Communication_CommunicationCohorts_Update] TO [FE_rohit.r-ext]
    AS [dbo];

