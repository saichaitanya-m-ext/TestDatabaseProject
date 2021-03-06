﻿/*        
------------------------------------------------------------------------------        
Procedure Name: usp_patientACGConditions_Select
Description   : This procedure is used to get data from patientACGConditions Table  
Created By    : NagaBabu
Created Date  : 20-Jan-2011
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION 
16-Feb-2011 Rathnam removed the set condition for  getting @i_ACGResultsID  value
                    AND kept userdefined datatype userdate instead of using DATETIME 
16-Feb-2011 NagaBabu Added Alias names to the tables 
14-Mar-2011 NagaBabu Deleted @i_PatientID,@dt_DateDetermined perameters And Added @i_ACGResultsID Perameter                                
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_ACGpatientConditions_Select]
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

----------- Select patientACGConditions details -------------------  

      SELECT
          ACGC.ACGConditionName AS 'Condition'
         ,ACGPC.ConditionCode AS 'Indication'
         ,ACGPC.Rxgaps AS 'Rx Gaps'
         ,ACGPC.MPR AS 'Rx Possession Ratio'
         ,ACGPC.CSA AS 'Continuous Rx Possession Ratio'
         ,URX.UntreatedRxCodeText AS 'Treated'
      FROM
          ACGConditions ACGC
      INNER JOIN ACGpatientConditions ACGPC WITH (NOLOCK)
          ON ACGC.ACGConditionsID = ACGPC.ACGConditionsID
      INNER JOIN ACGPatientResults ACGPR WITH (NOLOCK)
          ON ACGPC.ACGResultsID = ACGPR.ACGResultsID
      INNER JOIN UntreatedRx URX WITH (NOLOCK)
          ON URX.UntreatedRxCode = ACGPC.UntreatedRx
      WHERE
          ACGPR.ACGResultsID = @i_ACGResultsID
END TRY        
------------------------------------------------------------------------------------------------------   
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ACGpatientConditions_Select] TO [FE_rohit.r-ext]
    AS [dbo];

