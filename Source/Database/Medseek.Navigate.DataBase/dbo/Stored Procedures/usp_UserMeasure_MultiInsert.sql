/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserMeasure_MultiInsert    
Description   : This procedure is used to insert Multiple records into UserMeasure table
Created By    : NagaBabu    
Created Date  : 16-Sep-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION   
06-Sept-2011 Rathnam added time for datetaken column       
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_UserMeasure_MultiInsert]
(
 @i_AppUserId KEYID ,
 @i_PatientUserId KEYID ,
 @t_tUserMeasure tUserMeasure readonly 
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
	---------------- insert operation ---------------

       INSERT INTO
           PatientMeasure
           (
             PatientID ,
             MeasureId ,
             MeasureUOMId ,
             MeasureValueText ,
             MeasureValueNumeric ,
             Comments ,
             DateTaken ,
             isPatientAdministered ,
             DueDate ,
             StatusCode ,
             CreatedByUserId,
             DataSourceId
           )
         SELECT
             @i_PatientUserId ,
             PatientMeasure.MeasureId,
		     PatientMeasure.MeasureUOMId,
			 CASE ISNUMERIC(PatientMeasure.MeasureValue) WHEN 0 THEN PatientMeasure.MeasureValue ELSE NULL END,
			 CASE ISNUMERIC(PatientMeasure.MeasureValue) WHEN 1 THEN PatientMeasure.MeasureValue ELSE NULL END ,						
			 PatientMeasure.Comments,
			 CONVERT(DATETIME,CONVERT(VARCHAR,PatientMeasure.DateTaken,101) + ' ' + CONVERT(VARCHAR, GETDATE(), 14)),
		     0 ,
		     PatientMeasure.DateTaken ,
             'A' ,
             @i_AppUserId,
             PatientMeasure.DataSourceId
		 FROM 		
		     @t_tUserMeasure PatientMeasure 

		 SET @l_numberOfRecordsInserted = @@ROWCOUNT 	     

         IF @l_numberOfRecordsInserted < 1          
	     BEGIN          
		     RAISERROR      
				(  N'Invalid row count %d in insert UserMeasure'
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
    ON OBJECT::[dbo].[usp_UserMeasure_MultiInsert] TO [FE_rohit.r-ext]
    AS [dbo];

