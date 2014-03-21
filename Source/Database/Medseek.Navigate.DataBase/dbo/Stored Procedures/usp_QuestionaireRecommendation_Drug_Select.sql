/*    
------------------------------------------------------------------------------    
Procedure Name: usp_QuestionaireRecommendation_Drug_Select   
Description   : This procedure is used to get the list of all DrugName details  
    for a particular DrugCodeId or get complete list when passed NULL  
Created By    : P.V.P.MOhan    
Created Date  : 08-Nov-2012    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    

------------------------------------------------------------------------------    
*/ 
CREATE PROCEDURE [dbo].[usp_QuestionaireRecommendation_Drug_Select]  
(  
	@i_AppUserId KeyID,  
	@i_DrugCodeId KeyID = NULL

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
  
			SELECT 
					DrugName
			FROM CodeSetDrug

  WHERE ( DrugCodeId = @i_DrugCodeId 
          OR @i_DrugCodeId IS NULL  
         )  

  
END TRY    
--------------------------------------------------------     
BEGIN CATCH    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException   
     @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_QuestionaireRecommendation_Drug_Select] TO [FE_rohit.r-ext]
    AS [dbo];

