/*          
------------------------------------------------------------------------------          
Procedure Name: [usp_Reports_StandardQualityMeasure_DD]  
Description   : This procedure is used to get the drop downs for All types
Created By    : Rathnam          
Created Date  : 09-Dec-2011          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_Reports_StandardQualityMeasure_DD]
(
 @i_AppUserId KEYID ,
 @i_StandardID KEYID = NULL ,
 @i_DiseaseID KEYID = NULL ,
 @t_HealthCareQualityMeasureID TTYPEKEYID READONLY
)
AS
BEGIN
      BEGIN TRY
            SET NOCOUNT ON           
	-- Check if valid Application User ID is passed          
            IF ( @i_AppUserId IS NULL )
            OR ( @i_AppUserId <= 0 )
               BEGIN
                     RAISERROR ( N'Invalid Application User ID %d passed.' ,
                     17 ,
                     1 ,
                     @i_AppUserId )
               END    
	-------------------------------------------------------------------------------------------------------------------

            SELECT
                HealthCareQualityStandardID ,
                HealthCareQualityStandardName
            FROM
                HealthCareQualityStandard
            WHERE
                HealthCareQualityStandardName = 'Cadillac Measure'

            IF @i_StandardID IS NOT NULL
               BEGIN
                     SELECT DISTINCT
                         d.DiseaseId ,
                         d.Name
                     FROM
                         HealthCareQualityMeasure hcqm
                     INNER JOIN Disease d
                         ON hcqm.DiseaseID = d.DiseaseId
                     WHERE
                         hcqm.HealthCareQualityStandardId = @i_StandardID

                     IF @i_DiseaseID IS NOT NULL
                        BEGIN
                              SELECT DISTINCT
                                  HealthCareQualityMeasureID ,
                                  HealthCareQualityMeasureName
                              FROM
                                  HealthCareQualityMeasure hcqm
                              WHERE
                                  hcqm.DiseaseID = @i_DiseaseID
                                  AND hcqM.HealthCareQualityStandardId = @i_StandardID
                        END
               END

            IF EXISTS ( SELECT
                            1
                        FROM
                            @t_HealthCareQualityMeasureID )
               BEGIN
                     SELECT DISTINCT
                         hcqmdu.ProviderUserID ,
                         DBO.ufn_GetUserNameByID(hcqmdu.ProviderUserID) ProviderName
                     FROM
                         HealthCareQualityMeasureDenominatorUser hcqmdu
                     INNER JOIN @t_HealthCareQualityMeasureID hcqm
                         ON hcqm.tKeyId = hcqmdu.HealthCareQualityMeasureID
               END
      END TRY
------------------------------------------------------------------------------------------------------------------------- 
      BEGIN CATCH        
    -- Handle exception        
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

            RETURN @i_ReturnedErrorID
      END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Reports_StandardQualityMeasure_DD] TO [FE_rohit.r-ext]
    AS [dbo];

