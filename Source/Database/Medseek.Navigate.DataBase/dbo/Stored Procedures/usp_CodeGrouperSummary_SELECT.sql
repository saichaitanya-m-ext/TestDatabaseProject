/*   
   
------------------------------------------------------------------------------------------          
Procedure Name: [usp_CodeGrouperSummary_SELECT] 2,2
Description   : This procedure is used to select all the codegroupers and 
Created By    : Santosh          
Created Date  : 12-August-2013
------------------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION      
-------------------------------------------------------------------------------------------          
*/


CREATE PROCEDURE [dbo].[usp_CodeGrouperSummary_SELECT]
	(
	@i_AppUserId KEYID,
	@i_CodeGroupingTypeID KEYID = NULL
   ,@i_CodegroupersID KEYID = NULL
   ,@i_CodeGroupingSourceID KEYID = NULL
   ,@vc_CodegroupingName VARCHAR(20) = NULL
	,@b_display BIT = 0
	
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @i_numberOfRecordsSelected INT

	----- Check if valid Application User ID is passed--------------          
	IF (@i_AppUserId IS NULL)
		OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR (
				N'Invalid Application User ID %d passed.'
				,17
				,1
				,@i_AppUserId
				)
	END


IF @b_display = 0
  BEGIN
		
		--SELECT CTG.CodeTypeGroupersID,
		--CGT.CodeGroupType,
		--CodeTypeGroupersName,
		--ctg.CodeTypeShortDescription,
		--COUNT(CodeGroupingID) AS CountOfCodegroups
		--FROM  CodeTypeGroupers CTG 
		--INNER JOIN CodeGroupingType CGT
		-- ON CGT.CodeGroupingTypeID = CTG.CodeGroupingTypeID
		--INNER JOIN CodeGrouping C
		-- ON C.CodeTypeGroupersID = CTG.CodeTypeGroupersID
		--WHERE CTG.StatusCode = 'A'
		--AND (C.CodeTypeGroupersID = @i_CodeGroupingTypeID OR @i_CodeGroupingTypeID IS NULL)
		--AND (CGT.CodeGroupingTypeID = @i_CodeGroupingTypeID OR @i_CodeGroupingTypeID IS NULL)
		--AND (C.CodeGroupingID = @i_CodeGroupingSource OR @i_CodeGroupingSource IS NULL)
		--GROUP BY CTG.CodeTypeGroupersID,
		--CodeTypeGroupersName,
		--ctg.CodeTypeShortDescription,
		--CGT.CodeGroupType
		--ORDER BY CTG.CodeTypeGroupersID
		--AND (CodeTypeGroupersID = @i_CodetypeGroupersid OR @i_CodetypeGroupersid IS NULL)
		
		
		IF @vc_CodegroupingName <> 'HEDIS-ECT'
		 BEGIN
		SELECT DISTINCT CG.CodeGroupingID,
		       CG.CodeGroupingName,
		       CG.CodeGroupingDescription ,
		       ct.CodeTypeCode AS ECTHedisCodeTypeCode
		   FROM CodeGrouping CG
		 INNER JOIN CodeTypeGroupers C
		  ON C.CodeTypeGroupersID = CG.CodeTypeGroupersID 
		 INNER JOIN CodeGroupingDetailInternal CGD
		  ON CG.CodeGroupingID = CGD.CodeGroupingID
		 INNER JOIN LkUpCodeType ct
		  ON CGD.CodeGroupingCodeTypeID = ct.CodeTypeID
		 WHERE (CG.CodeTypeGroupersID = @i_CodegroupersID OR @i_CodegroupersID IS NULL)
		 AND (C.CodeGroupingTypeID = @i_CodeGroupingTypeID OR @i_CodeGroupingTypeID IS NULL)
		 AND (CG.CodeGroupingID = @i_CodeGroupingSourceID OR @i_CodeGroupingSourceID IS NULL)
				       
		 		
		END

ELSE
 BEGIN
 
  SELECT DISTINCT CodeGrouping.CodeGroupingID,
                  CodeGrouping.CodeGroupingName,
                  CodeGrouping.CodeGroupingDescription,
                  CodeSetECTHedisCodeType.ECTHedisCodeTypeCode 
		FROM CodeGrouping
		INNER JOIN CodeTypeGroupers 
		 ON CodeGrouping.CodeTypeGroupersID = CodeTypeGroupers.CodeTypeGroupersID 
		INNER JOIN CodeGroupingECTTable 
		 ON CodeGrouping.CodeGroupingID = CodeGroupingECTTable.CodeGroupingID
		AND CodeGroupingECTTable.ECTHedisCodeTypeID IS NULL
		INNER JOIN CodeSetHEDIS_ECTCode
	  	 ON CodeGroupingECTTable.ECThedisTableID = CodeSetHEDIS_ECTCode.ECTHedisTableID
		INNER JOIN CodeSetECTHedisCodeType
		 ON CodeSetHEDIS_ECTCode.ECTHedisCodeTypeID = CodeSetECTHedisCodeType.ECTHedisCodeTypeID
		WHERE (CodeGrouping.CodeTypeGroupersID = @i_CodegroupersID OR @i_CodegroupersID IS NULL)
		AND (CodeTypeGroupers.CodeGroupingTypeID = @i_CodeGroupingTypeID OR @i_CodeGroupingTypeID IS NULL) 
		AND (CodeGrouping.CodeGroupingID = @i_CodeGroupingSourceID OR @i_CodeGroupingSourceID IS NULL)
 
 UNION
 
   SELECT DISTINCT CodeGrouping.CodeGroupingID,
                  CodeGrouping.CodeGroupingName,
                  CodeGrouping.CodeGroupingDescription,
                  CodeSetECTHedisCodeType.ECTHedisCodeTypeCode 
	        FROM CodeGrouping
			INNER JOIN CodeTypeGroupers 
			 ON CodeGrouping.CodeTypeGroupersID = CodeTypeGroupers.CodeTypeGroupersID 
			INNER JOIN CodeGroupingECTTable 
			 ON CodeGrouping.CodeGroupingID = CodeGroupingECTTable.CodeGroupingID
			AND CodeGroupingECTTable.ECTHedisCodeTypeID IS NOT NULL 
			INNER JOIN CodeSetHEDIS_ECTCode
			 ON CodeGroupingECTTable.ECThedisTableID = CodeSetHEDIS_ECTCode.ECTHedisTableID
			AND CodeGroupingECTTable.ECTHedisCodeTypeID = CodeSetHEDIS_ECTCode.ECTHedisCodeTypeID
			INNER JOIN CodeSetECTHedisCodeType
			 ON CodeSetHEDIS_ECTCode.ECTHedisCodeTypeID = CodeSetECTHedisCodeType.ECTHedisCodeTypeID
			WHERE (CodeGrouping.CodeTypeGroupersID = @i_CodegroupersID OR @i_CodegroupersID IS NULL)
			AND (CodeTypeGroupers.CodeGroupingTypeID = @i_CodeGroupingTypeID OR @i_CodeGroupingTypeID IS NULL) 
			AND (CodeGrouping.CodeGroupingID = @i_CodeGroupingSourceID OR @i_CodeGroupingSourceID IS NULL)
 
 
 END		
		
		
		
 END
 
ELSE
  IF @b_display = 1

BEGIN


		SELECT CTG.CodeTypeGroupersID,
        CGT.CodeGroupType,
		CodeTypeGroupersName,
		ctg.CodeTypeShortDescription		
		FROM  CodeTypeGroupers CTG 
		INNER JOIN CodeGroupingType CGT
		 ON CGT.CodeGroupingTypeID = CTG.CodeGroupingTypeID
		INNER JOIN CodeGrouping C
		 ON C.CodeTypeGroupersID = CTG.CodeTypeGroupersID
		WHERE CTG.StatusCode = 'A'
		GROUP BY CTG.CodeTypeGroupersID,
		CodeTypeGroupersName,
		ctg.CodeTypeShortDescription,
		CGT.CodeGroupType
		ORDER BY CTG.CodeTypeGroupersID

END 
		 
		
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
    ON OBJECT::[dbo].[usp_CodeGrouperSummary_SELECT] TO [FE_rohit.r-ext]
    AS [dbo];

