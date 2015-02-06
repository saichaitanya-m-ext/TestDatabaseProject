/*    
---------------------------------------------------------------------------------------    
Procedure Name: usp_MetricnumeratorFrequency_Delete  
Description   : This procedure is used to delete Numerator frequency information
Created By    : Rathnam
Created Date  : 11-Dec-2012
---------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    

---------------------------------------------------------------------------------------    
*/ 

CREATE PROCEDURE [dbo].[usp_MetricnumeratorFrequency_Delete] 
(
 @i_AppUserId KEYID
,@i_MetricnumeratorFrequencyId KEYID 
)
AS
BEGIN TRY
      SET NOCOUNT ON
   
 -- Check if valid Application User ID is passed    
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END

      DELETE FROM MetricnumeratorFrequency  WHERE MetricNumeratorFrequencyId = @i_MetricnumeratorFrequencyId

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
    ON OBJECT::[dbo].[usp_MetricnumeratorFrequency_Delete] TO [FE_rohit.r-ext]
    AS [dbo];

