/*  
---------------------------------------------------------------------------------------  
Procedure Name: usp_ProgramExclusionReasons_Update
Description   : This procedure is used to update the ProgramExclusionReasons related data
Created By    : NagaBabu
Created Date  : 16-Mar-2011  
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
  
---------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_ProgramExclusionReasons_Update]
( @i_AppUserId INT,
  @i_ProgramTypeID KeyId ,
  @vc_ExclusionReason ShortDescription ,
  @vc_Description LongDescription ,
  @vc_StatusCode StatusCode ,
  @i_ProgramExcludeID KeyId 
)
AS
BEGIN TRY
    SET NOCOUNT ON   
    DECLARE @l_numberOfRecordsUpdated INT
 
 -- Check if valid Application User ID is passed  
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
	BEGIN
	   RAISERROR ( N'Invalid Application User ID %d passed.' ,
	   17 ,
	   1 ,
	   @i_AppUserId )
	END

	UPDATE ProgramExclusionReasons
	  SET ProgramTypeID = @i_ProgramTypeID,
		  ExclusionReason = @vc_ExclusionReason,
		  Description = @vc_Description,
		  StatusCode = @vc_StatusCode,
		  LastModifiedByUserId = @i_AppUserId,
		  LastModifiedDate = GETDATE()
     WHERE
		 ProgramExcludeID = @i_ProgramExcludeID

	SET @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Update ProgramExclusionReasons'
				,17      
				,1      
				,@l_numberOfRecordsUpdated
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
    ON OBJECT::[dbo].[usp_ProgramExclusionReasons_Update] TO [FE_rohit.r-ext]
    AS [dbo];

