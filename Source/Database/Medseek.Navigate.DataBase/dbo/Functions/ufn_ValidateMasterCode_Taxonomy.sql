

CREATE FUNCTION [dbo].[ufn_ValidateMasterCode_Taxonomy]
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

	 @RemoveLeadingZeros = Indicator of whether to remove or filter-out Leading Zeros (0's) from the NPI Code to be formatted.

	 @RemoveTrailingZeros = Indicator of whether to remove or filter-out Trailing Zeros (0's) from the NPI Code to be formatted.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint,
			@RemoveLeadingZeros bit,
			@RemoveTrailingZeros bit,

			@StrLen int,
			@CurrentPtr int
	

   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits],
		  @RemoveLeadingZeros = [RemoveLeadingZeros], @RemoveTrailingZeros = [RemoveTrailingZeros]
   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'Taxonomy'


   /* Removes Blanks (" ") -- both 'Leading' and 'Trailing' -- from the Code being validated.
	  Otherwise, no Code (NULL) is outputed. */
   SET @TaxonomyCode = RTRIM(LTRIM(@TaxonomyCode));


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @TaxonomyCode = ''
	  SET @TaxonomyCode = NULL;


   /* Checks and verifies that the Code does not contain a Decimal Point (.) or a Dash (-). */
   IF (@TaxonomyCode LIKE '%.%') OR (@TaxonomyCode LIKE '%-%')
	  SET @TaxonomyCode = NULL;


   /* Verifies that the code being formatted code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM -- of Codes
	  of its Code Type. */
   IF (LEN(@TaxonomyCode) < @MinimumNumDigits) OR (LEN(@TaxonomyCode) > @MaximumNumDigits)
	  SET @TaxonomyCode = NULL;


   -- Outputs the Successfully-Validate Code, or NULL. --
   RETURN (@TaxonomyCode);

END;

