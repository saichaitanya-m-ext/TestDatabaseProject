/*    
------------------------------------------------------------------------------    
Procedure Name: usp_MeasureType_Select    
Description   : This procedure is used to get the records from the MeasureType  
				table  
Created By    : Aditya    
Created Date  : 14-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------    
*/  

CREATE PROCEDURE [dbo].[usp_MeasureType_Select]  
(  
	 @i_AppUserId KeyID,  
	 @i_MeasureTypeId KeyID = NULL,  
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
		 MeasureTypeId,
		 MeasureTypeName,
		 Description,
		 SortOrder,
		 CreatedByUserId,
		 CreatedDate,
		 LastModifiedByUserId,
		 LastModifiedDate, 
		 CASE StatusCode   
			WHEN 'A' THEN 'Active'  
			WHEN 'I' THEN 'InActive'  
			ELSE ''  
		 END AS StatusDescription
	 FROM   
		 MeasureType
	 WHERE  ( MeasureTypeId = @i_MeasureTypeId OR @i_MeasureTypeId IS NULL )  
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
    ON OBJECT::[dbo].[usp_MeasureType_Select] TO [FE_rohit.r-ext]
    AS [dbo];

