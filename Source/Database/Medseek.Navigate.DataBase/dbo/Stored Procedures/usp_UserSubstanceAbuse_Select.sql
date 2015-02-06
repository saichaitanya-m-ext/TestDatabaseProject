/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_UserSubstanceAbuse_Select]    
Description   : This Procedure is used to get the values from UserSubstanceAbuse tabla				
Created By    : NagaBabu
Created Date  : 26-July-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
12-07-2012   Sivakrishna added SourceName column to the Existing Select statement.
17-07-2012   Sivakrishna added DataSourceId column to the Existing Select statement.   
21-Mar-2013	 P.V.P.Mohan modified DataSource to CodeSetDataSource and Columns
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_UserSubstanceAbuse_Select]
(  
	 @i_AppUserId KeyID ,
	 @i_PatientUserId KeyId,
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
  
	SELECT
		UserSubstanceAbuseId,
		UserSubstanceAbuse.SubstanceAbuseId,
		SubstanceAbuse.Name,
		PatientId PatientUserId,
		CASE SubstanceUse
			WHEN 'C' THEN 'Current'
			WHEN 'P' THEN 'Prior'
	    END AS SubstanceUse,
		NoOfYears,
		Comments,
		CASE UserSubstanceAbuse.StatusCode
			WHEN 'A' THEN 'Active'
			WHEN 'I' THEN 'InActive'
		END AS StatusCode,	
		UserSubstanceAbuse.CreatedByUserId,
		UserSubstanceAbuse.CreatedDate,
		UserSubstanceAbuse.LastModifiedByUserId,
		UserSubstanceAbuse.LastModifiedDate,
		UserSubstanceAbuse.DataSourceId,
		CodeSetDataSource.SourceName
	FROM
		UserSubstanceAbuse	WITH(NOLOCK)
	INNER JOIN SubstanceAbuse	WITH(NOLOCK)
		ON UserSubstanceAbuse.SubstanceAbuseId = SubstanceAbuse.SubstanceAbuseId
	LEFT JOIN CodeSetDataSource WITH(NOLOCK)
	    ON CodeSetDataSource.DataSourceId = UserSubstanceAbuse.DataSourceId
	WHERE PatientId = @i_PatientUserId	
	AND (UserSubstanceAbuse.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )      
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
    ON OBJECT::[dbo].[usp_UserSubstanceAbuse_Select] TO [FE_rohit.r-ext]
    AS [dbo];

