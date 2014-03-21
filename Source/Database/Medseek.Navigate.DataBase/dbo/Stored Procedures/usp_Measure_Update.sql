/*      
------------------------------------------------------------------------------      
Procedure Name: usp_Measure_Update      
Description   : This procedure is used to update record in Measure table  
Created By    : Aditya      
Created Date  : 15-Apr-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
01-Mar-2011 NagaBabu Added RealisticMin,RealisticMax fields as well as Perameters in Update statement 
27-July-2011 NagaBabu Added @i_MeasureTextOptionId as this new field added to the table Measure
28-July-2011 Rathnam added isVital column in update statement
22-Sep-2011 Rathnam added IF @vc_StatusCode = 'I' for measuresynonyms
17-Oct-2012 Rathnam added @v_CPTList, @v_CPTList parameters	
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_Measure_Update]
(
 @i_AppUserId KEYID
,@vc_Name SOURCENAME
,@vc_Description LONGDESCRIPTION
,@i_MeasureTypeId KEYID
,@i_SortOrder STID
,@vc_StatusCode STATUSCODE
,@i_StandardMeasureUOMId KEYID = NULL
,@vc_isVital ISINDICATOR
,@vc_IsTextValueForControls ISINDICATOR
,@i_MeasureId KEYID
,@d_RealisticMin DECIMAL(10,2)
,@d_RealisticMax DECIMAL(10,2)
,@i_MeasureTextOptionId KEYID
,@tblLoincList TTYPEKEYID READONLY
,@tblCPTList TTYPEKEYID READONLY
)
AS
BEGIN TRY

      SET NOCOUNT ON
      DECLARE @l_numberOfRecordsUpdated INT     
	 -- Check if valid Application User ID is passed      
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END

      UPDATE
          Measure
      SET
          Name = @vc_Name
         ,Description = @vc_Description
         ,MeasureTypeId = @i_MeasureTypeId
         ,SortOrder = @i_SortOrder
         ,StatusCode = @vc_StatusCode
         ,StandardMeasureUOMId = @i_StandardMeasureUOMId
         ,IsTextValueForControls = @vc_IsTextValueForControls
         ,LastModifiedByUserId = @i_AppUserId
         ,LastModifiedDate = GETDATE()
         ,RealisticMin = @d_RealisticMin
         ,RealisticMax = @d_RealisticMax
         ,MeasureTextOptionId = @i_MeasureTextOptionId
         ,IsVital = @vc_isVital
			 --LoincList = @v_LoincList,
	   --      CPTList  = @v_CPTList        
      WHERE
          MeasureId = @i_MeasureId

      SELECT
          @l_numberOfRecordsUpdated = @@ROWCOUNT

      IF @l_numberOfRecordsUpdated <> 1
         BEGIN
               RAISERROR ( N'Invalid Row count %d passed to update Measure'
               ,17
               ,1
               ,@l_numberOfRecordsUpdated )
         END

      IF @vc_StatusCode = 'I'
         BEGIN

               UPDATE
                   Measure
               SET
                   IsSynonym = 0
               FROM
                   Measure m
                   INNER JOIN MeasureSynonyms ms
                   ON ms.SynonymMeasureID = m.MeasureId
               WHERE
                   ms.SynonymMasterMeasureID = @i_MeasureId

               DELETE  FROM
                       MeasureSynonyms
               WHERE
                       SynonymMasterMeasureID = @i_MeasureId

         END

      UPDATE
          ProcedureMeasure
      SET
          StatusCode = 'I'
      WHERE
          MeasureId = @i_MeasureId
          AND NOT EXISTS ( SELECT
                               1
                           FROM
                               @tblCPTList t
                           WHERE
                               t.tKeyId = ProcedureMeasure.ProcedureId )

      UPDATE
          ProcedureMeasure
      SET
          StatusCode = 'A'
      WHERE
          MeasureId = @i_MeasureId
          AND EXISTS ( SELECT
                           1
                       FROM
                           @tblCPTList t
                       WHERE
                           t.tKeyId = ProcedureMeasure.ProcedureId )

      INSERT INTO
          ProcedureMeasure
          (
            MeasureId
          ,ProcedureId
          ,StatusCode
          ,CreatedByUserId
          )
          SELECT
              @i_MeasureId
             ,tKeyId
             ,'A'
             ,@i_AppUserId
          FROM
              @tblCPTList t
          WHERE
              NOT EXISTS ( SELECT
                               1
                           FROM
                               ProcedureMeasure pm
                           WHERE
                               pm.ProcedureId = t.tKeyId
                               AND pm.MeasureId = @i_MeasureId )

      UPDATE
          LoinCodeMeasure
      SET
          StatusCode = 'I'
      WHERE
          MeasureId = @i_MeasureId
          AND NOT EXISTS ( SELECT
                               1
                           FROM
                               @tblLoincList t
                           WHERE
                               t.tKeyId = LoinCodeMeasure.LoinCodeId )

      UPDATE
          LoinCodeMeasure
      SET
          StatusCode = 'A'
      WHERE
          MeasureId = @i_MeasureId
          AND EXISTS ( SELECT
                           1
                       FROM
                           @tblLoincList t
                       WHERE
                           t.tKeyId = LoinCodeMeasure.LoinCodeId )

      INSERT INTO
          LoinCodeMeasure
          (
            MeasureId
          ,LoinCodeId
          ,StatusCode
          ,CreatedByUserId
          )
          SELECT
              @i_MeasureId
             ,tKeyId
             ,'A'
             ,@i_AppUserId
          FROM
              @tblLoincList t
          WHERE
              NOT EXISTS ( SELECT
                               1
                           FROM
                               LoinCodeMeasure lc
                           WHERE
                               lc.LoinCodeId = t.tKeyId
                               AND lc.MeasureId = @i_MeasureId )





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
    ON OBJECT::[dbo].[usp_Measure_Update] TO [FE_rohit.r-ext]
    AS [dbo];

