/*  
---------------------------------------------------------------------------------  
Procedure Name: [usp_BloodTypes_Select]
Description   : This procedure is used to get data from BloodTypes Table 
Created By    : NagaBabu
Created Date  : 12-July-2011
----------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
----------------------------------------------------------------------------------  
*/  
  
CREATE PROCEDURE [dbo].[usp_BloodTypes_Select]  
( 
	@i_AppUserId KEYID ,
	@v_StatusCode StatusCode = NULL
)  
AS  
BEGIN TRY   
  
 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
      BEGIN  
           RAISERROR ( N'Invalid Application User ID %d passed.' ,  
           17 ,  
           1 ,  
           @i_AppUserId )  
      END  

      SELECT   
            BloodTypeId,
            BloodType,
            CASE StatusCode
				WHEN 'A' THEN 'Active'
				WHEN 'I' THEN 'InActive'
			END AS StatusCode	 
        FROM  
            CodeSetBloodType
       WHERE 
			StatusCode = @v_StatusCode OR @v_StatusCode IS NULL         
        
END TRY  
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_BloodTypes_Select] TO [FE_rohit.r-ext]
    AS [dbo];

