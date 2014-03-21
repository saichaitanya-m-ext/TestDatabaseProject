/*        
------------------------------------------------------------------------------        
Procedure Name: usp_UserProblem_Insert        
Description   : This procedure is used to insert record into UserProblem table    
Created By    : NagaBabu      
Created Date  : 19-May-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
20-Mar-2013 P.V.P.Mohan modified UserProblem to PatientProblem
			and modified columns.       
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_UserProblem_Insert]
(
 @i_AppUserId KeyID,
 @i_UserId	KeyID,
 @i_MedicalProblemId	KeyID,
 @vc_Comments	LongDescription,
 @dt_ProblemStartDate	UserDate = null ,
 @dt_ProblemEndDate	UserDate = null,
 @vc_StatusCode	StatusCode,
 @i_MedicalProblemClassificationId KeyID,
 @o_UserProblemId	Keyid OUTPUT,
 @i_DataSourceId KeyId 
)
AS
BEGIN TRY
      SET NOCOUNT ON
      DECLARE @l_numberOfRecordsInserted INT     
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END     

------------------insert operation into UserProblem table-----      

         INSERT INTO
             PatientProblem
             (
				PatientID,                                   
				MedicalProblemId,
				Comments,
				ProblemStartDate,
				ProblemEndDate,
				StatusCode,
				MedicalProblemClassificationId,
				CreatedByUserId,
				DataSourceId
		      )
         VALUES
             (
				@i_UserId,
				@i_MedicalProblemId,
				@vc_Comments,
				@dt_ProblemStartDate,
				@dt_ProblemEndDate,
				@vc_StatusCode,
				@i_MedicalProblemClassificationId,
				@i_AppUserId,
				@i_DataSourceId
             )

       SELECT @l_numberOfRecordsInserted = @@ROWCOUNT,
			  @o_UserProblemId = SCOPE_IDENTITY()

         IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert UserProblem'
				,17      
				,1      
				,@l_numberOfRecordsInserted                 
			)              
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
    ON OBJECT::[dbo].[usp_UserProblem_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

