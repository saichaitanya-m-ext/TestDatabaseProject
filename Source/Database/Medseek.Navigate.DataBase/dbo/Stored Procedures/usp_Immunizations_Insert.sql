/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Immunizations_Insert    
Description   : This procedure is used to insert record into Immunizations table
Created By    : Pramod    
Created Date  : 1-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
07-Apr-2011 NagaBabu Added @v_Route Parameter as well as in Insert statement  
11-Aug-2011 NagaBabu Added @i_ProcedureID as input parameter while this field was newly added to this table
22-Aug-2011 NagaBabu Added NULL to the parameter @i_ProcedureID by default 
28-Sep-2011 Ratham added  @i_DependentImmunizationID,@i_DaysBetweenImmunization,@v_Strength parameters
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_Immunizations_Insert]  
(  
	@i_AppUserId KeyID,  
	@v_Name SourceName, 
	@v_Description LongDescription,
	@i_SortOrder STID,
	@v_StatusCode StatusCode,
	@v_Route VARCHAR(50),
	@i_ProcedureID KeyID = NULL,
	@o_ImmunizationId KeyID OUTPUT,
	@i_DependentImmunizationID KEYID = NULL,
	@i_DaysBetweenImmunization INT = NULL,
	@v_Strength VARCHAR(30) = NULL
)  
AS  
BEGIN TRY  
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsInserted INT   
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR ( N'Invalid Application User ID %d passed.' ,  
		   17 ,  
		   1 ,  
		   @i_AppUserId )  
	END  

	INSERT INTO Immunizations
	   ( Name
	    ,Description
	    ,CreatedByUserId
	    ,StatusCode
	    ,SortOrder
	    ,Route
	    ,ProcedureID
	    ,DependentImmunizationID
		,DaysBetweenImmunization
		,Strength
	   )
	VALUES
	   ( @v_Name
	    ,@v_Description
	    ,@i_AppUserId
	    ,@v_StatusCode
	    ,@i_SortOrder
	    ,@v_Route
	    ,@i_ProcedureID
	    ,@i_DependentImmunizationID 
		,@i_DaysBetweenImmunization
		,@v_Strength 
	   )
	   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_ImmunizationId = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Insert Immunizations'
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
    ON OBJECT::[dbo].[usp_Immunizations_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

