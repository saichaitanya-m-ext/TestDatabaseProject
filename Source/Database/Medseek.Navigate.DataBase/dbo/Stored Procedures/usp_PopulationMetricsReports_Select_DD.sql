/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_PopulationMetricsReports_Select_DD]  23
Description   : This procedure is used to get the list of all Metric related reports
Created By    : Siva krishna
Created Date  : 28-Sep-2012 
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_PopulationMetricsReports_Select_DD] --23
(
 @i_AppUserId INT
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


				SELECT DISTINCT
				  ReportId,
				  AliasName AS ReportName,
				  Ismetric
				FROM
				  Report 
				WHERE StatusCode = 'A'

				
					

END TRY  
----------------------------------------------------------   
BEGIN CATCH  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationMetricsReports_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

