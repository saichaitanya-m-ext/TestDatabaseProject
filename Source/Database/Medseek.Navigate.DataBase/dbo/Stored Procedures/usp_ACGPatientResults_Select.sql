/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_ACGPatientResults_Select]
Description   : This procedure is used to get data from ACGPatientResults Table  
Created By    : NagaBabu
Created Date  : 19-Jan-2011
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION  
15-Feb-2011 NagaBabu Created #HealthStatusScore for getting Ranges for each HealthStatusScore 
16-Feb-2011 NagaBabu Added @i_ProbabilityIPHospScoreID,@i_ProbabilityIPHosp6mosScoreID,@i_ProbabilityICUHospScoreID,@i_probabilityInjuryHospScoreID,
				@i_probabilityExtendedHospScoreID,@i_ProbabilityHighTotalCostScoreID,@i_ProbabilityHighPharmacyCostScoreID,@i_ProbabilityUnexpectedPharmacyCostScoreID
				Perameters to eliminate Select statements in functions   
14-Mar-2011 NagaBabu Deleted @dt_DateDetermined as Input perameter and added @i_ACGResultsID perameter
17-Mar-2011 NagaBabu Added CAST operator to ProbabilityHighTotalCost field to convert into DECIMAL data type 				   
------------------------------------------------------------------------------        
*/			
CREATE PROCEDURE [dbo].[usp_ACGPatientResults_Select]
(  
  @i_AppUserId KeyID ,
  @i_PatientID KEYID ,
  @i_ACGResultsID KeyID
)  
AS  
BEGIN TRY  
      SET NOCOUNT ON         
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.' ,  
               17 ,  
               1 ,  
               @i_AppUserId )  
         END  
         
        
