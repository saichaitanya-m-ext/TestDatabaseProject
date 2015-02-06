/*    
------------------------------------------------------------------------------    
Procedure Name: usp_CareProviderDashBoard_PatientLetters 2
Description   : This procedure is used to get the details for patient letters
				for a particular care provider
Created By    : Pramod
Created Date  : 11-Aug-10
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
12-Aug-10 Pramod Modified the SP include DISTINCT CommunicationId and UserCommunicationId
23-Aug-2010 NagaBabu Added StatusCode = 'A' in  where clause 
28-Sep-10 Pramod Included join with communicationtemplate with usercommunication table
9-Nov-10 Pramod Removed the insert into table variable (join with CommunicationCohorts and
		communication is no more required as its covered in previous insert). 
		Removed the insert statement at the end and included select of all required fields
07-Jun-2011 Rathnam added upper function to the Patient name	
26-Dec-2011 Rathnam added order by clause on FullName	
05-March-2013 Rathnam commented the careteam functionality in the sp and added program related functionality
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_PatientLetters]
(  
   @i_AppUserId KEYID
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
	  /*	
	  DECLARE
			@tblCareTeam TABLE
			( CareTeamId KeyID,
			  UserId KeyID
			)
			  
	  INSERT INTO @tblCareTeam
	    ( CareTeamId, UserId )
	  SELECT DISTINCT CareTeam.CareTeamId, 
			 CareTeamMembers.UserId
	    FROM CareTeam
			 INNER JOIN CareTeamMembers
			   ON CareTeam.CareTeamId = CareTeamMembers.CareTeamId
			 INNER JOIN Users
			   ON Users.UserId = CareTeamMembers.UserId
       WHERE EXISTS 
			 (SELECT 1  
				FROM CareTeamMembers CTM
			   WHERE CareTeamId = CareTeam.CareTeamId 
				 AND CTM.UserId = @i_AppUserId
				 AND CTM.StatusCode = 'A'
			 )
		 AND CareTeam.StatusCode = 'A'
		 AND CareTeamMembers.StatusCode = 'A' 	 
	  	
      */
      SELECT DISTINCT PatientID INTO #Patient FROM PatientProgram WHERE ProviderID = @i_AppUserId AND StatusCode = 'A'
      
      
      SELECT Patients.PatientID As PatientUserId,
			 Patients.MemberNum,
			 UPPER(Patients.FullName) AS FullName,
			 Patients.Age,
			 Patients.Gender,
			 COUNT(DISTINCT PatientCommunication.PatientCommunicationId) AS PatientLetterCount
	    FROM  
             #Patient tdis
			 INNER JOIN Patients
				ON Patients.PatientID = tdis.PatientId
			 INNER JOIN PatientCommunication
				ON PatientCommunication.PatientId = Patients.PatientID
			 INNER JOIN CommunicationTemplate 
				ON CommunicationTemplate.CommunicationTemplateId = PatientCommunication.CommunicationTemplateId  
		WHERE 
		      PatientCommunication.StatusCode = 'A'
		  AND CommunicationTemplate.StatusCode = 'A'
		  AND PatientCommunication.CommunicationState = 'Ready To Print'
	    GROUP BY 
			 Patients.PatientID,
			 Patients.MemberNum,
			 Patients.FullName,
			 Patients.Age,
			 Patients.Gender
	   HAVING COUNT(DISTINCT PatientCommunication.PatientCommunicationId) > 1
	   ORDER BY FullName

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
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_PatientLetters] TO [FE_rohit.r-ext]
    AS [dbo];

