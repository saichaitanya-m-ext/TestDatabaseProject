

/*    
--------------------------------------------------------------------------------------------------------------    
Procedure Name: usp_Reports_TopUtilizer  1   
Description   : 
Created By    : Rathnam
Created Date  : 08-Dec-2011
---------------------------------------------------------------------------------------------------------------    
Log History   :     
DD-Mon-YYYY  BY  DESCRIPTION  
---------------------------------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Reports_TopUtilizer]
(
 @i_AppUserId KEYID
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
      SELECT TOP 100
          Patients.UserId AS PatientUserId ,
          Patients.MemberNum AS MemberNum ,
          Patients.FullName AS FullName ,
          CASE
               WHEN Patients.Age IS NOT NULL THEN ISNULL(CONVERT(VARCHAR , Patients.Age) , '') + '/' + ISNULL(Patients.Gender , '')
               ELSE ISNULL(Patients.Gender , '')
          END AS AgeSex ,
          STUFF((
                  SELECT TOP 2
                      ',' + ProgramName
                  FROM
                      Program with (nolock)
                  INNER JOIN UserPrograms with (nolock)
                      ON UserPrograms.ProgramId = Program.ProgramId
                  WHERE
                      UserPrograms.Userid = Patients.Userid
                      AND UserPrograms.EnrollmentStartDate IS NOT NULL
                      AND UserPrograms.EnrollmentEndDate IS NULL
                      AND Program.StatusCode = 'A'
                      AND UserPrograms.StatusCode = 'A'
                  ORDER BY
                      UserPrograms.EnrollmentStartDate DESC
                  FOR
                      XML PATH('')
                ) , 1 , 1 , '') AS ProgramName ,
          STUFF((
                  SELECT TOP 2
                      ',' + Name
                  FROM
                      Disease with (nolock)
                  INNER JOIN UserDisease with (nolock)
                      ON UserDisease.DiseaseId = Disease.DiseaseId
                  WHERE
                      UserDisease.Userid = Patients.Userid
                      AND UserDisease.DiagnosedDate IS NOT NULL
                      AND UserDisease.StatusCode = 'A'
                      AND Disease.StatusCode = 'A'
                  ORDER BY
                      UserDisease.DiagnosedDate DESC
                  FOR
                      XML PATH('')
                ) , 1 , 1 , '') AS DiseaseName ,
          '$' + CONVERT(VARCHAR , CONVERT(DECIMAL(10,2) , UserId)) AS BilledCharges ,
          '$' + CONVERT(VARCHAR , CONVERT(DECIMAL(10,2) , UserId - 3)) AS NetClaims ,
          '$0.00' OfficeVisist ,
          '$0.00' OfficeVisistClaims ,
          '$0.00' ERVisit ,
          '$0.00' ERVisitClaims ,
          '$' + CONVERT(VARCHAR , CONVERT(DECIMAL(10,2) , UserId - 2)) AS InpatientServices ,
          '$' + CONVERT(VARCHAR , CONVERT(DECIMAL(10,2) , UserId + 1)) AS InpatientClaims ,
          '$0.00' OutPatientServices ,
          '$0.00' OutPatientClaims
      FROM
          Patients
      WHERE
          Patients.MemberNum <> ''
      ORDER BY
          BilledCharges DESC
END TRY
BEGIN CATCH    
----------------------------------------------------------------------------------------------------------   
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Reports_TopUtilizer] TO [FE_rohit.r-ext]
    AS [dbo];

