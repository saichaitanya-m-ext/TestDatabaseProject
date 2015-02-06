
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_AuditPatientsName_Select]  23,'sha'
Description   : This procedure is used Search Patientnames in  Records
Created By    : SANTHOSH for inline search in UserActivityLog report
Created Date  : 11-Dec-2013  
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE usp_AuditPatientsName_Select
(
@i_AppUserID INT,
@vc_PatientSearch varchar(50)
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
		SELECT DISTINCT p.LastName+' , '+p.FirstName AS PatientName,p.PatientID as PatientID 
		FROM Patients p
		WHERE ((p.FirstName LIKE @vc_PatientSearch+ '%') 
				OR (p.LastName LIKE @vc_PatientSearch +'%') 
				)			
	END TRY
	BEGIN CATCH
		DECLARE @i_ReturnedErrorID INT              
		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId              
		RETURN @i_ReturnedErrorID  
	END CATCH 
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_AuditPatientsName_Select] TO [FE_rohit.r-ext]
    AS [dbo];

