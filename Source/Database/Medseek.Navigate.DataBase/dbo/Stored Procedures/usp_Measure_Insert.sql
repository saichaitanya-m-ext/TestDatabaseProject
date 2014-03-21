/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Measure_Insert    
Description   : This procedure is used to insert record into Measure table
Created By    : Aditya    
Created Date  : 15-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
01-Mar-2011 NagaBabu Added RealisticMin,RealisticMax fields as well as Perameters in insert statement 
27-July-2011 NagaBabu Added @i_MeasureTextOptionId as this new field added to the table Measure
17-Oct-2012 Rathnam added @v_CPTList, @v_LoincList parameters	
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_Measure_Insert]  
(  
	@i_AppUserId  KeyID,
	@vc_Name SourceName,
	@vc_Description LongDescription,
	@i_MeasureTypeId KeyID,
	@i_SortOrder STID,
	@vc_StatusCode StatusCode,
	@i_StandardMeasureUOMId KeyID = NULL,
	@vc_isVital IsIndicator,
	@vc_IsTextValueForControls IsIndicator,
	@o_MeasureId KeyID OUTPUT ,
	@d_RealisticMin DECIMAL(10,2) ,
	@d_RealisticMax DECIMAL(10,2),
	@i_MeasureTextOptionId KEYID = NULL,
	@tblLoincList ttypeKeyID READONLY,
	@tblCPTList ttypeKeyID READONLY  	 
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

	--------- Insert Operation into Measure starts here -------------------
	 
	INSERT INTO Measure
			(	
				Name,
				Description,
				MeasureTypeId,
				SortOrder,
				StatusCode,
				StandardMeasureUOMId,
				isVital,
				IsTextValueForControls,
				CreatedByUserId,
				RealisticMin ,
				RealisticMax ,
				MeasureTextOptionId
				--CPTList,
				--LoincList
			)
	VALUES
			(				  
				@vc_Name,
				@vc_Description,
				@i_MeasureTypeId,
				@i_SortOrder,
				@vc_StatusCode,
				@i_StandardMeasureUOMId,
				@vc_isVital,
				@vc_IsTextValueForControls,
				@i_AppUserId ,
				@d_RealisticMin ,
				@d_RealisticMax ,
				@i_MeasureTextOptionId 
				--@v_CPTList,
				--@v_LoincList
					 
			) 
			       
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT,
			@o_MeasureId = SCOPE_IDENTITY() 
			
			INSERT INTO ProcedureMeasure
				(
				MeasureId,
				ProcedureId,
				StatusCode,
				CreatedByUserId
				)
			
			SELECT @o_MeasureId, tKeyId, 'A', @i_AppUserId  FROM @tblCPTList t
			WHERE NOT EXISTS (SELECT 1 FROM ProcedureMeasure pm where pm.ProcedureId = tKeyId AND pm.MeasureId = @o_MeasureId)
			
			
			INSERT INTO LoinCodeMeasure
				(
				MeasureId,
				LoinCodeId,
				StatusCode,
				CreatedByUserId			
				)
			
			SELECT @o_MeasureId, tKeyId, 'A' , @i_AppUserId FROM @tblLoincList
			WHERE NOT EXISTS (SELECT 1 FROM LoinCodeMeasure pm where pm.LoinCodeId = tKeyId AND pm.MeasureId = @o_MeasureId)
			
			
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert Measure'
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
    ON OBJECT::[dbo].[usp_Measure_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

