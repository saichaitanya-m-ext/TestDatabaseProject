
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_ObstetricalConditions_Select    
Description   : This procedure is used to get the list of all ObstetricalConditions  
Created By    : Udaykumar    
Created Date  : 6-July-2011    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_ObstetricalConditions_Select]  
(  
	@i_AppUserId INT,  
	@i_ObstetricalConditionsID INT = NULL,
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
			 ObstetricalConditionsID  
			,ObstetricalName  
			,Comments  
			,CreatedByUserId  
			,CreatedDate  
			,LastModifiedByUserId  
			,LastModifiedDate
			,CASE StatusCode   
				WHEN 'A' THEN 'Active'  
				WHEN 'I' THEN 'InActive'  
				ELSE ''  
			 END AS StatusCode
			
		FROM 
			ObstetricalConditions   WITH(NOLOCK)
	    WHERE 
			( ObstetricalConditionsID = @i_ObstetricalConditionsID   
               OR @i_ObstetricalConditionsID IS NULL  
            )  
        AND ( @v_StatusCode IS NULL or StatusCode = @v_StatusCode )             
        ORDER BY ObstetricalName
  
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
    ON OBJECT::[dbo].[usp_ObstetricalConditions_Select] TO [FE_rohit.r-ext]
    AS [dbo];

