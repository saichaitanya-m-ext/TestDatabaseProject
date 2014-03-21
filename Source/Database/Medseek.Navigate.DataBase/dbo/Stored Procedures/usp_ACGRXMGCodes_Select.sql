/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_ACGRXMGCodes_Select]
Description   : This procedure is used to get data from ACGRXMGCodes Table  
Created By    : NagaBabu
Created Date  : 19-Jan-2011
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION    
16-Feb-2011 Rathnam removed the set condition for  getting @i_ACGResultsID  value
                    AND kept userdefined datatype userdate instead of using DATETIME 
16-Feb-2011 NagaBabu Added alias names to the table  
14-Mar-2011 NagaBabu Deleted @i_PatientID,@dt_DateDetermined perameters And Added @i_ACGResultsID Perameter                      
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_ACGRXMGCodes_Select]
       (
        @i_AppUserId KEYID
       ,@i_ACGResultsID KEYID
       )
AS
BEGIN TRY
      SET NOCOUNT ON         
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END

----------- Select RXMGCodes details --------------------------------------  

      SELECT
          RXMGC.RXMGCodeID
         ,RXMGC.RXMGCode
         ,RXMGC.RXMGDescription
      FROM
          ACGRXMGCodes RXMGC WITH (NOLOCK)
      INNER JOIN ACGPatientRXMGCodes PRXMG WITH (NOLOCK)
          ON RXMGC.RXMGCodeID = PRXMG.RXMGCodeID
      INNER JOIN ACGPatientResults ACGPR WITH (NOLOCK)
          ON PRXMG.ACGResultsID = ACGPR.ACGResultsID
      WHERE
          ACGPR.ACGResultsID = @i_ACGResultsID
END TRY        
-------------------------------------------------------------------------------   
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ACGRXMGCodes_Select] TO [FE_rohit.r-ext]
    AS [dbo];

