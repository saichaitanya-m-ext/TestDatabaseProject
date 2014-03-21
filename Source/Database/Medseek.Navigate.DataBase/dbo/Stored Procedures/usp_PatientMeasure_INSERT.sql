/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_PatientMeasure_INSERT] 23
Description   : This procedure is used to get data from Filter Tables
Created By    : Santosh
Created Date  : 25-Jul-2013
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_PatientMeasure_INSERT]
(
 @i_AppUserId KEYID
)
AS
BEGIN
      BEGIN TRY
            SET NOCOUNT ON         
      -- Check if valid Application User ID is passed        
            IF ( @i_AppUserId IS NULL )
            OR ( @i_AppUserId <= 0 )
               BEGIN
                     RAISERROR ( N'Invalid Application User ID %d passed.'
                     ,17
                     ,1
                     ,@i_AppUserId )
               END

          CREATE TABLE #LoincTEMP
          (
          LoincTEMPID INT IDENTITY(10,1),
          LoincCodeID INT
          )
          
          CREATE TABLE #PatientTemp
          (
          PatientTempID INT IDENTITY(10,1),
          PatientID INT
          )
          
          INSERT INTO #LoincTEMP
          SELECT LoincCodeId FROM CodeSetLoinc 
          WHERE LoincCodeId%700 = 12
           
          
          
          INSERT INTO #PatientTemp
          SELECT PatientID FROM Patients
          
       --DROP TABLE #LoincTEMP
       -- DROP TABLE #PatientTemp
          --SELECT * FROM #LoincTEMP
          --SELECT * FROM #PatientTemp
     
         DECLARE @i_Min INT = (SELECT MIN(PatientTempID) FROM #PatientTemp),
				@i_Max INT = (SELECT MAX(PatientTempID) FROM #PatientTemp),
				@i_PatientId INT
         
         
         WHILE (@i_Min <= @i_Max)
         BEGIN 
			SELECT @i_PatientId = Patientid FROM #PatientTemp WHERE PatientTempID = @i_Min
          
          INSERT INTO PatientMeasure(LOINCCodeID,PatientID,CreatedByUserId) 
          SELECT LoincCodeId,@i_PatientId,1 
          FROM #LoincTEMP 
          WHERE LoincTEMPID%10 = @i_Min%10
         
         SET @i_Min = @i_Min + 1
         
         END
         
         
         
		DECLARE @Start int = 1
		,@end int
		select @end = MAX(PatientMeasureId)
		from PatientMeasure

		while @Start<=@end
		begin

		UPDATE PatientMeasure  
		SET MeasureValueNumeric = CAST(LEFT(RIGHT('0000'+cast(PatientMeasureId as varchar),3),2)+'.'+RIGHT(RIGHT('0000'+cast(PatientMeasureId as varchar),3),2) as money) 
		, DateTaken =  DateAdd(d, ROUND(DateDiff(d, '2012-01-01', '2013-07-26') * RAND(CHECKSUM(NEWID())), 0),
         DATEADD(second,CHECKSUM(NEWID())%48000, '2012-01-01'))
		WHERE PatientMeasureId = @Start 

		set @Start=@Start+1

		Print cast(@Start as varchar) +' Updated'

		end
        
        
              
     --SELECT * FROM PatientMeasure
     
      END TRY 
             
-------------------------------------------------------------------------------   
      BEGIN CATCH        
    -- Handle exception        
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

            RETURN @i_ReturnedErrorID
      END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PatientMeasure_INSERT] TO [FE_rohit.r-ext]
    AS [dbo];

