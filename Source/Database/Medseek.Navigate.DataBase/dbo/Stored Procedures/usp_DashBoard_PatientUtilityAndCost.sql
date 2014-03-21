/*
--------------------------------------------------------------------------------
Procedure Name: [usp_DashBoard_PatientUtilityAndCost] 23,48
Description	  : This Procedure is used to get Utilities,Cost for a given patient
Created By    :	NagaBabu
Created Date  : 30-May-2012
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
21-MAy-2013 P.V.P.Mohan Modified table RxClaim (memberNum) to MemberID in the  Table.
---------------------------------------------------------------------------------
*/ 
CREATE PROCEDURE [dbo].[usp_DashBoard_PatientUtilityAndCost]--23,48
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
	
		CREATE TABLE #TempACGResults 
		(
			ID INT IDENTITY(1,1) ,
			Names VARCHAR(100) ,
			Value VARCHAR(20)
		) 
		
		CREATE TABLE #TempResults 
		(
			ID INT IDENTITY(1,1) ,
			Names VARCHAR(100) ,
			Value VARCHAR(20)  
		) 
		
		IF EXISTS ( SELECT 1
					FROM ACGPatientResults 
					WHERE ACGPatientResults.PatientID = @i_PatientUserID )
		BEGIN			
			INSERT INTO #TempACGResults
			(
				Names ,
				Value
			)
			SELECT Names,Value 
			FROM 
			( SELECT 
					CAST(OutpatientVisitCount AS VARCHAR) AS 'Outpatient Visits',
					CAST(EmergencyVisitCount AS VARCHAR) AS 'ER Visits',
					CAST(InpatientHospitalizationCount AS VARCHAR) AS 'Inpatient Admission',
					CAST(MajorProcedure AS VARCHAR) AS 'Major Procedure Performed',
					CAST(DialysisService AS VARCHAR) AS 'Dialysis Service' 
				FROM
					ACGPatientResults WITH (NOLOCK)
				WHERE ACGPatientResults.PatientID = @i_PatientUserID
					  AND CAST(DateDetermined AS DATE) BETWEEN CAST(GETDATE()-365 AS DATE) AND CAST(GETDATE() AS DATE))p
			UNPIVOT
			(value FOR names IN ([Outpatient Visits],[ER Visits],[Inpatient Admission],[Major Procedure Performed],[Dialysis Service]))AS unpvt

			INSERT INTO #TempResults
			(
				Names ,
				Value
			)
			SELECT Names,Value 
			FROM 
			(SELECT 
				CAST(HospitalDominantCount AS VARCHAR) AS 'Hospital Dominant Count',
				CAST(ProbabilityIPHosp6mos AS VARCHAR) AS 'Probability Hospital Admission(6Mos)',
				CAST(ProbabilityIPHosp AS VARCHAR) AS 'Probability Hospital Admission(12Mos)',
				CAST(ProbabilityICUHosp AS VARCHAR) AS 'Probability ICU/CCU Admission(12Mos)',
				CAST(probabilityInjuryHosp AS VARCHAR) AS 'Probability Injury Related Admission',
				CAST(probabilityExtendedHosp AS VARCHAR) AS 'Probability Long-Term Admission'
			FROM
				ACGPatientResults  WITH (NOLOCK)
			WHERE ACGPatientResults.PatientID = @i_PatientUserID
			      AND CAST(DateDetermined AS DATE) BETWEEN CAST(GETDATE()-365 AS DATE) AND CAST(GETDATE() AS DATE) )p
			UNPIVOT
			(value FOR Names IN ([Hospital Dominant Count],[Probability Hospital Admission(6Mos)],[Probability Hospital Admission(12Mos)],[Probability ICU/CCU Admission(12Mos)],[Probability Injury Related Admission],[Probability Long-Term Admission]))AS unpvt
		
			SELECT 
				TAR.Names ,
				TAR.Value ,
				TR.Names AS ACGName,
				TR.Value AS ACGValue
			FROM
				#TempACGResults TAR
			RIGHT JOIN #TempResults TR
				ON TR.ID = TAR.ID		
			 	
		END
		
	ELSE
		BEGIN
			INSERT INTO #TempACGResults
			(
				Names ,
				Value
			)
			SELECT 'Outpatient Visits' AS Names , '0' AS Value
			UNION
			SELECT 'ER Visits' AS Names , '0' AS Value
			UNION
			SELECT 'Inpatient Admission' AS Names , '0' AS Value
			UNION
			SELECT 'Major Procedure Performed' AS Names , '-' AS Value
			UNION
			SELECT 'Dialysis Service' AS Names , '-' AS Value
			
			INSERT INTO #TempResults
			(
				Names ,
				Value
			)
			SELECT 'Hospital Dominant Count' AS Names , 0 AS Value
			UNION
			SELECT 'Probability Hospital Admission(6Mos)' AS Names , 0 AS Value
			UNION
			SELECT 'Probability Hospital Admission(12Mos)' AS Names , 0 AS Value
			UNION
			SELECT 'Probability ICU/CCU Admission(12Mos)' AS Names , 0 AS Value
			UNION
			SELECT 'Probability Injury Related Admission' AS Names , 0 AS Value	
			UNION
			SELECT 'Probability Long-Term Admission' AS Names , 0 AS Value	
			
			SELECT 
				TAR.Names ,
				TAR.Value ,
				TR.Names AS ACGName,
				TR.Value AS ACGValue
			FROM
				#TempACGResults TAR
			RIGHT JOIN #TempResults TR
				ON TR.ID = TAR.ID		
				
		END
		
		SELECT DISTINCT
			EncounterType.Name ,
			ISNULL(COUNT(PatientEncounters.EncounterTypeId),0) EncounterVisits,
			SUM(ISNULL(ClaimInfo.NetPaidAmount,0)) CostPaid
		FROM
			EncounterType WITH (NOLOCK)
		LEFT JOIN PatientEncounters WITH (NOLOCK)
			ON EncounterType.EncounterTypeId = PatientEncounters.EncounterTypeId
		LEFT JOIN ClaimInfo WITH (NOLOCK)
			ON ClaimInfo.ClaimInfoId = PatientEncounters.ClaimInfoID
		WHERE PatientEncounters.PatientID = @i_PatientUserID
		AND PatientEncounters.EncounterDate BETWEEN CAST(GETDATE()-365 AS DATE) AND CAST(GETDATE() AS DATE)
		GROUP BY PatientEncounters.PatientID,EncounterType.Name
		UNION
		SELECT DISTINCT
			'RX' AS Name ,
			ISNULL(COUNT(Patient.PatientID),0) EncounterVisits,
			SUM(ISNULL(RxClaim.PaidAmount,0)) CostPaid
		FROM
			RxClaim WITH (NOLOCK)
		INNER JOIN Patient WITH (NOLOCK)
			ON Patient.PatientID = RxClaim.PatientID	
		AND RxClaim.DateFilled BETWEEN CAST(GETDATE()-365 AS DATE) AND CAST(GETDATE() AS DATE)
		WHERE Patient.PatientID = @i_PatientUserID
		GROUP BY Patient.PatientID
		
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
    ON OBJECT::[dbo].[usp_DashBoard_PatientUtilityAndCost] TO [FE_rohit.r-ext]
    AS [dbo];

