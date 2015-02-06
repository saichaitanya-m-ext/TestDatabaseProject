/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserProcedureCodes_Insert    
Description   : This procedure is used to insert record into UserProcedureCodes table
Created By    : Aditya    
Created Date  : 07-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
27-July-2010 NagaBabu Added ProcedureLeadtime Field to this Insert Statement 
18-Oct-2010  Rathnam pass null value to  @i_ProcedureLeadtime  
19-Jan-2011  Rama added ProcedureCodeModifierId column and passing null value to @i_ProcedureCodeModifierId
09-May-2011  Rathnam added @i_LabTestId parameter 
06-Jun-2011 Rathnam added @b_IsPreventive, @i_DiseaseID two more parameters 
09-Nov-2011 NagaBabu Added @i_ProgramId as input parameter
03-feb-2011 Sivakrishna Added @b_IsAdhoc to maintain the adhoc task
23-Jul-2012 Sivakrishna Added @i_Datasourceid to maintain the DatasourceId 
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_UserProcedureCodes_Insert]  
(  
	@i_AppUserId KeyID,
	@i_UserId KeyID,
	@i_ProcedureId KeyID,
	@vc_Commments ShortDescription,
	@vc_StatusCode StatusCode,
	@dt_DueDate UserDate,
	@dt_ProcedureCompletedDate	UserDate,
	@i_ProcedureLeadtime INT = NULL,
	@i_ProcedureCodeModifierId KeyID = NULL,
	@o_UserProcedureId	KeyID OUTPUT,
	@i_LabTestId KEYID = NULL,
	@i_DiseaseID KeyID = NULL,
    @b_IsPreventive IsIndicator = NULL,
    @i_ProgramId KeyId = NULL ,
    @b_IsAdhoc BIT = 0,
    @i_DataSourceId KeyId = NULL
)  
AS  
BEGIN TRY
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsInserted INT   
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

	INSERT INTO PatientProcedure
		( 
			PatientID,
			ProcedureCodeID,
			Commments,
			ProcedureCompletedDate,
			StatusCode,
			DueDate,
			CreatedByUserId,
			ProcedureLeadtime,
			ProcedureCodeModifierId,
			LabTestId,
			--DiseaseID,
			IsPreventive,
			ProgramId ,
			IsAdhoc,
			DataSourceId
	   )
	VALUES
	   ( 
			@i_UserId,
			@i_ProcedureId,
			@vc_Commments,
			@dt_ProcedureCompletedDate,
			@vc_StatusCode,
			@dt_DueDate,
			@i_AppUserId ,
			@i_ProcedureLeadtime,
			@i_ProcedureCodeModifierId,
			@i_LabTestId,
			--@i_DiseaseID,
			@b_IsPreventive,
			@i_ProgramId ,
			@b_IsAdhoc,
			@i_DataSourceId
	   )
	   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_UserProcedureId = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert UserProcedureCodes'
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
    ON OBJECT::[dbo].[usp_UserProcedureCodes_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

