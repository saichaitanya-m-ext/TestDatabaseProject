/*        
------------------------------------------------------------------------------        
Procedure Name: usp_CareTeam_Insert        
Description   : This procedure is used to insert record into CareTeam table    
Created By    : Aditya        
Created Date  : 15-Mar-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION
25-Sep-2010 NagaBabu Added @l_numberOfRecordsInserted as parameter for Error message        
------------------------------------------------------------------------------        
*/  
CREATE PROCEDURE [dbo].[usp_CareTeam_Insert]  
(  
 @i_AppUserId KEYID ,  
 @vc_CareTeamName SOURCENAME ,  
 @vc_Description SHORTDESCRIPTION ,  
 @vc_StatusCode STATUSCODE ,  
 @i_DiseaseId KEYID ,  
 @o_CareTeamId INT OUTPUT 
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
    
---------insert operation into CareTeam table-----       
  

         INSERT INTO  
             CareTeam  
             (  
               CareTeamName ,  
               Description ,  
               StatusCode ,  
               DiseaseId ,  
               CreatedByUserId )  
         VALUES  
             ( 
               @vc_CareTeamName,
               @vc_Description,
               @vc_StatusCode,
               @i_DiseaseId,
               @i_AppUserId
              )  
                 
		 SELECT @l_numberOfRecordsInserted = @@ROWCOUNT,
				@o_CareTeamId = SCOPE_IDENTITY()
		 IF @l_numberOfRecordsInserted <> 1          
		 BEGIN          
			 RAISERROR      
				 (  N'Invalid row count %d in insert CareTeam'
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
    ON OBJECT::[dbo].[usp_CareTeam_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

