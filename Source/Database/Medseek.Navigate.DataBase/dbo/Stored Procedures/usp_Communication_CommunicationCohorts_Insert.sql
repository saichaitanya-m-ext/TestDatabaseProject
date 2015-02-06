/*
---------------------------------------------------------------------------------
Procedure Name: usp_Communication_CommunicationCohorts_Insert
Description	  : This procedure is used to insert the Communication and cohorts
Created By    :	Pramod
Created Date  : 04-May-2010
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
16-Jul-10 Pramod Included the condition CohortListUsers.StatusCode = 'A' to pick 
	only active records
15-Dec-10 Rathnam added @i_CommunicationTypeID parameter for inserting the CommunicationTypeID
                  into communicaltion table.
18-Mar-2013 P.V.P.Mohan Modified PatientID in place of UserID .  
03-APR-2013 Mohan Modified PopulationDefinitionUsers to PopulationDefinitionPatients  Tables.      	
----------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_Communication_CommunicationCohorts_Insert]
(	@i_AppUserId KeyID ,
	@i_CommunicationId KeyID OUT,
	@i_CommunicationTemplateId KeyID,
	@v_SenderEmailAddress VARCHAR(256),
	@b_IsDraft	IsIndicator,
	@d_SubmittedDate UserDate,
	@v_ApprovalState VARCHAR(30),
	@d_ApprovalDate UserDate,
	@v_StatusCode StatusCode,
	@t_CohortlistID ttypeKeyID Readonly,
	@i_CommunicationTypeID KEYID
)	
AS
BEGIN TRY

       SET NOCOUNT ON	
       DECLARE @l_numberOfRecordsInserted INT
	-- Check if valid Application User ID is passed
       IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
       BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed to insert Communication' ,
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
       INSERT INTO Communication
          ( CommunicationTemplateId
            ,SenderEmailAddress
            ,IsDraft
            ,SubmittedDate
            ,ApprovalState
            ,ApprovalDate
            ,CreatedByUserId
            ,StatusCode
            ,CommunicationTypeId
          )
       VALUES
          (
			@i_CommunicationTemplateId
            ,@v_SenderEmailAddress
            ,@b_IsDraft
            ,@d_SubmittedDate
            ,@v_ApprovalState
            ,@d_ApprovalDate
            ,@i_AppUserId 
            ,@v_StatusCode
            ,@i_CommunicationTypeID
          )

		SET @l_numberOfRecordsInserted = @@ROWCOUNT
		SET @i_CommunicationId = SCOPE_IDENTITY()
		
		IF @l_numberOfRecordsInserted <> 1          
		BEGIN          
			RAISERROR
				(  N'Invalid row count %d in insert into Communication Table'
					,17
					,1
					,@l_numberOfRecordsInserted
				)
		END
		
        INSERT INTO CommunicationCohorts 
         ( PopulationDefinitionID, CommunicationId, UserID, CreatedByUserId, IsExcludedByPreference ) 
        SELECT tKeyId, @i_CommunicationId, PopulationDefinitionPatients.PatientID UserId, @i_AppUserId, 1
          FROM @t_CohortlistID 
               INNER JOIN PopulationDefinitionPatients
                  ON tKeyId = PopulationDefinitionPatients.PopulationDefinitionId
                  AND PopulationDefinitionPatients.StatusCode = 'A' -- Select only active records

	    IF( @l_TranStarted = 1 )  -- If transactions are there, then commit
	    BEGIN
	   	   SET @l_TranStarted = 0
		   COMMIT TRANSACTION 
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
    ON OBJECT::[dbo].[usp_Communication_CommunicationCohorts_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

