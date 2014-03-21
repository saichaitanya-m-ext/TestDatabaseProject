
     
/*      
--------------------------------------------------------------------------------      
Procedure Name: [dbo].[usp_DashBoard_Appointment]23,144145     
Description   :       
Created By    : Rathnam      
Created Date  : 13-DEC-2012      
---------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
       
---------------------------------------------------------------------------------      
*/    
    
CREATE PROCEDURE [dbo].[usp_DashBoard_Appointment] --64,172906    
    
(    
 @i_AppUserId KEYID    
,@i_PatientUserID KEYID    
)    
AS    
BEGIN    
      BEGIN TRY       
      
 -- Check if valid Application User ID is passed      
            IF ( @i_AppUserId IS NULL )    
            OR ( @i_AppUserId <= 0 )    
               BEGIN    
                     RAISERROR ( N'Invalid Application User ID %d passed.'    
                     ,17    
                     ,1    
                     ,@i_AppUserId )    
               END    
    
          
    
 DECLARE @d_CurrentDate DATETIME = ( SELECT    
                                                    GETDATE() )    
    
            SELECT TOP 5    
                Task.TaskId    
               ,EncounterType.Name AS [Type]    
               ,TaskDueDate AS DueDate    
               --,Organization.OrganizationName AS FacilityName    
               ,'' AS FacilityName    
               ,dbo.ufn_GetUserNameByID(PatientEncounters.ProviderId) AS Provider    
               ,    
            --    STUFF((    
            --                  SELECT    
            --                      ',' + DBO.ufn_GetSpecialityById(Speciality.SpecialityId)     
                                            
            --                       FROM      UserSpeciality    
                   
            --LEFT JOIN Speciality    
            --    ON Speciality.SpecialityId = UserSpeciality.SpecialityId    
            --    AND UserSpeciality.UserId = PatientEncounters.ProviderId    
            --                  FOR    
            --                      XML PATH('')    
            --                ) , 1 , 2 , '') SpecialityName ,    
                DBO.ufn_GetSpecialityById(1) SpecialityName    
               ,PatientEncounters.PatientEncounterID As UserEncounterID    
               ,PatientEncounters.ProgramID  
               ,PatientEncounters.CareTeamUserID
            FROM    
                Task WITH(NOLOCK)    
            INNER JOIN PatientEncounters WITH(NOLOCK)    
                ON Task.PatientEncounterID = PatientEncounters.PatientEncounterID    
            LEFT JOIN EncounterType WITH(NOLOCK)    
                ON EncounterType.EncounterTypeId = PatientEncounters.EncounterTypeId    
            --LEFT JOIN Organization WITH(NOLOCK)    
            --    ON Organization.OrganizationId = PatientEncounters.OrganizationHospitalId    
            WHERE    
                Task.PatientId = @i_PatientUserID    
                AND TaskDueDate > @d_CurrentDate    
                AND TaskCompletedDate IS NULL    
                AND EncounterType.Name NOT IN ( 'ER' , 'Inpatient' , 'Urgent Care' , 'Ambulance' )    
                AND PatientEncounters.StatusCode = 'A'    
                --AND EncounterType.StatusCode = 'A'    
                --AND Speciality.StatusCode = 'A'    
            ORDER BY    
                TaskDueDate DESC    
      END TRY    
      BEGIN CATCH      
---------------------------------------------------------------------------------------------------------------------------------      
    -- Handle exception      
            DECLARE @i_ReturnedErrorID INT    
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
            RETURN @i_ReturnedErrorID    
      END CATCH    
END      
      

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_DashBoard_Appointment] TO [FE_rohit.r-ext]
    AS [dbo];

