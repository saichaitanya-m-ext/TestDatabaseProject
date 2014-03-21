/*      
------------------------------------------------------------------------------      
Procedure Name: [usp_MeasureSynonyms_Select]
Description   : This procedure is used to select the data from  MeasureSynonyms table
Created By    : Rathnam
Created Date  : 25-Aug-2011
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
      
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_MeasureSynonyms_Select]   
	(    
		 @i_AppUserId KEYID ,  
		 @i_SynonymMasterMeasureID KEYID 
		 
	)    
AS    
BEGIN TRY  
  
	 SET NOCOUNT ON    
	     
	 -- Check if valid Application User ID is passed      
	 IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )    
	 BEGIN    
		 RAISERROR   
		 ( N'Invalid Application User ID %d passed.' ,    
		   17 ,    
		   1 ,    
		   @i_AppUserId  
		 )    
	 END 
	 SELECT 
		 ms.SynonymMasterMeasureID,
		 ms.SynonymMeasureID,
		 (SELECT 
			  m.Name 
		  FROM 
			  Measure m
		  WHERE m.MeasureID = ms.SynonymMeasureID
		 ) AS MeasureName,
		 ms.CreatedDate
	 FROM 
		MeasureSynonyms ms WITH (NOLOCK) 
	INNER JOIN Measure m WITH (NOLOCK) 
		ON m.MeasureId = ms.SynonymMeasureID
	 WHERE 
		ms.SynonymMasterMeasureID = @i_SynonymMasterMeasureID
	 AND m.StatusCode = 'A'
	
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
    ON OBJECT::[dbo].[usp_MeasureSynonyms_Select] TO [FE_rohit.r-ext]
    AS [dbo];

