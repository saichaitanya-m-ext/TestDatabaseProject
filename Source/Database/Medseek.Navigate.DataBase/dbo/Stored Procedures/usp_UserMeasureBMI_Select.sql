/*  
--------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_UserMeasureBMI_Select]  
Description   : This procedure is used to select  previous Heightn & Weight records from userMeasure table.  
Created By    : Rathnam
Created Date  : 10-May-2011  
---------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
---------------------------------------------------------------------------------  
*/  
  
CREATE PROCEDURE [dbo].[usp_UserMeasureBMI_Select] 
	(
	@i_AppUserId KEYID ,
	@i_PatientUserId KEYID 
	)
AS  
BEGIN TRY   
  
 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
      BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.' ,  
               17 ,  
               1 ,  
               @i_AppUserId )  
      END  
----------- Select all the active Measure details ---------------  
      
      DECLARE @i_MeasureWeightID KEYID ,
			  @i_MeasureHeightID KEYID,
              @d_MeasureWeight DECIMAL(10,2),
              @d_MeasureHeight DECIMAL(10,2)
              
      SELECT TOP 1
		  @i_MeasureWeightID = Measure.MeasureId, 
		  @d_MeasureWeight = UserMeasure.MeasureValueNumeric 
      FROM  
          Measure WITH(NOLOCK)
      INNER JOIN  UserMeasure WITH(NOLOCK)
          ON Measure.MeasureId = UserMeasure.MeasureId 
      WHERE PatientUserId = @i_PatientUserId
        AND UserMeasure.StatusCode = 'A'
        AND Measure.StatusCode = 'A'
        AND Measure.Name = 'Weight (lb)'
      ORDER BY UserMeasureId DESC
      
      IF @@ROWCOUNT = 0
		  BEGIN
			SELECT 
				@i_MeasureWeightID = Measure.MeasureId 
			FROM  
				Measure
			WHERE Measure.StatusCode = 'A'
			  AND Measure.Name = 'Weight (lb)'
		  END
      
      
      SELECT TOP 1 
		  @i_MeasureHeightID = Measure.MeasureId ,
		  @d_MeasureHeight = UserMeasure.MeasureValueNumeric 
      FROM  
           Measure WITH(NOLOCK)
      INNER JOIN  UserMeasure WITH(NOLOCK)
          ON Measure.MeasureId = UserMeasure.MeasureId      
      WHERE PatientUserId = @i_PatientUserId
        AND UserMeasure.StatusCode = 'A'
        AND Measure.StatusCode = 'A'
        AND Measure.Name = 'Height (inch)'
      ORDER BY UserMeasureId DESC 
      
      IF @@ROWCOUNT = 0
		  BEGIN
			SELECT 
				@i_MeasureHeightID = Measure.MeasureId 
			FROM  
				Measure WITH(NOLOCK)
			WHERE Measure.StatusCode = 'A'
			  AND Measure.Name = 'Height (inch)'
		  END
      
	  SELECT @i_MeasureWeightID  AS MeasureWeightID, @d_MeasureWeight AS MeasureWeight
      SELECT @i_MeasureHeightID AS MeasureHeightID, @d_MeasureHeight AS MeasureHeight
      
      SELECT 
          MeasureId AS MeasureBMIId
      FROM
          Measure WITH(NOLOCK)
      WHERE Name = 'Body Mass Index'    

END TRY 
-------------------------------------------------------------------------------------------------- 
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserMeasureBMI_Select] TO [FE_rohit.r-ext]
    AS [dbo];

