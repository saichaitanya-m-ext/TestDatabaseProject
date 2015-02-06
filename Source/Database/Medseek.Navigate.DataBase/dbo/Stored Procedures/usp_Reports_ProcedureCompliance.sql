
/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_Reports_ProcedureCompliance]
Description   : Program shall have the Care Teams/Care Providers mapped to it. 
                This is to fetch reports based on Care Team/Provider level reports 
                on the Procedure Compliance for the patient list managed by them
Created By    : Rathnam
Created Date  : 1-June-2011    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
23-02-2012 NagaBabu Added ActualFrequency field into #tblProgramProcedure table for getting patient count in correct range 
13-Mar-2012 NagaBabu Added New Resultset with the field name PatientCount and joined UserPrograms table to filter 
						the patients for specific program 
14-May-2012 NagaBabu Replaced UserPrograms table by Program	table to get that patients of input program,procedures					 
22-May-2012 Nagababu modified Patientcount resultset for both MyPatients and AllPatient levels 
-----------------------------------------------------------------------------
*/  --usp_Reports_ProcedureCompliance  64,73,0,'5/15/2011','5/15/2012',0,25,7526
CREATE PROCEDURE [dbo].[usp_Reports_ProcedureCompliance]
(
 @i_AppUserId KEYID ,
 @i_ProgramId KEYID ,
 @b_IsMyPatients ISINDICATOR = 0 ,
 @d_FromDate DATETIME = NULL ,
 @d_ToDate DATETIME = NULL ,
 @i_FromRange INT = NULL ,
 @i_ToRange INT = NULL ,
 @i_Procedureid INT = NULL
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

      DECLARE @i_DateDiff INT
      SET @i_DateDiff = ISNULL(DATEDIFF(DAY , @d_FromDate , @d_ToDate) , 0)
      CREATE TABLE #tblProgramProcedure
      (
        ProcedureId INT ,
        FrequencyNumber INT ,
        Frequency VARCHAR(1) ,
        ActualFrequency INT
      )
      INSERT INTO
          #tblProgramProcedure
          (
            ProcedureId ,
            FrequencyNumber ,
            Frequency ,
            ActualFrequency
          )
          SELECT
              ProcedureId ,
              FrequencyNumber ,
              Frequency ,
              @i_DateDiff / CASE
                                 WHEN Frequency = 'D' THEN FrequencyNumber
                                 WHEN Frequency = 'W' THEN FrequencyNumber * 7
                                 WHEN Frequency = 'M' THEN FrequencyNumber * 30
                                 WHEN Frequency = 'Y' THEN FrequencyNumber * 365
                            END AS ActualFrequency
          FROM
              ProgramProcedureFrequency
          WHERE
              ProgramId = @i_ProgramId
              AND StatusCode = 'A'
              AND ISNULL(FrequencyNumber , 0) <> 0

      CREATE TABLE #tblUserProcedure
      (
        UserId INT ,
        ProcedureId INT ,
        ProcedureName VARCHAR(500) ,
        FrequencyCount INT ,
        UserFrequencyPercentage DECIMAL(10,2) ,
        FrequencyNumber INT ,
        Frequency CHAR(1) ,
        ActualFrequency INT
      )

      IF ( @b_IsMyPatients = 0 )
         BEGIN
               INSERT INTO
                   #tblUserProcedure
                   (
                     UserId ,
                     ProcedureId ,
                     ProcedureName ,
                     FrequencyCount ,
                     UserFrequencyPercentage ,
                     FrequencyNumber ,
                     Frequency ,
                     ActualFrequency
                   )
                   SELECT
                       upc.UserId ,
                       upc.ProcedureId ,
                       csp.ProcedureName ,
                       COUNT(DISTINCT upc.ProcedureCompletedDate) FrequencyCount ,
                       CONVERT(DECIMAL(10,2) , ( COUNT(DISTINCT upc.ProcedureCompletedDate) * 100.00 ) / tblpc.ActualFrequency) ,
                       tblpc.FrequencyNumber ,
                       tblpc.Frequency ,
                       tblpc.ActualFrequency
                   FROM
                       UserProcedureCodes upc
                   --INNER JOIN UserPrograms
                   --    ON UserPrograms.UserId = upc.UserId
                   INNER JOIN #tblProgramProcedure tblpc
                       ON tblpc.ProcedureId = upc.ProcedureId
				   INNER JOIN Program
					   ON Program.ProgramId	= upc.ProgramId 
                   INNER JOIN CodeSetProcedure csp
                       ON csp.ProcedureId = upc.ProcedureId
                   INNER JOIN Patients p
                       ON p.UserId = upc.UserId
                   WHERE
                       upc.StatusCode = 'A'
                       AND p.UserStatusCode = 'A'
                       AND (
                             (
                             (
                             ( upc.ProcedureCompletedDate BETWEEN @d_FromDate
                             AND @d_ToDate )
                             OR ( upc.DueDate BETWEEN @d_FromDate
                                  AND @d_ToDate )
                             )
                             AND (
                                   @d_FromDate IS NOT NULL
                                   AND @d_ToDate IS NOT NULL
                                 )
                             )
                             OR (
                                  @d_FromDate IS NULL
                                  AND @d_ToDate IS NULL
                                )
                           )
                       AND Program.ProgramId = @i_ProgramId
                   GROUP BY
                       upc.UserId ,
                       upc.ProcedureId ,
                       csp.ProcedureName ,
                       tblpc.FrequencyNumber ,
                       tblpc.Frequency ,
                       tblpc.ActualFrequency
                       
         END
      ELSE
         BEGIN
               INSERT INTO
                   #tblUserProcedure
                   (
                     UserId ,
                     ProcedureId ,
                     ProcedureName ,
                     FrequencyCount ,
                     UserFrequencyPercentage ,
                     FrequencyNumber ,
                     Frequency ,
                     ActualFrequency
                   )
                   SELECT
                       upc.UserId ,
                       upc.ProcedureId ,
                       csp.ProcedureName ,
                       COUNT(upc.ProcedureCompletedDate) FrequencyCount ,
                       CONVERT(DECIMAL(10,2) , ( COUNT(upc.ProcedureCompletedDate) * 100.00 ) / tblpc.ActualFrequency) ,
                       tblpc.FrequencyNumber ,
                       tblpc.Frequency ,
                       tblpc.ActualFrequency
                   FROM
                       UserProcedureCodes upc
                   --INNER JOIN UserPrograms
                   --    ON UserPrograms.UserId = upc.UserId
                   INNER JOIN #tblProgramProcedure tblpc
                       ON tblpc.ProcedureId = upc.ProcedureId
                   INNER JOIN Program
					   ON Program.ProgramId	= upc.ProgramId     
                   INNER JOIN CodeSetProcedure csp
                       ON csp.ProcedureId = upc.ProcedureId
                   INNER JOIN Patients p
                       ON p.UserId = upc.UserId
                          AND p.UserStatusCode = 'A'
                   INNER JOIN CareTeam ct
                       ON ct.CareTeamId = p.CareTeamId
                          AND ct.StatusCode = 'A'
                   INNER JOIN CareTeamMembers ctm
                       ON ctm.CareTeamId = ct.CareTeamId
                          AND ctm.StatusCode = 'A'
                   WHERE
                       ctm.UserId = @i_AppUserId
                       AND upc.StatusCode = 'A'
                       AND (
                             (
                             ( upc.ProcedureCompletedDate BETWEEN @d_FromDate
                             AND @d_ToDate )
                             OR ( upc.DueDate BETWEEN @d_FromDate
                                  AND @d_ToDate )
                             AND (
                                   @d_FromDate IS NOT NULL
                                   AND @d_ToDate IS NOT NULL
                                 )
                             )
                             OR (
                                  @d_FromDate IS NULL
                                  AND @d_ToDate IS NULL
                                )
                           )
                       AND Program.ProgramId = @i_ProgramId
                   GROUP BY
                       upc.UserId ,
                       upc.ProcedureId ,
                       csp.ProcedureName ,
                       tblpc.FrequencyNumber ,
                       tblpc.Frequency ,
                       tblpc.ActualFrequency
         END

      IF (
           @i_FromRange IS NULL
           AND @i_ToRange IS NULL
         )
         BEGIN
               SELECT
                   tblup.ProcedureId ,
                   tblup.ProcedureName ,
                   SUM(CASE
                            WHEN tblup.UserFrequencyPercentage BETWEEN 0
                            AND 25 THEN 1
                            ELSE 0
                       END) AS ComplianceFrom0To25Percentage ,
                   SUM(CASE
                            WHEN tblup.UserFrequencyPercentage BETWEEN 26
                            AND 50 THEN 1
                            ELSE 0
                       END) AS ComplianceFrom26To50Percentage ,
                   SUM(CASE
                            WHEN tblup.UserFrequencyPercentage BETWEEN 51
                            AND 75 THEN 1
                            ELSE 0
                       END) AS ComplianceFrom51To75Percentage ,
                   SUM(CASE
                            WHEN tblup.UserFrequencyPercentage >= 76 THEN 1
                            ELSE 0
                       END) AS ComplianceFrom76To100Percentage ,
                   SUM(CASE
                            WHEN tblup.UserFrequencyPercentage >= 100 THEN 1
                            ELSE 0
                       END) AS Compliance100Percentage ,
                   tblup.Frequency ,
                   tblup.FrequencyNumber ,
                   SUM(CASE
                            WHEN tblup.UserFrequencyPercentage = 0 THEN 1
                            ELSE 0
                       END) AS Compliance0Percentage
               INTO
                   #tblCompliance
               FROM
                   #tblUserProcedure tblup
               GROUP BY
                   tblup.ProcedureId ,
                   tblup.ProcedureName ,
                   tblup.Frequency ,
                   tblup.FrequencyNumber


               SELECT
                   ProcedureId ,
                   ProcedureName + ' [ ' + ISNULL(CONVERT(VARCHAR , CASE Frequency
                                                                      WHEN 'D' THEN @i_DateDiff / NULLIF(( FrequencyNumber ) , 0)
                                                                      WHEN 'W' THEN @i_DateDiff / NULLIF(( FrequencyNumber * 7 ) , 0)
                                                                      WHEN 'M' THEN @i_DateDiff / NULLIF(( FrequencyNumber * 30 ) , 0)
                                                                      WHEN 'Y' THEN @i_DateDiff / NULLIF(( FrequencyNumber * 365 ) , 0)
                                                                    END) , 0) + ' Times ] ' AS ProcedureName ,
                   ComplianceFrom0To25Percentage ,
                   ComplianceFrom26To50Percentage ,
                   ComplianceFrom51To75Percentage ,
                   ComplianceFrom76To100Percentage ,
                   Compliance100Percentage ,
                   25 AS Percentage ---For Dev review
                   ,
                   Compliance0Percentage
               FROM
                   #tblCompliance
               IF EXISTS ( SELECT
                               1
                           FROM
                               #tblCompliance )
                  BEGIN
                        SELECT
                            SUM(ComplianceFrom0To25Percentage) AS ComplianceFrom0To25Percentage ,
                            SUM(ComplianceFrom26To50Percentage) AS ComplianceFrom26To50Percentage ,
                            SUM(ComplianceFrom51To75Percentage) AS ComplianceFrom51To75Percentage ,
                            SUM(ComplianceFrom76To100Percentage) AS ComplianceFrom76To100Percentage ,
                            SUM(Compliance100Percentage) AS Compliance100Percentage ,
                            SUM(Compliance0Percentage) AS Compliance0Percentage
                        FROM
                            #tblCompliance
                  END
               ELSE
                  BEGIN
                        SELECT
                            ComplianceFrom0To25Percentage AS ComplianceFrom0To25Percentage ,
                            ComplianceFrom26To50Percentage AS ComplianceFrom26To50Percentage ,
                            ComplianceFrom51To75Percentage AS ComplianceFrom51To75Percentage ,
                            ComplianceFrom76To100Percentage AS ComplianceFrom76To100Percentage ,
                            Compliance100Percentage AS Compliance100Percentage ,
                            Compliance0Percentage AS Compliance0Percentage
                        FROM
                            #tblCompliance
                  END

         END
      IF (
           @i_FromRange IS NOT NULL
           AND @i_ToRange IS NOT NULL
         )
      OR (
           @i_FromRange IS NOT NULL
           AND @i_ToRange IS NULL
         )
         BEGIN
               DECLARE @v_ProgramName VARCHAR(150)
               SELECT
                   @v_ProgramName = ProgramName
               FROM
                   Program
               WHERE
                   ProgramId = @i_ProgramId

               IF @i_FromRange = 76
               AND @i_ToRange = 100
                  BEGIN
                        SELECT
                            @i_ToRange = MAX(UserFrequencyPercentage)
                        FROM
                            #tblUserProcedure
                  END

               SELECT
                   tblup.Userid ,
                   p.MemberNum ,
                   p.FullName ,
                   ISNULL(CONVERT(VARCHAR , p.Age) , '') + '/' + p.Gender AS 'AgeAndGender' ,
                   tblup.Procedureid ,
                   tblup.ProcedureName ,
                   @v_ProgramName AS ProgramName ,
                   tblup.ActualFrequency AS ProcFrequencyNumber ,
                   tblup.FrequencyCount AS UserFrequencyCount ,
                   tblup.UserFrequencyPercentage AS Percentage ,
                   ISNULL(STUFF((
                                  SELECT
                                      ' $$ ' + CONVERT(VARCHAR , upc.ProcedureCompletedDate , 101) + ' : C' ---Procedurecompleted
                                  FROM
                                      UserProcedureCodes upc
                                  WHERE
                                      upc.Userid = p.Userid
                                      AND upc.ProcedureId = tblup.Procedureid
                                      AND upc.ProcedureCompletedDate IS NOT NULL
                                      AND upc.StatusCode = 'A'
                                      AND (
                                            (
                                            upc.ProcedureCompletedDate BETWEEN @d_FromDate
                                            AND @d_ToDate
                                            AND (
                                                  @d_FromDate IS NOT NULL
                                                  AND @d_ToDate IS NOT NULL
                                                )
                                            )
                                            OR (
                                                 @d_FromDate IS NULL
                                                 AND @d_ToDate IS NULL
                                               )
                                          )
                                  ORDER BY
                                      upc.UserProcedureId DESC
                                  FOR
                                      XML PATH('')
                                ) , 2 , 2 , '') , '') + ' ' + ISNULL(STUFF((
                                                                             SELECT
                                                                                 ' $$ ' + CONVERT(VARCHAR , upc.DueDate , 101) + ' : D' ----Duedates
                                                                             FROM
                                                                                 UserProcedureCodes upc
                                                                             WHERE
                                                                                 upc.Userid = p.Userid
                                                                                 AND upc.ProcedureId = tblup.Procedureid
                                                                                 AND upc.ProcedureCompletedDate IS NULL
                                                                                 AND upc.DueDate IS NOT NULL
                                                                                 AND upc.StatusCode = 'A'
                                                                                 AND (
                                                                                       (
                                                                                       upc.DueDate BETWEEN @d_FromDate
                                                                                       AND @d_ToDate
                                                                                       AND (
                                                                                             @d_FromDate IS NOT NULL
                                                                                             AND @d_ToDate IS NOT NULL
                                                                                           )
                                                                                       )
                                                                                       OR (
                                                                                            @d_FromDate IS NULL
                                                                                            AND @d_ToDate IS NULL
                                                                                          )
                                                                                     )
                                                                             ORDER BY
                                                                                 upc.UserProcedureId DESC
                                                                             FOR
                                                                                 XML PATH('')
                                                                           ) , 2 , 2 , '') , '') AS Summary
               FROM
                   #tblUserProcedure tblup
               INNER JOIN Patients p
                   ON p.UserId = tblup.Userid
                      AND P.UserStatusCode = 'A'
               WHERE
                   (
                   tblup.Procedureid = @i_Procedureid
                   OR @i_Procedureid IS NULL
                   )
                   AND (
                         (
                         ( tblup.UserFrequencyPercentage BETWEEN @i_FromRange
                         AND @i_ToRange )
                         AND (
                               @i_FromRange IS NOT NULL
                               AND @i_ToRange IS NOT NULL
                             )
                         )
                         OR (
                              tblup.UserFrequencyPercentage = @i_FromRange
                              AND @i_FromRange IS NOT NULL
                            )
                       )

         END
		
		IF @b_IsMyPatients = 0
			  SELECT
				  COUNT(DISTINCT UserProcedureCodes.UserId) AS PatientCount
			  FROM
				  UserProcedureCodes with (nolock)
			  INNER JOIN Patients  with (nolock)
				  ON Patients.UserId = UserProcedureCodes.UserId   
			  INNER JOIN ProgramProcedureFrequency with (nolock)
				  ON ProgramProcedureFrequency.ProcedureId = UserProcedureCodes.ProcedureId
				  AND UserProcedureCodes.ProgramId = ProgramProcedureFrequency.ProgramId	  
			  WHERE
				  UserProcedureCodes.ProgramId = @i_ProgramId
				  AND (ProcedureCompletedDate BETWEEN @d_FromDate AND @d_ToDate  
					 OR ( DueDate BETWEEN @d_FromDate AND @d_ToDate ))
				  AND ProgramProcedureFrequency.StatusCode = 'A' 
				  AND UserProcedureCodes.StatusCode = 'A' 
				  AND Patients.UserStatusCode = 'A'
				  AND ISNULL(FrequencyNumber , 0) <> 0
	    ELSE
			SELECT
				  COUNT(DISTINCT UserProcedureCodes.UserId) AS PatientCount
			  FROM
				  UserProcedureCodes
			  INNER JOIN Patients  with (nolock)
				  ON Patients.UserId = UserProcedureCodes.UserId   
			  INNER JOIN ProgramProcedureFrequency with (nolock)
				  ON ProgramProcedureFrequency.ProcedureId = UserProcedureCodes.ProcedureId
				  AND UserProcedureCodes.ProgramId = ProgramProcedureFrequency.ProgramId	
			  INNER JOIN CareTeam ct
                   ON ct.CareTeamId = Patients.CareTeamId
                   AND ct.StatusCode = 'A'
              INNER JOIN CareTeamMembers ctm
                   ON ctm.CareTeamId = ct.CareTeamId
                   AND ctm.StatusCode = 'A'	    
			  WHERE
				  ctm.UserId = @i_AppUserId	
				  AND UserProcedureCodes.ProgramId = @i_ProgramId
				  AND (ProcedureCompletedDate BETWEEN @d_FromDate AND @d_ToDate  
					 OR ( DueDate BETWEEN @d_FromDate AND @d_ToDate ))
				  AND ProgramProcedureFrequency.StatusCode = 'A' 
				  AND UserProcedureCodes.StatusCode = 'A' 
				  AND Patients.UserStatusCode = 'A'
				  AND ISNULL(FrequencyNumber , 0) <> 0
				  
END TRY    
--------------------------------------------------------     
BEGIN CATCH    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID END CATCH


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Reports_ProcedureCompliance] TO [FE_rohit.r-ext]
    AS [dbo];

