CREATE FUNCTION [dbo].[ufn_HEDIS_GetPatients_RxClaims_SelectedPopulation_MP] (
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
	,@i_ManagedPopulationID INT
	,@c_ReportType char(1) ='P' --P for Population ,S for Stratagic
	)
RETURNS @Output TABLE
( PatientID INT
  ,RxClaimNumber VARCHAR(80)
			,ClaimLineID INT
			,NDCCode VARCHAR(15)
			,DrugName VARCHAR(500)
			,BrandName VARCHAR(100)
			,DrugDescription VARCHAR(4000)
			,NDCLabel VARCHAR(200)
			,DrugCodeType VARCHAR(150)
			,DateFilled DATE
			,DaysSupply SMALLINT
			,QuantityDispensed DECIMAL(9,2)
			,IsGeneric BIT
			,Formulary VARCHAR(10)
			,InsuranceGroupID INT
			,MemberID INT
			,PolicyNumber VARCHAR(100)
			,GroupNumber VARCHAR(10)
			,DependentSequenceNo  VARCHAR(10)
			--,rx_clm.[IngredientCost]
			--,rx_clm.[PaidAmount]
			--,rx_clm.ApprovedCopay
			,[Prescribing Physician ID] INT
			,PharmacyName VARCHAR(100)
			,[Pharmacy Provider ID] INT
			,DefaultTaskCareProviderID INT
			,StatusCode CHAR(1)
			,RxClaimSourceID INT
			,DataSourceID INT
			,DataSourceFileID INT
			,RecordTag_FileID INT

    )
		/************************************************************ INPUT PARAMETERS ************************************************************  
	    
	    @ECTTableName = Name of the ECT Table containing NDC Drug Codes to be used for selection of Patients for inclusion in the Eligible  
	    Population of Patients with qualifying Rx/Pharmacy Claims are to be drawn or selected from.  
	    
	    @PopulationDefinitionID = Handle to the selected Population of Patients from which the Eligible Population of Patients of the Numerator  
	    are to be constructed.  
	    
	    @AnchorYear_NumYearsOffset = Number of Years of OFFSET -- After (+) or Before (-) -- from the Anchor Year around which the Patients in the  
	    selected Population was chosen, serving as the new Anchor Year around which the Eligible Population of  
	    Patients is to be constructed.  
	    
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
BEGIN
		
		INSERT INTO @OutPut
		SELECT rx_clm.[PatientID]
			,rx_clm.[RxClaimNumber]
			,NULL AS [ClaimLineID]
			,rx.DrugCode AS 'NDCCode'
			,rx.[DrugName]
			,NULL AS [BrandName]
			,rx.[DrugDescription]
			,csdl.FirmName AS [NDCLabel]
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
			,rx_clm.[PrescriberID] AS 'Prescribing Physician ID'
			,NULL AS [PharmacyName]
			,NULL AS 'Pharmacy Provider ID'
			,pat.[DefaultTaskCareProviderID]
			,rx_clm.[StatusCode]
			,rx_clm.[RxClaimSourceID]
			,rx_clm.[DataSourceID]
			,rx_clm.[DataSourceFileID]
			,NULL AS [RecordTag_FileID]
		FROM [RxClaim] rx_clm
		INNER JOIN [dbo].[PopulationDefinitionPatients] p
			ON p.[PatientID] = rx_clm.[PatientID]
		INNER JOIN PatientProgram pp WITH(nolock)
		    ON pp.PatientID = p.PatientID	
		INNER JOIN (
					SELECT pdpa1.PopulationDefinitionPatientID, MAX(pdpa1.OutPutAnchorDate) OutPutAnchorDate
		             FROM PopulationDefinitionPatientAnchorDate pdpa1 WITH(nolock)
		             INNER JOIN PopulationDefinitionPatients pdp WITH(nolock)
		             ON pdp.PopulationDefinitionPatientID = pdpa1.PopulationDefinitionPatientID
		           WHERE pdp.PopulationDefinitionID = @PopulationDefinitionID
					GROUP BY pdpa1.PopulationDefinitionPatientID
		) pdpa
			ON pdpa.PopulationDefinitionPatientID = p.PopulationDefinitionPatientID
		INNER JOIN [dbo].[Patient] pat
			ON pat.[PatientID] = p.[PatientID]
		LEFT OUTER JOIN [CodeSetDrug] rx
			ON (rx.[DrugCodeId] = rx_clm.[DrugCodeId])
		LEFT OUTER JOIN CodeSetDrugLabeler csdl
			ON csdl.LabelerID = rx.LabelerID
				AND (
					rx_clm.[DateFilled] BETWEEN rx.[BeginDate]
						AND rx.[EndDate]
					)
		WHERE (
				rx_clm.[DateFilled] BETWEEN (DATEADD(YYYY, - @Num_Months_Prior, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pdpa.OutPutAnchorDate)))
					AND (DATEADD(YYYY, @Num_Months_After, DATEADD(YYYY, @AnchorYear_NumYearsOffset, pdpa.OutPutAnchorDate)))
				)
			AND p.PopulationdefinitionID = @PopulationDefinitionID
			AND (
				rx.[DrugCode] IN (
					SELECT [DrugCode]
					FROM dbo.ufn_HEDIS_GetDrugInfo_ByTableName(@ECTTableName, @ECTCodeVersion_Year, @ECTCodeStatus)
					)
			)
			AND pp.ProgramID = @i_ManagedPopulationID
			--AND pdpa.DateKey = CONVERT(VARCHAR(10), @AnchorDate_Year) + CONVERT(VARCHAR(10), @AnchorDate_Month) + CONVERT(VARCHAR(10), @AnchorDate_Day)


RETURN
END
