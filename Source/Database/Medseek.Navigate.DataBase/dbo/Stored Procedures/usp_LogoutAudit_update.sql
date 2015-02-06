
--sp_helptext usp_LogOutAudit_Update    
/*            
------------------------------------------------------------------------------            
Procedure Name: [usp_LoginAudit_Update]        
Description   : This Procedure is used to update values into LoginAudit         
Created By    : Venugopal.G        
Created Date  : 21-July-2011        
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION     
Santosh commented the Userid Update       
------------------------------------------------------------------------------            
*/
--select * from LoginAudit      
--exec usp_LogoutAudit_update 23,'2013-02-06 16:05:02.767','192.168.57'      
--select * from LoginAudit      
CREATE PROCEDURE [dbo].[usp_LogoutAudit_update] (
	@AppUserId KEYID
	,@logouttime DATETIME
	,@Auditid INT
	,@logoutype VARCHAR(50)
	)
AS
SET NOCOUNT ON

DECLARE @l_numberOfRecordsupdated INT
DECLARE @logintime AS DATETIME
DECLARE @Sec BIGINT
DECLARE @timeduration VARCHAR(50)

SET @logouttime = GETUTCDATE()

SELECT @logintime = LoginDate
FROM LoginAudit
WHERE AuditId = @Auditid

SELECT @Sec = DateDiff(s, @logintime, @logouttime)

SELECT @timeduration = convert(VARCHAR(5), @sec / 3600) + ':' + convert(VARCHAR(5), @sec % 3600 / 60) + ':' + convert(VARCHAR(5), (@sec % 60))

UPDATE LoginAudit
SET logoutdate = @logouttime
	--,userid = @AppUserId
	,timeduration = @timeduration
	,Logouttype = @logoutype
WHERE LoginDate = @logintime
	AND AuditId = @Auditid

IF @l_numberOfRecordsupdated <> 1
BEGIN
	RAISERROR (
			N'Invalid row count %d in insert LoginAudit table'
			,17
			,1
			,@l_numberOfRecordsupdated
			)
END

RETURN 0

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LogoutAudit_update] TO [FE_rohit.r-ext]
    AS [dbo];

