/*                
------------------------------------------------------------------------------                
Procedure Name: usp_UserMeasure_Select_ByUserId_MeasureId               
Description   : This procedure is used to get the details from PatientMeasure Table              
Created By    : NagaBabu                
Created Date  : 17-June-2010                
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION                
22-June-2010  NagaBabu  Changed DateTaken field format in Select Statement
24-June-2010  NagaBabu  Added AxisStartvalue,AxisEndvalue fields
07-July-2010  NagaBabu  Added YAxisStartvalue,YAxisEndvalue fields and renamed
		        the AxisStartvalue and AxisEndvalue to XAxisStartvalue
			and XAxisEndvalue
08-July-2010 NagaBabu	Interchanged X,Y axis values
12-July-2010 NagaBabu   Changed XAxisStartvalue,XAxisEndvalue values Deleted Datetaken
                        field and Modified Datetaken1 field as Datetaken field 
10-Aug-2010 NagaBabu ORDER BYclause changed to DESC                          		
7-Oct-10 Pramod Set default NULL for @i_MeasureId and changed declare table, select to include measureid
23-Oct-10 Pramod Modified the Last SQL (with Max, Min measure data)
21-Feb-11 Rathnam added isnull condition for final select statement columns.
05-May-11 Rathnam removed the order by desc clause from first select statement
20-May-11 Rathnam added where clause DateTaken IS NOT NULL
11-July-2011 NagaBabu Replaced CONVERT function as CAST Function
19-July-2011 NagaBabu Added join condition with select querry in first resultset
05-Sep-2011 Rathnam commented Derived table for getting all the values of values of a measure 
13-Sep-2011 NagaBabu Added the Functionality to get only Mastermeasures(Including respective synonyms) 
15-Sep-2011 NagaBabu Added Distint keyword in first resultset Query 
29-July-2013 Rathnam removed the measure join and kept Loinc code join
------------------------------------------------------------------------------                
*/  
CREATE PROCEDURE [dbo].[usp_UserMeasure_Select_ByUserId_MeasureId]--23,null,5
(
 @i_AppUserId KEYID ,
 @i_MeasureId KEYID = NULL,
 @i_PatientUserId KEYID
)
AS
BEGIN TRY
      SET NOCOUNT ON                 
-- Check if valid Application User ID is passed              

      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END

      DECLARE @MeasureValue TABLE
      (
        Datetaken DATETIME ,
        MeasureValue DECIMAL(10,2),
        MeasureId KeyID ,
        Name VARCHAR(1000)
      )

      INSERT INTO
          @MeasureValue
          (
            Datetaken ,
            MeasureValue,
            MeasureId,
            Name
          )
          SELECT
              PatientMeasure.DateTaken AS DateTaken ,
              MeasureValueNumeric AS MeasureValue,
              MSR.LOINCCodeID AS MeasureId,
              MSR.LoincCode + ' - ' + MSR.ShortDescription
          FROM
              PatientMeasure WITH(NOLOCK)
          INNER JOIN CodeSetLoinc MSR WITH(NOLOCK)
			  ON PatientMeasure.LOINCCodeID = MSR.LOINCCodeID    
          WHERE                                       
              MSR.LOINCCodeID  = @i_MeasureId
              AND PatientID = @i_PatientUserId
              AND DateTaken IS NOT NULL
              --AND PatientMeasure.StatusCode = 'A'
              AND PatientMeasure.DateTaken BETWEEN GETDATE()-365 AND GETDATE()
         

      SELECT DISTINCT
          MSV.Datetaken  AS Datetaken ,
          ISNULL(MSV.MeasureValue,0)AS MeasureValue,
          MeasureId,
          Name
      FROM
          @MeasureValue MSV
	  ORDER BY 	Datetaken 	

 
	  DECLARE @tabMeasureRange TABLE 
			(  YAxisStartvalue DECIMAL(10,2), YAxisEndvalue DECIMAL(10,2), 
			   XAxisStartvalue DATETIME, XAxisEndvalue DATETIME, MeasureId INT )
			   
	  INSERT INTO @tabMeasureRange 
      SELECT
          CEILING(MIN(MeasureValue) - ( MIN(MeasureValue) / 5 )) AS YAxisStartvalue ,
          CEILING(MAX(MeasureValue) + ( MAX(MeasureValue) / 5 )) AS YAxisEndvalue ,
          MIN(Datetaken) AS XAxisStartvalue ,
          MAX(Datetaken) AS XAxisEndvalue,
          MeasureId
      FROM
          @MeasureValue
      GROUP BY MeasureId

	  SELECT CASE WHEN YAxisStartvalue > YAxisEndvalue THEN ISNULL(YAxisEndvalue,0) ELSE ISNULL(YAxisStartvalue,0) END AS YAxisStartvalue,
			 CASE WHEN YAxisStartvalue > YAxisEndvalue THEN ISNULL(YAxisStartvalue,0) ELSE ISNULL(YAxisEndvalue,0) END AS YAxisEndvalue,
			 CAST(XAxisStartvalue AS DATE) AS XAxisStartvalue,
			 CAST(XAxisEndvalue AS DATE) AS XAxisEndvalue,
			 MeasureId 
		FROM @tabMeasureRange

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
    ON OBJECT::[dbo].[usp_UserMeasure_Select_ByUserId_MeasureId] TO [FE_rohit.r-ext]
    AS [dbo];

