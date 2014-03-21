/*      
------------------------------------------------------------------------------      
Procedure Name: [usp_MeasureSynonyms_Update]
Description   : This procedure is used to update the data into  MeasureSynonyms table
Created By    : Rathnam
Created Date  : 23-Aug-2011
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
      
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_MeasureSynonyms_Update]    
	(    
		 @i_AppUserId KEYID ,  
		 @i_SynonymMasterMeasureID KEYID,  
		 @t_SynonymMeasureID ttypeKeyID READONLY 
		 
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
	 DECLARE @l_TranStarted BIT = 0  
                      
    IF(@@TRANCOUNT = 0)  
	 BEGIN  
		BEGIN TRANSACTION  
		SET @l_TranStarted = 1  
	 END  
    ELSE 
	 BEGIN  
		SET @l_TranStarted = 0
     END 
	 
	 UPDATE Measure
	 SET IsSynonym = 0,
		 LastModifiedByUserId = @i_AppUserId,
		 LastModifiedDate = GETDATE()
	 FROM Measure m
	 INNER JOIN MeasureSynonyms mss   
		ON m.MeasureID = mss.SynonymMeasureID
	 WHERE mss.SynonymMasterMeasureID = @i_SynonymMasterMeasureID
	 
	 DELETE FROM MeasureSynonyms WHERE SynonymMasterMeasureID = @i_SynonymMasterMeasureID    
	 
	 INSERT INTO MeasureSynonyms
	 (
		SynonymMasterMeasureID,
		SynonymMeasureID,
		CreatedByUserId,
		CreatedDate
	 )
	 SELECT 
		 @i_SynonymMasterMeasureID,
		 tKeyID,
		 @i_AppUserId,
		 GETDATE()
	 FROM
	     @t_SynonymMeasureID
	 
	 UPDATE Measure
	 SET IsSynonym = 1,
		 LastModifiedByUserId = @i_AppUserId,
		 LastModifiedDate = GETDATE()
	 FROM Measure m
	 INNER JOIN @t_SynonymMeasureID tblSM    
	 ON m.MeasureID = tblSM.tKeyID
    
    
     IF @l_TranStarted = 1  
	   BEGIN  
			SET @l_TranStarted = 0  
			COMMIT TRANSACTION  
	   END  
    ELSE 
       BEGIN 
			ROLLBACK TRANSACTION 
       END				 	
     RETURN 0   
    
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
    ON OBJECT::[dbo].[usp_MeasureSynonyms_Update] TO [FE_rohit.r-ext]
    AS [dbo];

