
/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_UserActivityLog_Insert]  
Description   : This procedure is used to Insert UserActivityLog Records
Created By    : Chaitanya
Created Date  : 01-Oct-2013  
------------------------------------------------------------------------------    
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
12/11/2013	    Chaitanya changed @v_Click_Event to @v_ActivityType	
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_UserActivityLog_Insert] (
	@i_AppUserId INT
	, @v_UserLoginIPAddress VARCHAR(20) = NULL
	, @v_PageName VARCHAR(200) = NULL
	, @v_ControlType VARCHAR(50) = NULL
	, @v_ActivityType VARCHAR(50) = NULL
	, @vc_ActivityDetails VARCHAR(max) = NULL
--	, @dt_OldDate DATETIME = NULL
	, @i_PatientUserID BIGINT = NULL
	, @vc_PatientMRN VARCHAR(20) = NULL
	, @i_GridRowId VARCHAR(4) = NULL
	, @i_GridDetails VARCHAR(100) = NULL
	, @i_Status INT OUTPUT
	)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		-- Check if valid Application User ID is passed                    
		IF (@i_AppUserId IS NULL)
			OR (@i_AppUserId <= 0)
		BEGIN
			RAISERROR (
					N'Invalid Application User ID %d passed.'
					, 17
					, 1
					, @i_AppUserId
					)
		END

		INSERT INTO UserActivityLog (
			UserID
			, UserLoginIPAddress
			, [DATETIME]
			, PageName
			, ControlType
			, ActivityDetails
			, ActivityType
			, PatientID
			, MRNNumber
			, RowID
			, GridDetails
--			,OldDate
			)
		VALUES (
			@i_AppUserId
			, @v_UserLoginIPAddress
			, GETUTCDATE()
			, @v_PageName
			, @v_ControlType
			, @vc_ActivityDetails
			, @v_ActivityType
			, CASE 
				WHEN @i_PatientUserID = 0
					THEN NULL
				ELSE @i_PatientUserID
				END
			, CASE 
				WHEN (@vc_PatientMRN ='' OR @vc_PatientMRN IS NULL)
					THEN NULL
				ELSE @vc_PatientMRN
				END
			,@i_GridRowId
			,@i_GridDetails
--			,@dt_OldDate
            )
		SET @i_Status = 1
	END TRY

	----------------------------------------------------------------------------------------
	BEGIN CATCH
		-- Handle exception  
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
	END CATCH
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserActivityLog_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

