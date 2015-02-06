/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserFamilyMedicalHistory_Select   
Description   : This procedure is used to get the list of all UserFamilyMedicalHistory Details
Created By    : Rahul    
Created Date  : 6-July-2011    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION  
06-Jun-2012 NagaBabu Added @i_UserFamilyMedicalHistoryID as input parameter  
12-Jul-2012   Sivakrishna Added DataSourceName Column to Existing select statement.     
16-Jul-2012   Sivakrishna Added DataSourceId Column to Existing select statement.     
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_UserFamilyMedicalHistory_Select] -- 1
(  
	@i_AppUserId INT,
	@i_UserID KeyId = NULL,   
	@v_StatusCode StatusCode = NULL ,
	@i_UserFamilyMedicalHistoryID KeyId = NULL
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

	SELECT 
		UserFamilyMedicalHistory.UserFamilyMedicalHistoryID, 
		UserFamilyMedicalHistory.UserID, 
		disease.DiseaseId, 
		Disease.Name, 
		FamilyRelation.Relation, 
		UserFamilyMedicalHistory.Comments,
		UserFamilyMedicalHistory.StartDate,
		UserFamilyMedicalHistory.EndDate,
		UserFamilyMedicalHistory.CreatedByUserId,  
        UserFamilyMedicalHistory.CreatedDate,
        UserFamilyMedicalHistory.LastModifiedByUserId,
        UserFamilyMedicalHistory.LastModifiedDate,
        CASE UserFamilyMedicalHistory.StatusCode     
        WHEN 'A' THEN 'Active'    
        WHEN 'I' THEN 'InActive'    
        ELSE ''    
        END AS StatusCode   ,
        UserFamilyMedicalHistory.DataSourceId,
        DataSource.SourceName
	FROM 
		UserFamilyMedicalHistory WITH(NOLOCK)
	INNER JOIN Disease WITH(NOLOCK)
	    ON UserFamilyMedicalHistory.DiseaseID= Disease.DiseaseId
	INNER JOIN FamilyRelation WITH(NOLOCK)
	    ON FamilyRelation.RelationId = UserFamilyMedicalHistory.RelationID
	LEFT JOIN DataSource WITH(NOLOCK)
	   ON DataSource.DataSourceId = UserFamilyMedicalHistory.DataSourceId
	WHERE ( UserFamilyMedicalHistory.UserID = @i_UserID )    
        AND ( UserFamilyMedicalHistory.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )
        AND (UserFamilyMedicalHistory.UserFamilyMedicalHistoryID = @i_UserFamilyMedicalHistoryID OR @i_UserFamilyMedicalHistoryID IS NULL )
END TRY    
----------------------------------------------------------------------------------                       
BEGIN CATCH      
    -- Handle exception      
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
      RETURN @i_ReturnedErrorID  
END CATCH
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserFamilyMedicalHistory_Select] TO [FE_rohit.r-ext]
    AS [dbo];

