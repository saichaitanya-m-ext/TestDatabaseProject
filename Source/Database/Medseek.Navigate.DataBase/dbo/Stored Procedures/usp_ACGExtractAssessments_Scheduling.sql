/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_ACGSchedule_Scheduling]
Description   : This Procedure Schedules the ExportDates  
Created By    : NagaBabu
Created Date  : 07-Mar-2011
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------        
*/  
CREATE PROCEDURE [dbo].[usp_ACGExtractAssessments_Scheduling]
(  
 @i_AppUserId KEYID
)  
AS  
BEGIN TRY  
      SET NOCOUNT ON         
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.' ,  
               17 ,  
               1 ,  
               @i_AppUserId )  
         END
--------------------------------------------------------------------
	DECLARE @i_ACGScheduleID KeyID ,
			@vc_Frequency VARCHAR(1) ,
			@d_StartDate USERDATE ,
			@d_DateOfLastExport USERDATE ,
			@d_DateOfLastImport USERDATE ,
			@p_ParamDate DATE = GETDATE() ,
			@d_DateOfNextExport	USERDATE
			
	DECLARE CurACGSchedule CURSOR
		FOR SELECT 
				ACGScheduleID ,
				Frequency ,
				CONVERT(VARCHAR(10),StartDate,101) ,
				CONVERT(VARCHAR(10),DateOfLastExport,101) ,
				DateOfLastImport
			FROM
				ACGSchedule	
			WHERE
				StatusCode = 'A'
	
	OPEN CurACGSchedule
	FETCH NEXT FROM CurACGSchedule
				INTO @i_ACGScheduleID ,
					 @vc_Frequency ,
					 @d_StartDate ,
					 @d_DateOfLastExport ,
				 	 @d_DateOfLastImport 
				 	 
		 	 
	WHILE @@FETCH_STATUS = 0
		BEGIN
		    	 	 
			SET @d_DateOfNextExport	= CASE  @vc_Frequency 
													   WHEN 'O' THEN NULL
													   WHEN 'W' THEN DATEADD(DAY,7,@d_DateOfLastExport)
	        										   WHEN 'M' THEN DATEADD(MONTH,1,@d_DateOfLastExport) 
	        										   WHEN 'Q' THEN DATEADD(MONTH,3,@d_DateOfLastExport)
	        										   WHEN 'A' THEN DATEADD(YEAR,1,@d_DateOfLastExport)
		        								   END	
		    
			IF ((@d_StartDate IS NOT NULL 
				 AND @d_StartDate <= GETDATE()
				 AND @d_DateOfLastExport IS NULL 
				) 
				OR				
			    (@d_DateOfLastExport IS NOT NULL 
				 AND @d_DateOfNextExport <= GETDATE()
				)
			   )	 
				BEGIN
					UPDATE ACGSchedule
					   SET DateOfLastExport	= @p_ParamDate
					 WHERE ACGScheduleID = @i_ACGScheduleID							
				END
					 
			FETCH NEXT FROM CurACGSchedule
				INTO @i_ACGScheduleID ,
					 @vc_Frequency ,
					 @d_StartDate ,
					 @d_DateOfLastExport ,
				 	 @d_DateOfLastImport  
		
		END	 	
        CLOSE CurACGSchedule
        DEALLOCATE CurACGSchedule
				
END TRY        
---------------------------------------------------------------------   
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ACGExtractAssessments_Scheduling] TO [FE_rohit.r-ext]
    AS [dbo];

