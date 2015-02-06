/*  
------------------------------------------------------------------------------    
Procedure Name: usp_UserMeasure_Insert    
Description   : This procedure is used to insert record into UserMeasure table
Created By    : Aditya    
Created Date  : 16-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
06-Sept-2011 Rathnam added time for datetaken column 
04-APR-2013 P.V.P.MOHAN modified UserMeasure Table to PatientMeasure and Columns of that Table .  
declare @p12 int
set @p12=NULL
exec usp_UserMeasure_Insert @i_AppUserId=10,@i_PatientUserId=6,@i_MeasureId=164,@i_MeasureUOMId=11,
@vc_MeasureValue=N'12',
@i_DataSourceId=NULL,
@vc_Comments=N'',@i_isPatientAdministered=0,@dt_DateTaken='2013-04-17 00:00:00',
@dt_DueDate=NULL,@vc_StatusCode=N'A',
@o_UserMeasureId=@p12 output   
------------------------------------------------------------------------------    
*/


CREATE PROCEDURE [dbo].[usp_UserMeasure_Insert]
(
 @i_AppUserId KEYID ,
 @i_PatientUserId KEYID ,
 @i_MeasureId KEYID ,
 @i_MeasureUOMId KEYID ,
 @vc_MeasureValue VARCHAR(200) , -- Can be numeric or text. If numeric insert value into 
								 --UserMeasure.MeasureValueNumeric else UserMeasure.MeasureValueText
--@i_MeasureValueNumeric	decimal (10,2),
  @i_DataSourceId KeyId,
 @vc_Comments VARCHAR(200) ,
 @i_isPatientAdministered ISINDICATOR ,
 @dt_DateTaken USERDATE ,
 @dt_DueDate USERDATE ,
 @vc_StatusCode STATUSCODE ,
 @o_UserMeasureId KEYID OUTPUT

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
	---------------- insert operation ---------------

  
               INSERT INTO
                   PatientMeasure
                   (
                     PatientID ,
                     MeasureId ,
                     MeasureUOMId ,
                     MeasureValueText ,
                     MeasureValueNumeric ,
                     DataSourceId,
                     Comments ,
                     isPatientAdministered ,
                     DateTaken ,
                     DueDate ,
                     StatusCode ,
                     CreatedByUserId

                   )
               VALUES
                   (
                     @i_PatientUserId ,
                     @i_MeasureId ,
                     @i_MeasureUOMId ,
                     CASE ISNUMERIC(@vc_MeasureValue) WHEN 0 THEN  @vc_MeasureValue ELSE NULL END,
                     CASE ISNUMERIC(@vc_MeasureValue) WHEN 1 THEN  @vc_MeasureValue ELSE NULL END,
                     @i_DataSourceId,
                     @vc_Comments ,
                     @i_isPatientAdministered ,
                     CONVERT(DATETIME,CONVERT(VARCHAR,@dt_DateTaken,101) + ' ' + CONVERT(VARCHAR, GETDATE(), 14)),
                     @dt_DueDate ,
                     @vc_StatusCode ,
                     @i_AppUserId 
                     )
         
      SELECT
          @l_numberOfRecordsInserted = @@ROWCOUNT ,
          @o_UserMeasureId = SCOPE_IDENTITY()

      IF @l_numberOfRecordsInserted <> 1
         BEGIN
               RAISERROR ( N'Invalid row count %d in insert document Type' ,
               17 ,
               1 ,
               @l_numberOfRecordsInserted )
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
    ON OBJECT::[dbo].[usp_UserMeasure_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

