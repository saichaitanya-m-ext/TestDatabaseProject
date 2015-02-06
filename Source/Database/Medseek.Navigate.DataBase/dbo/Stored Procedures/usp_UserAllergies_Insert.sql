/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserAllergies_Insert      
Description   : This procedure is used to insert record into UserAllergies table  
Created By    : Aditya      
Created Date  : 24-Mar-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
12-Jul-2012 Sivakrishna Added @i_DataSourceId parameter  and added DatasourceId Column to Existing insert Statement
05-Sep-2012 P.V.P.Moahn Added @i_AllergiesID parameter and added AllergiesID Column to Existing insert Statement
19-Mar-2013 P.V.P.Moahn Modified  UserID to PatientID parameter 
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_UserAllergies_Insert] --64,172906,11,'sadad','sas','ssadsd','A','9/5/2012',null,2    
(    
		@i_AppUserId KeyID,    
		@i_UserID KeyID,
		@i_AllergiesID KeyID,
		@vc_Reaction ShortDescription,
		@vc_Severity Unit,
		@vc_Comments LongDescription,
		@vc_StatusCode StatusCode,
		@dt_UserAllergiesDate DATE,
		@o_UserAllergiesID KeyID OUTPUT  ,
		@i_DataSourceId KeyId 
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
  
 INSERT INTO PatientAllergies  
		( 
			PatientID,
			AllergiesID,
			Reaction,
			Severity,
			Comments,
			StatusCode,
			UserAllergiesDate,
			CreatedByUserId,
			DataSourceID

		 )  
 VALUES  
    (		
			@i_UserId,
			@i_AllergiesID,
			@vc_Reaction,
			@vc_Severity,
			@vc_Comments,
			@vc_StatusCode,
			@dt_UserAllergiesDate,
			@i_AppUserId,
			@i_DataSourceId
    )  
       
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT  
          ,@o_UserAllergiesID = SCOPE_IDENTITY()  
        
    IF @l_numberOfRecordsInserted <> 1            
 BEGIN            
  RAISERROR        
   (  N'Invalid row count %d in Insert UserAllergies'  
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
    ON OBJECT::[dbo].[usp_UserAllergies_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

