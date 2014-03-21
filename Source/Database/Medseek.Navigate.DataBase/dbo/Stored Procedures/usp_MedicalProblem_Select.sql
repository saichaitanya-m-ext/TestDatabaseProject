/*        
---------------------------------------------------------------------------------        
Procedure Name: [dbo].[usp_MedicalProblem_Select]        
Description   : This procedure is used to get the records from MedicalProblem table        
Created By    : Aditya        
Created Date  : 18-May-2010        
----------------------------------------------------------------------------------        
Log History   :         
DD-Mon-YYYY  BY  DESCRIPTION        
13-OCT-2010 Rathnam modified the order by condition 
06-July-2011 NagaBabu Added IsShowPatientCriteria field      
----------------------------------------------------------------------------------        
*/

CREATE PROCEDURE [dbo].[usp_MedicalProblem_Select]
(
 @i_AppUserId KEYID
,@i_MedicalProblemId KEYID = NULL
,@v_StatusCode STATUSCODE = NULL
)
AS
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
---------------- All the MedicalProblem records are retrieved here--------        
      SELECT
          MedicalProblem.MedicalProblemId
         ,MedicalProblemClassification.ProblemClassName AS ClassificationName
         ,MedicalProblem.ProblemName
         ,MedicalProblem.Description
         ,MedicalProblem.MedicalProblemClassificationId
         ,CASE MedicalProblem.StatusCode
            WHEN 'A' THEN 'Active'
            WHEN 'I' THEN 'InActive'
            ELSE ''
          END AS StatusDescription
         ,MedicalProblem.CreatedByUserId
         ,MedicalProblem.CreatedDate
         ,MedicalProblem.LastModifiedByUserId
         ,MedicalProblem.LastModifiedDate
         ,MedicalProblem.IsShowPatientCriteria
      FROM
          MedicalProblem WITH(NOLOCK)
      INNER JOIN MedicalProblemClassification WITH(NOLOCK)
      ON  MedicalProblemClassification.MedicalProblemClassificationId = MedicalProblem.MedicalProblemClassificationId
      WHERE
          (
          MedicalProblem.MedicalProblemId = @i_MedicalProblemId
          OR @i_MedicalProblemId IS NULL
          )
          AND (
                MedicalProblem.StatusCode = @v_StatusCode
                OR @v_StatusCode IS NULL
              )
      ORDER BY
          MedicalProblem.MedicalProblemId DESC
           -- MedicalProblem.CreatedDate,MedicalProblem.ProblemName   
END TRY
BEGIN CATCH        
        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH 
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_MedicalProblem_Select] TO [FE_rohit.r-ext]
    AS [dbo];

