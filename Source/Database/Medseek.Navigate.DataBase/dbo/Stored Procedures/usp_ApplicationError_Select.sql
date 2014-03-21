/*        
------------------------------------------------------------------------------        
Procedure Name: usp_ApplicationError_Select    
Description   : This procedure is used to get the details from application error table and the error in date wise     
Created By    : Dilip Kumar        
Created Date  : 13-June-2011    
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
13-June-2011 NagaBabu Added ErrorId,UserName  Fields and Joined with Users Table    
14-June-2011 NagaBabu Added @b_IsErrorType as Input Parameter and added select statement to get ErrorLog table data   
21-June-2011 DilipKumar Added ErrorDescription field  
------------------------------------------------------------------------------        
*/    

 
CREATE PROCEDURE [dbo].[usp_ApplicationError_Select]  
(      
 @i_AppUserID KeyID , -- Login User Id    
 @b_IsErrorType BIT   
 --@i_UserID KeyID    
 -- @d_FromDate date,  
 -- @d_ToDate date  
    
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
        
      IF (@b_IsErrorType = 0)  
   -- Application Error related messages      
         SELECT TOP 500  
     ErrorID,  
     COALESCE(ISNULL(Provider.LastName , '') + ', '       
       + ISNULL(Provider.FirstName , '') + '. '       
       + ISNULL(Provider.MiddleName , ''),'') AS 'UserName',    
     PageName,  
       
     COALESCE(ISNULL(Errordescription , '') + ' - '       
       + ISNULL(Tracedescription , ''),'') as 'ErrorDescription',      
     --Errordescription,  
     --Tracedescription,  
      
     ApplicationErrorLog.CreatedDate   
    FROM   
     ApplicationErrorLog   
    INNER JOIN Provider  WITH (NOLOCK)  
     ON ApplicationErrorLog.CreatedByuserId = Provider.ProviderID      
    ORDER BY CreatedDate DESC  
   ELSE   
   -- Database Error related messages         
    SELECT TOP 500  
     ErrorlogID,  
     Errordate,  
     SystemUser,  
     errorProcedure,  
     COALESCE((cast( ErrorNumber as varchar(10))) + '- '        
     +(ISNULL(cast(ErrorMessage as varchar(2048)), '')) + ' - '   
     + 'Severity'+'-'+(cast(ErrorSeverity as varchar(10))) + ' - '   
     + 'State'+'-'+(cast(ErrorState as varchar(10))) + ' - '   
     + 'Line'+'-'+(cast(ErrorLine as varchar(10))),'') as ErrorDescription  
    FROM  
     ErrorLog   
    ORDER BY errordate DESC  
         
     
END TRY    
--------------------------------------------------------         
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT      
    --  EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId      
      
      RETURN @i_ReturnedErrorID      
END CATCH  
  
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ApplicationError_Select] TO [FE_rohit.r-ext]
    AS [dbo];

