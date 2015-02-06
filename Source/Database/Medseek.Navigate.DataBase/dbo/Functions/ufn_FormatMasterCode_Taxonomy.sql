

CREATE FUNCTION [dbo].[ufn_FormatMasterCode_Taxonomy]
(
	@TaxonomyCode varchar(10)
)
RETURNS varchar(10)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @TaxonomyCode = The "Health Care Provider Taxonomy" Code to be formatted.

	 @MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.

	 @MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.

	 @RemoveALLBlanks = Indicator of whether to remove or filter-out ALL Blanks or Empty String (" ") from the Provider Taxonomy Code to be
						formatted.

	 @RemoveLeadingZeros = Indicator of whether to remove or filter-out Leading Zeros (0's) from the Provider Taxonomy Code to be formatted.

	 @RemoveTrailingZeros = Indicator of whether to remove or filter-out Trailing Zeros (0's) from the Provider Taxonomy Code to be formatted.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint,
	
			@RemoveALLBlanks bit,
			@RemoveLeadingZeros bit,
			@RemoveTrailingZeros bit,

			@StrLen int,
			@CurrentPtr int,
			@StrChr varchar(1)


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits],
		  @RemoveALLBlanks = [RemoveALLBlanks], @RemoveLeadingZeros = [RemoveLeadingZeros],
		  @RemoveTrailingZeros = [RemoveTrailingZeros]
   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'Taxonomy'


   /* Removes Blanks (" ") from the Code to be formatted. */

   -- Removes both 'Leading' and 'Trailing' Blanks (" ") from the Code to be formmated. --
   SET @TaxonomyCode = RTRIM(LTRIM(@TaxonomyCode));

   -- Removes ALL Other Blanks (" ") from the Code to be formatted. --
   IF @RemoveALLBlanks = 1
	  SET @TaxonomyCode = REPLACE(@TaxonomyCode, ' ', '');


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @TaxonomyCode = ''
	  SET @TaxonomyCode = NULL;


   /* Removes 'Leading Zeros' from the Code being formatted, if 'Leading Zeros' are to be removed from the
	  formatted code (RemoveLeadingZeros = 1). */
   IF @RemoveLeadingZeros = 1
   BEGIN
   	  SET @StrLen = LEN(@TaxonomyCode);

   	  SET @CurrentPtr = 1;

   	  WHILE (@CurrentPtr < @StrLen)
   	  BEGIN
		 IF SUBSTRING(@TaxonomyCode, @CurrentPtr, @CurrentPtr) <> '0'
			BREAK;

		 SET @CurrentPtr = @CurrentPtr + 1
	  END

	  SET @TaxonomyCode = SUBSTRING(@TaxonomyCode, @CurrentPtr, @StrLen);
   END


   /* Removes 'Trailing Zeros' from the Code being formatted, if 'Trailing Zeros' are to be removed from the
	  formatted code (RemoveTrailingZeros = 1). */
   IF @RemoveTrailingZeros = 1
   BEGIN
	  SET @StrLen = LEN(@TaxonomyCode);

	  WHILE (@StrLen > 1)
	  BEGIN
		 IF (SUBSTRING(@TaxonomyCode, @StrLen, @StrLen) = '0')
			SET @StrLen = @StrLen - 1
		 ELSE
			BREAK
	  END

	  SET @TaxonomyCode = SUBSTRING(@TaxonomyCode, 1, @StrLen);
   END


   /* Checks and verifies that the Code does not contain a Decimal Point (.) or a Dash (-). */
   IF (@TaxonomyCode LIKE '%.%') OR (@TaxonomyCode LIKE '%-%')
	  SET @TaxonomyCode = NULL;


   /* Verifies that the code being formatted code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM -- of Codes
	  of its Code Type. */
   IF (LEN(@TaxonomyCode) < @MinimumNumDigits) OR (LEN(@TaxonomyCode) > @MaximumNumDigits)
	  SET @TaxonomyCode = NULL;


   -- Outputs the Formatted Code, or NULL. --
   RETURN (@TaxonomyCode);

END;

