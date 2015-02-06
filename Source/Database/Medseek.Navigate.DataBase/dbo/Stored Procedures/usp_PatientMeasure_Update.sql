/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_CareProviderDashBoard_CareManagement_Filter] 23
Description   : This procedure is used to get data from Filter Tables
Created By    : Santosh
Created Date  : 25-Jul-2013
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_PatientMeasure_Update]
(
 @i_AppUserId KEYID
)
AS
BEGIN
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

          SELECT 1
      END TRY 
             
-------------------------------------------------------------------------------   
      BEGIN CATCH        
    -- Handle exception        
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

            RETURN @i_ReturnedErrorID
      END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PatientMeasure_Update] TO [FE_rohit.r-ext]
    AS [dbo];

