/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_HealthCareQualityMeasure_Select] 
Description   : This procedure is used to select the HealthCareQualityMeasure data .  
Created By    : NagaBabu  
Created Date  : 23-Aug-2010  
----------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
26-Aug-2010  Rathnam Enhanced the select statement.
27-Sep-2010 NagaBabu Added @i_HealthCareQualityStandardId as parameter
27-Sep-2010 Pramod Included a parameter @v_HealthCareQualityStandardName and exist clause
29-Oct-10 Pramod ISNULL included in the query
3-Nov-10 Pramod modified the SP to include denominator <> 0 in where clause
4-Nov-2010 NagaBabu Modified PQRIPercentage Field
09-Nov-2010 Rathnam declare the table variables and added CriteriaText,NrDrIndicator fields
18-Nov-10 Pramod Included ISNULL(NumeratorCount) <> 0, ISNULL(DenominatorCount) in where clause
29-Mar-2011 NagaBabu Added case statement to PQRIPercentage field in last selectstatement
23-May-2011 Rathnam added @i_ReportingYear,@v_ReportingPeriod,@i_ProgramID,@i_DiseaseID,@i_HealthCareQualityCategoryID
                    parameters
28-Jun-2011 Rathnam @i_HealthCareQualityBCategoryId make as a default parameter
25-July-2011 NagaBabu Added 'AND hcqm.StatusCode = 'A' ' in first select statement for getting active measures only
18-Oct-2011 Removed the @i_ProviderID logic for temporaory purpose
15-Nov-2011 NagaBabu Added LEFT keyword for Denominator,Numerator fields and added select statement from 
						#tHealthCareQualityMeasure CriteriaText Field changed to VARCHAR(MAX) in @t_Nr,@t_Dr  
07-Mar-2012 NagaBabu Added ,PQRINumeratorCount,PQRIDenominatorCount,PQRINumeratorPercentage,PQRIDenominatorPercentage						
						,Complient,NonComplient Fields
----------------------------------------------------------------------------------  
*/ --[usp_HealthCareQualityMeasure_Select]23,null,7,2012,'1 year',null,null,null,null
CREATE PROCEDURE [dbo].[usp_HealthCareQualityMeasure_Select]
       (
        @i_AppUserId KEYID
       ,@i_HealthCareQualityBCategoryId KEYID = NULL
       ,@i_HealthCareQualityStandardId KEYID 
       ,@i_ReportingYear KEYID 
       ,@v_ReportingPeriod VARCHAR(10) 
       ,@i_ProgramID KeyID = NULL
       ,@i_DiseaseID KEYID = NULL
       ,@i_HealthCareQualityCategoryID KEYID = NULL
       ,@i_ProviderID KeyID = NULL
       )
AS
BEGIN TRY   
  
 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END  
