/*  
------------------------------------------------------------------------------  
Procedure Name: usp_ProgramExclusionReasons_Select  
Description   : This procedure used to get ProgramExclusionReasons details
Created By    : NagaBabu  
Created Date  : 17-Mar-2011 
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
  
------------------------------------------------------------------------------  
*/  
CREATE PROCEDURE [dbo].[usp_ProgramExclusionReasons_Select]
(
	@i_AppUserId KeyID,
	@i_ProgramTypeId KeyID ,
    @v_StatusCode StatusCode = NULL
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
		ProgramExcludeID ,
		ProgramTypeID ,
		ExclusionReason ,
		Description ,
		CASE StatusCode
			WHEN 'A' THEN 'Active'
			WHEN 'I' THEN 'Inactive'
			ELSE ''
		END AS StatusCode ,
		CreatedByUserID ,
		CreatedDate	,
		LastModifiedByUserID ,
		LastModifiedDate 		
	FROM 
		ProgramExclusionReasons
	WHERE 
        ProgramTypeId = @i_ProgramTypeId
    AND ( StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )   
     
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
    ON OBJECT::[dbo].[usp_ProgramExclusionReasons_Select] TO [FE_rohit.r-ext]
    AS [dbo];

