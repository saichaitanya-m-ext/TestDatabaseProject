/*    
--------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_LookUpCodeType_Select]  1  
Description   : This procedure is used to select the details from LkUpCodeType_Test table (Node).    
Created By    : Rama Krishna      
Created Date  : 5-Dec-2013    
---------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
---------------------------------------------------------------------------------    
*/    
CREATE PROCEDURE [dbo].[usp_LookUpCodeType_Select] (    
 @i_AppUserId   KeyID,  
 @i_CodeTypeID KeyID =NULL  
  
 )    
AS    
BEGIN TRY    
 -- Check if valid Application User ID is passed    
 IF (@i_AppUserId IS NULL)    
  OR (@i_AppUserId <= 0)     
 BEGIN    
  RAISERROR (    
    N'Invalid Application User ID %d passed.'    
    ,17    
    ,1    
    ,@i_AppUserId    
    )    
 END    
    
 ----------- Select all the Activity details ---------------    
   
SELECT top 20
 CodeTypeID,  
 CodeTypeCode,  
 CodeTypeName,  
 TypeDescription,  
 CodeTableName  
FROM LkUpCodeType_Test   
WHERE    
(    
   CodeTypeID = @i_CodeTypeID   
   OR @i_CodeTypeID  IS NULL    
   )  
   order by  CodeTypeID DESC   
  
END TRY    
    
BEGIN CATCH    
 -- Handle exception    
 DECLARE @i_ReturnedErrorID INT    
    
 EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
 RETURN @i_ReturnedErrorID    
END CATCH 

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LookUpCodeType_Select] TO [FE_rohit.r-ext]
    AS [dbo];

