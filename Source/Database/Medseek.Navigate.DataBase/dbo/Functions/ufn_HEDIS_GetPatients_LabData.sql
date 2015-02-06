CREATE FUNCTION [dbo].[ufn_HEDIS_GetPatients_LabData]
(
	@ECTTableName varchar(30),

	@AnchorDate_Year int,
	@AnchorDate_Month int,
	@AnchorDate_Day int,

	@Num_Months_Prior int,
	@Num_Months_After int,

	@ECTCodeVersion_Year int,
	@ECTCodeStatus varchar(1)
)
RETURNS TABLE
AS

RETURN
(
	/************************************************************ INPUT PARAMETERS ************************************************************

	 @ECTTableName = Name of the ECT Table containing LOINC Codes to be used for selection of Patients for inclusion in the Eligible
					 Population of Patients with qualifying Lab Data are to be drawn or selected from.

	 @AnchorDate_Year = Year of the Anchor Date for which Eligible Population is to be constructed.

	 @AnchorDate_Month = Month of the Anchor Date for which Eligible Population is to be constructed.

	 @AnchorDate_Day = Day in the Month of the Anchor Date for which Eligible Population is to be constructed.

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


	SELECT pm.[PatientID], pm.[MeasureID], m.[Name] AS 'MeasureName', muom.[UOMText], pm.[MeasureValueText],
		   pm.[MeasureValueNumeric], pm.[DateTaken], pm.[IsPatientAdministered], pm.[LOINCCodeID],
		   cod_loinc.[LOINCCode], cod_loinc.[ShortDescription], pm.[ProcedureCodeID], cod_proc.[ProcedureCode],
		   cod_proc.[ProcedureName], cod_proc.[ProcedureShortDescription], pm.[StatusCode], pm.[DataSourceID],
		   pm.[DataSourceFileID], pm.[RecordTag_FileID]

	FROM [dbo].[PatientMeasure] pm

	LEFT OUTER JOIN [dbo].[Measure] m ON m.[MeasureId] = pm.[MeasureId]

	LEFT OUTER JOIN [dbo].[MeasureUOM] muom ON muom.[MeasureUOMId] = pm.[MeasureUOMId]

	LEFT OUTER JOIN [dbo].[CodeSetLOINC] cod_loinc ON cod_loinc.[LOINCCodeID] = pm.[LOINCCodeID]

	LEFT OUTER JOIN [dbo].[CodeSetProcedure] cod_proc ON cod_proc.[ProcedureCodeID] = pm.[ProcedureCodeID]

	WHERE (pm.[DateTaken] BETWEEN (DATEADD(YYYY, -@Num_Months_Prior, (CONVERT(varchar, @AnchorDate_Year) + '-' +
																	  CONVERT(varchar, @AnchorDate_Month) + '-' +
																	  CONVERT(varchar, @AnchorDate_Day)))) AND
								  (DATEADD(YYYY, @Num_Months_After, (CONVERT(varchar, @AnchorDate_Year) + '-' +
																	 CONVERT(varchar, @AnchorDate_Month) + '-' +
																	 CONVERT(varchar, @AnchorDate_Day))))) AND

		  (cod_loinc.[LOINCCode] IN (SELECT [ECTCode]
									 FROM dbo.ufn_HEDIS_GetECTCodeInfo_ByTableName(@ECTTableName, @ECTCodeVersion_Year, @ECTCodeStatus)
									 WHERE [ECTHedisCodeTypeCode] = 'LOINC'))

);
