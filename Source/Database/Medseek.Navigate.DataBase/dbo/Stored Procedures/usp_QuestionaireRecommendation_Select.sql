
/*              
------------------------------------------------------------------------------              
Procedure Name: usp_QuestionaireRecommendation_Select             
Description   : This procedure is used to get the QuestionaireRecommendation Details based on the           
    QuestionaireId or get all the Questionaire when passed NULL            
Created By    : P.V.P.MOhan              
Created Date  : 30-Oct-2012              
------------------------------------------------------------------------------              
Log History   :               
DD-MM-YYYY		BY				DESCRIPTION              
24-July-2013	GouriShankar	Modified logic for new CodeSetDrug Structure
USAGE		  : [usp_QuestionaireRecommendation_Select] 64 ,4
------------------------------------------------------------------------------              
*/ 
CREATE PROCEDURE [dbo].[usp_QuestionaireRecommendation_Select]
(
    @i_AppUserId                        KEYID
   ,@i_QuestionaireRecommendationId     KEYID = NULL
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
	
	
	SELECT DISTINCT 
	       QR.QuestionaireRecommendationId
	      ,QR.QuestionaireId
	      ,RE.RecommendationName
	      ,QR.RecommendationId
	      ,QR.StopMedication
	      ,CASE 
	            WHEN QR.StopMedication = 0 THEN 'No'
	            ELSE 'Yes'
	       END  AS StopMedicationText
	      ,(
	           SELECT CASE 
	                       WHEN COUNT(MQ.DrugCodeId) > 0 THEN 'View Medication' + ' [' + CAST(COUNT(MQ.DrugCodeId) AS VARCHAR)
	                            + ']'
	                       ELSE                  'NA'
	                  END
	           FROM   MedicationQuestionaire     MQ
	           WHERE  QuestionaireRecommendationId = QR.QuestionaireRecommendationId
	       )    AS MedicationDetails
	      ,QR.DaysToNextQuestionnaire
	      ,(
	           SELECT QuestionaireName
	           FROM   Questionaire
	           WHERE  QuestionaireId = QR.QuestionaireId
	       )    AS QuestionaireName
	      ,QR.NextQuestionaireId
	      ,(
	           SELECT QuestionaireName
	           FROM   Questionaire
	           WHERE  QuestionaireId = QR.NextQuestionaireId
	       )    AS NextQuestionaireName
	FROM   Recommendation RE WITH(NOLOCK)
	INNER JOIN QuestionaireRecommendation QR WITH(NOLOCK)
	       ON  RE.RecommendationId = QR.RecommendationId
	INNER JOIN Questionaire QU WITH(NOLOCK)
	       ON  QR.QuestionaireId = Qu.QuestionaireId
	LEFT JOIN MedicationQuestionaire MQ WITH(NOLOCK)
	       ON  QR.QuestionaireRecommendationId = MQ.QuestionaireRecommendationId
	WHERE  (
	           QR.QuestionaireRecommendationId = @i_QuestionaireRecommendationId
	       OR  @i_QuestionaireRecommendationId IS NULL
	       )
	GROUP BY
	       QR.QuestionaireRecommendationId
	      ,RE.RecommendationName
	      ,QR.StopMedication
	      ,MQ.DrugCodeId
	      ,QR.DaysToNextQuestionnaire
	      ,QU.QuestionaireName
	      ,QR.QuestionaireId
	      ,QR.RecommendationId
	      ,QR.NextQuestionaireId      
	
	SELECT MQ.MedicationQuestionaireID
	      ,QR.QuestionaireRecommendationId
	      ,CAST(MQ.DrugCodeId AS VARCHAR(20)) + ' - ' + CD.DrugName AS DrugCodeTradeValue
	      ,ISNULL(CD.DrugCode ,'') 
	       + ' - ' + ISNULL(CD.Drugname ,'') 
	       + ' - ' + ISNULL(CD.Unit ,'') 
	       + ' - ' + CASE 
	                      WHEN CD.Strength IS NULL THEN ''
	                      ELSE CD.Strength
	                 END               AS DrugCodeName
	      ,CD.DrugName
	      ,MQ.RecommendationNumber     AS NoOfTimes
	      ,MQ.RecommendationFrequency  AS NoOfTimesPer
	      ,CAST(MQ.RecommendationNumber AS VARCHAR(20)) 
	       + ' times per ' + CASE 
	                              WHEN MQ.RecommendationFrequency = 'M' THEN 'month'
	                              WHEN MQ.RecommendationFrequency = 'W' THEN 'week'
	                              WHEN MQ.RecommendationFrequency = 'D' THEN 'day'
	                              WHEN MQ.RecommendationFrequency = 'Y' THEN 'year'
	                         END       AS NoOfTimesPerText
	      ,MQ.DurationNumber
	      ,MQ.DurationFrequency        AS DurationPer
	      ,CAST(MQ.DurationNumber AS VARCHAR(20)) 
	       + '' + ' ' + CASE 
	                         WHEN MQ.DurationFrequency = 'M' THEN 'month(s)'
	                         WHEN MQ.DurationFrequency = 'W' THEN 'week(s)'
	                         WHEN MQ.DurationFrequency = 'D' THEN 'day(s)'
	                         WHEN MQ.DurationFrequency = 'Y' THEN 'year(s)'
	                    END            AS DurationText
	FROM   MedicationQuestionaire MQ WITH(NOLOCK)
	INNER JOIN QuestionaireRecommendation QR WITH(NOLOCK)
	       ON  MQ.QuestionaireRecommendationId = QR.QuestionaireRecommendationId
	INNER JOIN vw_CodeSetDrug CD WITH(NOLOCK)
	       ON  MQ.DrugCodeId = CD.DrugCodeId
	WHERE  QR.QuestionaireRecommendationId = @i_QuestionaireRecommendationId
	AND    MQ.DrugCodeId IS NOT           NULL
END TRY              

BEGIN CATCH
	-- Handle exception              
	DECLARE @i_ReturnedErrorID INT 
	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId 
	
	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_QuestionaireRecommendation_Select] TO [FE_rohit.r-ext]
    AS [dbo];