---------------- All the HealthCareQualityMeasure records are retrieved --------  

      DECLARE @t_Nr TABLE
            (
               HealthCareQualityMeasureID KEYID
              ,CriteriaText VARCHAR(MAX)
            )
      DECLARE @t_Dr TABLE
            (
               HealthCareQualityMeasureID KEYID
              ,CriteriaText VARCHAR(MAX)
            )
      DECLARE @t_HealthCareQualityMeasure TABLE
            (
               HealthCareQualityMeasureID KEYID
              ,HealthCareQualityMeasureName VARCHAR(400)
              ,NumeratorCount INT
              ,DenominatorCount INT
              ,NumeratorValue DECIMAL(10,2)
              ,DenominatorValue DECIMAL(10,2)
              ,PQRIPercentage DECIMAL(10,2)
              ,PQRINumeratorCount INT 
              ,PQRIDenominatorCount INT 
              ,PQRINumeratorPercentage DECIMAL(10,2)
              ,PQRIDenominatorPercentage DECIMAL(10,2)
             )

      INSERT INTO
          @t_HealthCareQualityMeasure
          (
           HealthCareQualityMeasureID
          ,HealthCareQualityMeasureName
          ,NumeratorCount
          ,DenominatorCount
          ,NumeratorValue
          ,DenominatorValue
          ,PQRIPercentage
          ,PQRINumeratorCount
          ,PQRIDenominatorCount
          ,PQRINumeratorPercentage
          ,PQRIDenominatorPercentage
          )
          SELECT
              hcqm.HealthCareQualityMeasureID
             ,hcqm.HealthCareQualityMeasureName
             ,ISNULL(hcqm.NumeratorCount , 0) AS NumeratorCount
             ,ISNULL(hcqm.DenominatorCount , 0) AS DenominatorCount
             ,ISNULL(hcqm.NumeratorValue , 0) AS NumeratorValue
             ,ISNULL(hcqm.DenominatorValue , 0) AS DenominatorValue
             ,(ISNULL(hcqm.NumeratorCount * 1.000 , 0) / ISNULL(hcqm.DenominatorCount * 1.000 , 0) ) * 100.000 AS PQRIPercentage
             ,ISNULL(hcqm.NumeratorCount , 0)
             ,ISNULL(hcqm.DenominatorCount , 0) - ISNULL(hcqm.NumeratorCount , 0)
             ,(ISNULL(hcqm.NumeratorCount * 1.000 , 0) / ISNULL(hcqm.DenominatorCount * 1.000 , 0) ) * 100.000
             ,100.0 - (ISNULL(hcqm.NumeratorCount * 1.000 , 0) / ISNULL(hcqm.DenominatorCount * 1.000 , 0) ) * 100.000
          FROM
              HealthCareQualityMeasure hcqm  WITH (NOLOCK) 
          INNER JOIN HealthCareQualityBCategory hcqb   WITH (NOLOCK)  
              ON hcqb.HealthCareQualityBCategoryId = hcqm.HealthCareQualityBCategoryId
          INNER JOIN HealthCareQualityCategory hcqc  WITH (NOLOCK) 
              ON hcqc.HealthCareQualityCategoryID = hcqb.HealthCareQualityCategoryId      
          WHERE
              (hcqm.HealthCareQualityBCategoryId = @i_HealthCareQualityBCategoryId OR @i_HealthCareQualityBCategoryId IS NULL)
          AND (hcqc.HealthCareQualityCategoryID = @i_HealthCareQualityCategoryID OR @i_HealthCareQualityCategoryID IS NULL)
          AND  hcqm.ReportingYear = @i_ReportingYear
          AND  hcqm.ReportingPeriod = @v_ReportingPeriod
          AND (hcqm.ProgramID = @i_ProgramID OR @i_ProgramID IS NULL)
          AND (hcqm.DiseaseID = @i_DiseaseID OR @i_DiseaseID IS NULL)
          --AND (@i_ProviderID IN (SELECT KeyValue FROM udf_SplitStringToTable(ProviderIDList,',')) OR @i_ProviderID IS NULL)
          AND (hcqm.HealthCareQualityStandardId = @i_HealthCareQualityStandardId )
          AND ISNULL(DenominatorCount , 0) <> 0
          AND ISNULL(NumeratorCount , 0) <> 0
          AND hcqm.StatusCode = 'A'

      INSERT INTO
          @t_Dr
          SELECT DISTINCT
              HQM1.HealthCareQualityMeasureID
             ,STUFF(( SELECT DISTINCT
                          '    ,' + REPLACE(REPLACE(HQMNrDr.CriteriaText,'<font color=''black''><b><br/>AND</b></font>',''),'<font color=''black''><b><br/>or</b></font>','')
                      FROM
                          HealthCareQualityMeasureNrDrDefinition AS HQMNrDr
                      WHERE
                          HQMNrDr.HealthCareQualityMeasureID = HQM1.HealthCareQualityMeasureID
                          AND HQMNrDr.NrDrIndicator = 'D'
                      ORDER BY
                          '    ,' + REPLACE(REPLACE(HQMNrDr.CriteriaText,'<font color=''black''><b><br/>AND</b></font>',''),'<font color=''black''><b><br/>or</b></font>','')
                      FOR
                          XML PATH('') ) , 1 , 1 , '') AS 'DR'
          FROM
              @t_HealthCareQualityMeasure AS HQM1

      INSERT INTO
          @t_Nr
          SELECT DISTINCT
              HQM1.HealthCareQualityMeasureID
             ,STUFF(( SELECT DISTINCT 
                          '    ,' + REPLACE(REPLACE(HQMNrDr.CriteriaText,'<font color=''black''><b><br/>AND</b></font>',''),'<font color=''black''><b><br/>or</b></font>','')
                      FROM
                          HealthCareQualityMeasureNrDrDefinition AS HQMNrDr
                      WHERE
                          HQMNrDr.HealthCareQualityMeasureID = HQM1.HealthCareQualityMeasureID
                          AND HQMNrDr.NrDrIndicator = 'N'
                      ORDER BY
                          '    ,' + REPLACE(REPLACE(HQMNrDr.CriteriaText,'<font color=''black''><b><br/>AND</b></font>',''),'<font color=''black''><b><br/>or</b></font>','')
                      FOR
                          XML PATH('') ) , 1 , 1 , '') AS 'NR'
          FROM
              @t_HealthCareQualityMeasure AS HQM1
      SELECT
          HealthCareQualityMeasureID
         ,HealthCareQualityMeasureName
         ,NumeratorCount
         ,DenominatorCount
         ,NumeratorValue
         ,DenominatorValue
         ,CASE WHEN PQRIPercentage > 0 AND PQRIPercentage < 1 THEN 0
			  ELSE PQRIPercentage END AS PQRIPercentage
		 ,PQRINumeratorCount
         ,PQRIDenominatorCount	
         ,CASE WHEN PQRINumeratorPercentage > 0 AND PQRINumeratorPercentage < 1 THEN 0
			  ELSE PQRINumeratorPercentage END AS PQRINumeratorPercentage
		 ,CASE WHEN PQRIDenominatorPercentage > 0 AND PQRIDenominatorPercentage < 1 THEN 0
			  ELSE PQRIDenominatorPercentage END AS PQRIDenominatorPercentage
		 ,'Complient' AS Complient
		 ,'NonComplient' AS NonComplient	  	   
         ,LEFT((
            SELECT
                SUBSTRING(CriteriaText , 5 , LEN(CriteriaText))
            FROM
                @t_Dr
            WHERE
                HealthCareQualityMeasureID = THQM.HealthCareQualityMeasureID
          ),499) AS Denominator
         ,LEFT((
            SELECT
                SUBSTRING(CriteriaText , 5 , LEN(CriteriaText))
            FROM
                @t_Nr
            WHERE
                HealthCareQualityMeasureID = THQM.HealthCareQualityMeasureID
          ),499) AS Numerator
      INTO 
		  #tHealthCareQualityMeasure	    
      FROM
          @t_HealthCareQualityMeasure THQM
      ORDER BY THQM.HealthCareQualityMeasureName
      
      SELECT HealthCareQualityMeasureID
         ,HealthCareQualityMeasureName
         ,NumeratorCount
         ,DenominatorCount
         ,NumeratorValue
         ,DenominatorValue
         ,PQRIPercentage 
         ,PQRINumeratorCount
         ,PQRIDenominatorCount	
         ,PQRINumeratorPercentage
         ,PQRIDenominatorPercentage
         ,Complient
         ,NonComplient
         ,SUBSTRING(Denominator,1,100) + ' \n ' +
          SUBSTRING(Denominator,101,100) + ' \n ' +
          SUBSTRING(Denominator,201,100) + ' \n ' +
          SUBSTRING(Denominator,301,100) + ' \n ' +
          SUBSTRING(Denominator,401,100) AS Denominator
         ,SUBSTRING(Numerator,1,100) + ' \n ' +
          SUBSTRING(Numerator,101,100) + ' \n ' +
          SUBSTRING(Numerator,201,100) + ' \n ' +
          SUBSTRING(Numerator,301,100) + ' \n ' +
          SUBSTRING(Numerator,401,100) AS Numerator
     FROM 
		#tHealthCareQualityMeasure
		       
END TRY
------------------------------------------------------------------------------------
BEGIN CATCH  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HealthCareQualityMeasure_Select] TO [FE_rohit.r-ext]
    AS [dbo];

