/*      
------------------------------------------------------------------------------      
Procedure Name: [usp_ProgramName_Select]  23,17  
Description   : This procedure is used to get the details Through  Program table    
    all users PCP Names  
Created By    : P.V.P.Mohan      
Created Date  : 21-Dec-2012     
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION
19-Mar-2013 P.V.P.Moahn Modified table UserCareTeam to PatientCareTeam  
25-Mar-2013 P.V.P.Moahn Modified table CareTeamMembers  column UserId to ProviderID          
------------------------------------------------------------------------------      
*/ 
CREATE PROCEDURE [dbo].[usp_ProgramName_Select] --23,17
(    
 @i_AppUserId KeyID,    
 @i_ProgramId KeyID = NULL
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
  
   CREATE TABLE #tmpCareTeamMember
     (
        ProgramId INT,
        UserId INT
        
     )
     CREATE TABLE #tmpPCP
     (
        ProgramId INT,
        PCPId INT
        
     )

    INSERT INTO #tmpCareTeamMember 
      
    SELECT 
    DISTINCT  
    Program.ProgramId
   ,CareTeamMembers.ProviderID UserId   
    FROM 
	    Program 
     WITH(NOLOCK)  
    INNER JOIN PatientCareTeam  WITH(NOLOCK)  
        ON PatientCareTeam.ProgramID = Program.ProgramID
    INNER JOIN CareTeam WITH(NOLOCK)
        ON CareTeam.CareTeamID = PatientCareTeam.CareTeamID    
    INNER JOIN CareTeamMembers 
       ON CareTeamMembers.CareTeamId = CareTeam.CareTeamId
    WHERE ( Program.ProgramId = @i_ProgramId     
          OR @i_ProgramId IS NULL    
           ) 
    
    INSERT INTO #tmpPCP  
    SELECT DISTINCT 
    Program.ProgramId,    
    Patients.PCPId      
    FROM Program  WITH(NOLOCK)  
    INNER  JOIN PatientCareTeam  WITH(NOLOCK)  
        ON PatientCareTeam.ProgramID = Program.ProgramID
    INNER  JOIN Patients  WITH(NOLOCK)  
        ON Patients.PatientID = PatientCareTeam.PatientID
   WHERE ( Program.ProgramId = @i_ProgramId     
          OR @i_ProgramId IS NULL    
           )
  AND Patients.PCPId IS NOT NULL
    
    
    SELECT 
		ProgramId,
		UserId,
		dbo.ufn_GetUserNameByID(UserId)  AS CareTeamMemberName 
	FROM 
	   #tmpCareTeamMember
	ORDER BY    ProgramId,CareTeamMemberName
	SELECT 
		ProgramId,
		PCPId,
		dbo.ufn_GetUserNameByID(PCPId)  AS PcpName 
	FROM 
	   #tmpPCP
    ORDER BY    ProgramId,PcpName
   
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
    ON OBJECT::[dbo].[usp_ProgramName_Select] TO [FE_rohit.r-ext]
    AS [dbo];

