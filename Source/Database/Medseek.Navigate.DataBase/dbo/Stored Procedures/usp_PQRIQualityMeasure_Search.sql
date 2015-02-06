/*    
--------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_PQRIQualityMeasure_Search]    
Description   : This procedure is used to get the details of PQRIQualityMeasure Search.    
Created By    : Rathnam     
Created Date  : 13-Dec-2010    
---------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION   
22-Dec-2010   Rama Added MeasuretoMeasureGroupMapings Column   
25-Dec-2010   Rama replaced PQRIQualityMeasuretoMeasureGroup by PQRIQualityMeasureGroupToMeasure 
27-Dec-2010   Rama Added DocumentLibraryID column
3-Jan-2011    Rama Added MigratedPQRIQualityMeasureID column for not to retrieve migrated data
03-Feb-2011 NagaBabu Added IsAllowEdit field 
---------------------------------------------------------------------------------    
*/    
    
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasure_Search]
       (    
        @i_AppUserId KEYID    
       ,@i_ReportingYear SMALLINT     
       ,@v_StatusCode StatusCode     
       ,@i_PQRIMeasureID KEYID = NULL     
       ,@v_MeasureName SHORTDESCRIPTION = NULL
       ,@b_IsMigrated ISINDICATOR = 0    
       )    
AS    
BEGIN TRY     
    
 -- Check if valid Application User ID is passed    
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )    
         BEGIN    
               RAISERROR ( N'Invalid Application User ID %d passed.'    
               ,17    
               ,1    
               ,@i_AppUserId )    
         END    
----------- Select all the PQRIQualityMeasure details ---------------    
 
      SELECT    
          PQRIQualityMeasureID    
         ,PQRIMeasureID    
         ,Name AS PQRIQualityMeasureName    
		 ,STUFF(( SELECT 
					  ',' + CONVERT(VARCHAR,PQRIQualityMeasureGroupId)
				  FROM
					   PQRIQualityMeasureGroupToMeasure
				  
				  WHERE
					  PQRIQualityMeasureID = PQRIQualityMeasure.PQRIQualityMeasureID
					 
				   FOR
					   XML PATH('') ) , 1 , 1 , '') AS MeasuretoMeasureGroupMapings  
         ,Description    
         ,CASE StatusCode        
              WHEN 'A' THEN 'Active'        
              WHEN 'I' THEN 'Inactive'        
          END AS StatusCode     
         ,DocumentStartPage 
         ,MigratedPQRIQualityMeasureID  
         ,DocumentLibraryID
         ,IsAllowEdit 
      FROM    
          PQRIQualityMeasure     
      WHERE    
          ReportingYear = @i_ReportingYear    
          AND StatusCode = @v_StatusCode     
          AND (PQRIMeasureID = @i_PQRIMeasureID OR @i_PQRIMeasureID IS NULL)    
          AND (Name LIKE '%'+ @v_MeasureName + '%' OR @v_MeasureName IS NULL)
          AND ((PQRIQualityMeasureID NOT IN (SELECT ISNULL(MigratedPQRIQualityMeasureID,0) FROM PQRIQualityMeasure) AND @b_IsMigrated  = 1) OR @b_IsMigrated  = 0)
      ORDER BY PQRIQualityMeasure.PQRIMeasureID     
          
END TRY    
---------------------------------------------------------------------------------------------------------------    
BEGIN CATCH    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PQRIQualityMeasure_Search] TO [FE_rohit.r-ext]
    AS [dbo];

