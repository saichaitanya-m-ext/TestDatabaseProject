/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Immunizations_Update    
Description   : This procedure is used to update record in Immunizations table
Created By    : Pramod    
Created Date  : 1-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
07-Apr-2011 NagaBabu Added @v_Route Parameter as well as in Update statement 
11-Aug-2011 NagaBabu Added @i_ProcedureID as input parameter while this field was newly added to this table
29-Aug-2011 NagaBabu Changed datatype of '@v_Description' as LongDescription       
28-Sep-2011 Ratham added  @i_DependentImmunizationID,@i_DaysBetweenImmunization,@v_Strength parameters
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_Immunizations_Update]  
(  
	@i_AppUserId INT,
	@i_ImmunizationID KeyID,
	@v_Name SourceName, 
	@v_Description LongDescription,
	@i_SortOrder STID,
	@v_StatusCode StatusCode,
	@v_Route VARCHAR(50),
	@i_ProcedureID KeyID,
	@i_DependentImmunizationID KEYID = NULL,
	@i_DaysBetweenImmunization INT = NULL,
	@v_Strength VARCHAR(30) = NULL
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

	 UPDATE Immunizations
	    SET	Name = @v_Name,
	        Description = @v_Description,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			SortOrder = @i_SortOrder,
			StatusCode = @v_StatusCode,
			Route = @v_Route,
			ProcedureID = @i_ProcedureID, 
			DependentImmunizationID = @i_DependentImmunizationID ,
			DaysBetweenImmunization = @i_DaysBetweenImmunization ,
			Strength = @v_Strength 
	  WHERE ImmunizationID = @i_ImmunizationID

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update Immunization Details'  
				,17  
				,1 
				,@l_numberOfRecordsUpdated            
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
    ON OBJECT::[dbo].[usp_Immunizations_Update] TO [FE_rohit.r-ext]
    AS [dbo];

