/*  
--------------------------------------------------------------------------------  
Procedure Name: [dbo].[Usp_Measure_Select_DD]  
Description   : This procedure is used to select  all active records from Measure table.  
Created By    : Aditya   
Created Date  : 16-Apr-2010  
---------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
22-Apr-2010 Pramod Included the StandardUOMID, UOM in the Select statement
01-Mar-2011 NagaBabu Added RealisticMin,RealisticMax fields and joined with MeasureType table in Select statement  
13-Sep-2011 NagaBabu Added @b_IsMasterMeasure Parameter for getting all master measures for reports related 
						mesaures drop down
19-Sep-2011 Rathnam added one more paramter @i_MeasureID		
28-Nov-2011	Gurumoorthy V Added Condition(Measure.IsSynonym = 0)in Measure Where Clause
			
---------------------------------------------------------------------------------  
*/  
 
CREATE PROCEDURE [dbo].[usp_Measure_Select_DD]
(
	@i_AppUserId KEYID,
	@b_IsSynonym ISINDICATOR = NULL,
	@b_IsMasterMeasure ISINDICATOR = NULL,
	@i_MeasureID KEYID = NULL
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
	IF @b_IsSynonym IS NULL AND @b_IsMasterMeasure IS NULL
		BEGIN  
			  SELECT  
				  Measure.MeasureId ,  
				  Measure.Name,
				  Measure.RealisticMin ,
				  Measure.RealisticMax ,
				  Measure.StandardMeasureUOMId AS MeasureUOMID,
				  MeasureUOM.UOMText AS UOM,
				  Measure.IsTextValueForControls 
			  FROM  
				  Measure   WITH (NOLOCK) 
			  LEFT OUTER JOIN MeasureUOM WITH (NOLOCK) 
				  ON MeasureUOM.MeasureUOMId = Measure.StandardMeasureUOMId
			  INNER JOIN MeasureType WITH (NOLOCK) 
				  ON Measure.MeasureTypeId = MeasureType.MeasureTypeId   
		            
			  WHERE  
						Measure.StatusCode = 'A'  
				  AND 
						Measure.IsSynonym = 0
			  ORDER BY  
				  Measure.SortOrder,
				  Measure.Name
		  END
      IF @b_IsSynonym = 1 AND @i_MeasureID IS NOT NULL AND @b_IsMasterMeasure IS NULL
		  BEGIN    
			  SELECT
				  m.MeasureId ,  
				  m.Name     
			  FROM  
				  Measure m WITH (NOLOCK) 
			  WHERE m.IsVital = 0
			  AND ISNULL(m.IsSynonym,0) = 0
			  AND m.StatusCode = 'A'
			  AND m.MeasureId <> @i_MeasureID
			  AND NOT EXISTS (SELECT TOP 1 1 FROM MeasureSynonyms ms WHERE ms.SynonymMasterMeasureID = m.MeasureID)
		  END
		  
	 IF @b_IsMasterMeasure = 1 AND @b_IsSynonym IS NULL 
		BEGIN
			SELECT
				  Measure.MeasureId ,  
				  Measure.Name,
				  Measure.RealisticMin ,
				  Measure.RealisticMax ,
				  Measure.StandardMeasureUOMId AS MeasureUOMID,
				  MeasureUOM.UOMText AS UOM,
				  Measure.IsTextValueForControls 
			  FROM  
				  Measure WITH (NOLOCK) 
			  LEFT OUTER JOIN MeasureUOM WITH (NOLOCK) 
				  ON MeasureUOM.MeasureUOMId = Measure.StandardMeasureUOMId
			  INNER JOIN MeasureType WITH (NOLOCK) 
				  ON Measure.MeasureTypeId = MeasureType.MeasureTypeId   	  
			  WHERE ISNULL(IsSynonym,0) = 0
				  AND Measure.StatusCode = 'A'	
			  ORDER BY  
				  Measure.SortOrder,
				  Measure.Name	   
		END
			   
END TRY  
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Measure_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

