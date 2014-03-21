CREATE  FUNCTION [dbo].[ufn_HEDIS_GetPatients_LabData_SelectedPopulation] (
	@ECTTableName VARCHAR(30)
	,@PopulationDefinitionID INT
	,@AnchorYear_NumYearsOffset INT
	,@Num_Months_Prior INT
	,@Num_Months_After INT
	,@ECTCodeVersion_Year INT
	,@ECTCodeStatus VARCHAR(1)
	,@AnchorDate_Year INT = 2012
	,@AnchorDate_Month VARCHAR(2) = 12
	,@AnchorDate_Day VARCHAR(2) = 31
	,@c_ReportType CHAR(1) = 'P'
	)
RETURNS @OUTPUT TABLE (
	 PatientID INT
	,MeasureID INT
	,MeasureName VARCHAR(150)
	,UOMText VARCHAR(50)
	,MeasureValueText VARCHAR(510)
	,MeasureValueNumeric DECIMAL(9, 2)
	,DateTaken DATETIME
	,IsPatientAdministered BIT
	,LOINCCodeID INT
	,LOINCCode VARCHAR(10)
	,ShortDescription VARCHAR(1000)
	,ProcedureCodeID INT
	,ProcedureCode VARCHAR(10)
	,ProcedureName VARCHAR(500)
	,ProcedureShortDescription VARCHAR(1000)
	,StatusCode CHAR(1)
	,DataSourceID INT
	,DataSourceFileID INT
	,RecordTag_FileID VARCHAR(30)
	)

/************************************************************ INPUT PARAMETERS ************************************************************

	 @ECTTableName = Name of the ECT Table containing LOINC Codes to be used for selection of Patients for inclusion in the Eligible
					 Population of Patients with qualifying Lab Data are to be drawn or selected from.

	 @PopulationDefinitionID = Handle to the selected Population of Patients from which the Eligible Population of Patients of the Numerator
							   are to be constructed.

	 @AnchorYear_NumYearsOffset = Number of Years of OFFSET -- After (+) or Before (-) -- from the Anchor Year around which the Patients in the
								  selected Population was chosen, serving as the new Anchor Year around which the Eligible Population of
								  Patients is to be constructed.

	 @Num_Months_Prior = Number of Months Before the Anchor Date from which Eligible Population of Patients with Encounters/Event Diagnoses
						 is to be constructed.

	 @Num_Months_After = Number of Months After the Anchor Date from which Eligible Population of Patients with Encounters/Diagnoses
						 is to be constructed.

	 @ECTCodeVersion_Year = Code Version Year from which HEDIS-associated ECT Codes (e.g. ICD-9-CM, ICD-10-CM, etc.) that are to be used to
							select Patients for inclusion in the Eligible Population of Patients, with health claims for Encounters/Event
							Diagnoses that are for Diseases and Health Conditions associated with the Measure, to be constructed for the
							Measurement Period.

	 @ECTCodeStatus = Status of HEDIS-associated ECT Codes (e.g. ICD-9-CM, ICD-10-CM, etc.) that are to be used to select Patients for inclusion
					  in the Eligible Population of Patients, with health claims for Encounters/Event Diagnoses that are for Diseases and Health
					  Conditions associated with the Measure, to be constructed for the Measurement Period.
					  Examples = 'A' (for 'Active') or 'I' (for 'Inactive').

	 *********************************************************************************************************************************************/
BEGIN
	
	    INSERT INTO @OUTPUT
		SELECT pm.[PatientID]
			,pm.[MeasureID]
			,m.[Name] AS 'MeasureName'
			,muom.[UOMText]
			,pm.[MeasureValueText]
			,pm.[MeasureValueNumeric]
			,pm.[DateTaken]
			,pm.[IsPatientAdministered]
			,pm.[LOINCCodeID]
			,cod_loinc.[LOINCCode]
			,cod_loinc.[ShortDescription]
			,pm.[ProcedureCodeID]
			,cod_proc.[ProcedureCode]
			,cod_proc.[ProcedureName]
			,cod_proc.[ProcedureShortDescription]
			,pm.[StatusCode]
			,pm.[DataSourceID]
			,pm.[DataSourceFileID]
			,pm.[RecordTag_FileID]
		FROM [dbo].[PatientMeasure] pm
		INNER JOIN [dbo].[PopulationDefinitionPatients] p ON p.[PatientID] = pm.[PatientID]
		INNER JOIN PopulationDefinitionPatientAnchorDate pdpa ON pdpa.PopulationDefinitionPatientID = p.PopulationDefinitionPatientID
		LEFT OUTER JOIN [dbo].[Measure] m ON m.[MeasureId] = pm.[MeasureId]
		LEFT OUTER JOIN [dbo].[MeasureUOM] muom ON muom.[MeasureUOMId] = pm.[MeasureUOMId]
		LEFT OUTER JOIN [dbo].[CodeSetLOINC] cod_loinc ON cod_loinc.[LOINCCodeID] = pm.[LOINCCodeID]
		LEFT OUTER JOIN [dbo].[CodeSetProcedure] cod_proc ON cod_proc.[ProcedureCodeID] = pm.[ProcedureCodeID]
		WHERE (
				pm.[DateTaken] BETWEEN (DATEADD(YYYY, - @Num_Months_Prior, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pdpa.OutPutAnchorDate)))
					AND (DATEADD(YYYY, @Num_Months_After, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pdpa.OutPutAnchorDate)))
				)
			AND (
				cod_loinc.[LOINCCode] IN (
					SELECT [ECTCode]
					FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName(@ECTTableName, @ECTCodeVersion_Year, @ECTCodeStatus)
					WHERE [ECTHedisCodeTypeCode] = 'LOINC'
					)
				)
			AND P.PopulationDefinitionID = @PopulationDefinitionID
			AND pdpa.DateKey = CONVERT(VARCHAR(10), @AnchorDate_Year) + CONVERT(VARCHAR(10), @AnchorDate_Month) + CONVERT(VARCHAR(10), @AnchorDate_Day)
	


	RETURN
END
