
/*    
---------------------------------------------------------------------------------------    
Procedure Name: usp_ReportFilterConfiguration_Insert 
Description   : This procedure is used to Insert the ReportFilterConfiguration data  
Created By    : Sivakrishna  
Created Date  : 28-nov-2012   
---------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    

---------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_ReportFilterConfiguration_Insert]
(
			@i_AppUserId KeyID ,
			@b_Filter Bit ,
			@t_Population ttypekeyId  READONLY 
			
)
AS
BEGIN TRY
      SET NOCOUNT ON
      DECLARE @l_numberOfRecordsInserted INT  
   
 -- Check if valid Application User ID is passed    
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END


		
			IF @b_Filter = 0 
					BEGIN
					   DELETE  ReportFilterConfiguration 
						WHERE PopulationId Is NOT NULL
						
						INSERT INTO ReportFilterConfiguration	
						 (
						  PopulationId,
						  CreatedByUserId
						  )
						 SELECT 
							tkeyId,
							@i_AppUserId
						 FROM 
							@t_Population
						 
					  END
					ELSE 
						BEGIN
							DELETE  ReportFilterConfiguration 
							WHERE  ConditionId Is NOT NULL
					
							INSERT INTO ReportFilterConfiguration	
								(
									ConditionId,
									CreatedbyUserId
								)
							 SELECT 
								tkeyId,
								@i_AppUserId
							 FROM 
								@t_Population
						  END
			    
			     
      
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
    ON OBJECT::[dbo].[usp_ReportFilterConfiguration_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