----------- Select PatientACGResults details ------------------- 
 
	     CREATE TABLE #HealthStatusScore
			(	
				ProbabilityIPHosp  DECIMAL(10,2) ,
				ProbabilityIPHosp6mos  DECIMAL(10,2),
				ProbabilityICUHosp  DECIMAL(10,2),
				probabilityInjuryHosp DECIMAL(10,2),
				probabilityExtendedHosp  DECIMAL(10,2),
				ProbabilityHighTotalCost FLOAT ,
				ProbabilityHighPharmacyCost FLOAT ,
				ProbabilityUnexpectedPharmacyCost DECIMAL(10,2),
				InpatientHospitalizationCount SMALLINT ,
				EmergencyVisitCount SMALLINT ,
				OutpatientVisitCount SMALLINT ,
				UniqueProviderCount SMALLINT ,
				SpecialtyCount SMALLINT ,
				NoGeneralist NVARCHAR(2) ,
				MajorAGDCount SMALLINT ,
				HospitalDominantCount SMALLINT,
			    ChronicConditionCount SMALLINT,
			    MajoritySourceOfCarePercent FLOAT,
			    MajoritySourceOfCareProviders NVARCHAR(200),
			    TotalCost MONEY,
			    TotalCostBand NVARCHAR(40),
			    ResourceUtilizationBand INT,
			    PharmacyCost MONEY,
			    PharmacyCostBand NVARCHAR(40),
			    GenericDrugCount SMALLINT,
			    HighRiskUnexpectedPharmacyCost VARCHAR(1),
			    Pregnant SMALLINT,
			    Delivered SMALLINT,
			    LowBirthWeight SMALLINT,
			    DialysisService SMALLINT,
			    NursingService SMALLINT,
			    FrailtyFlag NVARCHAR(2),
			    UnscaledTotalCostResourceIndex  DECIMAL(10,2) ,
			    RescaledTotalCostResourceIndex  DECIMAL(10,2) ,
			    UnscaledPharmacyCostResourceIndex DECIMAL(10,2) ,
			    RescaledPharmacyCostResourceIndex  DECIMAL(10,2)
			)	 
			 
		INSERT INTO #HealthStatusScore
			(		
				ProbabilityIPHosp  ,
				ProbabilityIPHosp6mos ,
				ProbabilityICUHosp  ,
				probabilityInjuryHosp ,
				probabilityExtendedHosp  ,
				ProbabilityHighTotalCost ,
				ProbabilityHighPharmacyCost  ,
				ProbabilityUnexpectedPharmacyCost ,
				InpatientHospitalizationCount ,
				EmergencyVisitCount ,
				OutpatientVisitCount ,
				UniqueProviderCount  ,
				SpecialtyCount  ,
				NoGeneralist ,
				MajorAGDCount  ,
				HospitalDominantCount ,
			    ChronicConditionCount ,
			    MajoritySourceOfCarePercent ,
			    MajoritySourceOfCareProviders ,
			    TotalCost ,
			    TotalCostBand ,
			    ResourceUtilizationBand ,
			    PharmacyCost ,
			    PharmacyCostBand ,
			    GenericDrugCount ,
			    HighRiskUnexpectedPharmacyCost ,
			    Pregnant ,
			    Delivered ,
			    LowBirthWeight ,
			    DialysisService ,
			    NursingService ,
			    FrailtyFlag ,
			    UnscaledTotalCostResourceIndex ,
			    RescaledTotalCostResourceIndex ,
			    UnscaledPharmacyCostResourceIndex ,
			    RescaledPharmacyCostResourceIndex 	 
			)		
		 SELECT DISTINCT
			 CAST(ACGPR.ProbabilityIPHosp AS DECIMAL(10,2)) AS ProbabilityIPHosp ,
			 CAST(ACGPR.ProbabilityIPHosp6mos AS DECIMAL(10,2)) AS ProbabilityIPHosp6mos ,
			 CAST(ACGPR.ProbabilityICUHosp AS DECIMAL(10,2)) AS ProbabilityICUHosp ,
			 CAST(ACGPR.probabilityInjuryHosp AS DECIMAL(10,2)) AS probabilityInjuryHosp ,
			 CAST(ACGPR.probabilityExtendedHosp AS DECIMAL(10,2)) AS probabilityExtendedHosp,
			 CAST(ACGPR.ProbabilityHighTotalCost  AS DECIMAL(10,2)) AS ProbabilityHighTotalCost ,
			 ACGPR.ProbabilityHighPharmacyCost ,
			 CAST(ACGPR.ProbabilityUnexpectedPharmacyCost AS DECIMAL(10,2)) AS ProbabilityUnexpectedPharmacyCost ,
			 ACGPR.InpatientHospitalizationCount ,
			 ACGPR.EmergencyVisitCount ,
			 ACGPR.OutpatientVisitCount ,
			 ACGPR.UniqueProviderCount ,
			 ACGPR.SpecialtyCount ,
			 ACGPR.NoGeneralist ,
			 ACGPR.MajorAGDCount ,
			 ACGPR.HospitalDominantCount ,
			 ACGPR.ChronicConditionCount ,
			 ACGPR.MajoritySourceOfCarePercent ,
			 ACGPR.MajoritySourceOfCareProviders ,
			 ACGPR.TotalCost ,
			 ACGPR.TotalCostBand ,
			 ACGPR.ResourceUtilizationBand ,
			 ACGPR.PharmacyCost ,
			 ACGPR.PharmacyCostBand ,
			 ACGPR.GenericDrugCount ,
			 ACGPR.HighRiskUnexpectedPharmacyCost ,
			 ACGPR.Pregnant ,
			 ACGPR.Delivered ,
			 ACGPR.LowBirthWeight ,
			 ACGPR.DialysisService ,
			 ACGPR.NursingService ,
			 ACGPR.FrailtyFlag ,
			 CAST(ACGPR.UnscaledTotalCostResourceIndex AS DECIMAL(10,2)) AS UnscaledTotalCostResourceIndex ,
			 CAST(ACGPR.RescaledTotalCostResourceIndex AS DECIMAL(10,2)) AS RescaledTotalCostResourceIndex ,
			 CAST(ACGPR.UnscaledPharmacyCostResourceIndex AS DECIMAL(10,2)) AS UnscaledPharmacyCostResourceIndex ,
			 CAST(ACGPR.RescaledPharmacyCostResourceIndex AS DECIMAL(10,2)) AS RescaledPharmacyCostResourceIndex
		 FROM
			 ACGPatientResults ACGPR WITH (NOLOCK)
		 INNER JOIN UserHealthStatusScore UHSS  WITH (NOLOCK)
			 ON UHSS.UserId = ACGPR.PatientID
		 INNER JOIN HealthStatusScoreType HSST 
			 ON HSST.HealthStatusScoreId = UHSS.HealthStatusScoreId	 	 
		 WHERE
			 PatientID = @i_PatientID
		 --AND CONVERT(VARCHAR(10),ACGPR.DateDetermined,101) = @dt_DateDetermined
		 --AND CONVERT(VARCHAR(10),UHSS.DateDetermined,101) = @dt_DateDetermined
		 AND ACGResultsID = @i_ACGResultsID
		 
		 DECLARE @i_ProbabilityIPHospScoreID KeyID ,
				 @i_ProbabilityIPHosp6mosScoreID KeyID ,
				 @i_ProbabilityICUHospScoreID KeyID ,
				 @i_probabilityInjuryHospScoreID KeyID ,
				 @i_probabilityExtendedHospScoreID KeyID ,
				 @i_ProbabilityHighTotalCostScoreID KeyID ,
				 @i_ProbabilityHighPharmacyCostScoreID KeyID ,
				 @i_ProbabilityUnexpectedPharmacyCostScoreID KeyID ,
				 @dt_DateDetermined DATETIME
				 
		 SELECT @dt_DateDetermined = DateDetermined 
		 FROM
			 ACGPatientResults
		 WHERE
			 ACGResultsID = @i_ACGResultsID	 		 
		 
		 SELECT	@i_ProbabilityIPHospScoreID = HealthStatusScoreId
		 FROM
			 HealthStatusScoreType
		 WHERE 
			 Name = 'Probability of Inpatient Hospitalization (YR)' 
			 	 
		 SELECT @i_ProbabilityIPHosp6mosScoreID = HealthStatusScoreId
		 FROM
			 HealthStatusScoreType
		 WHERE 
		     Name = 'Probability of Inpatient Hospitalization < 6 months'
	 	 
	 	 SELECT @i_ProbabilityICUHospScoreID = HealthStatusScoreId
		 FROM
		     HealthStatusScoreType
		 WHERE 
		     Name = 'Probability of ICU Admission'
		     
		 SELECT @i_probabilityInjuryHospScoreID = HealthStatusScoreId
		 FROM
			 HealthStatusScoreType
		 WHERE 
			 Name = 'Probability of Injury Related Admission'
			 
		 SELECT @i_probabilityExtendedHospScoreID = HealthStatusScoreId
		 FROM
			 HealthStatusScoreType
		 WHERE 
			 Name = 'Probability of Long-term admission (12+ days)'	     
	 	 
	 	 SELECT @i_ProbabilityHighTotalCostScoreID = HealthStatusScoreId
		 FROM
			 HealthStatusScoreType
		 WHERE 
			 Name = 'Probability of High Total Cost'	 	 
	 	 
	 	 SELECT @i_ProbabilityHighPharmacyCostScoreID = HealthStatusScoreId
		 FROM
			 HealthStatusScoreType
		 WHERE 
			 Name = 'Probability high pharmacy cost' 
	 	
	 	 SELECT @i_ProbabilityUnexpectedPharmacyCostScoreID = HealthStatusScoreId
		 FROM
			 HealthStatusScoreType
		 WHERE 
			 Name = 'Probability Unexpected pharmacy cost' 
			 
	 	 SELECT 
			ProbabilityIPHosp  ,
		    dbo.ufn_GetACGHealthStatusScoreRange(@i_PatientID,@dt_DateDetermined,@i_ProbabilityIPHospScoreID,ProbabilityIPHosp)AS 'ProbabilityIPHospRange',	
			ProbabilityIPHosp6mos ,
			dbo.ufn_GetACGHealthStatusScoreRange(@i_PatientID,@dt_DateDetermined,@i_ProbabilityIPHosp6mosScoreID,ProbabilityIPHosp6mos)AS 'ProbabilityIPHosp6mosRange',	
			ProbabilityICUHosp  ,
			dbo.ufn_GetACGHealthStatusScoreRange(@i_PatientID,@dt_DateDetermined,@i_ProbabilityICUHospScoreID,ProbabilityICUHosp)AS 'ProbabilityICUHospRange',	
			probabilityInjuryHosp ,
			dbo.ufn_GetACGHealthStatusScoreRange(@i_PatientID,@dt_DateDetermined,@i_probabilityInjuryHospScoreID,probabilityInjuryHosp)AS 'ProbabilityInjuryHospRange',	
			probabilityExtendedHosp  ,
			dbo.ufn_GetACGHealthStatusScoreRange(@i_PatientID,@dt_DateDetermined,@i_probabilityExtendedHospScoreID,probabilityExtendedHosp)AS 'ProbabilityExtendedHospRange',	
			ProbabilityHighTotalCost ,
			dbo.ufn_GetACGHealthStatusScoreRange(@i_PatientID,@dt_DateDetermined,@i_ProbabilityHighTotalCostScoreID,ProbabilityHighTotalCost)AS 'ProbabilityHighTotalCostRange',	
			ProbabilityHighPharmacyCost  ,
			dbo.ufn_GetACGHealthStatusScoreRange(@i_PatientID,@dt_DateDetermined,@i_ProbabilityHighPharmacyCostScoreID,ProbabilityHighPharmacyCost)AS 'ProbabilityHighPharmacyCostRange',	
			ProbabilityUnexpectedPharmacyCost ,
			dbo.ufn_GetACGHealthStatusScoreRange(@i_PatientID,@dt_DateDetermined,@i_ProbabilityUnexpectedPharmacyCostScoreID,ProbabilityUnexpectedPharmacyCost)AS 'ProbabilityUnexpectedPharmacyCostRange',	
			InpatientHospitalizationCount ,
			EmergencyVisitCount ,
			OutpatientVisitCount ,
			UniqueProviderCount  ,
			SpecialtyCount  ,
			NoGeneralist ,
			MajorAGDCount  ,
			HospitalDominantCount ,
			ChronicConditionCount ,
			MajoritySourceOfCarePercent ,
			MajoritySourceOfCareProviders ,
			TotalCost ,
			TotalCostBand ,
			ResourceUtilizationBand ,
			PharmacyCost ,
			PharmacyCostBand ,
			GenericDrugCount ,
			HighRiskUnexpectedPharmacyCost ,
			Pregnant ,
			Delivered ,
			LowBirthWeight ,
			DialysisService ,
			NursingService ,
			FrailtyFlag ,
			UnscaledTotalCostResourceIndex ,
			RescaledTotalCostResourceIndex ,
			UnscaledPharmacyCostResourceIndex ,
			RescaledPharmacyCostResourceIndex 
		FROM
			#HealthStatusScore 	
		
END TRY        
   
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ACGPatientResults_Select] TO [FE_rohit.r-ext]
    AS [dbo];

