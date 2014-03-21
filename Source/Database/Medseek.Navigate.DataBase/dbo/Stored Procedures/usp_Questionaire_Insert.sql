/*  
-------------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Questionaire_Insert]  
Description   : This procedure is used to insert records into Questionaire table.   
Created By    : Balla Kalyan   
Created Date  : 15-Mar-2010  
-------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
29-June-2010 NagaBabu Deleted ProgramID perameter  
28-Sep-2011	Gurumoorthy.V Added @i_MaxScore parameter,and included in insert statement
-------------------------------------------------------------------------------------------------  
*/  
  
CREATE PROCEDURE [dbo].[usp_Questionaire_Insert]  
(  
 @i_AppUserId KEYID ,  
 @vc_QuestionaireName SHORTDESCRIPTION ,  
 @vc_Description LONGDESCRIPTION ,  
 @i_QuestionaireTypeId KEYID ,  
 @i_DiseaseID KEYID ,  
 --@i_ProgramID KEYID = NULL,  
 @vc_StatusCode STATUSCODE , 
 @i_MaxScore INT,
 @i_QuestionaireId INT OUTPUT  
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
  
------------------insert operation into Questionaire table-----   
     
  
               INSERT INTO  
                   Questionaire  
                   (  
                     QuestionaireName ,  
                     Description ,  
                     QuestionaireTypeId ,  
                     DiseaseID ,  
                     --ProgramId ,  
                     CreatedByUserId ,  
                     StatusCode,
                     MaxScore
                    )  
               VALUES  
                   (  
                     @vc_QuestionaireName ,  
                     @vc_Description ,  
                     @i_QuestionaireTypeId ,  
                     @i_DiseaseID ,  
                     --@i_ProgramID ,  
                     @i_AppUserId,  
                     @vc_StatusCode,
                     @i_MaxScore
                    )  
               SET @i_QuestionaireId = SCOPE_IDENTITY()  
  
               RETURN 0  
  
           
END TRY  
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Questionaire_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

