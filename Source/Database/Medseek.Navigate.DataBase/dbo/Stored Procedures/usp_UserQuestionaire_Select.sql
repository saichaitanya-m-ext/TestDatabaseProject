
/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserQuestionaire_Select  23,48,1  
Description   : This procedure is used to get the details from UserQuestionaire table    
    based on the userID.    
Created By    : Aditya      
Created Date  : 26-Mar-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
15-Apr-10  Pramod Included the subsection to get the data titration and medications      
17-Jun-10 Pramod  Included the code IF @i_UserQuestionaireId IS NOT NULL BEGIN for   
   the recommendation and other values  
9-Sep-2010 NagaBabu Deleted NewUserDrugID1,NewUserDrugID2,OldUserDrugID1,OldUserDrugID2 fields and added UserDrugId     
9-Oct-10 Pramod Modified the RecommendationName to varchar(200) for the declare table, fixed system recommendation query  
17-Nov-10 Pramod Included logic for getting previous recommended drug detail and also included istitration=1 in queries  
09-Jun-2011 Rathnam added DiseaseId,Ispreventive columnt to the UserQuestionaire table  
18-July-2011 NagaBabu Replaced Listings.Unit by '' as this field is is deleted from table  
03-Oct-2011 Rathnam added totalscore to the userquestionaire table  
17-Oct-2011 Rathnam Added QuestionnaireScoring.QuestionaireId = QuestionaireId into the where clause for score calculation
09-Nov-2011 NagaBabu Added ProgramName to the select statement 
15-Nov-2011 NagaBabu Added NULL to the field ProgramName of @tbl_UserQuestionaire Table variable
22-Nov-2011 Rathnam added statuscodes for UserQuestionaire & Questionaire tables
11-Dec-2012 Mohan Removed statuscode
20-Mar-2013 P.V.P.Mohan Modified table name UserDrugCodes to PatientDrugCodes,UserQuestionaire to  PatientQuestionaire
03-APR-2013 Mohan Commented  Disease columns .    
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_UserQuestionaire_Select] --23,48
	(
	@i_AppUserId KEYID
	,@i_UserId KEYID
	,@i_UserQuestionaireId KEYID = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	-- Check if valid Application User ID is passed    
	IF (@i_AppUserId IS NULL)
		OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR (
				N'Invalid Application User ID %d passed.'
				,17
				,1
				,@i_AppUserId
				)
	END

	DECLARE @tbl_UserQuestionaire TABLE (
		UserQuestionaireId KEYID
		,UserId KEYID
		,QuestionaireId KEYID
		,QuestionaireName SHORTDESCRIPTION
		,DateTaken DATETIME
		,CreatedDate DATETIME
		,CreatedByUserId KEYID
		,Comments VARCHAR(4000)
		,DateDue DATETIME
		,DateAssigned DATETIME
		,PreviousUserQuestionaireId KEYID
		,DiseaseName VARCHAR(50)
		,IsPreventive ISINDICATOR
		,TotalScore INT
		,ProgramId KeyId
		,ProgramName SHORTDESCRIPTION NULL
		,IsMedicationTitration BIT
		,AssignedCareProviderId KEYID
		)

	INSERT INTO @tbl_UserQuestionaire (
		UserQuestionaireId
		,UserId
		,QuestionaireId
		,QuestionaireName
		,DateTaken
		,CreatedDate
		,CreatedByUserId
		,Comments
		,DateDue
		,DateAssigned
		,PreviousUserQuestionaireId
		--,DiseaseName
		,IsPreventive
		,TotalScore
		,ProgramId
		,ProgramName
		,IsMedicationTitration
		,AssignedCareProviderId
		)
	SELECT PatientQuestionaire.PatientQuestionaireId UserQuestionaireId
		,PatientQuestionaire.PatientId UserId
		,PatientQuestionaire.QuestionaireId
		,Questionaire.QuestionaireName
		,PatientQuestionaire.DateTaken
		,PatientQuestionaire.CreatedDate
		,PatientQuestionaire.CreatedByUserId
		,PatientQuestionaire.Comments
		,PatientQuestionaire.DateDue
		,PatientQuestionaire.DateAssigned
		,PatientQuestionaire.PreviousPatientQuestionaireId - '' AS NAME
		,ISNULL(PatientQuestionaire.IsPreventive, 0)
		,PatientQuestionaire.TotalScore
		,Program.ProgramId
		,Program.ProgramName
		,CASE 
			WHEN QuestionaireType.QuestionaireTypeName = 'Medication Titration'
				THEN 'TRUE'
			ELSE 'FALSE'
			END
		,PatientQuestionaire.AssignedCareProviderId
	FROM PatientQuestionaire WITH (NOLOCK)
	INNER JOIN Questionaire WITH (NOLOCK)
		ON Questionaire.QuestionaireId = PatientQuestionaire.QuestionaireId
			AND PatientQuestionaire.StatusCode <> 'I'
			AND Questionaire.StatusCode = 'A'
	INNER JOIN QuestionaireType QuestionaireType WITH (NOLOCK)
		ON Questionaire.QuestionaireTypeId = QuestionaireType.QuestionaireTypeId
	--LEFT OUTER JOIN Disease WITH(NOLOCK)
	--    ON PatientQuestionaire.DiseaseId = Disease.DiseaseId
	--AND Disease.StatusCode = 'A' 
	LEFT OUTER JOIN Program WITH (NOLOCK)
		ON Program.ProgramId = PatientQuestionaire.ProgramId
			AND Program.StatusCode = 'A'
	WHERE PatientId = @i_UserId
		AND (
			PatientQuestionaireId = @i_UserQuestionaireId
			OR @i_UserQuestionaireId IS NULL
			)

	SELECT UserQuestionaireId
		,UserId
		,QuestionaireId
		,QuestionaireName
		,DateTaken
		,CreatedDate
		,CreatedByUserId
		,Comments
		,DateDue
		,DateAssigned
		,DiseaseName
		,IsPreventive
		,TotalScore AS Score
		,(
			SELECT TOP 1 RangeName
			FROM QuestionnaireScoring
			WHERE TotalScore BETWEEN RangeStartScore
					AND RangeEndScore
				AND QuestionnaireScoring.QuestionaireId = tblUQ.QuestionaireId
			) AS RangeName
		,ProgramId
		,ProgramName
		,IsMedicationTitration
		,AssignedCareProviderId
	FROM @tbl_UserQuestionaire tblUQ

	-- Code FOR Recommendations AND Actions
	IF @i_UserQuestionaireId IS NOT NULL
	BEGIN
		DECLARE @tbl_UserQuestionaireRecommendation TABLE (
			ActionType VARCHAR(20)
			,RecommendationId KEYID
			,RecommendationName VARCHAR(200)
			,QDescription VARCHAR(100)
			,ActionComment VARCHAR(200)
			,FrequencyOfTitrationDays INT
			,UserDrugId KEYID
			,CreatedDate DATETIME
			)

		INSERT INTO @tbl_UserQuestionaireRecommendation (
			ActionType
			,RecommendationId
			,RecommendationName
			,QDescription
			,ActionComment
			,FrequencyOfTitrationDays
			,UserDrugId
			,CreatedDate
			)
		SELECT 'Action' AS ActionType
			,PatientQuestionaireRecommendations.RecommendationId AS RecommendationId
			,Recommendation.RecommendationName
			,Recommendation.Description
			,PatientQuestionaireRecommendations.ActionComment
			,PatientQuestionaireRecommendations.FrequencyOfTitrationDays
			,PatientQuestionaireDrugs.PatientDrugID UserDrugID
			,PatientQuestionaireRecommendations.CreatedDate
		FROM PatientQuestionaireRecommendations WITH (NOLOCK)
		INNER JOIN Recommendation WITH (NOLOCK)
			ON PatientQuestionaireRecommendations.RecommendationId = Recommendation.RecommendationId
		INNER JOIN PatientQuestionaireDrugs WITH (NOLOCK)
			ON PatientQuestionaireDrugs.PatientQuestionaireId = PatientQuestionaireRecommendations.PatientQuestionaireId
		WHERE PatientQuestionaireRecommendations.PatientQuestionaireId = @i_UserQuestionaireId
			AND PatientQuestionaireRecommendations.RecommendationId IS NOT NULL
		
		UNION
		
		SELECT 'Recommendation' AS ActionType
			,PatientQuestionaireRecommendations.SysRecommendationId AS RecommendationId
			,Recommendation.RecommendationName
			,Recommendation.Description
			,'' AS ActionComment
			,Recommendation.DefaultFrequencyOfTitrationDays AS FrequencyOfTitrationDays
			,RecommendationDrugs.RecommendationDrugsID AS UserDrugID
			,PatientQuestionaireRecommendations.CreatedDate
		FROM PatientQuestionaireRecommendations WITH (NOLOCK)
		INNER JOIN Recommendation WITH (NOLOCK)
			ON PatientQuestionaireRecommendations.SysRecommendationId = Recommendation.RecommendationId
		LEFT OUTER JOIN RecommendationDrugs WITH (NOLOCK)
			ON RecommendationDrugs.RecommendationID = Recommendation.RecommendationId
		WHERE PatientQuestionaireRecommendations.PatientQuestionaireId = @i_UserQuestionaireId
			AND PatientQuestionaireRecommendations.RecommendationId IS NOT NULL

		SELECT ActionType
			,RecommendationId
			,RecommendationName
			,QDescription
			,ActionComment
			,FrequencyOfTitrationDays
		FROM @tbl_UserQuestionaireRecommendation

		-- Code for Titrated Medications    
		SELECT TUQR.RecommendationId
			,'Current' AS Period
			,CSD.DrugName
			,CAST(csdf.Strength AS VARCHAR(20)) + ' ' + CAST('' AS VARCHAR(20)) AS CodeSetDrugListingsDosage
			,TUQR.CreatedDate AS DateChanged
		FROM @tbl_UserQuestionaireRecommendation TUQR
		INNER JOIN RxClaim UDC WITH (NOLOCK)
			ON TUQR.UserDrugId = UDC.RxClaimID
				AND UDC.StatusCode = 'A'
		--AND UDC.IsTitration = 1
		INNER JOIN CodeSetDrug CSD
			ON CSD.DrugCodeId = UDC.DrugCodeId
		--AND CSD.StatusCode = 'A'
		INNER JOIN CodeSetDrugFormulationBridge csdfb
			ON csdfb.DrugCodeID = CSD.DrugCodeID
		INNER JOIN CodeSetDrugFormulation csdf
			ON csdf.FormulationID = csdfb.FormulationID
		WHERE TUQR.UserDrugId IS NOT NULL
		
		UNION
		
		SELECT PatientQuestionaireRecommendations.RecommendationId
			,'Previous' AS Period
			,csd.DrugName
			,CAST(csdf.Strength AS VARCHAR(20)) + ' ' + CAST('' AS VARCHAR(20)) AS CodeSetDrugListingsDosage
			,PatientQuestionaireRecommendations.CreatedDate AS DateChanged
		FROM @tbl_UserQuestionaire UserQuestionaire
		INNER JOIN PatientQuestionaireRecommendations WITH (NOLOCK)
			ON UserQuestionaire.UserQuestionaireId = PatientQuestionaireRecommendations.PatientQuestionaireId
		INNER JOIN PatientQuestionaireDrugs WITH (NOLOCK)
			ON PatientQuestionaireDrugs.PatientQuestionaireID = UserQuestionaire.PreviousUserQuestionaireId
		INNER JOIN PatientDrugCodes WITH (NOLOCK)
			ON PatientQuestionaireDrugs.PatientDrugID = PatientDrugCodes.PatientDrugId
				AND PatientDrugCodes.StatusCode = 'I' -- Kept this for showing previous record data  
				AND PatientDrugCodes.IsTitration = 1
		INNER JOIN CodeSetDrug csd WITH (NOLOCK)
			ON csd.DrugCodeId = PatientDrugCodes.DrugCodeId
		-- AND CodeSetDrug.StatusCode = 'A'
		INNER JOIN CodeSetDrugFormulationBridge csdfb
			ON csdfb.DrugCodeID = CSD.DrugCodeID
		INNER JOIN CodeSetDrugFormulation csdf
			ON csdf.FormulationID = csdfb.FormulationID
	END
END TRY

--------------------------------------------------------       
BEGIN CATCH
	-- Handle exception      
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserQuestionaire_Select] TO [FE_rohit.r-ext]
    AS [dbo];

