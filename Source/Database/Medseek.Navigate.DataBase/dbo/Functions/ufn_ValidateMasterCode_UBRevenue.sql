

CREATE FUNCTION [dbo].[ufn_ValidateMasterCode_UBRevenue]
(
	@UBRevenueCode varchar(10)
)
RETURNS varchar(4)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @UBRevenueCode = The "UB Revenue" Code to be formatted.

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
			@StrChr varchar(10)


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits],
		  @RemoveLeadingZeros = [RemoveLeadingZeros], @RemoveTrailingZeros = [RemoveTrailingZeros]
   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'UB-Revenue'


   /* Removes Blanks (" ") -- both 'Leading' and 'Trailing' -- from the Code being validated.
	  Otherwise, no Code (NULL) is outputed. */
   SET @UBRevenueCode = RTRIM(LTRIM(@UBRevenueCode));


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @UBRevenueCode = ''
	  SET @UBRevenueCode = NULL;


   /* Checks and verifies that the Code meets the 'Numeric Digits' requirement of the type of the
	  Formatted Code.  Otherwise, no Code (NULL) is outputed. */
   SET @StrLen = LEN(@UBRevenueCode);

   SET @StrChr = SUBSTRING(@UBRevenueCode, 1, @StrLen);

   IF (ISNUMERIC(@StrChr) = 0) OR (@StrChr LIKE '%.%')
	  SET @UBRevenueCode = NULL;


   /* Verifies that the Code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM --
	  of Codes of its Code Type.  Otherwise, no Code (NULL) is outputed. */
   IF (LEN(@UBRevenueCode) < @MinimumNumDigits) OR (LEN(@UBRevenueCode) > @MaximumNumDigits)
	  SET @UBRevenueCode = NULL;


   -- Outputs the Formatted Code, or NULL. --
   RETURN (@UBRevenueCode);

END;

