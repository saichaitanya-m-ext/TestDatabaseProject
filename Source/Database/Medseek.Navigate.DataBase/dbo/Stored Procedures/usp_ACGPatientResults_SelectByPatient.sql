/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_PatientACGResults_SelectByPatient] 
Description   : This Procedure is used to get datedetermined data from PatientACGResults table for a specific Patient
Created By    : NagaBabu
Created Date  : 01-02-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION  
14-Mar-2011 NagaBabu Added Join condition to ACGPatientResults table and created #ACGPatient table 
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers 
------------------------------------------------------------------------------    
*/  
	
CREATE PROCEDURE [dbo].[usp_ACGPatientResults_SelectByPatient]
(  
 @i_AppUserId KeyID,  
 @i_PatientID KEYID 
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
 --------------------------------------------------------	
	SELECT
		ACGPR.ACGResultsID ,
		CONVERT(VARCHAR(10),ACGPR.DateDetermined,101) AS DateDetermined ,
		ACGPR.ACGScheduleID ,
		CASE ACGS.ACGType
			 WHEN 'F' THEN 'Full Population'
			 WHEN 'P' THEN 'Program'
			 WHEN 'C' THEN 'PopulationDefinition'
			 WHEN 'T' THEN 'Care Team'
		 END AS	'Type' ,
		 CASE ACGS.ACGType
			 WHEN 'F' THEN ''	
		     WHEN 'P' THEN Program.ProgramName
		     WHEN 'C' THEN PopulationDefinition.PopulationDefinitionName
		     WHEN 'T' THEN CareTeam.CareTeamName 
		 END AS 'Type Name' 
	INTO	
		#ACGPatient        
	FROM
		ACGPatientResults ACGPR WITH (NOLOCK)
	INNER JOIN ACGSchedule ACGS WITH (NOLOCK)
		ON ACGPR.ACGScheduleID = ACGS.ACGScheduleID	
	LEFT OUTER JOIN Program WITH (NOLOCK)
		ON ACGS.ACGSubTypeID = Program.ProgramId
	LEFT OUTER JOIN PopulationDefinition WITH (NOLOCK)
		ON ACGS.ACGSubTypeID = PopulationDefinition.PopulationDefinitionId
	LEFT OUTER JOIN CareTeam WITH (NOLOCK)
		ON ACGS.ACGSubTypeID = CareTeam.CareTeamId	 	
	WHERE	
		ACGPR.PatientID = @i_PatientID
	AND ACGS.StatusCode = 'A'	
	ORDER BY 	
		CONVERT(VARCHAR(10),DateDetermined,101) 

	SELECT 		
		ACGResultsID ,
		(DateDetermined + ' - '+ "Type" + ' : ' + "Type Name") AS DateDetermined 
    FROM 
		#ACGPatient		 
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
    ON OBJECT::[dbo].[usp_ACGPatientResults_SelectByPatient] TO [FE_rohit.r-ext]
    AS [dbo];

