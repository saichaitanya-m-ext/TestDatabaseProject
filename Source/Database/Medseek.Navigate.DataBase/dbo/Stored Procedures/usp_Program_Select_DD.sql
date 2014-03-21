
/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_Program_Select_DD]  
Description   : This procedure is used to get the list of all active Program Names.
Created By    : Aditya
Created Date  : 23-Mar-2010  
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
17-June-2010 NagaBabu Added programidAndEnrolment  in select statement 
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Program_Select_DD] (@i_AppUserId INT)
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

	--------------- Select all Program Names -------------
	SELECT ProgramId
		,ProgramName
		,CAST(ProgramId AS VARCHAR(4)) + '-' + (
			CASE AllowAutoEnrollment
				WHEN 1
					THEN '1'
				ELSE '0'
				END
			) AS ProgramIdAndEnrolment
	FROM Program
	WHERE StatusCode = 'A'
	ORDER BY ProgramName
END TRY

----------------------------------------------------------   
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Program_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

