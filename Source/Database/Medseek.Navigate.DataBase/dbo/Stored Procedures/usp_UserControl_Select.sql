/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_UserControl_Select]  
Description   : This procedure is used to get the records from UserControl table.  
Created By    : Aditya  
Created Date  : 27-Apr-2010  
----------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
28-Apr-2010 Pramod  Concatenated DataSourceName into UserControlName
----------------------------------------------------------------------------------  
*/  
  
CREATE PROCEDURE [dbo].[usp_UserControl_Select]  
( @i_AppUserId KEYID

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
---------------- Select operation starts here--------  
      SELECT   
			UserControlId,
			UserControlName + '~' + DataSourceName AS UserControlName,
			DataSourceName,
			DataSourceType,
			UserControlDescription,
			CreatedByUserId,
			CreatedDate,
			LastModifiedByUserId,
			LastModifiedDate  
        FROM  
            UserControl WITH(NOLOCK)
  
END TRY  
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserControl_Select] TO [FE_rohit.r-ext]
    AS [dbo];

