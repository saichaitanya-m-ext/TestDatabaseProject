/*
---------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_MedicalProblem_Select_DD]
Description	  : This procedure is used to select all the active ProblemName records 
				from MedicalProblem table.
Created By    :	Aditya 
Created Date  : 19-May-2010
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
19-Aug-2010 NagaBabu Added ORDER BY clause to the select statement
08-Mar-2011 NagaBabu Added @i_MedicalProblemClassificationId
07-July-2011 NagaBabu Added AND IsShowPatientCriteria = 1 in where condition  
----------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_MedicalProblem_Select_DD] 
(	
	@i_AppUserId KEYID ,
	@i_MedicalProblemClassificationId KEYID = NULL
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
---------------- All the Active MedicalProblem records are retrieved --------
      SELECT
          MedicalProblemId,
		  ProblemName
      FROM
          MedicalProblem
      WHERE
          StatusCode = 'A'
      AND ( MedicalProblemClassificationId = @i_MedicalProblemClassificationId OR @i_MedicalProblemClassificationId IS NULL )
      AND IsShowPatientCriteria = 1   
	  ORDER BY
		  ProblemName
		  
	  
		  	  	
        
END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_MedicalProblem_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

