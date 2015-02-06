/*    
------------------------------------------------------------------------------    
Procedure Name: usp_CareTeam_Update    
Description   : This procedure is used to update record in CareTeam table.
Created By    : Aditya    
Created Date  : 15-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
27-Sep-2010 NagaBabu Modified return statement by returning 0 and Modified return value as 'RETURN -1' 
						in First return Statement
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_CareTeam_Update]
(  
	@i_AppUserId KeyId,
	@i_CareTeamId KeyID,
	@vc_CareTeamName SourceName, 
	@vc_Description ShortDescription,
	@i_DiseaseId KeyID,
	@vc_StatusCode StatusCode
)  
AS  
BEGIN TRY

	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsUpdated INT   
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR 
		   ( N'Invalid Application User ID %d passed.' ,  
		     17 ,  
		     1 ,  
		     @i_AppUserId
		   )  
	END
	
 ----------- check whether CareTeam ID already exists or not -----------  
      IF EXISTS ( SELECT
                      1
                  FROM
                      CareTeam
                  WHERE
                      CareTeamName = @vc_CareTeamName AND CareTeamId <> @i_CareTeamId)
         BEGIN
               RETURN -1
         END
      ELSE   
  
---------Update operation into CareTeam table-----  
	BEGIN
	
	 UPDATE CareTeam
	    SET	CareTeamName = @vc_CareTeamName,
	        Description = @vc_Description,
	        DiseaseId = @i_DiseaseId,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			StatusCode = @vc_StatusCode
	  WHERE CareTeamId = @i_CareTeamId

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update CareTeam Details'  
				,17  
				,1 
				,@l_numberOfRecordsUpdated            
			)          
		END  
   END 
   RETURN 0
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
    ON OBJECT::[dbo].[usp_CareTeam_Update] TO [FE_rohit.r-ext]
    AS [dbo];

