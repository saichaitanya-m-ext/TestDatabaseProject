CREATE FUNCTION [dbo].[ufn_HEDIS_GetDrugInfo_ByTableName2]
(
  @TableName varchar(20) ,
  @ECTCodeVersion_Year int ,
  @ECTCodeStatus varchar(1)
)
RETURNS TABLE
AS
RETURN
(
	/************************************************************ INPUT PARAMETERS *************************************************************

	 @TableName = Name of ECT Table for which HEDIS-associated NDC Drug data is to be retrieved.  Examples:  'CDC-A', 'CDC-B', 'ASM-C', etc.

	 @ECTCodeVersion_Year = Code Version Year for which valid HEDIS-associated NDC Drug codes and related data is to be retrieved.

	 @ECTCodeStatus = Status of ECT Table for which HEDIS-associated NDC Drug Codes and related data is to be retrieved.
					  Examples:  'A' (for 'Active') or 'I' (for 'Inactive').

	*********************************************************************************************************************************************/
    SELECT distinct
           hed_drug.[HEDIS_DrugCodeID],
           vcsd.[DrugCode],
           vcsd.[DrugCodeType],
           vcsd.[DrugName],
          -- vcsd.[DrugDescription],
           ect_tbl.[ECTHedisTableName],
           ect_tbl.[ECTHedisTableLetter],
           vcsd.NonProprietaryName AS 'GenericProductName',
           --vcsd.[GenericName]  AS 'GenericProductName',
           vcsd.MarketingCategoryName,
           --vcsd.[MarketingCategoryName],
           vcsd.RouteName AS RouteCode,
           --drug_rc.RouteCode,
           hed_drug.[CategoryName],
           vcsd.[IngredientName],
           vcsd.[Strength]     AS 'Formulation Strength',
           vcsd.[Unit],
           vcsd.[DosageName],
           NULL AS [DrugID],
           vcsd.[MedicationId],
           vcsd.[BeginDate],
           vcsd.[EndDate],
           vcsd.DrugName AS [TradeName],
           NULL as[TradenameSuffix],
           vcsd.[Strength],
           DrugCode AS [ProductCode],
           DrugCodeType AS [ProductType],
           vcsd.[LabelerCode],
           vcsd.[LabelerName],
           vcsd.[PackageCode],
           vcsd.DrugDescription,
           vcsd.[ApplicationNumber]
    FROM   [dbo].[CodeSetHEDIS_DrugCode] hed_drug
    INNER JOIN [dbo].[CodeSetECTHedisTable] ect_tbl
           ON  (ect_tbl.[ECTHedisTableID] = hed_drug.[ECTHedisTableID])
           AND (ect_tbl.[ECTHedisTableName] = @TableName)
           AND (ect_tbl.[StatusCode] = @ECTCodeStatus)
    LEFT OUTER JOIN [dbo].[vw_CodeSetDrug] vcsd
           ON  vcsd.[DrugCodeId] = hed_drug.[DrugCodeID]
    WHERE  hed_drug.[VersionYear] = @ECTCodeVersion_Year

	--SELECT hed_drug.[HEDIS_DrugCodeID], drug.[DrugCode], drug.[DrugCodeType], drug.[DrugName],
	--	   drug.[DrugDescription], ect_tbl.[ECTHedisTableName], ect_tbl.[ECTHedisTableLetter],
	--	   drug_list.[GenericName] AS 'GenericProductName', drug_list.[MarketingCategoryName],
	--	   drug_rc.RouteCode, hed_drug.[CategoryName], drug_form.[IngredientName],
	--	   drug_form.[Strength] AS 'Formulation Strength', drug_form.[Unit], drug_dose.[DosageName],
	--	   drug_list.[DrugID], drug.[MedicationId], drug.[BeginDate], drug.[EndDate], drug_list.[TradeName],
	--	   drug_list.[TradenameSuffix], drug_list.[Strength], drug_list.[ProductCode], drug_list.[ProductType],
	--	   drug_list.[LabelerCode], drug_list.[LabelerName], drug_pkg.[PackageCode], drug_pkg.[PackageDesc],
	--	   drug_list.[ApplicationNumber]

	--FROM [dbo].[CodeSetHEDIS_DrugCode] hed_drug

	--INNER JOIN [dbo].[CodeSetECTHedisTable] ect_tbl ON (ect_tbl.[ECTHedisTableID] = hed_drug.[ECTHedisTableID]) AND
	--												   (ect_tbl.[ECTHedisTableName] = @TableName) AND
	--												   (ect_tbl.[StatusCode] = @ECTCodeStatus)

	--LEFT OUTER JOIN [dbo].[CodeSetDrug] drug ON drug.[DrugCodeId] = hed_drug.[DrugCodeID]

	--LEFT OUTER JOIN [Listings] drug_list ON drug_list.[ListingSequenceNo] = drug.[ListingSequenceNo]

	--LEFT OUTER JOIN [Formulations] drug_form ON drug_form.[ListingSequenceNo] = drug_list.[ListingSequenceNo]

	--LEFT OUTER JOIN [Routes] drug_rte ON drug_rte.[ListingSequenceNo] = drug_list.[ListingSequenceNo]

	--LEFT OUTER JOIN [RouteCodes] drug_rc ON drug_rc.[RouteCodeID] = drug_rte.[RouteCodeID]

	--LEFT OUTER JOIN [DosageForm] drug_df ON drug_df.[ListingSequenceNo] = drug_list.[ListingSequenceNo]

	--LEFT OUTER JOIN [Dosage] drug_dose ON drug_dose.[DosageId] = drug_df.[DosageID]

	--LEFT OUTER JOIN [Packages] drug_pkg ON drug_pkg.[ListingSequenceNo] = drug_list.[ListingSequenceNo]

	--WHERE hed_drug.[VersionYear] = @ECTCodeVersion_Year
);
