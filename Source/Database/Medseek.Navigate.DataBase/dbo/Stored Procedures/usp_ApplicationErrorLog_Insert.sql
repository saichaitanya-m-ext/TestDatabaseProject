/*    
---------------------------------------------------------------------------------------    
Procedure Name: [usp_ApplicationErrorLog_Insert]
Description   : This Procedure is used to inser application errors into ApplicationErrorLog  
Created By    : NagaBabu
Created Date  : 23-Mar-2011
---------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION  
24-Mar-2011 NagaBabu changed @vc_ErrorDescription LongDescription,@vc_TraceDescription LongDescription to 
						@nv_ErrorDescription  NVARCHAR(1000),@nv_TraceDescription  NVARCHAR(1000)
---------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_ApplicationErrorLog_Insert]
(
 @i_AppUserId KeyID ,
 @i_UserID KeyID ,
 @nv_IpAddress NVARCHAR(20) ,
 @nv_ErrorDescription  NVARCHAR(1000),
 @vc_PageName ShortDescription ,
 @nv_TraceDescription  NVARCHAR(1000),
 @vc_Status VARCHAR(15) ,
 @i_ErrorID KeyID OUT
)
AS
BEGIN TRY
      SET NOCOUNT ON
      DECLARE @l_numberOfRecordsInserted INT  
   
 -- Check if valid Application User ID is passed    
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END

      INSERT INTO
          ApplicationErrorLog
          (
            UserID ,
            IpAddress ,
            ErrorDescription ,
            PageName ,
            TraceDescription ,
            [Status] ,
            CreatedByUserId
          )
      VALUES
          (
            @i_UserId ,
			@nv_IpAddress ,
			@nv_ErrorDescription ,
			@vc_PageName ,
			@nv_TraceDescription ,
			@vc_Status ,
			@i_AppUserId 
          ) 
      
      SELECT 
		  @i_ErrorID = SCOPE_IDENTITY() ,
          @l_numberOfRecordsInserted = @@ROWCOUNT 

      IF @l_numberOfRecordsInserted <> 1
         BEGIN
               RAISERROR ( N'Invalid row count %d in Insert ApplicationErrorLog' ,
               17 ,
               1 ,
               @l_numberOfRecordsInserted )
         END

      RETURN 0
END TRY    
----------------------------------------------------------------------------     
BEGIN CATCH    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ApplicationErrorLog_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

