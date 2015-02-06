/*              
------------------------------------------------------------------------------              
Procedure Name: usp_UserEncounters_Select    2          
Description   : This procedure is used to get the details from UserEncounters table             
Created By    : Aditya              
Created Date  : 22-Apr-2010              
------------------------------------------------------------------------------              
Log History   :               
DD-MM-YYYY  BY   DESCRIPTION              
08-June-2010 NagaBabu   modified ORDER BY clause as UserEncounters.DateDue DESC,EncounterType.Name              
22-Jun-2010 Pramod Modified the SP to address issue with care provider display
03-Sep-2010 NagaBabu Added new field CareTeamUserID  
19-Oct-2010 Rathnam Modified the case statement  for UserProviderID and removed the join condtions UserProviders,
                    ExternalCareProvider,Users 
20-Oct-2010 Rathnam Changed the order of the CareProvider name. 
06-Jun-2011 Rathnam added DiseaseName column to the select statement 
29-Aug-2011 NagaBabu Added IsEncounterwithPCP field in select statement
10-Nov-2011 NagaBabu Added IsPreventive field in select statement   
15-Nov-2011 NagaBabu Replaced Case statement for IsPreventive field    
12-07-2014   Sivakrishna added DataSourceName column to  the Existing Select statement.
17-07-2014   Sivakrishna added DataSourceId column to the Existing Select statement.  
20-Mar-2013 P.V.P.Mohan modified UserEncounters to PatientEncounters,DataSource to CodeSetDataSource
			and modified columns.
03-APR-2013 Mohan Coomented LeftJoin Disease Table and put Alias in Disease Name Position           
------------------------------------------------------------------------------              
*/      
CREATE PROCEDURE [dbo].[usp_UserEncounters_Select]
(      
	@i_AppUserId KEYID ,
	@i_UserEncounterID KEYID = NULL ,
	@i_UserId KEYID = NULL ,
	@v_StatusCode STATUSCODE = NULL,
	@i_UserProviderId KEYID = NULL,
	@b_ShowLastOneYearData BIT = 0
)      
AS      
BEGIN TRY      
      SET NOCOUNT ON               
-- Check if valid Application User ID is passed            
      
      IF ( @i_AppUserId IS NULL )      
      OR ( @i_AppUserId <= 0 )      
         BEGIN      
               RAISERROR ( N'Invalid Application User ID %d passed.' ,      
               17 ,      
               1 ,      
               @i_AppUserId )      
         END      
   
      SELECT DISTINCT      
          PatientEncounters.PatientEncounterID UserEncounterID ,      
          PatientEncounters.PatientID UserId ,  
          CASE 
            WHEN PatientEncounters.ProviderID IS NULL THEN (SELECT 
                                                                 COALESCE(ISNULL(Patient.LastName,'') + ' ' + 
																		  ISNULL(Patient.FirstName,'') + ' ' + 
																		  ISNULL(Patient.MiddleName,''),''
																		  )  
															 FROM 
															     Patient  
															 WHERE 
															     PatientID=PatientEncounters.CareTeamUserID
															 )
            ELSE  dbo.ufn_GetPhysicianByUserProviderID(PatientEncounters.ProviderID) 
          END AS CareProvider ,
          PatientEncounters.EncounterDate ,      
          EncounterType.Name AS EncounterType ,      
          PatientEncounters.IsInpatient ,      
          PatientEncounters.Comments ,      
          PatientEncounters.StayDays ,      
          PatientEncounters.EncounterTypeId ,      
          PatientEncounters.CreatedByUserId ,      
          PatientEncounters.CreatedDate ,      
          PatientEncounters.LastModifiedByUserId ,      
          PatientEncounters.LastModifiedDate ,      
          CASE PatientEncounters.StatusCode      
            WHEN 'A' THEN 'Active'      
            WHEN 'I' THEN 'InActive'      
            ELSE ''      
          END AS StatusDescription ,      
          PatientEncounters.DateDue ,      
          PatientEncounters.ScheduledDate ,      
          PatientEncounters.ProviderID  UserProviderID ,
          PatientEncounters.CareTeamUserID , 
          '' as Name, 
          ISNULL(PatientEncounters.IsEncounterwithPCP,0) AS IsEncounterwithPCP ,
          ISNULL(PatientEncounters.IsPreventive,0) AS IsPreventive,
          PatientEncounters.DataSourceId,
          CodeSetDataSource.SourceName,
          PatientEncounters.ProgramID AS ManagedPopulationId
	  FROM        
          PatientEncounters   WITH(NOLOCK)     
      LEFT JOIN CodeSetDataSource WITH(NOLOCK)
         ON PatientEncounters.DataSourceId = CodeSetDataSource.DataSourceId
      LEFT OUTER JOIN EncounterType   WITH(NOLOCK)      
          ON EncounterType.EncounterTypeId = PatientEncounters.EncounterTypeId
      --LEFT OUTER JOIN Disease  WITH(NOLOCK)
      --    ON PatientEncounters.DiseaseID = Disease.DiseaseId  
     WHERE        
           ( PatientEncounterID = @i_UserEncounterID OR @i_UserEncounterID IS NULL )        
       AND ( PatientEncounters.PatientID = @i_UserId OR @i_UserId IS NULL )        
       AND ( PatientEncounters.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )        
       AND ( PatientEncounters.ProviderId = @i_UserProviderId OR @i_UserProviderId IS NULL ) 
       AND ( @b_ShowLastOneYearData = 0 OR
				( @b_ShowLastOneYearData = 1 AND
				  PatientEncounters.EncounterDate > DATEADD(YEAR, -1, GETDATE())
				)  
			)                          
     ORDER BY                  
         PatientEncounters.DateDue DESC,
         EncounterType.Name    
             
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
    ON OBJECT::[dbo].[usp_UserEncounters_Select] TO [FE_rohit.r-ext]
    AS [dbo];

