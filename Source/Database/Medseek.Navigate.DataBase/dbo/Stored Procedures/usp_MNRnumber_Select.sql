/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_MNRnumber_Select]  23,'123'
Description   : This procedure is used Search MNRNUMBERS Records
Created By    : SANTHOSH for inline search in UserActivityLog report
Created Date  : 11-Dec-2013  
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE usp_MNRnumber_Select
(
@i_AppUserID INT,
@vc_MnrNoSearch varchar(50)
)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		IF(@i_AppUserID IS NULL)OR (@i_AppUserID<=0)
			BEGIN
				RAISERROR ( N'Invalid Application User ID %d passed.' ,              
				17 ,              
				1 ,              
				@i_AppUserID) 
			END
		SELECT DISTINCT p.MemberNum AS MNRNO,p.MemberNum as MNRText 
		FROM Patients p
		WHERE P.MemberNum like @vc_MnrNoSearch+'%'
	END TRY
	BEGIN CATCH
		DECLARE @i_ReturnedErrorID INT              
		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId              
		RETURN @i_ReturnedErrorID  
	END CATCH 
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_MNRnumber_Select] TO [FE_rohit.r-ext]
    AS [dbo];

