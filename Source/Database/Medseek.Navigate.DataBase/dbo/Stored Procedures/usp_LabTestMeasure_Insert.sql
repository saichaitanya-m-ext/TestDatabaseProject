/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_LabTestMeasure_Insert]
Description	  : This procedure is used to Insert data into LabTestMeasure table.
Created By    :	NagaBabu
Created Date  : 26-Apr-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY	DESCRIPTION
---------------------------------------------------------------------------------
*/  
   
CREATE PROCEDURE [dbo].[usp_LabTestMeasure_Insert] 
(
	@i_AppUserId KEYID ,
	@i_LabTestId KEYID ,
    @i_MeasureId KEYID ,
    @v_StatusCode StatusCode 
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
----------- Select all the Activity details ---------------
        INSERT INTO LabTestMeasure
        (
			LabTestId ,
			MeasureId ,
			StatusCode ,
		    CreatedByUseriD
	    )
	    VALUES
	    (
			@i_LabTestId ,
			@i_MeasureId ,
			@v_StatusCode ,
			@i_AppUserId
		)			
       
        SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
         
		IF @l_numberOfRecordsInserted <> 1          
		BEGIN          
			RAISERROR      
				(  N'Invalid row count %d in insert LabTestMeasure'
					,17      
					,1      
					,@l_numberOfRecordsInserted                 
				)              
		END  

	RETURN 0        
		  
END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LabTestMeasure_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

