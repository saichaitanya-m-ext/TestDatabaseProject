/*
-------------------------------------------------------------------------
Procedure Name: usp_HandleException
Description	  : This Stored Procedure is used for Exception Handling.
Created By    : Aditya
Created Date  : 07-Jan-2010
--------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION

--------------------------------------------------------------------------
19-Mar-2012 Gurumoorthy.V Uncommented the Exception code
*/

CREATE PROCEDURE [dbo].[usp_HandleException] @i_UserID INT = NULL
AS
BEGIN

      SET NOCOUNT ON ;

	
    -- Return if there is no error information to log.
      IF ERROR_NUMBER() IS NULL
         RETURN ;

      DECLARE
              @vc_Error_Message NVARCHAR(2048) ,
              @i_Error_Number INT ,
              @i_Error_Severity INT ,
              @i_Error_State INT ,
              @vc_Error_Procedure SYSNAME ,
              @i_Error_Procedure INT ,
              @i_Trancount INT ,
              @i_SPReturn INT

      SET @vc_Error_Message = ERROR_MESSAGE()
      SET @i_Error_Number = ERROR_NUMBER()
      SET @i_Error_Severity = ERROR_SEVERITY()
      SET @i_Error_State = ERROR_STATE()
      SET @vc_Error_Procedure = ISNULL(ERROR_PROCEDURE() , '-')
      SET @i_Error_Procedure = ERROR_LINE()
      SET @i_Trancount = @@TRANCOUNT
      SET @i_SPReturn = 0


      IF @i_Trancount > 0
         BEGIN
               ROLLBACK TRANSACTION ;
         END

	 --Throw the original error information.
      IF @i_Error_Number < 50000 -- If Err Num >= 50000 means it is user generated error and RAISERROR has alreaby been issued.
         BEGIN
               RAISERROR (	 -- Build the message string that will contain original error information.
               N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: %s' ,
               @i_Error_State ,
               @i_Error_Number -- parameter: original error number.
               ,
               @i_Error_Severity -- parameter: original error severity.
               ,
               @i_Error_State -- parameter: original error state.
               ,
               @vc_Error_Procedure -- parameter: original error procedure name.
               ,
               @i_Error_Procedure -- parameter: original error line number.
               ,
               @vc_Error_Message	-- parameter: original error message.
               ) ;
         END
	
	-- Log the error into ErrorLog table
      EXECUTE @i_SPReturn = dbo.usp_ErrorLog_Insert @i_UserID = @i_UserID , @i_Error_Number = @i_Error_Number , @i_Error_Message = @vc_Error_Message , @i_Error_Severity = @i_Error_Severity , @i_Error_State = @i_Error_State , @i_Error_Procedure = @vc_Error_Procedure , @i_Error_Line = @i_Error_Procedure , @i_Trancount = @i_Trancount

      RETURN @i_Error_Number
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HandleException] TO [FE_rohit.r-ext]
    AS [dbo];

