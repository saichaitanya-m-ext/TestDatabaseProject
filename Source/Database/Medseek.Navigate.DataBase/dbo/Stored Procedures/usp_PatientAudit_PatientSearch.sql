/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_PatientAudit_PatientSearch] 1,NULL,'655'
Description   : This procedure is used to get PatientName and MRNNumber data in the dropdowns
Created By    : Chaitanya
Created Date  : 16-Dec-2013  
------------------------------------------------------------------------------    
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
-------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_PatientAudit_PatientSearch] (
	@i_AppUserID INT
	, @vc_PatientName VARCHAR(100) = NULL
	, @vc_MemberNum VARCHAR(80) = NULL
	)
AS
BEGIN
	BEGIN TRY
		IF (@i_AppUserID IS NULL)
			OR (@i_AppUserID <= 0)
		BEGIN
			RAISERROR (
					N'Invalid Application User ID %d passed.'
					, 17
					, 1
					, @i_AppUserID
					)
		END

		SELECT DISTINCT P.PatientID
			, ISNULL(P.LastName, NULL) + ', ' + ISNULL(P.FirstName, NULL) AS PatientName
			, P.MedicalRecordNumber AS MRNNumber
			, P.MedicalRecordNumber AS MRNValue
		FROM Patient P
		INNER JOIN UserActivityLog ual
		ON ual.PatientID = P.PatientID
		WHERE ual.PatientID IS NOT NULL
			AND (
				P.MedicalRecordNumber LIKE @vc_MemberNum + '%'
				OR @vc_MemberNum IS NULL
				)
			AND (
				(P.FirstName LIKE '%' + @vc_PatientName + '%')
				OR (P.LastName LIKE '%' + @vc_PatientName + '%')
				OR @vc_PatientName IS NULL
				)
			--AND ual.PatientID IS NOT NULL
	END TRY

	---------------------------------------------------------------------------------------------------------------------     
	BEGIN CATCH
		-- Handle exception          
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PatientAudit_PatientSearch] TO [FE_rohit.r-ext]
    AS [dbo];

