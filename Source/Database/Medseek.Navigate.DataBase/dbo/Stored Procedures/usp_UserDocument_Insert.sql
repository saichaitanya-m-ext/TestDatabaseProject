/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserDocument_Insert      
Description   : This procedure is used to Insert records into UserDocument table  
Created By    : NagaBabu      
Created Date  : 27-May-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY     BY        DESCRIPTION      
22-June-2010 NagaBabu  Added MimeType parameter in Insert statement	
27-Sep-2010 NagaBabu modified  @i_numberOfRecordsInserted > 0 by <> 1 
18-Nov-2010 Rathnam  @vb_Body varbinary changed to @vb_Body VARBINARY(MAX)  
19-mar-2013 P.V.P.Mohan Modified UserDocument to PatientDocument 
------------------------------------------------------------------------------      
*/  
CREATE PROCEDURE [dbo].[usp_UserDocument_Insert]    
(    
 @i_AppUserId KeyID,  
 @i_UserID KeyID,
 @i_DocumentCategoryId KeyID,
 @vc_Name ShortDescription,
 @vb_Body VARBINARY(MAX),
 @i_FileSizeinBytes KeyID,
 @i_DocumentTypeId KeyID,
 @vc_StatusCode StatusCode,
 @vc_MimeType VARCHAR(20),
 @o_UserDocumentId KeyID OUTPUT
) 
AS  
BEGIN TRY
	  SET NOCOUNT ON  
	  DECLARE @l_numberOfRecordsInserted INT   
	  -- Check if valid Application User ID is passed    
	  IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	  BEGIN  
		   RAISERROR 
		   ( N'Invalid Application UserID %d passed.' ,  
		     17 ,  
		     1 ,  
		     @i_AppUserId
		   )  
	  END  
--------- Insert Operation into UserDocument Table starts here ---------  
  
	 INSERT INTO PatientDocument  
		(   
			PatientID ,
			DocumentCategoryId ,
			Name ,
			Body ,
			FileSizeinBytes ,
			DocumentTypeId ,
			StatusCode,
			CreatedByUserId ,
			MimeType
		)  
	 VALUES
		(  
			 @i_UserID,
			 @i_DocumentCategoryId ,
			 @vc_Name ,
			 @vb_Body ,
			 @i_FileSizeinBytes ,
			 @i_DocumentTypeId ,
			 @vc_StatusCode,
			 @i_AppUserId ,
			 @vc_MimeType
		 )
		   	
     SELECT @l_numberOfRecordsInserted = @@ROWCOUNT,
            @o_UserDocumentId  = SCOPE_IDENTITY()    

     IF @l_numberOfRecordsInserted <> 1          
	 BEGIN          
		 RAISERROR      
			(  N'Invalid Rowcount %d in insert UserDocument'
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
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserDocument_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

