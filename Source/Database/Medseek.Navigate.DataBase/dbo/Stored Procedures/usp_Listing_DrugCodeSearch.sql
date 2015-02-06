
/*          
----------------------------------------------------------------------------------          
Procedure Name: [usp_Listing_DrugCodeSearch]  2,1
Description   : This procedure is used to select Drug Codes based on the search           
  criteria          
Created By    : Balla Kalyan          
Created Date  : 01-Mar-2010          
----------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
2-Jul-10 Pramod Added CodeSetDrug.DrugCode into the select  
04-Nov-2010 Rathnam removed the left join and kept Inner join condition.   
changed joins to start with codesetdrug and etc (included TOP 500)  
19-Jan-2011 Pramod Used listings.Strength (earlier, it was CodeSetDrugListingsFormulation.strength)  
11-may-2011: bhimashankar changed where condition   
18-JULY-2011 Pramod Modified NDC,Unit,RXOTC FIELDS  
19-Jul-2011 Pramod Modified the query for inline not null from listings.TradeName
					with CodeSetDrug.DrugName
09-Aug-2011 NagaBabu Added ISNULL condition for FirmName,Unit,Strength,IngredientName fields
12-Sep-2011 NagaBabu Replaced @v_Segment1,@v_Segment2 Perameters by @v_NDCCode	
15-Sep-2011 NagaBabu Modified searching criteria for Strength to Listings from CodeSetDrugListingsFormulation	
21-Mar-2012 Gurumoorthy.V removed @v_Segment1,@v_Segment2 parameters  and changed the LEFT JOIN 
			instead of INNER JOIN to get the correct records
04-Apr-2012 Gurumoorthy.V removed duplicate column(CodeSetDrug.DrugCode)
----------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_Listing_DrugCodeSearch] @i_AppUserId KEYID
	,@v_TradeName SHORTDESCRIPTION = NULL
	,@v_FirmName VARCHAR(65) = NULL
	,@v_NDCCode VARCHAR(15) = NULL
	,@v_IngredientName VARCHAR(100) = NULL
	,@v_Strength VARCHAR(10) = NULL
	,@v_DrugType VARCHAR(2) = NULL
	,@i_inline KEYID = 1
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @i_numberOfRecordsSelected INT

	SET ROWCOUNT 500

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

	--------- search Drug Codes from the search criteria ----------------          
	IF (@i_inline = 1)
		SELECT DISTINCT CSD.DrugCodeId AS ListingSequenceNo
			,CSD.NonProprietaryName AS TradeName
			,CSD.LabelerID AS FirmID
			,ISNULL(CSD.FirmName, '') AS FirmName
			,CSD.DrugCode AS NDC
			,ISNULL(CSD.Unit, '') AS Unit
			,ISNULL(CSD.Strength, '') AS Strength
			,ISNULL(CSD.IngredientName, '') AS IngredientName
			,'' AS RXOTC
			,CSD.DrugCodeId
			,CSD.DrugName
		FROM vw_CodeSetDrug CSD
		WHERE ((CSD.DrugCode + '-' + ISNULL(CSD.DrugName, '')) LIKE '%' + @v_TradeName + '%')
		ORDER BY CSD.DrugCodeId
	ELSE
		SELECT DISTINCT CSD.DrugCodeId AS ListingSequenceNo
			,CSD.NonProprietaryName AS TradeName
			,CSD.LabelerID AS FirmID
			,ISNULL(CSD.FirmName, '') AS FirmName
			,CSD.DrugCode AS NDC
			,ISNULL(CSD.Unit, '') AS Unit
			,ISNULL(CSD.Strength, '') AS Strength
			,ISNULL(CSD.IngredientName, '') AS IngredientName
			,'' AS RXOTC
			,CSD.DrugCodeId
			,CSD.DrugName
		FROM vw_CodeSetDrug CSD
		WHERE (
				(CSD.NonProprietaryName LIKE @v_TradeName + '%')
				OR @v_TradeName IS NULL
				OR @v_TradeName = ''
				)
			AND (
				(CSD.FirmName LIKE @v_FirmName + '%')
				OR @v_FirmName IS NULL
				OR @v_FirmName = ''
				)
			AND (
				(CSD.DrugCode LIKE @v_NDCCode + '%')
				OR @v_NDCCode IS NULL
				OR @v_NDCCode = ''
				)
			AND (
				(CSD.IngredientName LIKE @v_IngredientName + '%')
				OR @v_IngredientName IS NULL
				OR @v_IngredientName = ''
				)
			AND (
				(CSD.Strength LIKE @v_Strength + '%')
				OR @v_Strength IS NULL
				OR @v_Strength = ''
				)
		ORDER BY CSD.DrugCodeID
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
    ON OBJECT::[dbo].[usp_Listing_DrugCodeSearch] TO [FE_rohit.r-ext]
    AS [dbo];

