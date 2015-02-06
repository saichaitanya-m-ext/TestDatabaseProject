


CREATE VIEW [dbo].[vw_CodeSetDrug] 
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
       csd.LabelerID,
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
       csdf.Strength+'-'+csdf.Unit AS StrengthUnitNormalized,
       SUBSTRING(
           (   
               SELECT ',' + csdf.Strength+'-'+csdf.Unit
               FROM   CodeSetDrug csd1
               JOIN CodeSetDrugFormulationBridge csdfb
                      ON  csdfb.DrugCodeID = csd1.DrugCodeId
               JOIN CodeSetDrugFormulation csdf
                      ON  csdf.FormulationID = csdfb.FormulationID
               WHERE  csd1.DrugCodeId = csd.DrugCodeId
               ORDER BY
                      csdf.Strength,csdf.Unit
                      FOR XML PATH('')
           ),2,200000
       )                              AS StrengthUnit,
       csdf.IngredientName            AS IngredientNameNormalized,
       SUBSTRING(
           (
               SELECT ',' + csdf.[IngredientName]
               FROM   CodeSetDrug csd1
               JOIN CodeSetDrugFormulationBridge csdfb
                      ON  csdfb.DrugCodeID = csd1.DrugCodeId
               JOIN CodeSetDrugFormulation csdf
                      ON  csdf.FormulationID = csdfb.FormulationID
               WHERE  csd1.DrugCodeId = csd.DrugCodeId
               ORDER BY
                      csdf.[IngredientName]
                      FOR XML PATH('')
           ),2,200000
       )                              AS IngredientName,
       --csdl.LabelerCode,
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
       csdd.DosageName                AS DosageNameNormalized,
       SUBSTRING(
           (
               SELECT ',' + csdd.DosageName
               FROM   CodeSetDrug csd1
               JOIN CodeSetDrugDosageBridge csddb
                      ON  csddb.DrugCodeID = csd1.DrugCodeId
               JOIN CodeSetDrugDosage csdd
                      ON  csdd.DosageId = csddb.DosageID
               WHERE  csd1.DrugCodeId = csd.DrugCodeId
               ORDER BY
                      csdf.[IngredientName]
                      FOR XML PATH('')
           ),2,200000
       )                              AS DosageName,
       SUBSTRING(csd.DrugCode, 6, 4)  AS ProductCode,
       RIGHT(csd.DrugCode, 2)         AS PackageCode
FROM   CodeSetDrug csd
LEFT OUTER JOIN CodeSetDrugDosageBridge csddb
       ON  csddb.DrugCodeID = csd.DrugCodeId
LEFT OUTER JOIN CodeSetDrugFormulationBridge csdfb
       ON  csdfb.DrugCodeID = csd.DrugCodeId
LEFT OUTER JOIN CodeSetDrugRoutesBridge csdrb
       ON  csdrb.DrugCodeID = csd.DrugCodeId
LEFT OUTER JOIN CodeSetDrugFormulation csdf
       ON  csdf.FormulationID = csdfb.FormulationID
LEFT OUTER JOIN CodeSetDrugDosage csdd
       ON  csdd.DosageId = csddb.DosageID
LEFT OUTER JOIN CodeSetDrugRoutes csdr
       ON  csdr.RouteCodeID = csdrb.RouteCodeID
LEFT OUTER JOIN CodeSetDrugLabeler csdl
       ON  csdl.LabelerID = csd.LabelerID


