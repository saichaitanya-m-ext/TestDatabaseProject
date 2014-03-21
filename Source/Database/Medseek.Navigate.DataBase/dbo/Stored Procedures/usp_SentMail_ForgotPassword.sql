
/*
---------------------------------------------------------------------------------------
Procedure Name: [usp_SentMail_ForgotPassword]
Description	  : This StoredProcedure is used to provide login credentials to the password forgot users
Created By    :	NagaBabu
Created Date  : 21-Feb-2012
----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY	DESCRIPTION
----------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_SentMail_ForgotPassword] (
	@v_profile_name VARCHAR(24) = 'CCM'
	,@v_NotifyCommunicationText NVARCHAR(MAX)
	,@v_NotifySubjectText VARCHAR(200)
	,@i_dbmailReferenceId INT = NULL
	,@v_EmailIdPrimary EmailId
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	-- Check if valid Application User ID is passed
	EXEC msdb.dbo.sp_send_dbmail @profile_name = @v_profile_name
		,@recipients = @v_EmailIdPrimary
		,@body = @v_NotifyCommunicationText
		,@subject = @v_NotifySubjectText
		,@body_format = 'HTML'
		,@mailitem_id = @i_dbmailReferenceId OUTPUT
END TRY

BEGIN CATCH
	-- Handle exception
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = 1
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_SentMail_ForgotPassword] TO [FE_rohit.r-ext]
    AS [dbo];

