/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_ClaimType_Select]
Description   : This Procedure is used to get ClaimType details 
Created By    : NagaBabu
Created Date  : 08-Dec-2011
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_ClaimType_Select]
(
	@i_AppUserId KeyID
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
		ClaimTypeId ,
		[Description] ,
		CASE StatusCode 
			WHEN 'A' THEN 'Active'
			WHEN 'I' THEN 'InActive'
		END AS StatusCode	,
		CreatedByUserId ,
		CONVERT(VARCHAR,CreatedDate,101) AS CreatedDate
	FROM
		ClaimType	
 	
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
    ON OBJECT::[dbo].[usp_ClaimType_Select] TO [FE_rohit.r-ext]
    AS [dbo];

