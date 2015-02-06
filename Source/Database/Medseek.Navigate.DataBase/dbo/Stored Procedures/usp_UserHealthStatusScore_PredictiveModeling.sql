/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserHealthStatusScore_PredictiveModeling    
Description   : This procedure is used to get the records FOR PredictiveModeling  
				table  
Created By    : Rathnam    
Created Date  : 14-Oct-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
24-Oct-2011 NagaBabu Added UserId field in select list for the condition IF @i_HealthStatusScoreId IS NOT NULL
20-Mar-2013 P.V.P.Mohan modified UserHealthStatusScore to PatientHealthStatusScore
			and modified columns.   
------------------------------------------------------------------------------    
*/

CREATE PROCEDURE [dbo].[usp_UserHealthStatusScore_PredictiveModeling]--1,35
(
 @i_AppUserId KEYID
,@i_HealthStatusScoreId KEYID = NULL
)
AS
BEGIN TRY
    SET NOCOUNT ON     
-- Check if valid Application User ID is passed  

    IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
       BEGIN
             RAISERROR ( N'Invalid Application User ID %d passed.'
             ,17
             ,1
             ,@i_AppUserId )
       END
    IF @i_HealthStatusScoreId IS NULL
		BEGIN
			SELECT
				uhs.HealthStatusScoreId
			   ,hst.Name
			   ,COUNT(uhs.PatientID) AS NoOfPatients
			FROM
				PatientHealthStatusScore uhs
			INNER JOIN HealthStatusScoreType hst
				ON uhs.HealthStatusScoreId = hst.HealthStatusScoreId
			INNER JOIN (SELECT MAX(PatientHealthStatusId) AS UserHealthStatusId  FROM PatientHealthStatusScore GROUP BY PatientID ) uhs1
			   ON uhs1.UserHealthStatusId = uhs.PatientHealthStatusId 		
			WHERE
				uhs.StatusCode = 'A'
				AND hst.StatusCode = 'A'
				AND ISNULL(CONVERT(VARCHAR,uhs.Score),uhs.ScoreText) <> ''
				AND uhs.DateDetermined IS NOT NULL
			GROUP BY
				uhs.HealthStatusScoreId
			   ,hst.Name
			ORDER BY
				NoOfPatients desc
		END
	ELSE IF @i_HealthStatusScoreId IS NOT NULL
		BEGIN
			SELECT
				uhs.PatientHealthStatusId UserHealthStatusId
			   ,uhs.PatientID UserId
			   ,UPPER(dbo.ufn_GetUserNameByID(uhs.PatientID)) AS PatientName
			   ,uhs.DateDetermined
			   ,ISNULL(CONVERT(VARCHAR,uhs.Score),uhs.ScoreText) AS Score
			FROM
				PatientHealthStatusScore uhs
			INNER JOIN HealthStatusScoreType hst
				ON hst.HealthStatusScoreId = uhs.HealthStatusScoreId
			INNER JOIN (SELECT MAX(PatientHealthStatusId) AS UserHealthStatusId  FROM PatientHealthStatusScore GROUP BY PatientID ) uhs1
			   ON uhs1.UserHealthStatusId = uhs.PatientHealthStatusId 		
			WHERE
				uhs.StatusCode = 'A'
				AND hst.StatusCode = 'A'
				AND hst.HealthStatusScoreId = @i_HealthStatusScoreId
				AND ISNULL(CONVERT(VARCHAR,uhs.Score),uhs.ScoreText) <> ''
				AND uhs.DateDetermined IS NOT NULL
		    ORDER BY Score		
		END
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
    ON OBJECT::[dbo].[usp_UserHealthStatusScore_PredictiveModeling] TO [FE_rohit.r-ext]
    AS [dbo];

