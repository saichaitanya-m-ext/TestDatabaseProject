
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_ProgramProcedureFrequency_UserProcedureFrequency_Override 2,29         
Description   : This procedure is used to get the details from ProgramProcedureFrequency    
    and UserProcedure frequency table using the userid    
Created By    : RATHNAM    
Created Date  : 23-May-2011        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
15-July-2011 NagaBabu Added PatientProcEffectiveEndDate in select statement	
23-Aug-2011 Gurumoorthy.V Added column UserSpecificProcedures.ExclusionReason in select statement	
07-Oct-2011 Rathnam ,ISNULL(ProgramProcedure.NeverSchedule , UserSpecificProcedures.NeverSchedule) AS ExclusionReason 
03-APR-2013 Mohan Modified UserProcedureFrequency to PatientProcedureFrequency Tables.    						
------------------------------------------------------------------------------        
*/     
CREATE PROCEDURE [dbo].[usp_ProgramProcedureFrequency_UserProcedureFrequency_Override]
(
 @i_AppUserId KEYID
,@i_UserId KEYID = NULL
,@v_StatusCode STATUSCODE = NULL
)
AS
BEGIN TRY
      SET NOCOUNT ON         
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END



DECLARE @tblProgramProcedure TABLE
(
ProgramID INT,
CodeGroupingID INT
)
INSERT INTO @tblProgramProcedure 
SELECT DISTINCT ProgramId, CodeGroupingID FROM PatientProcedureGroup 
WHERE PatientID = @i_UserId
AND StatusCode = 'A'
AND ProgramId IS NOT NULL


      SELECT
          ISNULL(ProgramProcedure.CodeGroupingID , UserSpecificProcedures.CodeGroupingID) AS CodeGroupingID
         ,ISNULL(ProgramProcedure.ProgramId,UserSpecificProcedures.ProgramID) ProgramID
         ,ISNULL(ProgramProcedure.ProgramName, (SELECT ProgramName FROM Program WHERE ProgramID = UserSpecificProcedures.ProgramID)) ProgramName
         ,ISNULL(ProgramProcedure.CodeGroupingName , UserSpecificProcedures.CodeGroupingName) AS CodeGroupingName
         ,ProgramProcedure.Frequency AS ProgramFrequency
         ,ProgramProcedure.FrequencyNumber AS ProgramFrequencyNumber
         ,CONVERT(VARCHAR , ProgramProcedure.EffectiveStartDate , 101) AS ProgramEffectiveStartDate
         ,UserSpecificProcedures.Frequency AS PatientProcFrequency
         ,ISNULL(ProgramProcedure.ExclusionReason , UserSpecificProcedures.ExclusionReason ) AS ExclusionReason
         ,UserSpecificProcedures.FrequencyNumber AS PatientProcFrequencyNumber
         ,CONVERT(VARCHAR , UserSpecificProcedures.EffectiveStartDate , 101) AS PatientProcEffectiveStartDate
         ,CONVERT(VARCHAR , UserSpecificProcedures.EffectiveEndDate , 101) AS PatientProcEffectiveEndDate
         ,CASE
               WHEN UserSpecificProcedures.CodeGroupingID IS NULL THEN 'Program'
               ELSE 'Patient'
          END AS 'DefinedLevel'
         ,CASE
               WHEN UserSpecificProcedures.CodeGroupingID IS NOT NULL
               AND ProgramProcedure.CodeGroupingID IS NOT NULL
               AND ProcedureGroupFrequencyoverride.ProcOverride IS NULL THEN 1
               WHEN UserSpecificProcedures.CodeGroupingID IS NOT NULL
               AND ProgramProcedure.CodeGroupingID IS NULL
               AND ProcedureGroupFrequencyoverride.ProcOverride IS NOT NULL THEN ProcOverride - 1
               WHEN ProcedureGroupFrequencyoverride.ProcOverride IS NULL THEN 0
               ELSE ProcedureGroupFrequencyoverride.ProcOverride
          END AS 'NoOfOverrides'
          ,ISNULL(ISNULL(ProgramProcedure.NeverSchedule , UserSpecificProcedures.NeverSchedule),0) AS NeverSchedule
      FROM
          (
            -- Get the list of recommended Programs and procedures    
            SELECT DISTINCT
				--UserProcedureCodes.ProgramId,
				--dbo.ufn_ProgramName(UserProcedureCodes.ProgramId) AS ProgramName,
                Program.ProgramId
               ,Program.ProgramName
               ,CodeGrouping.CodeGroupingID
               ,CodeGrouping.CodeGroupingName 
               ,ProgramTaskBundle.FrequencyNumber
               ,NULL EffectiveStartDate
               ,CASE ProgramTaskBundle.Frequency
                  WHEN 'D' THEN 'Day(s)'
                  WHEN 'W' THEN 'Week(s)'
                  WHEN 'M' THEN 'Month(s)'
                  WHEN 'Y' THEN 'Year(s)'
                END AS Frequency
               ,CASE ProgramTaskBundle.StatusCode
                  WHEN 'A' THEN 'Active'
                  WHEN 'I' THEN 'InActive'
                  ELSE ''
                END AS StatusDescription
               ,NULL AS NeverSchedule
               ,NULL AS ExclusionReason
               ,ProcedureGroupFrequency.LabTestId
               ,LabTests.LabTestName
               
            FROM
                ProgramTaskBundle with (nolock) 
            INNER JOIN CodeGrouping with (nolock) 
                ON CodeGrouping.CodeGroupingID = ProgramTaskBundle.GeneralizedID
            INNER JOIN @tblProgramProcedure tpc 
                ON tpc.CodeGroupingID = CodeGrouping.CodeGroupingID
            INNER JOIN Program with (nolock) 
                ON Program.ProgramId = tpc.ProgramId
            LEFT OUTER JOIN ProcedureGroupFrequency with (nolock) 
                ON ProgramTaskBundle.GeneralizedID = ProcedureGroupFrequency.CodeGroupingID
            LEFT OUTER JOIN LabTests with (nolock) 
                ON ProcedureGroupFrequency.LabTestId = LabTests.LabTestId
            WHERE
                ProgramTaskBundle.TaskType = 'P'
                AND ( @v_StatusCode IS NULL
                      OR ProgramTaskBundle.StatusCode = @v_StatusCode
                    )
          ) ProgramProcedure
      FULL OUTER JOIN (
                        -- 2nd Grid for user specific procedure detail    
                        SELECT DISTINCT
                            CodeGrouping.CodeGroupingID 
                           ,CodeGrouping.CodeGroupingName 
                           ,PatientProcedureGroupFrequency.FrequencyNumber
                           ,CASE PatientProcedureGroupFrequency.Frequency
                              WHEN 'D' THEN 'Day(s)'
                              WHEN 'W' THEN 'Week(s)'
                              WHEN 'M' THEN 'Month(s)'
                              WHEN 'Y' THEN 'Year(s)'
                            END AS Frequency
                           ,CASE PatientProcedureGroupFrequency.StatusCode
                              WHEN 'A' THEN 'Active'
                              WHEN 'I' THEN 'InActive'
                              ELSE ''
                            END AS StatusDescription
                           ,PatientProcedureGroupFrequency.NeverSchedule
                           ,PatientProcedureGroupFrequency.ExclusionReason
                           ,PatientProcedureGroupFrequency.LabTestId
                           ,PatientProcedureGroupFrequency.EffectiveStartDate
                           ,PatientProcedureGroupFrequency.EffectiveEndDate
                           ,LabTests.LabTestName
                           ,(SELECT TOP 1 ProgramID FROM @tblProgramProcedure WHERE CodeGroupingID = CodeGrouping.CodeGroupingID) ProgramID
                        FROM
                            PatientProcedureGroupFrequency
                        INNER JOIN CodeGrouping
                            ON CodeGrouping.CodeGroupingID = PatientProcedureGroupFrequency.CodeGroupingID
                        LEFT OUTER JOIN LabTests
                            ON PatientProcedureGroupFrequency.LabTestId = LabTests.LabTestId
                        WHERE
                            PatientId = @i_UserId
                            AND ( @v_StatusCode IS NULL
                                  OR PatientProcedureGroupFrequency.StatusCode = @v_StatusCode
                                )
                      ) UserSpecificProcedures
          ON UserSpecificProcedures.CodeGroupingID = ProgramProcedure.CodeGroupingID
      LEFT OUTER JOIN ( SELECT
                            CodeGroupingID
                           ,COUNT(*) AS ProcOverride
                        FROM
                            PatientProcedureGroupFrequencyOverride
                        WHERE
                            PatientID = @i_UserId
                            AND ProgramID IS NULL
                        GROUP BY
                            CodeGroupingID
                           ,PatientID
                      ) AS ProcedureGroupFrequencyoverride
          ON ProcedureGroupFrequencyoverride.CodeGroupingID = UserSpecificProcedures.CodeGroupingID
      ORDER BY
          UserSpecificProcedures.CodeGroupingID DESC
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
    ON OBJECT::[dbo].[usp_ProgramProcedureFrequency_UserProcedureFrequency_Override] TO [FE_rohit.r-ext]
    AS [dbo];

