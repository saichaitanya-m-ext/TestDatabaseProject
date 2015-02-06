
/*  
------------------------------------------------------------------------------  
Procedure Name: usp_NPOPatientSupplementalForm_InsertUpdate
Description   : This procedure is used to insert\update the data into NPOPatientSupplementalForm
Created By    : Rathnam
Created Date  : 10-June-2013
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_NPOPatientSupplementalForm_InsertUpdate] 
	(
	@i_AppUserId KeyID
	,@i_PatientId KeyID
	,@d_DateOfService DATETIME = NULL
	,@v_RecordType VARCHAR(1) --> o	Service(S) o	Lab(R) o	Pharmacy(P) o	Deceased(X)
	,@i_CodeTypeID keyid = NULL
	,@i_MeasureID keyid = NULL
	,@v_CodeValue VARCHAR(20) = NULL
	,@v_ServiceCode VARCHAR(3) = NULL
	,@b_IsNumericResultType keyid = NULL
	,@v_LabOperator VARCHAR(20) = NULL
	,@dc_LabResultValue DECIMAL(5, 2) = NULL
	,@i_LabResultTextID KEYID = NULL
	,@i_EthnicityID KEYID = NULL
	,@i_RaceID KEYID = NULL
	,@i_SpokenLanguageID keyid = NULL
	,@i_WrittenLanguageID KEYID = NULL
	,@d_DateOfDeath USERDATE = NULL
	,@vc_ServiceProviderNPI VARCHAR(50) = NULL
	,@vc_ServiceProviderMILicenceNo VARCHAR(50) = NULL
	,@vc_PCPNPI VARCHAR(50) = NULL
	,@vc_PCPMILicenceNo VARCHAR(50) = NULL
	,@i_NPOPatientSupplementalForm KEYID = NULL
	,@O_NPOPatientSupplementalForm KEYID OUTPUT
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

	--IF @i_NPOPatientSupplementalForm IS NULL
	--BEGIN
		INSERT INTO NPOPatientSupplementalForm (
			PatientId
			,DateofService
			,RecordType
			,CodeTypeID
			,MeasureID
			,CodeValue
			,ServiceCode
			,IsNumericResultType
			,LabOperator
			,LabResultValue
			,LabResultTextID
			,EthnicityID
			,RaceID
			,SpokenLanguageID
			,WrittenLanguageID
			,CreatedByUserID
			,CreatedDate
			,DateOfDeath
			,ServiceProviderNPI
			,ServiceProviderMILicenceNo
			,PCPNPI
			,PCPMILicenceNo
			)
		VALUES (
			 @i_PatientId
			,@d_DateOfService
			,@v_RecordType
			,@i_CodeTypeID
			,@i_MeasureID
			,@v_CodeValue
			,@v_ServiceCode
			,@b_IsNumericResultType
			,@v_LabOperator
			,@dc_LabResultValue
			,@i_LabResultTextID
			,@i_EthnicityID
			,@i_RaceID
			,@i_SpokenLanguageID
			,@i_WrittenLanguageID
			,@i_AppUserId
			,GETDATE()
			,@d_DateOfDeath
			,@vc_ServiceProviderNPI
			,@vc_ServiceProviderMILicenceNo
			,@vc_PCPNPI
			,@vc_PCPMILicenceNo
			)
			SELECT @O_NPOPatientSupplementalForm = SCOPE_IDENTITY()
	--END
	--ELSE
	--BEGIN
	--	UPDATE NPOPatientSupplementalForm
	--	SET  PatientId = @i_PatientId
	--		,DateofService = @d_DateOfService
	--		,RecordType = @v_RecordType
	--		,CodeTypeID = @i_CodeTypeID
	--		,MeasureID = @i_MeasureID
	--		,CodeTypeID = @i_CodeTypeID
	--		,ServiceCode = @v_ServiceCode
	--		,IsNumericResultType = @b_IsNumericResultType
	--		,LabOperator = @v_LabOperator
	--		,LabResultValue = @dc_LabResultValue
	--		,LabResultTextID = @i_LabResultTextID
	--		,EthnicityID = @i_EthnicityID
	--		,RaceID = @i_RaceID
	--		,SpokenLanguageID = @i_SpokenLanguageID
	--		,WrittenLanguageID = @i_WrittenLanguageID
	--	WHERE PatientSupplementalFormID = @i_NPOPatientSupplementalForm
	--END
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
    ON OBJECT::[dbo].[usp_NPOPatientSupplementalForm_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

