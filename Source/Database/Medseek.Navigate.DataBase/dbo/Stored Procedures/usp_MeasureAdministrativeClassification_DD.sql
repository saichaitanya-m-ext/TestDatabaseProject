﻿/*  
---------------------------------------------------------------------------------------  
Procedure Name: usp_MeasureAdministrativeClassification_DD 
Description   : This procedure is used to get Classificationnames from MeasureAdministrativeClassification 
Created By    : Rathnam
Created Date  : 03-May-2011
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
---------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_MeasureAdministrativeClassification_DD]
(
	@i_AppUserId KEYID
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
-------------------------------------------------------- 
	SELECT 
	    ClassificationID,
		ClassificationName 
	FROM
	    MeasureAdministrativeClassification 				

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
    ON OBJECT::[dbo].[usp_MeasureAdministrativeClassification_DD] TO [FE_rohit.r-ext]
    AS [dbo];

