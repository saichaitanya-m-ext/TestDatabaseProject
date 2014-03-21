/*
-------------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_ErrorLog_Insert]
Description	  : This Stored Procedure is used for inserting a row into the ErrorLog table.
Created By    : Aditya
Created Date  : 07-Jan-2010
--------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION

--------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[usp_ErrorLog_Insert]
       @i_UserID INT = NULL ,
       @i_Error_Number INT ,
       @i_Error_Severity INT ,
       @i_Error_State INT ,
       @i_Error_Procedure SYSNAME ,
       @i_Error_Line INT ,
       @i_Error_Message NVARCHAR(2048) ,
       @i_Trancount INT ,
       @i_ErrorLogID INT = 0 OUTPUT
AS
BEGIN
      SET NOCOUNT ON

      BEGIN TRY      
      
         --Return if there is no error information to log.      
            IF ERROR_NUMBER() IS NULL
               RETURN -1   
      
        -- Return if inside an uncommittable transaction.      
        -- Data insertion/modification is not allowed when       
        -- a transaction is in an uncommittable state.      
            IF XACT_STATE() = -1
               BEGIN
                     PRINT 'Cannot log error since the current transaction is in an uncommittable state. ' + 'Rollback the transaction before executing dbo.usp_ErrorLog_Insert in order to successfully log error information.' ;
                     RETURN ;
               END ;

            INSERT
                dbo.ErrorLog
                (
                  UserID ,
                  ErrorNumber ,
                  ErrorSeverity ,
                  ErrorState ,
                  ErrorProcedure ,
                  ErrorLine ,
                  ErrorMessage ,
                  TransactionCount ,
                  ErrorDate ,
                  CurrentUser ,
                  SystemUser )
            VALUES
                (
                  @i_UserID ,
                  @i_Error_Number ,
                  @i_Error_Severity ,
                  @i_Error_State ,
                  @i_Error_Procedure ,
                  @i_Error_Line ,
                  @i_Error_Message ,
                  @i_Trancount ,
                  GETDATE() ,
                  CURRENT_USER ,
                  SYSTEM_USER )  
      
        -- Pass back the ErrorLogID of the row inserted      
            SELECT
                @i_ErrorLogID = SCOPE_IDENTITY()

            RETURN 0
      END TRY
      BEGIN CATCH

            PRINT 'An error occurred in stored procedure dbo.usp_ErrorLog_Insert'
            RETURN -1
      END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ErrorLog_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

