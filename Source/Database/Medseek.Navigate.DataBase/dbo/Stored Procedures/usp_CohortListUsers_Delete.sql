
/*      
------------------------------------------------------------------------------      
Procedure Name: [usp_CohortListUsers_Delete]      
Description   : This procedure is used to Delete record from CohortListUsers table  
Created By    : Gurumoorthy.V      
Created Date  : 28-11-2011
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
      
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_CohortListUsers_Delete] (
	@i_AppUserId KEYID
	,@i_CohortListId KEYID = NULL
	,@i_SubCohortListId KEYID = NULL
	,@t_UserCohortList TTYPEKEYID READONLY
	,@t_UserSubCohortList TTYPEKEYID READONLY
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @l_numberOfRecordsDeleted INT

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

	------------DELETE OPERATION -----------------
	IF (@i_CohortListId IS NOT NULL)
		OR (@i_CohortListId <> 0)
	BEGIN
		UPDATE CLU
		SET StatusCode = 'I'
		FROM CohortListUsers CLU
		INNER JOIN @t_UserCohortList TUCD ON CLU.UserId = TUCD.tKeyId
		WHERE StatusCode = 'P'
	END

	IF (@i_SubCohortListId IS NOT NULL)
		OR (@i_SubCohortListId <> 0)
	BEGIN
		UPDATE SCLU
		SET StatusCode = 'I'
		FROM SubCohortListUsers SCLU
		INNER JOIN @t_UserSubCohortList TUSCD ON SCLU.UserId = TUSCD.tKeyId
		WHERE StatusCode = 'P'
	END

	SELECT @l_numberOfRecordsDeleted = @@ROWCOUNT

	IF @l_numberOfRecordsDeleted <> 1
	BEGIN
		RAISERROR (
				N'Invalid Row count %d passed to CohortListCriteria'
				,17
				,1
				,@l_numberOfRecordsDeleted
				)
	END

	RETURN 0
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
    ON OBJECT::[dbo].[usp_CohortListUsers_Delete] TO [FE_rohit.r-ext]
    AS [dbo];

