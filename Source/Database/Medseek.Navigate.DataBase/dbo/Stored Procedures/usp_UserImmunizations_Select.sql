/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserImmunizations_Select      
Description   : This procedure is used to get the list of all the detais from the     
    UserImmunizations table based on ImmunizationID or all immunizationId's    
    details when passed NULL.     
Created By    : Aditya      
Created Date  : 17-Mar-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
11-Oct-2010 Rathnam modifed the CASE statement UserImmunizations.IsPatientDeclined. 
10-Nov-2011 NagaBabu Added IsPreventive field to the resultset
15-Nov-2011 NagaBabu Replaced Case statement for IsPreventive field
12-Jul-2012 Sivakrishna Added DataSourceName Column to Existing select statement.
17-Jul-2012 Sivakrishna Added DataSourceId Column to Existing select statement.
07-Jan-2013 Praveen Added ProgramID in select command.
20-Mar-2013 P.V.P.Mohan modified UserImmunizations to PatientImmunizations
			and modified columns.
------------------------------------------------------------------------------      
*/    

CREATE PROCEDURE [dbo].[usp_UserImmunizations_Select] 
(    
 @i_AppUserId KeyId,   
 @i_UserID KeyId,   
 @i_UserImmunizationID KeyId = NULL,  
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
		PatientImmunizations.PatientImmunizationID UserImmunizationID,    
		PatientImmunizations.ImmunizationID,    
		PatientImmunizations.PatientID UserID,      
		PatientImmunizations.ImmunizationDate,    
		CASE PatientImmunizations.IsPatientDeclined    
			WHEN 0 THEN 'OPT IN'    
			WHEN 1 THEN 'OPT OUT'    
		END AS IsPatientDeclined,    
		PatientImmunizations.Comments,    
		Immunizations.Name AS ImmunizationType,    
		PatientImmunizations.AdverseReactionComments,    
		PatientImmunizations.CreatedByUserId,  
		PatientImmunizations.CreatedDate,
		PatientImmunizations.LastModifiedByUserId,
		PatientImmunizations.LastModifiedDate ,
		PatientImmunizations.DueDate,
		CASE PatientImmunizations.StatusCode     
			WHEN 'A' THEN 'Active'    
			WHEN 'I' THEN 'InActive'    
			ELSE ''    
		END AS StatusDescription,
		ISNULL(PatientImmunizations.IsPreventive,0) AS IsPreventive,
	    PatientImmunizations.DataSourceID,
	    CodeSetDataSource.SourceName,
	    PatientImmunizations.ProgramID,
	    PatientImmunizations.AssignedCareProviderId
	FROM 
		PatientImmunizations  WITH(NOLOCK)  
	INNER JOIN Immunizations   WITH(NOLOCK) 
		ON Immunizations.ImmunizationID = PatientImmunizations.ImmunizationID    
	LEFT OUTER JOIN CodeSetDataSource WITH(NOLOCK)
	    ON CodeSetDataSource.DataSourceId = PatientImmunizations.DataSourceID	
	LEFT OUTER JOIN Program WITH(NOLOCK)
		ON Program.ProgramId=PatientImmunizations.ProgramID
	WHERE ( PatientImmunizations.PatientID = @i_UserID )    
	  AND ( PatientImmunizations.PatientImmunizationID = @i_UserImmunizationID OR @i_UserImmunizationID IS NULL )    
	  AND ( PatientImmunizations.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )    
	  
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
    ON OBJECT::[dbo].[usp_UserImmunizations_Select] TO [FE_rohit.r-ext]
    AS [dbo];

