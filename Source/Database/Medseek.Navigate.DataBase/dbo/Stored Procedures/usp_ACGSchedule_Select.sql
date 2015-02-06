/*    
------------------------------------------------------------------------------    
Procedure Name: usp_ACGSchedule_Select    
Description   : This Procedure is used to get the values from ACGSchedule tabla				
Created By    : NagaBabu
Created Date  : 01-Mar-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
09-Mar-2011 NagaBabu Changed Programe to Program  
09-May-2011 Rathnam added audit columns to select statement.
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers 
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_ACGSchedule_Select]
(  
	 @i_AppUserId KeyID ,
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
		 ACGSchedule.ACGScheduleID ,
		 CASE ACGSchedule.ACGType
			 WHEN 'F' THEN 'Full Population'
			 WHEN 'P' THEN 'Program'
			 WHEN 'C' THEN 'Cohort List'
			 WHEN 'T' THEN 'Care Team'
		 END AS	'Type' ,
		 CASE ACGSchedule.ACGType
			 WHEN 'F' THEN ''	
		     WHEN 'P' THEN Program.ProgramName
		     WHEN 'C' THEN PopulationDefinition.PopulationDefinitionName
		     WHEN 'T' THEN CareTeam.CareTeamName 
		 END AS 'Type Name' ,
		 CASE ACGSchedule.Frequency 
			 WHEN 'O' THEN 'Once'
			 WHEN 'W' THEN 'Weekly'
			 WHEN 'M' THEN 'Monthly'
			 WHEN 'Q' THEN 'Quarterly'
			 WHEN 'A' THEN 'Annually' 
		 END AS 'Frequency' ,
		 CONVERT(VARCHAR(10),ACGSchedule.StartDate,101) AS 'Start Date' ,
		 CONVERT(VARCHAR(10),ACGSchedule.DateOfLastExport,101) AS 'Last Export Date' ,
		 CONVERT(VARCHAR(10),ACGSchedule.DateOfLastImport,101) AS 'Last Import Date' ,
		 CASE ACGSchedule.StatusCode	   
			 WHEN 'A' THEN 'Active'
			 WHEN 'I' THEN 'InActive'
		 END AS 'Status',
		 ACGSchedule.CreatedByUserid,
		 ISNULL(ACGSchedule.CreatedDate,'') AS CreatedDate,
		 ACGSchedule.LastModifiedByUserid,
		 ACGSchedule.LastModifiedDate AS LastModifiedDate 	  
		 FROM	
			 ACGSchedule 
		 LEFT OUTER JOIN Program WITH(NOLOCK)
			 ON ACGSchedule.ACGSubTypeID = Program.ProgramId
		 LEFT OUTER JOIN PopulationDefinition WITH(NOLOCK)
			 ON ACGSchedule.ACGSubTypeID = PopulationDefinition.PopulationDefinitionId
		 LEFT OUTER JOIN CareTeam WITH(NOLOCK)
			 ON ACGSchedule.ACGSubTypeID = CareTeam.CareTeamId	 
	     WHERE 
			 ACGSchedule.StatusCode = 'A' OR @v_StatusCode IN ('I','A')	 	      
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
    ON OBJECT::[dbo].[usp_ACGSchedule_Select] TO [FE_rohit.r-ext]
    AS [dbo];

