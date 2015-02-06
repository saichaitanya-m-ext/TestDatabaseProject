/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_PreviousExaminationLabFindings_InsertUpdate]       
Description   : This procedure is used to insert/update Values into LabOrPhysicalExamination  table
Created By    : Rathnam 
Created Date  : 07-07-2011      
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION 
08-July-2011 NagaBabu Added 'IF NOT EXISTS' Condition for restricting Duplicates  
------------------------------------------------------------------------------        
*/

CREATE PROCEDURE [dbo].[usp_LabOrPhysicalExamination_InsertUpdate]
(
 @i_AppUserId KEYID ,
 @v_Name ShortDescription ,
 @v_StatusCode	StatusCode,
 @i_LabOrPhysicalExaminationID KEYID = NULL,
 @o_LabOrPhysicalExaminationID KEYID OUT
 )
AS
BEGIN TRY
      SET NOCOUNT ON  
      DECLARE @i_numberOfRecords INT  
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL )OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END    
    
---------insert operation into LabOrPhysicalExamination table-----  
      IF @i_LabOrPhysicalExaminationID IS NULL
		  BEGIN
			   				      		   	
			   INSERT INTO 
				   LabOrPhysicalExamination  
				   (
					 Name,
					 StatusCode,
					 CreatedByUserId,
					 CreatedDate 
				   )
			   VALUES
				   (
					 @v_Name ,
					 @v_StatusCode,
					 @i_AppUserId,
					 GETDATE() 
				   )
				SELECT @o_LabOrPhysicalExaminationID = SCOPE_IDENTITY(),      	   	        
					   @i_numberOfRecords = @@ROWCOUNT
				IF @i_numberOfRecords <> 1
				BEGIN
					RAISERROR
						( N'Invalid row count %d in insert LabOrPhysicalExamination'
						   ,17      
						   ,1      
						   ,@i_numberOfRecords                 
						) 
				END
					
			END
		ELSE
			BEGIN
				UPDATE LabOrPhysicalExamination
				   SET Name = @v_Name,
					   StatusCode = @v_StatusCode
				 WHERE
					   LabOrPhysicalExaminationID = @i_LabOrPhysicalExaminationID
					  	 
				SET @i_numberOfRecords = @@ROWCOUNT
						
				IF @i_numberOfRecords <> 1 
					RAISERROR
					(	 N'Update of LabOrPhysicalExamination table experienced invalid row count of %d'
						,17
						,1
						,@i_numberOfRecords         
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
    ON OBJECT::[dbo].[usp_LabOrPhysicalExamination_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

