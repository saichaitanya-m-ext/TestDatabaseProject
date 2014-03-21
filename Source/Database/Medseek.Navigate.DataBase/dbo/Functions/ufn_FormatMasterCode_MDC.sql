

CREATE FUNCTION [dbo].[ufn_FormatMasterCode_MDC]
(
	@MDCCode varchar(10)
)
RETURNS varchar(2)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @MDCCode = The MDC Code to be formatted.

	 @MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.

	 @MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.

	 @RemoveALLBlanks = Indicator of whether to remove or filter-out ALL Blanks or Empty String (" ") from the MDC Code to be formatted.

	 @RemoveLeadingZeros = Indicator of whether to remove or filter-out Leading Zeros (0's) from the CMS Place of Service Code to be formatted.

	 @RemoveTrailingZeros = Indicator of whether to remove or filter-out Trailing Zeros (0's) from the CMS Place of Service Code to be formatted.

	 @PadWithLeadingZeros = Indicator of whether to pad or fill-in Leading Zeros (0's) from the CMS Place of Service Code to be formatted.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint,
	
			@RemoveALLBlanks bit,
			@RemoveLeadingZeros bit,
			@RemoveTrailingZeros bit,
			@PadWithLeadingZeros bit,

			@StrLen int,
			@CurrentPtr int,
			@StrChr varchar(10)


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits],
		  @RemoveALLBlanks = [RemoveALLBlanks], @RemoveLeadingZeros = [RemoveLeadingZeros],
		  @RemoveTrailingZeros = [RemoveTrailingZeros], @PadWithLeadingZeros = [PadWithLeadingZeros]
   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'MDC'


   /* Removes Blanks (" ") from the Code to be formatted. */

   -- Removes both 'Leading' and 'Trailing' Blanks (" ") from the Code to be formmated. --
   SET @MDCCode = RTRIM(LTRIM(@MDCCode));

   -- Removes ALL Other Blanks (" ") from the Code to be formatted. --
   IF @RemoveALLBlanks = 1
	  SET @MDCCode = REPLACE(@MDCCode, ' ', '');


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @MDCCode = ''
	  SET @MDCCode = NULL;


   /* Removes 'Leading Zeros' from the Code being formatted, if 'Leading Zeros' are to be removed from the
	  formatted code (RemoveLeadingZeros = 1). */
   IF @RemoveLeadingZeros = 1
   BEGIN
   	  SET @StrLen = LEN(@MDCCode);
   	  
   	  SET @CurrentPtr = 1;
   	  
   	  WHILE (@CurrentPtr < @StrLen)
   	  BEGIN
		 IF SUBSTRING(@MDCCode, @CurrentPtr, 1) <> '0'
			BREAK;

		 SET @CurrentPtr = @CurrentPtr + 1
	  END

	  SET @MDCCode = SUBSTRING(@MDCCode, @CurrentPtr, @StrLen);
   END


   /* Removes 'Trailing Zeros' from the Code being formatted, if 'Trailing Zeros' are to be removed from the
	  formatted code (RemoveTrailingZeros = 1). */
   IF @RemoveTrailingZeros = 1
   BEGIN
	  SET @StrLen = LEN(@MDCCode);

	  WHILE (@StrLen > 1)
	  BEGIN
		 IF SUBSTRING(@MDCCode, @StrLen, 1) <> '0'
			BREAK;

		 SET @StrLen = @StrLen - 1;

	  END

	  SET @MDCCode = SUBSTRING(@MDCCode, 1, @StrLen);
   END


   /* Checks and verifies that the Code meets the 'Numeric Digits' requirement of the type of the
	  Formatted Code.  Otherwise, no Code (NULL) is outputed. */
   SET @StrLen = LEN(@MDCCode);

   SET @StrChr = SUBSTRING(@MDCCode, 1, @StrLen);

   IF (ISNUMERIC(@StrChr) = 0) OR (@StrChr LIKE '%.%')
	  SET @MDCCode = NULL;


   /* Checks if the Formatted Code exceeds the MINIMUM 'Code Length' requirement of its Code Type.  If Yes, the Formatted Code
	  is padded with Leading Zeros, upto the MINIMUM 'Code Length' of the Code Type of the Code. */
   IF (LEN(@MDCCode) >= 1) AND (LEN(@MDCCode) < @MinimumNumDigits)
   BEGIN
	  IF @PadWithLeadingZeros = 1
		 SET @MDCCode = '0' + @MDCCode;
   END


   /* Checks if the Formatted Code exceeds the MAXIMUM 'Code Length' requirement of its Code Type.  If Yes, not Code (NULL)
	  is outputed. */
   IF (LEN(@MDCCode) < @MinimumNumDigits) OR (LEN(@MDCCode) > @MaximumNumDigits)
	  SET @MDCCode = NULL;


   -- Outputs the Formatted Code, or NULL. --
   RETURN (@MDCCode);

END;

