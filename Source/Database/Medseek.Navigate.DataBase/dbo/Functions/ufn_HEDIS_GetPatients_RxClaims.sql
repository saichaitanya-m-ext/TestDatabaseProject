CREATE FUNCTION [dbo].[ufn_HEDIS_GetPatients_RxClaims]
(
	@ECTTableName            VARCHAR(30)
   ,@AnchorDate_Year         INT
   ,@AnchorDate_Month        INT
   ,@AnchorDate_Day          INT
   ,@Num_Months_Prior        INT
   ,@Num_Months_After        INT
   ,@ECTCodeVersion_Year     INT
   ,@ECTCodeStatus           VARCHAR(1)
)
RETURNS TABLE
AS
	RETURN
	(
	    /************************************************************ INPUT PARAMETERS ************************************************************
	    
	    @ECTTableName = Name of the ECT Table containing NDC Drug Codes to be used for selection of Patients for inclusion in the Eligible
	    Population of Patients with qualifying Rx/Pharmacy Claims are to be drawn or selected from.
	    
	    @AnchorDate_Year = Year of the Anchor Date for which Eligible Population is to be constructed.
	    
	    @AnchorDate_Month = Month of the Anchor Date for which Eligible Population is to be constructed.
	    
	    @AnchorDate_Day = Day in the Month of the Anchor Date for which Eligible Population is to be constructed.
	    
	    @Num_Months_Prior = Number of Months Before the Anchor Date from which Eligible Population of Patients with "Diabetes" Pharmacy/Rx Claims
	    is to be constructed.
	    
	    @Num_Months_After = Number of Months After the Anchor Date from which Eligible Population of Patients with "Diabetes" Pharmacy/Rx Claims
	    is to be constructed.
	    
	    @ECTCodeVersion_Year = Code Version Year from which HEDIS-associated NDC Drug Codes that are used to select Patients for inclusion in
	    the Eligible Population of Patients, with Rx/Pharmacy claims that are for Diseases and Health Conditions
	    associated with the Measure, to be constructed for the Measurement Year/Period.
	    
	    @ECTCodeStatus = Status of HEDIS-associated NDC Drug Codes that are used to select Patients for inclusion in the Eligible Population of
	    Patients, with Rx/Pharmacy claims that are for Diseases and Health Conditions associated with the Measure, to be
	    constructed for the Measurement Year/Period.
	    Examples = 1 (for 'Enabled') or 0 (for 'Disabled').
	    
	    *********************************************************************************************************************************************/
	    
	    
	    SELECT rx_clm.[PatientID]
	          ,rx_clm.[RxClaimNumber]
	          ,NULL                   AS [ClaimLineID]
	          ,rx.DrugCode            AS 'NDCCode'
	          ,rx.[DrugName]
	          ,NULL AS [BrandName]
	          ,rx.[DrugDescription]
	          ,csdl.FirmName          AS [NDCLabel]
	          ,rx.[DrugCodeType]
	          ,rx_clm.[DateFilled]
	          ,rx_clm.[DaysSupply]
	          ,rx_clm.[QuantityDispensed]
	          ,rx_clm.[IsGeneric]
	          ,NULL AS [Formulary]
	          ,NULL AS [InsuranceGroupID]
	          ,NULL AS [MemberID]
	          ,NULL AS [PolicyNumber]
	          ,NULL AS [GroupNumber]
	          ,NULL AS [DependentSequenceNo]
	          --,rx_clm.[IngredientCost]
	          --,rx_clm.[PaidAmount]
	          --,rx_clm.ApprovedCopay
	          ,rx_clm.[PrescriberID]  AS 'Prescribing Physician ID'
	          ,NULL AS [PharmacyName]
	          ,NULL AS 'Pharmacy Provider ID'
	          ,pat.[DefaultTaskCareProviderID]
	          ,rx_clm.[StatusCode]
	          ,rx_clm.[RxClaimSourceID]
	          ,rx_clm.[DataSourceID]
	          ,rx_clm.[DataSourceFileID]
	          ,NULL AS [RecordTag_FileID]
	    FROM   [RxClaim] rx_clm
	    INNER JOIN [dbo].[Patient] pat
	           ON  rx_clm.[PatientID] = pat.[PatientID]
	    LEFT OUTER JOIN [CodeSetDrug] rx
	           ON  (rx.[DrugCodeId] = rx_clm.[DrugCodeId])
	    LEFT OUTER JOIN CodeSetDrugLabeler csdl
				ON csdl.LabelerID = rx.LabelerID
	    AND        (
	                   rx_clm.[DateFilled] BETWEEN rx.[BeginDate] AND rx.[EndDate]
	               )
	    WHERE  (
	               rx_clm.[DateFilled] BETWEEN (
	                   DATEADD(
	                       YYYY
	                      ,-@Num_Months_Prior
	                      ,(
	                           CONVERT(VARCHAR ,@AnchorDate_Year) + '-' +
	                           CONVERT(VARCHAR ,@AnchorDate_Month) + '-' +
	                           CONVERT(VARCHAR ,@AnchorDate_Day)
	                       )
	                   )
	               ) AND
	               (
	                   DATEADD(
	                       YYYY
	                      ,@Num_Months_After
	                      ,(
	                           CONVERT(VARCHAR ,@AnchorDate_Year) + '-' +
	                           CONVERT(VARCHAR ,@AnchorDate_Month) + '-' +
	                           CONVERT(VARCHAR ,@AnchorDate_Day)
	                       )
	                   )
	               )
	           )
	    AND    (
	               rx.[DrugCode] IN (SELECT [DrugCode]
	                                 FROM   dbo.ufn_HEDIS_GetDrugInfo_ByTableName(@ECTTableName ,@ECTCodeVersion_Year ,@ECTCodeStatus))
	           )
	);
