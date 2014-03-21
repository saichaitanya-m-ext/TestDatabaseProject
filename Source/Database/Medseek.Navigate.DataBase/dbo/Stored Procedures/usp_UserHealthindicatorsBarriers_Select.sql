/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserHealthindicatorsBarriers_Select
Description   : This procedure is used to fetch HealthindicatorsBarriers for a particular patient
Created By    : Rathnam    
Created Date  : 27-Sep-2011    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION   
20-Mar-2013 P.V.P.Mohan modified UserHealthindicatorsBarriers to PatientHealthindicatorsBarriers
			and modified columns.
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_UserHealthindicatorsBarriers_Select]
(
 @i_AppUserId KEYID
,@i_PatientUserId KEYID
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
	

            SELECT
                uhib.PatientID UserId
               ,uhib.HealthIndicatorsAndBarriersId
               ,hib.Type
            FROM
                PatientHealthindicatorsBarriers uhib WITH(NOLOCK)
            INNER JOIN HealthIndicatorsAndBarriers hib WITH(NOLOCK)
				ON uhib.HealthIndicatorsAndBarriersId = hib.HealthIndicatorsAndBarriersId    
            WHERE
                uhib.PatientID = @i_PatientUserId
            AND uhib.StatusCode = 'A'    
            AND hib.StatusCode = 'A'

            
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
    ON OBJECT::[dbo].[usp_UserHealthindicatorsBarriers_Select] TO [FE_rohit.r-ext]
    AS [dbo];

