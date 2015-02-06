/*  
------------------------------------------------------------------------------  
Procedure Name: usp_UserAllergies_Select  
Description   : This procedure is used to get the details from UserAllergies table
				based on the userID.
Created By    : Aditya  
Created Date  : 23-Mar-2010  
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
20-Apr-2011 NagaBabu Added WHEN 'N' THEN 'Not Reported' statement to the select statement  
12-Jul-2012 Sivakrishna Added DataSourceName Column to Existing select statement.
17-Jul-2012 Sivakrishna Added DataSourceId Column to Existing select statement.
05-Sep-2012 P.V.P.Moahn Added AllergiesName parameter and added Join Statement AllergiesID Column to Existing insert Statement
19-Mar-2013 P.V.P.Moahn Modified  UserID to PatientID parameter and Modified table userAllergies to PatientAllergies 
------------------------------------------------------------------------------  
*/  
CREATE PROCEDURE [dbo].[usp_UserAllergies_Select]
(
	@i_AppUserId KeyID,
	@i_UserID KeyID,
	@i_UserAllergiesID KeyID = NULL,
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

	SELECT 	PatientAllergiesID UserAllergiesID,
			PatientID UserID,
			Allergies.AllergiesID,
			Reaction,
			CASE Severity
			   WHEN 'S' THEN 'Severe Reaction'
			   WHEN 'M' THEN 'Mild Reaction'
			   WHEN 'N' THEN 'Not Reported'
			END AS Severity,
			Comments,
			PatientAllergies.CreatedByUserId,
			PatientAllergies.CreatedDate,
			PatientAllergies.LastModifiedByUserId,
			PatientAllergies.LastModifiedDate,
			UserAllergiesDate,
			CASE PatientAllergies.StatusCode 
			   WHEN 'A' THEN 'Active'
			   WHEN 'I' THEN 'InActive'
			   ELSE ''
			END AS StatusDescription,
		  PatientAllergies.DataSourceID,
		  CodeSetDataSource.SourceName,
		  Allergies.Name
		  
		  
	 FROM 
		 PatientAllergies WITH(NOLOCK)
	 LEFT JOIN CodeSetDataSource WITH(NOLOCK)
	    ON PatientAllergies.DataSourceID = CodeSetDataSource.DataSourceId
	 LEFT JOIN Allergies  WITH(NOLOCK)
	    ON Allergies.AllergiesID = PatientAllergies.AllergiesID   
	 WHERE (PatientID = @i_UserID  OR @i_UserID IS NULL)
	   AND ( PatientAllergiesID  = @i_UserAllergiesID
				  OR @i_UserAllergiesID IS NULL ) 
       AND ( @v_StatusCode IS NULL or PatientAllergies.StatusCode = @v_StatusCode )
        
END TRY  
--------------------------------------------------------   
BEGIN CATCH  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserAllergies_Select] TO [FE_rohit.r-ext]
    AS [dbo];

