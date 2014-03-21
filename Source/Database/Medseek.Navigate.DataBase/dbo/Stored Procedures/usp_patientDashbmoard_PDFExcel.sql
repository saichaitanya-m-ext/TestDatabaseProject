/*        
------------------------------------------------------------------------------        
Procedure Name: usp_patientDashbmoard_PDFExcel @i_AppUserId = 2,@i_PatientUserID = 1 
Description   : This procedure is used to get the details from patient table      
    or a complete list of all the CodeGroupingName      
Created By    : Gurumoorthy V
Created Date  : 24-June-2013  
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------        
*/
cREATE PROCEDURE [dbo].[usp_patientDashbmoard_PDFExcel] --2,1  
	(
	@i_AppUserId KEYID
	,@i_PatientUserID INT
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	-- Check if valid Application User ID is passed      
	IF (@i_AppUserId IS NULL)
		OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR (
				N'Invalid Application User ID %d passed.'
				,17
				,1
				,@i_AppUserId
				)
	END

	EXEC usp_PatientDashBoard_Home @i_AppUserId,@i_PatientUserID
	EXEC usp_DashBoard_PatientHomePage_ProgramEncounters @i_AppUserId,@i_PatientUserID
	EXEC usp_UserMedicationImmunizations_Select @i_AppUserId,@i_PatientUserID,NULL,NULL
	EXEC usp_PatientDashBoard_OutcomeMetric @i_AppUserId,@i_PatientUserID

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
    ON OBJECT::[dbo].[usp_patientDashbmoard_PDFExcel] TO [FE_rohit.r-ext]
    AS [dbo];

