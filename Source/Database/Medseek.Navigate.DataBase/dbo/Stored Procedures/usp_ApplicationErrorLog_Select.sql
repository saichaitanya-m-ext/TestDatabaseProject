/*          
------------------------------------------------------------------------------          
Procedure Name: usp_ApplicationErrorLog_Select
Description   : This procedure is used to select ApplicationErrorLog values
Created By    : NagaBabu
Created Date  : 23-Mar-2011
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION  
28-Mar-2011 NagaBabu Added Remarks field in select statement     
------------------------------------------------------------------------------          
*/      
CREATE PROCEDURE [dbo].[usp_ApplicationErrorLog_Select] 
(      
 @i_AppUserId KEYID ,
 @i_UserID KeyID = NULL ,
 @nv_IpAddress NVARCHAR(20) = NULL ,
 @vc_PageName ShortDescription = NULL ,
 @vc_Status VARCHAR(15) = NULL ,
 @d_CreatedDate UserDate = NULL 
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
         ErrorID ,
         UserID ,
         IpAddress ,
         ErrorDescription ,
         PageName ,
         TraceDescription ,
         [Status] ,
         CreatedByUserID ,
         CreatedDate ,
         UpdatedByUserID ,
         UpdatedDate,
         Remarks  
     FROM      
         ApplicationErrorLog  
	 WHERE
		 ( UserID = @i_UserID OR @i_UserID IS NULL )  
	 AND ( IpAddress = @nv_IpAddress OR @nv_IpAddress IS NULL )	
	 AND ( PageName = @vc_PageName OR @vc_PageName IS NULL )
	 AND ( [Status] = @vc_Status OR @vc_Status IS NULL )
	 AND ( CreatedDate = @d_CreatedDate OR @d_CreatedDate IS NULL )    
  
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
    ON OBJECT::[dbo].[usp_ApplicationErrorLog_Select] TO [FE_rohit.r-ext]
    AS [dbo];

