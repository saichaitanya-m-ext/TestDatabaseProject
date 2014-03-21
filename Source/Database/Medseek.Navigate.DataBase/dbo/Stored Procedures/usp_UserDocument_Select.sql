/*              
--------------------------------------------------------------------------------------------    
Procedure Name: usp_UserDocument_Select    
Description   : This procedure is used to get the details from DocumentCategory,UserDocument  
                DocumentType Tables.    
Created By    : NagaBabu    
Created Date  : 27-May-2010    
---------------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY     BY       DESCRIPTION              
22-June-2010 NagaBabu  Added MimeType parameter  
22-June-2010 NagaBabu  Deleted MimeType parameter  
13-Aug-2010  Rathnam   Added Rule patient Viewable Case statement in whereclause.  
19-mar-2013 P.V.P.Mohan Modified UserDocument to PatientDocument  
---------------------------------------------------------------------------------------------              
*/
CREATE PROCEDURE [dbo].[usp_UserDocument_Select] (
	@i_AppUserId KEYID
	,@i_UserId KEYID = NULL
	,@i_UserDocumentId KEYID = NULL
	,@v_StatusCode STATUSCODE = NULL
	--@vc_MimeType VARCHAR(20) = NULL    
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	-- Check if valid Application User ID is passed              
	IF (@i_AppUserId IS NULL)
		OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR (
				N'Invalid Application UserID %d passed.'
				,17
				,1
				,@i_AppUserId
				)
	END

	--------------------- SELECT OPERATION TAKES PLACE ---------------------------------------------    
	DECLARE @b_Patient BIT

	SET @b_Patient = (
			SELECT 1
			FROM Patients
			WHERE Patients.PatientID = @i_AppUserId
			)

	SELECT PatientDocument.PatientDocumentId UserDocumentId
		,PatientDocument.PatientID UserId
		,DocumentCategory.DocumentCategoryId
		,DocumentCategory.CategoryName AS DocumentCategory
		,DocumentType.DocumentTypeId
		,DocumentType.NAME AS DocumentType
		,PatientDocument.NAME AS FileName
		,PatientDocument.Body
		,PatientDocument.FileSizeinBytes AS FileSize
		,PatientDocument.CreatedByUserId
		,PatientDocument.CreatedDate
		,PatientDocument.LastModifiedByUserId
		,PatientDocument.LastModifiedDate
		,CASE PatientDocument.StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'InActive'
			END AS StatusDescription
		,PatientDocument.MimeType
	FROM PatientDocument WITH (NOLOCK)
	INNER JOIN DocumentCategory WITH (NOLOCK)
		ON DocumentCategory.DocumentCategoryId = PatientDocument.DocumentCategoryId
	INNER JOIN DocumentType WITH (NOLOCK)
		ON PatientDocument.DocumentTypeId = DocumentType.DocumentTypeId
	WHERE (
			PatientDocument.PatientID = @i_UserId
			OR @i_UserId IS NULL
			)
		AND (
			PatientDocument.PatientDocumentId = @i_UserDocumentId
			OR @i_UserDocumentId IS NULL
			)
		AND (
			PatientDocument.StatusCode = @v_StatusCode
			OR @v_StatusCode IS NULL
			)
		AND (
			@b_Patient IS NULL
			OR (
				DocumentCategory.isPatientViewable = 1
				AND @b_Patient = 1
				)
			)
END TRY

BEGIN CATCH
	-- Handle Exception              
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserDocument_Select] TO [FE_rohit.r-ext]
    AS [dbo];

