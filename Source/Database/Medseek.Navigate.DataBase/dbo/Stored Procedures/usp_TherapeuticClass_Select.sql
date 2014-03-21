/*  
------------------------------------------------------------------------------  
Procedure Name: usp_TherapeuticClass_Select  
Description   : This procedure is used to get the details of a TherapeuticClass Type
				or a complete list of all the TherapeuticClass types
Created By    : Aditya  
Created Date  : 08-mar-2010  
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_TherapeuticClass_Select]
(
	@i_AppUserId KeyID,
	@i_TherapeuticID KeyID = NULL,
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

	SELECT TherapeuticID
		  ,Name
		  ,Description
		  ,SortOrder
		  ,CreatedByUserId
		  ,CreatedDate
		  ,LastModifiedByUserId
		  ,LastModifiedDate
		  ,CASE StatusCode 
		       WHEN 'A' THEN 'Active'
		       WHEN 'I' THEN 'InActive'
		       ELSE ''
		   END AS StatusDescription
	 FROM TherapeuticClass WITH(NOLOCK)
	 WHERE ( TherapeuticID = @i_TherapeuticID 
	         OR @i_TherapeuticID IS NULL
	        )
       AND ( @v_StatusCode IS NULL or StatusCode = @v_StatusCode )
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
    ON OBJECT::[dbo].[usp_TherapeuticClass_Select] TO [FE_rohit.r-ext]
    AS [dbo];

