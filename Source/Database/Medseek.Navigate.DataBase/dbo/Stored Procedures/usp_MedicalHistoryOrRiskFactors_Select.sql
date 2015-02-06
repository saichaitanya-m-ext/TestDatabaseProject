


/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_MedicalHistoryOrRiskFactors_Select]2  
Description   : This procedure is used to select all the MedicalHistoryOrRiskFactors records.  
Created By    : Rathnam  
Created Date  : 07-07-2011  
----------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
12-07-2011 Gurumoorthy.V Added Distinct   
----------------------------------------------------------------------------------  
*/  
  
CREATE PROCEDURE [dbo].[usp_MedicalHistoryOrRiskFactors_Select]  
(   
 @i_AppUserId KEYID  
)  
AS  
BEGIN TRY   
  
 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.' ,  
               17 ,  
               1 ,  
               @i_AppUserId )  
         END  
---------------- All the PreviousExaminationLabFindings records are retrieved --------  
 --Medical History  
   
   SELECT Distinct  
          MedicalConditionID,  
          Disease.Name + ' ('+ISNULL(Condition,'')+')' AS Condition  
   FROM  
          MedicalCondition   WITH(NOLOCK)
      INNER JOIN Disease   WITH(NOLOCK)
          ON Disease.DiseaseId = MedicalCondition.DiseaseId      
      WHERE  
          MedicalCondition.StatusCode = 'A'  
      AND Disease.StatusCode = 'A'      
      ORDER BY  
          Condition  
            
        --Obstetrical History  
        
      SELECT Distinct  
    ObstetricalConditionsID,  
          ObstetricalName  
      FROM   
          ObstetricalConditions   
      WHERE StatusCode = 'A'  
            
      ORDER BY  
          ObstetricalName         
        
        --Previous Examination  
        
      SELECT Distinct  
          LabOrPhysicalExaminationID,  
    Name  
      FROM  
          LabOrPhysicalExamination  
      WHERE  
          StatusCode = 'A'  
      ORDER BY  
          Name  
        
        --Family History   
     SELECT  Distinct  
        ConditionID  DiseaseId,  
		ConditionName Name   
     FROM   
         Condition  
     WHERE StatusCode = 'A'  
     ORDER BY Name      
            
     SELECT   
	  SubstanceAbuseId,  
	  Name  
  FROM SubstanceAbuse  
	WHERE StatusCode  = 'A'   
  ORDER BY Name  
          
END TRY  
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH  
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_MedicalHistoryOrRiskFactors_Select] TO [FE_rohit.r-ext]
    AS [dbo];

