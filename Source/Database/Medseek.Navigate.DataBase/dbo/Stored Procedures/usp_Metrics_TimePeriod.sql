
/*  
---------------------------------------------------------------------------------------  
Procedure Name: [usp_Metrics_TimePeriod]
Description   : This Procedure used to get the Diseases mapped to PopulationDefinition  
Created By    : P.V.P.MOhan
Created Date  : 26-Nov-2012
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
---------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Metrics_TimePeriod]
(
 @i_AppUserId INT

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
-------------------------------------------------------- 

               BEGIN
                     SELECT
                         MetricsTimePeriodId
                        ,Name

                     FROM
                     
                     MetricsTimePeriod
                     
                     WHERE MetricsTimePeriod.StatusCode = 'A'
        END
      END TRY  
--------------------------------------------------------   
      BEGIN CATCH  
    -- Handle exception  
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

            RETURN @i_ReturnedErrorID
      END CATCH
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Metrics_TimePeriod] TO [FE_rohit.r-ext]
    AS [dbo];

