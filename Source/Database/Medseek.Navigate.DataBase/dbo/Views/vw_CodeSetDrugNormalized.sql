CREATE VIEW [dbo].[vw_CodeSetDrugNormalized] 
AS
 
SELECT csd.DrugCodeId,
       csd.DrugCode,
       csd.DrugCodeType,
       csd.DrugName,
       csd.DrugDescription,
       csd.CreatedByUserId,
       csd.CreatedDate,
       csd.LastModifiedByUserId,
       csd.LastModifiedDate,
       csd.MedicationId,
       csd.BeginDate,
       csd.EndDate,
       csd.NonProprietaryName,
       csdl.LabelerCode,
       csdl.FirmName AS LabelerName,
       csd.PharmClasses,
       csd.StartMarketingDate,
       csd.EndMarketingDate,
       csd.StatusCode,
       csd.MarketingCategoryName,
       csd.ApplicationNumber,
       csdf.Strength,
       csdf.Unit,
       NULL AS StrengthUnit,
       csdf.IngredientName,
       csdl.FirmName,
       csdl.AddressHeading,
       csdl.Street,
       csdl.PostBox,
       csdl.ForiegnAddress,
       csdl.City,
       csdl.[State],
       csdl.ZipCode,
       csdl.Province,
       csdl.Country,
       csdr.RouteCode                 AS RouteName,
       csdd.DosageName,
       SUBSTRING(csd.DrugCode, 6, 4)  AS ProductCode,
       RIGHT(csd.DrugCode, 2)         AS PackageCode
FROM   CodeSetDrug csd
JOIN CodeSetDrugDosageBridge csddb
       ON  csddb.DrugCodeID = csd.DrugCodeId
JOIN CodeSetDrugFormulationBridge csdfb
       ON  csdfb.DrugCodeID = csd.DrugCodeId
JOIN CodeSetDrugRoutesBridge csdrb
       ON  csdrb.DrugCodeID = csd.DrugCodeId
JOIN CodeSetDrugFormulation csdf
       ON  csdf.FormulationID = csdfb.FormulationID
JOIN CodeSetDrugDosage csdd
       ON  csdd.DosageId = csddb.DosageID
JOIN CodeSetDrugRoutes csdr
       ON  csdr.RouteCodeID = csdrb.RouteCodeID
JOIN CodeSetDrugLabeler csdl
       ON  csdl.LabelerID = csd.LabelerID