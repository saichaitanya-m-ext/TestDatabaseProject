/*
-----------------------------------------------------------------------------------------------
Procedure Name: [dbo].[Usp_Activity_Update_StatusChain]
Description	  : This procedure is used to update the Status code for an activity and 
				corresponding dependent activities
Created By    :	Pramod
Created Date  : 24-Mar-2010
------------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION

------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_Activity_Update_StatusChain]
(
	 @i_AppUserId        KeyID
	,@i_ActivityId       KeyID
	,@vc_StatusCode 	 StatusCode
)

AS
BEGIN TRY 

	SET NOCOUNT ON	
	-- Check if valid Application User ID is passed
	DECLARE @i_numberOfRecordsUpdated INT
	IF(@i_AppUserId IS NULL) OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR
		(	 N'Invalid Application User ID %d passed.'
			,17
			,1
			,@i_AppUserId
		)
	END
	
	  DECLARE @TranStarted BIT
      SET @TranStarted = 0

      IF ( @@TRANCOUNT = 0 )
         BEGIN
               BEGIN TRANSACTION
               SET @TranStarted = 1
         END
      ELSE
         SET @TranStarted = 0

------------    Updation operation takes place   --------------------------
			
	
	DECLARE 
		@tree TABLE
		(
	      TreeId INT IDENTITY
				 PRIMARY KEY ,
		  ActivityId INT NOT NULL ,
		  lvl INT ,
		  ParentTreeId INT
		 )

	DECLARE
		@rowcount INT ,
		@lvl INT

	SET @lvl = 0

	INSERT INTO
		@tree
		( ActivityId , lvl )
	VALUES
		( @i_ActivityId, @lvl )

	SET @rowcount = @@ROWCOUNT

	WHILE @rowcount > 0
	BEGIN

		SET @lvl = @lvl + 1

		INSERT INTO
			@tree ( ActivityId, lvl, ParentTreeId )
			SELECT Act.ActivityId ,
				   @lvl ,
				   t.TreeId
			  FROM Activity Act 
			       INNER JOIN @tree t
			         ON Act.ParentActivityId = t.ActivityId AND t.lvl = @lvl - 1

		SET @rowcount = @@ROWCOUNT
		
	END

	UPDATE Activity
	   SET statuscode = @vc_StatusCode ,
		   LastModifiedByUserId = @i_AppUserId ,
		   LastModifiedDate = GETDATE()
	 WHERE ActivityId IN ( SELECT ActivityId
						     FROM @tree 
						  )
		  	 
	SET @i_numberOfRecordsUpdated = @@ROWCOUNT
			
	IF @i_numberOfRecordsUpdated <= 0  
		RAISERROR
		(	 N'Update of Activity table experienced invalid row count of %d'
			,17
			,1
			,@i_numberOfRecordsUpdated         
	)
	
	  IF ( @TranStarted = 1 )
         BEGIN
               SET @TranStarted = 0
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
    DECLARE @i_ReturnedErrorID	INT
    
    EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException
				@i_UserId = @i_AppUserId
                        
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Activity_Update_StatusChain] TO [FE_rohit.r-ext]
    AS [dbo];

