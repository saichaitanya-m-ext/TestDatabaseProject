

/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_Questionaire_SelectByProviderID_DD]
Description   : This Procedure is used to get the dashboard questionairesList by ProviderID
Created By    : sivakrishna
Created Date  : 10-Oct-2011
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  


------------------------------------------------------------------------------  
*/
--[usp_QuestionaireAnalytics_DashBoard] 64

CREATE PROCEDURE [dbo].[usp_QuestionaireAnalytics_DashBoard]
(
 @i_AppUserId KEYID,
 @i_ProviderUserID KEYID = NULL
)
AS
BEGIN TRY
    SET NOCOUNT ON   
-- Check if valid Application User ID is passed

    IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
       BEGIN
             RAISERROR ( N'Invalid Application User ID %d passed.'
             ,17
             ,1
             ,@i_AppUserId )
       END

	IF @i_ProviderUserID IS NULL
		BEGIN
			SELECT 
				q.QuestionaireId
			   ----,'(' + CAST(COUNT(DISTINCT UserId)AS VARCHAR) + ')' + ' ' + q.QuestionaireName AS QuestionaireName 
			   ,q.QuestionaireName AS QuestionaireName 
			   ,COUNT(DISTINCT PatientId) AS UserCount
			FROM Questionaire q
			INNER JOIN PatientQuestionaire with (nolock) 
				ON Q.QuestionaireId = PatientQuestionaire.QuestionaireId
			WHERE q.StatusCode = 'A'
			GROUP BY q.QuestionaireId,q.QuestionaireName
			ORDER BY COUNT(DISTINCT PatientId) DESC
		END
    ELSE IF @i_ProviderUserID IS NOT NULL		
		BEGIN
			SELECT DISTINCT
				q.QuestionaireId
			   --,'(' + CAST(COUNT(DISTINCT uqr.UserId)AS VARCHAR) + ')' + ' ' + q.QuestionaireName AS QuestionaireName 
			   ,q.QuestionaireName AS QuestionaireName 
			   ,COUNT(DISTINCT uqr.PatientId) AS UserCount
			FROM
				CareTeamMembers ctm WITH(NOLOCK)
			INNER JOIN CareTeam cm  WITH(NOLOCK)
				ON ctm.CareTeamId = cm.CareTeamId
				   AND cm.StatusCode = 'A'
				   AND ctm.StatusCode = 'A'
			INNER JOIN PatientCareTeam p  WITH(NOLOCK)
				ON p.CareTeamId = cm.CareTeamId
				   AND p.StatusCode = 'A'
			INNER JOIN PatientQuestionaire uqr WITH(NOLOCK)
				ON uqr.PatientId = p.PatientID
			INNER JOIN Questionaire q WITH(NOLOCK)
				ON q.QuestionaireId = uqr.QuestionaireId
			   AND q.StatusCode = 'A'  
			WHERE
				ctm.ProviderID = @i_ProviderUserID
			GROUP BY q.QuestionaireId,q.QuestionaireName
			
        END
        
        DECLARE 
			@d_FromDate datetime,
			@d_ToDate datetime,
			@i_QuestionaireID KEYID
		
		
		SET @d_FromDate =  CAST(DATEADD(YY,-1,GETDATE()) AS DATE)
		SET @d_ToDate =  CAST(GETDATE() AS DATE)
		
		SELECT 
			TOP 1 @i_QuestionaireID = qr.QuestionaireId 
		FROM 
			Questionaire qr
		INNER JOIN PatientQuestionaire uqr
		   ON qr.QuestionaireId = uqr.QuestionaireId
		GROUP BY qr.QuestionaireId 
		ORDER BY COUNT(PatientId) DESC
   
	CREATE TABLE #tblPatientQuestionaireAnswers
     (
        UserQuestionaireId INT
       ,UserId INT
       ,QuestionaireId INT
       ,QuestionSetId INT
       ,QuestionId INT
       ,Description VARCHAR(500)
       ,AnswerID INT
       ,AnswerDescription VARCHAR(100)
       ,DueDate DATETIME
       ,DateTaken DATETIME
     )

	  
			INSERT INTO 
				  #tblPatientQuestionaireAnswers
				  SELECT 
					  uqre.PatientQuestionaireId UserQuestionaireId
					 ,uqre.PatientId UserId
					 ,qre.QuestionaireId
					 ,qsq.QuestionSetId
					 ,q.QuestionId
					 ,q.QuestionText
					 ,a.AnswerID
					 ,ISNULL(a.AnswerDescription,a.AnswerString) as AnswerDescription
					 ,uqre.DateDue
					 ,uqre.DateTaken
				  FROM
					  Questionaire qre
				  INNER JOIN PatientQuestionaire uqre
					  ON qre.QuestionaireId = uqre.QuestionaireId
						 AND qre.StatusCode = 'A'
						 AND uqre.StatusCode = 'C'
				  INNER JOIN UserQuestionaireAnswers uqa
					  ON uqre.PatientQuestionaireId = uqa.UserQuestionaireID
				  INNER JOIN QuestionSetQuestion qsq
					  ON uqa.QuestionSetQuestionId = qsq.QuestionSetQuestionId
				  INNER JOIN Question q
					  ON q.QuestionId = qsq.QuestionId
						 AND q.StatusCode = 'A'
				  INNER JOIN Answer a
					  ON a.AnswerId = uqa.AnswerID
						 AND a.StatusCode = 'A'
				  WHERE qre.QuestionaireId = @i_QuestionaireID
				    AND  ( ( ( CAST(uqre.DateTaken AS DATE) BETWEEN @d_FromDate
								AND @d_ToDate )
							  AND ( @d_FromDate IS NOT NULL
									AND @d_ToDate IS NOT NULL
								  )
							)
							OR ( @d_FromDate IS NULL
								 AND @d_ToDate IS NULL
							   )
						  )		
				   
		            
         DECLARE @i_QuestionaireAttempts INT = (SELECT COUNT(UserId)
											 FROM #tblPatientQuestionaireAnswers) ,
			  @i_NoofPatients INT = (SELECT
										 COUNT(DISTINCT UserId)
									 FROM
										 #tblPatientQuestionaireAnswers) 							 
      
      DECLARE @t_QuestionDetails TABLE 
      (
		  QuestionId KeyId ,
		  NoOfQuesPatients INT ,
		  QuesPercentage DECIMAL(10,2)
	  )	   
      
  
	  INSERT INTO @t_QuestionDetails	
      (
		  QuestionId ,
		  NoOfQuesPatients ,
		  QuesPercentage
	  )	  
      SELECT
		  QuestionId ,
		  COUNT(Distinct UserId) AS NoOfQuesPatients ,
		  CONVERT(DECIMAL(10,2),COUNT(Distinct Userid) * 100) / (SELECT
															COUNT(UserId) 
														FROM 
															#tblPatientQuestionaireAnswers
													   )
	  FROM
		  #tblPatientQuestionaireAnswers
	  GROUP BY QuestionId	  											   	
      
      
      CREATE TABLE #QuestionaireReport
      (
		ID INT IDENTITY(1,1),
		QuestionId INT ,
		[Description] VARCHAR(500) ,
		AnswerID INT ,
		AnswerDescription VARCHAR(100) ,
        NoOfPatients INT ,
        Percentage DECIMAL(10,2) ,
        NoOfQuesPatients INT ,
        QuesPercentage DECIMAL(10,2) ,
        AnswerAttempts INT
	  )
    
      INSERT INTO #QuestionaireReport
      (
		QuestionId  ,
		[Description] ,
		AnswerID  ,
		AnswerDescription  ,
        NoOfPatients  ,
        Percentage  ,
        NoOfQuesPatients ,
        QuesPercentage ,
        AnswerAttempts 
      )
      SELECT 
          TPQA.QuestionId
         ,TPQA.Description
         ,ISNULL(TPQA.AnswerID,0) AS AnswerID
         ,TPQA.AnswerDescription AS AnswerDescription 
         --,COUNT( TPQA.UserId) AS NoOfPatients 
         ,COUNT(DISTINCT TPQA.UserId) AS NoOfPatients   
         ,CONVERT(DECIMAL(10,2) , ( COUNT(*) * 100.00 ) / @i_QuestionaireAttempts) AS Percentage 
         ,QD.NoOfQuesPatients 
         ,QD.QuesPercentage 
         ,COUNT( TPQA.UserId) AS AnswerAttempts                                                  
      FROM
          #tblPatientQuestionaireAnswers TPQA
      INNER JOIN @t_QuestionDetails QD
		  ON TPQA.QuestionId = QD.QuestionId 
	  GROUP BY
            TPQA.QuestionId
           ,TPQA.Description
           ,TPQA.AnswerID
           ,TPQA.AnswerDescription
           ,QD.NoOfQuesPatients 
           ,QD.QuesPercentage 
      
      
      INSERT INTO #QuestionaireReport
      (
		QuestionId  ,
		[Description] ,
		AnswerID  ,
		AnswerDescription  ,
        NoOfPatients  ,
        Percentage  ,
        NoOfQuesPatients ,
        QuesPercentage ,
        AnswerAttempts
      )
      SELECT 
          TPQA.QuestionId
         ,TPQA.Description
         --,ISNULL(TPQA.AnswerID,0) AS AnswerID
         ,0 AS AnswerID
         ,'Not Answered' AS AnswerDescription 
         --,COUNT(DISTINCT TPQA.UserId) AS NoOfPatients
         ,@i_NoofPatients AS NoOfPatients
         ,CONVERT(DECIMAL(10,2) , ( (@i_QuestionaireAttempts - COUNT( TPQA.UserId))  * 100.00 ) / @i_QuestionaireAttempts) AS Percentage  
         ,QD.NoOfQuesPatients 
         ,QD.QuesPercentage   
         ,@i_QuestionaireAttempts - COUNT( TPQA.UserId) AS AnswerAttempts                                           
      FROM
          #tblPatientQuestionaireAnswers TPQA
      INNER JOIN @t_QuestionDetails QD
		  ON TPQA.QuestionId = QD.QuestionId 
	  GROUP BY
            TPQA.QuestionId
           ,TPQA.Description
           --,TPQA.AnswerID
           --,TPQA.AnswerDescription
           ,QD.NoOfQuesPatients 
           ,QD.QuesPercentage    
	  HAVING COUNT( DISTINCT TPQA.UserId) < @i_QuestionaireAttempts
	  
	  SELECT 
		    QR.QuestionId  ,
			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([Description],'/i',''),'/b',''),'&',''),'gt;','>'),'lt;',''),'i>',''),'b>',''),'>',''),':','') AS [Description],
			AnswerID  ,
			AnswerDescription  ,
			NoOfPatients  ,
			Percentage  ,
			NoOfQuesPatients ,
			QuesPercentage ,
			AnswerAttempts ,
			QA.QuestionAttempts 
	  FROM #QuestionaireReport QR
	  INNER JOIN (SELECT COUNT(TPQA.QuestionId) AS QuestionAttempts ,
						 TPQA.QuestionId
				  FROM
					  #tblPatientQuestionaireAnswers TPQA
				  INNER JOIN @t_QuestionDetails QD
					  ON TPQA.QuestionId = QD.QuestionId 
				  GROUP BY
						TPQA.QuestionId ) AS QA
		  ON QA.QuestionId = QR.QuestionId 	
	  WHERE AnswerAttempts <> 0	  				
	  ORDER BY QuestionId,AnswerID DESC		
          	
		 SELECT TOP 1
			 QuestionaireId ,
			 COUNT(DISTINCT UserId) AS PatientCount  ,
			 COUNT(UserId) AS QuestionaireUserCount ,
			 CAST(COUNT(UserId)*1.00/COUNT(DISTINCT UserId) AS DECIMAL(10,2)) AS Average
		 FROM
			 #tblPatientQuestionaireAnswers 
	     
		 GROUP BY QuestionaireId
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
    ON OBJECT::[dbo].[usp_QuestionaireAnalytics_DashBoard] TO [FE_rohit.r-ext]
    AS [dbo];

