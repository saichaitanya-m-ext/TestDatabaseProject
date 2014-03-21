/*  
-----------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_PQRIProviderUserEncounter_Update]
Description   : This procedure is used to update the TransactionStatus into PQRIProviderUserEncounter 
                and update the isallowedit column in PQRIProviderPersonalization, PQRIQualityMeasure,PQRIQualityMeasureGroup
Created By    : Rathnam  
Created Date  : 20-Jan-2011
------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
15-Feb-2011 Rathnam Removed the update statements PQRIProviderPersonalization, PQRIQualityMeasure,PQRIQualityMeasureGroup
------------------------------------------------------------------------------------------------  
*/

CREATE PROCEDURE [dbo].[usp_PQRIProviderUserEncounter_Update]
       (
        @i_AppUserId KEYID
       ,@i_PQRIProviderUserEncounterID KEYID
       ,@v_TransactionStatus VARCHAR(10)
       )
AS
BEGIN TRY

      SET NOCOUNT ON   
 -- Check if valid Application User ID is passed  
      DECLARE @i_numberOfRecordsUpdated INT
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )

         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END  
      
       UPDATE
           PQRIProviderUserEncounter
       SET
           TransactionStatus = @v_TransactionStatus
          ,LastModifiedByUserId = @i_AppUserId
          ,LastModifiedDate = GETDATE()
       WHERE
           PQRIProviderUserEncounterID = @i_PQRIProviderUserEncounterID
       
       SET @i_numberOfRecordsUpdated = @@ROWCOUNT
			
	   IF @i_numberOfRecordsUpdated <> 1 
			RAISERROR
			(	 N'Update of PQRIProviderUserEncounter table experienced invalid row count of %d'
				,17
				,1
				,@i_numberOfRecordsUpdated         
			)       
       
       RETURN 0
END TRY   
------------ Exception Handling --------------------------------  
BEGIN CATCH
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PQRIProviderUserEncounter_Update] TO [FE_rohit.r-ext]
    AS [dbo];

