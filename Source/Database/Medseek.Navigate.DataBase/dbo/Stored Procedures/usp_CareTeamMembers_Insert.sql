/*          
------------------------------------------------------------------------------          
Procedure Name: usp_CareTeamMembers_Insert          
Description   : This procedure is used to insert record into CareTeamMembers table      
Created By    : Aditya          
Created Date  : 15-Mar-2010          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
27-Sep-2010 NagaBabu Added @l_numberOfRecordsInserted condition for Error message
12-Oct-10 Pramod Removed the duplicate check condition
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_CareTeamMembers_Insert]
(
 @i_AppUserId KEYID
,@i_UserId KEYID
,@i_CareTeamId KEYID
,@i_IsCareTeamManager KEYID
,@vc_StatusCode STATUSCODE
)
AS
BEGIN TRY
      SET NOCOUNT ON
      DECLARE @l_numberOfRecordsInserted INT        
 -- Check if valid Application User ID is passed          
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END       

------------------insert operation into CareTeamMembers table-----        

               INSERT INTO
                   CareTeamMembers
                   (
                     ProviderID
                   ,StatusCode
                   ,CareTeamId
                   ,IsCareTeamManager
                   ,CreatedByUserId
                   )
               VALUES
                   (
                     @i_UserId
                   ,@vc_StatusCode
                   ,@i_CareTeamId
                   ,@i_IsCareTeamManager
                   ,@i_AppUserId
                   )

               SET @l_numberOfRecordsInserted = @@ROWCOUNT
               IF @l_numberOfRecordsInserted <> 1
                  BEGIN
                        RAISERROR ( N'Invalid row count %d in Insert CareTeamMembers'
                        ,17
                        ,1
                        ,@l_numberOfRecordsInserted )
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
    ON OBJECT::[dbo].[usp_CareTeamMembers_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

