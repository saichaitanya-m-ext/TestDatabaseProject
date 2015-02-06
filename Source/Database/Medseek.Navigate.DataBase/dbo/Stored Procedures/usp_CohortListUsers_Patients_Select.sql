/*
-------------------------------------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_CohortListUsers_Patients_Select]
Description	  : This procedure is used to select the details from CohortListUsers,Users tables.
Created By    :	NagaBabu
Created Date  : 04-June-2010
--------------------------------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
24-Jun-10 Pramod Included order by Cohortlistusers.Statuscode
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers
--------------------------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_CohortListUsers_Patients_Select] 
(
	@i_AppUserId KEYID,
    @i_PopulationDefinitionId KEYID
)
AS
BEGIN TRY 

	-- Check if valid Application User ID is passed
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END
----------- Select all the Activity details ---------------
      SELECT 
			   Users.UserId,
			   Users.UserLoginName,
			   Users.FullName,
			   Users.Gender,			   
               DateDIFF(Year , Users.DateOfBirth , GETDATE()) AS Age ,
			   Users.MemberNum,
			   CASE Users.UserStatusCode
			     WHEN 'A' THEN 'Active'
			     WHEN 'I' THEN 'InActive'
			     ELSE ' '
			   END AS StatusDescription,
			   PopulationDefinitionUsers.LeaveInList,
			   CASE PopulationDefinitionUsers.StatusCode
			     WHEN 'A' THEN 'Active'
			     WHEN 'I' THEN 'InActive'
			     WHEN 'P' THEN 'Pending Delete'
			     ELSE ' '
			   END AS StatusCode
			   
		  FROM PopulationDefinitionUsers  WITH (NOLOCK) 
			   INNER JOIN Patients Users  WITH (NOLOCK) 
				  ON Users.UserId = PopulationDefinitionUsers.UserId
					AND Users.UserStatusCode = 'A'
	     WHERE PopulationDefinitionUsers.PopulationDefinitionId = @i_PopulationDefinitionId
		   AND Users.EndDate is NULL
		   AND ISNULL(Users.IsDeceased,0) = 0
		 ORDER BY PopulationDefinitionUsers.StatusCode,
				  FullName,
				  MemberNum
    
END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			 @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CohortListUsers_Patients_Select] TO [FE_rohit.r-ext]
    AS [dbo];

