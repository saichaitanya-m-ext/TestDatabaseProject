/*    
--------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_PQRIProviderPersonalization_Select]   
Description   : This procedure is used to get the details of PQRIProviderPersonalization and data from PQRIQualityMeasure
						or PQRIQualityMeasureGroup as per @v_Input parameter.    
Created By    : NagaBabu     
Created Date  : 06-Jan-2011    
---------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION  
10-Jan-2011 NagaBabu Added DocumentLibraryID,PQRIMeasureID for second,third select statements
12-Jan-2011 NagaBabu Replaced ProviderUserID,ReportingYear with PQRIProviderPersonalizationID 
01-Nov-2011 NagaBabu Added DocumentStartPage field in second,third resultsets
26-NOV-2011 Rathnam added PQRIMeasureID list column in the last select statement
---------------------------------------------------------------------------------    
*/       
CREATE PROCEDURE [dbo].[usp_PQRIProviderPersonalization_Select]
(    
    @i_AppUserId KEYID ,
    @i_PQRIProviderPersonalizationID KEYID 
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
----------- Select data from PQRIProviderPersonalization ---------------   
      SELECT 
		  ProviderUserID ,
		  ReportingYear ,	
		  SubmissionMethod ,
		  ReportingPeriod ,
		  QualityMeasureReportingMethod ,
		  QualityMeasureGroupReportingMethod
	  FROM
		  PQRIProviderPersonalization	
	  WHERE
		  PQRIProviderPersonalizationID = @i_PQRIProviderPersonalizationID
	  
	 SELECT
		 PQM.PQRIQualityMeasureID ,
		 PQM.DocumentLibraryID ,
		 PQM.PQRIMeasureID ,
		 PQM.Name ,
		 CONVERT(VARCHAR,PQM.PQRIQualityMeasureID) + '~' + ISNULL(CONVERT(VARCHAR,DocumentLibraryID),0) AS MeasureAndLibraryID ,
         CONVERT(VARCHAR,PQM.PQRIMeasureID) + ' - ' + Name AS MeasureName ,
         PQM.DocumentStartPage
	 FROM
		 PQRIQualityMeasure	PQM WITH(NOLOCK)
	 INNER JOIN PQRIProviderQualityMeasure PPQM WITH(NOLOCK)
		 ON PQM.PQRIQualityMeasureID = PPQM.PQRIQualityMeasureID
	 INNER JOIN PQRIProviderPersonalization	PPP  WITH(NOLOCK)
		 ON PPP.PQRIProviderPersonalizationID = PPQM.PQRIProviderPersonalizationID	 
	 WHERE
		 PPP.PQRIProviderPersonalizationID = @i_PQRIProviderPersonalizationID
			 
	  
	 SELECT
		 PMG.PQRIQualityMeasureGroupID ,
		 PMG.DocumentLibraryID ,
		 PMG.PQRIMeasureGroupID ,
		 PMG.Name ,
		 CONVERT(VARCHAR,PMG.PQRIQualityMeasureGroupID) + '~' + 
		 ISNULL(CONVERT(VARCHAR,DocumentLibraryID),0) + '~' +  
		 ISNULL(STUFF(( SELECT 
					  ',' + CONVERT(VARCHAR,PQRIQualityMeasureId)
				  FROM
					   PQRIQualityMeasureGroupToMeasure
				  
				  WHERE
					  PQRIQualityMeasureGroupId = PPQMG.PQRIQualityMeasureGroupID
					 
				   FOR
					   XML PATH('') ) , 1 , 1 , ''),'')AS MeasureAndLibraryID ,
         CONVERT(VARCHAR,PMG.PQRIMeasureGroupID) + ' - ' + Name AS MeasureName
         ,ISNULL(STUFF(( SELECT 
					  ',' + CONVERT(VARCHAR,PQRIQualityMeasureId)
				  FROM
					   PQRIQualityMeasureGroupToMeasure
				  
				  WHERE
					  PQRIQualityMeasureGroupId = PPQMG.PQRIQualityMeasureGroupID
					 
				   FOR
					   XML PATH('') ) , 1 , 1 , ''),'') AS MeasuretoMeasureGroupMapings ,
		 PMG.DocumentStartPage,
		 ISNULL(STUFF(( SELECT 
					  ',' + CONVERT(VARCHAR,PQRIQualityMeasure.PQRIMeasureID)
				  FROM
					   PQRIQualityMeasureGroupToMeasure
				  INNER JOIN PQRIQualityMeasure	   
				  ON PQRIQualityMeasure.PQRIQualityMeasureID = PQRIQualityMeasureGroupToMeasure.PQRIQualityMeasureID
				  WHERE
					  PQRIQualityMeasureGroupId = PPQMG.PQRIQualityMeasureGroupID
					 
				   FOR
					   XML PATH('') ) , 1 , 1 , ''),'')AS PQRIMeasureIDList 		     			 
	 FROM
		 PQRIQualityMeasureGroup PMG WITH(NOLOCK)
	 INNER JOIN PQRIProviderQualityMeasureGroup PPQMG WITH(NOLOCK)
		 ON PMG.PQRIQualityMeasureGroupID = PPQMG.PQRIQualityMeasureGroupID
	 INNER JOIN PQRIProviderPersonalization	PPP  WITH(NOLOCK)
		 ON PPQMG.PQRIProviderPersonalizationID = PPP.PQRIProviderPersonalizationID	  	 
	 WHERE
		PPP.PQRIProviderPersonalizationID = @i_PQRIProviderPersonalizationID
	 	 
	 
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
    ON OBJECT::[dbo].[usp_PQRIProviderPersonalization_Select] TO [FE_rohit.r-ext]
    AS [dbo];

