/*    
------------------------------------------------------------------------------    
Procedure Name: usp_CodeSetICDGroups_Select
Description   : This Procedure is used to select data from CodeSetICDGroups
Created By    : NagaBabu
Created Date  : 08-Apr-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_CodeSetICDGroups_Select]  
(  
	@i_AppUserId INT,  
	@i_ICDCodeGroupId KeyId = NULL,
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
			ICDCodeGroupId ,
			ICDGroupName ,
			CASE StatusCode
				WHEN 'A' THEN 'Active'
				WHEN 'I' THEN 'InActive'
				ELSE ''
			END AS StatusCode ,
			CreatedByUserId ,
			CreatedDate ,
			LastModifiedByUserId ,
			LastModifiedDate
		FROM
			CodeSetICDGroups
		WHERE
			( ICDCodeGroupId = @i_ICDCodeGroupId OR @i_ICDCodeGroupId IS NULL )
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
    ON OBJECT::[dbo].[usp_CodeSetICDGroups_Select] TO [FE_rohit.r-ext]
    AS [dbo];

