/*
----------------------------------------------------------------------------------------
Procedure Name: usp_DiseaseMeasure_SearchByDiseaseId
Description	  : This procedure is used to select all the data or the data based on the 
				disease Id from the DiseaseMeasure table. 
Created By    :	Aditya 
Created Date  : 15-Jan-2010
-----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
28-Oct-2010  NagaBabu Added IF..ELSE Condition 
13-Sep-2011 NagaBabu deleted IF..ELSE Condition and Applied MeasureSynonyms functionality
15-Sep-2011 NagaBabu Deleted DiseaseId from resultset
-----------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_DiseaseMeasure_SearchByDiseaseId]
(
  @i_AppUserId KeyID
 ,@i_DiseaseId KeyID = NULL
)	 
AS

BEGIN TRY 

	-- Check if valid Application User ID is passed
	IF(@i_AppUserId IS NULL) OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR
		(	 N'Invalid Application User ID %d passed.'
			,17
			,1
			,@i_AppUserId
		)
	END

------------ Selection from DiseaseMeasure table table starts here ------------
	    	SELECT 	   
				 DiseaseMeasure.DiseaseId,
				 DiseaseMeasure.MeasureId,
				 MeasureSynonyms.SynonymMasterMeasureID
			INTO
				#MeasuresMas
			FROM 
				DiseaseMeasure
				LEFT OUTER JOIN MeasureSynonyms
					ON (MeasureSynonyms.SynonymMeasureID = DiseaseMeasure.MeasureId	
						OR MeasureSynonyms.SynonymMasterMeasureID = DiseaseMeasure.MeasureId)		
			WHERE
				 DiseaseMeasure.DiseaseId = @i_DiseaseId
				 OR @i_DiseaseId IS NULL  
			
			SELECT distinct
				--TMMA.DiseaseId ,
				ISNULL(TMMA.SynonymMasterMeasureID,TMMA.MeasureId) AS MeasureId ,
				MeasureType.MeasureTypeId ,
				MeasureType.[Description] AS 'MeasureTypeName',
				Measure.Name AS 'MeasureName',
				Measure.SortOrder
			FROM
				#MeasuresMas TMMA
			INNER JOIN Measure
				ON ISNULL(TMMA.SynonymMasterMeasureID,TMMA.MeasureId) = Measure.MeasureId
				AND Measure.IsSynonym = 0
				AND Measure.StatusCode = 'A'				
			INNER JOIN MeasureType
				ON MeasureType.MeasureTypeId = Measure.MeasureTypeId 
			ORDER BY Measure.SortOrder,
					 Measure.Name	
		 
END TRY 
--------------------------------------------------------------------------------------------------
BEGIN CATCH

    -- Handle exception
    DECLARE @i_ReturnedErrorID	INT
    
    EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException
				@i_UserId = @i_AppUserId
                        
    RETURN @i_ReturnedErrorID
    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_DiseaseMeasure_SearchByDiseaseId] TO [FE_rohit.r-ext]
    AS [dbo];

