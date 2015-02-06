/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_PQRIQualityMeasureGroup_Search]
Description	  : This procedure is used to get the details of PQRIQualityMeasureGroup Search.
Created By    :	Rathnam 
Created Date  : 15-Dec-2010
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
22-Dec-2010   Rama Added PQRIMeasureGroupID,MeasureGrouptoMeasure Column 
27-Dec-2010   Rama Added DocumentLibraryID column
29-Dec-2010   Rama Added MigratedPQRIQualityMeasureGroupID column 
12-Jan-2011 NagaBabu Added IsAllowEdit field to the select statement 
17-Oct-2011 Rathnam mapped pqrimeaureid instead of mapping pqriqualitymeasureid for column MeasureGrouptoMeasure
---------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureGroup_Search] 
       (
        @i_AppUserId KEYID
       ,@i_ReportingYear SMALLINT 
       ,@v_StatusCode StatusCode 
       ,@v_PQRIMeasureGroupID SHORTDESCRIPTION = NULL
       ,@v_MeasureGroupName SHORTDESCRIPTION = NULL
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
          PQRIQualityMeasureGroupID
         ,PQRIMeasureGroupID
         ,Name AS PQRIQualityMeasureName
         ,STUFF(( SELECT 
					  ',' + CONVERT(VARCHAR,PQRIQualityMeasure.PQRIMeasureID)
				  FROM
					  PQRIQualityMeasureGroupToMeasure
			      INNER JOIN PQRIQualityMeasure		  
				  ON PQRIQualityMeasure.PQRIQualityMeasureID = PQRIQualityMeasureGroupToMeasure.PQRIQualityMeasureID
				  WHERE
					  PQRIQualityMeasureGroupToMeasure.PQRIQualityMeasureGroupId = PQRIQualityMeasureGroup.PQRIQualityMeasureGroupID
					 
				   FOR
					   XML PATH('') ) , 1 , 1 , '') AS MeasureGrouptoMeasure
         ,Description
         ,CASE StatusCode    
              WHEN 'A' THEN 'Active'    
              WHEN 'I' THEN 'InActive'    
          END AS StatusCode 
         ,DocumentStartPage
         ,DocumentLibraryID 
         ,MigratedPQRIQualityMeasureGroupID
         ,IsAllowEdit
      FROM
          PQRIQualityMeasureGroup 
      WHERE
          ReportingYear = @i_ReportingYear
          AND StatusCode = @v_StatusCode 
          AND (PQRIMeasureGroupID = @v_PQRIMeasureGroupID OR @v_PQRIMeasureGroupID IS NULL)
          AND (Name LIKE '%'+ @v_MeasureGroupName + '%' OR @v_MeasureGroupName IS NULL)
          AND ((PQRIQualityMeasureGroupID NOT IN (SELECT ISNULL(MigratedPQRIQualityMeasureGroupID,0) FROM PQRIQualityMeasureGroup) AND @b_IsMigrated  = 1) OR @b_IsMigrated  = 0)
      ORDER BY Name
      
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureGroup_Search] TO [FE_rohit.r-ext]
    AS [dbo];

