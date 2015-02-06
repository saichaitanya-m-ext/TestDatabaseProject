CREATE PROCEDURE [dbo].[usp_HEDIS_HealthPlans_CDC_HbA1c_GetNumeratorCount_2012]
(
	@PopulationDefinitionID INT,
	@AnchorDate_Year int = 2011,
	@AnchorDate_Month int = 12,
	@AnchorDate_Day int = 31,

	@Num_Months_Prior int = 12,
	@Num_Months_After int = 0,

	@ECTCodeVersion_Year int = 2012,
	@ECTCodeStatus varchar(1) = 'A'
)
AS

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @AnchorDate_Year = Year of the Anchor Date for which Numerator  is to be constructed.

	 @AnchorDate_Month = Month of the Anchor Date for which Numerator  is to be constructed.

	 @AnchorDate_Day = Day in the Month of the Anchor Date for which Numerator is to be constructed.

	 @Num_Months_Prior = Number of Months Before the Anchor Date from which Numerator is to be constructed.

	 @Num_Months_After = Number of Months After the Anchor Date from which Numerator is to be constructed.

	

	 @ECTCodeVersion_Year = Code Version Year from which valid HEDIS-associated Codes are retrieved for use in Numerator during the
							Measurement Period (derived from ECT tables).

	 @ECTCodeStatus = Status of valid HEDIS-associated Codes that are retrieved for use in Numerator during the Measurement Period.
					  Examples = A (for 'Active') or I (for 'InActive').(derived from ECT tables).

	 *********************************************************************************************************************************************/


DECLARE	@UserID int


CREATE TABLE [#ECTCodes_Table_CDC_D]
(
	[ECTCode] varchar(20) NOT NULL,
	[ECTCodeDescription] varchar(255) NOT NULL,
	[ECTTypeCode] varchar(20) NOT NULL
);

CREATE NONCLUSTERED INDEX [IX_ECTCodes_Table_CDC_C] ON [#ECTCodes_Table_CDC_D] 
(
	[ECTCode] ASC,
	[ECTCodeDescription] ASC,
	[ECTTypeCode] ASC
);


CREATE TABLE #DiabetesPatients_CandidatesHbA1c
(
	[UserID] int NOT NULL,
	[ClaimInfoID] int NOT NULL,
	[ClaimLineID] int NULL,
	[ProcedureCode] int NULL,
	[BeginServiceDate] datetime NULL
);

CREATE CLUSTERED INDEX [IX_DiabetesPatients_CandidatesHbA1c] ON [#DiabetesPatients_CandidatesHbA1c] 
(
	[UserID] ASC,
	[ClaimInfoID] ASC,
	[ClaimLineID] ASC,
	[ProcedureCode] ASC,
	[BeginServiceDate] ASC
)WITH (FILLFACTOR = 90)


CREATE TABLE #DiabetesPatients
(
	[UserID] int ,[BeginServiceDate] datetime
)


INSERT INTO #ECTCodes_Table_CDC_D
SELECT [ECTCode], [ECTCodeDescription], ECTHedisCodeTypeCode
FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName('CDC-D', @ECTCodeVersion_Year, @ECTCodeStatus)


INSERT INTO [#DiabetesPatients_CandidatesHbA1c]
SELECT [PatientID] AS 'UserID', [ClaimInfoId], [ClaimLineID], [ProcedurecodeId], [BeginServiceDate]

FROM dbo.ufn_HEDIS_GetPatients_EncouterClaims_ByProcedure('CDC-2', @AnchorDate_Year, @AnchorDate_Month, @AnchorDate_Day, @Num_Months_Prior,
														  @Num_Months_After, @ECTCodeVersion_Year, @ECTCodeStatus)




-- Retrieve Patients meeting criteria of having requisite number HbA1c test.
INSERT INTO #DiabetesPatients
SELECT diab_pat.[UserId],[BeginServiceDate]
FROM ( SELECT DISTINCT [UserId], [ClaimInfoId], [ProcedureCode], [BeginServiceDate]  
     FROM [#DiabetesPatients_CandidatesHbA1c])  AS diab_pat  
		
		
SELECT [UserID]
,count(distinct [BeginServiceDate]) [Count] 
,1 AS IsIndicator   
FROM #DiabetesPatients  
group by USERID,BeginServiceDate
ORDER BY [UserID] 


DROP TABLE #ECTCodes_Table_CDC_D;
DROP TABLE [#DiabetesPatients_CandidatesHbA1c];
DROP TABLE #DiabetesPatients;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HEDIS_HealthPlans_CDC_HbA1c_GetNumeratorCount_2012] TO [FE_rohit.r-ext]
    AS [dbo];

