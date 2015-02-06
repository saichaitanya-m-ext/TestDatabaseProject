/*      
------------------------------------------------------------------------------      
Procedure Name: usp_PopulationDefinitionCriteria_Delete      
Description   : This procedure is used to Delete record from CohortListCriteria table  
Created By    : NagaBabu      
Created Date  : 27-May-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
14-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added PopulationDefinitionID in 
            the place of CohortListID     
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_PopulationDefinitionCriteria_Delete]
(
 @i_AppUserId KEYID ,
 @i_PopulationDefinitionID KEYID
)
AS
BEGIN TRY

      SET NOCOUNT ON
      DECLARE @l_numberOfRecordsDeleted INT     
 -- Check if valid Application User ID is passed      
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END
------------DELETE OPERATION -----------------

      DELETE  FROM
              PopulationDefinitionCriteria
      WHERE
              PopulationDefinitionID = @i_PopulationDefinitionID


      
	SELECT
          @l_numberOfRecordsDeleted = @@ROWCOUNT

      IF @l_numberOfRecordsDeleted <> 1
         BEGIN
               RAISERROR ( N'Invalid Row count %d passed to CohortListCriteria' ,
               17 ,
               1 ,
               @l_numberOfRecordsDeleted )
         END

      RETURN 0
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
    ON OBJECT::[dbo].[usp_PopulationDefinitionCriteria_Delete] TO [FE_rohit.r-ext]
    AS [dbo];

