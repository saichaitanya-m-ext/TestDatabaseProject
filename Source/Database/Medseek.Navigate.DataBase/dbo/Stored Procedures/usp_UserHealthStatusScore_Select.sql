/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserHealthStatusScore_Select    
Description   : This procedure is used to get the records from the UserHealthStatusScore  
				table  
Created By    : Aditya    
Created Date  : 21-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
20-Mar-2013 P.V.P.Mohan modified UserHealthStatusScore to PatientHealthStatusScore
			and modified columns.  
------------------------------------------------------------------------------    
*/  

CREATE PROCEDURE [dbo].[usp_UserHealthStatusScore_Select]  
(  
	 @i_AppUserId KeyID,  
	 @i_UserHealthStatusId KeyID = NULL,  
	 @i_UserId KeyID = NULL,
	 @v_StatusCode StatusCode = NULL  
)  
AS  
BEGIN TRY  
    SET NOCOUNT ON     
-- Check if valid Application User ID is passed  
  
    IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
    BEGIN  
           RAISERROR ( N'Invalid Application User ID %d passed.' ,  
           17 ,  
           1 ,  
           @i_AppUserId )  
    END  
  
	 SELECT PatientHealthStatusScore.PatientHealthStatusId UserHealthStatusId,
			PatientHealthStatusScore.PatientID UserId,
			ISNULL(CAST(PatientHealthStatusScore.Score AS VARCHAR(200)),'') +	ISNULL(PatientHealthStatusScore.ScoreText,'') as Score,
			HealthStatusScoreType.Name as Type,
			HealthStatusScoreOrganization.Name as Organization,
			PatientHealthStatusScore.Comments,
			PatientHealthStatusScore.DateDetermined,
			PatientHealthStatusScore.HealthStatusScoreId,
			PatientHealthStatusScore.DateDue,
			PatientHealthStatusScore.CreatedByUserId,
			PatientHealthStatusScore.CreatedDate,
			PatientHealthStatusScore.LastModifiedByUserId,
			PatientHealthStatusScore.LastModifiedDate, 
			 CASE PatientHealthStatusScore.StatusCode   
				WHEN 'A' THEN 'Active'  
				WHEN 'I' THEN 'InActive'  
				ELSE ''  
			 END AS StatusDescription  
	  FROM   PatientHealthStatusScore WITH(NOLOCK)
			 INNER JOIN HealthStatusScoreType WITH(NOLOCK)
					ON HealthStatusScoreType.HealthStatusScoreId = PatientHealthStatusScore.HealthStatusScoreId
			 INNER JOIN HealthStatusScoreOrganization WITH(NOLOCK)
					ON HealthStatusScoreOrganization.HealthStatusScoreOrgId = HealthStatusScoreType.HealthStatusScoreOrgId 
	  WHERE  ( PatientHealthStatusScore.PatientHealthStatusId = @i_UserHealthStatusId OR @i_UserHealthStatusId IS NULL )  
			  AND ( PatientHealthStatusScore.PatientID = @i_UserId OR @i_UserId IS NULL )
			  AND ( PatientHealthStatusScore.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL ) 
      ORDER BY  PatientHealthStatusScore.DateDue DESC,
				PatientHealthStatusScore.DateDetermined DESC
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
    ON OBJECT::[dbo].[usp_UserHealthStatusScore_Select] TO [FE_rohit.r-ext]
    AS [dbo];

