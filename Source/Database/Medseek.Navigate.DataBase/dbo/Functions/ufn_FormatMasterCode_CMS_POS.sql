

CREATE FUNCTION [dbo].[ufn_FormatMasterCode_CMS_POS]
(
	@CMS_POSCode varchar(10)
)
RETURNS varchar(2)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @CMS_POSCode = The CMS Place of Service Code to be formatted.

	 @MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.

	 @MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.

	 @RemoveALLBlanks = Indicator of whether to remove or filter-out ALL Blanks or Empty String (" ") from the CMS Place of Service Code to be
						formatted.

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
   WHERE [CodeTypeCode] = 'CMS_POS'


   /* Removes Blanks (" ") from the Code to be formatted. */

   -- Removes both 'Leading' and 'Trailing' Blanks (" ") from the Code to be formmated. --
   SET @CMS_POSCode = RTRIM(LTRIM(@CMS_POSCode));

   -- Removes ALL Other Blanks (" ") from the Code to be formatted. --
   IF @RemoveALLBlanks = 1
	  SET @CMS_POSCode = REPLACE(@CMS_POSCode, ' ', '');


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @CMS_POSCode = ''
	  SET @CMS_POSCode = NULL;


   /* Removes 'Leading Zeros' from the Code being formatted, if 'Leading Zeros' are to be removed from the
	  formatted code (RemoveLeadingZeros = 1). */
   IF @RemoveLeadingZeros = 1
   BEGIN
   	  SET @StrLen = LEN(@CMS_POSCode);
   	  
   	  SET @CurrentPtr = 1;
   	  
   	  WHILE (@CurrentPtr < @StrLen)
   	  BEGIN
		 IF SUBSTRING(@CMS_POSCode, @CurrentPtr, 1) <> '0'
			BREAK;

		 SET @CurrentPtr = @CurrentPtr + 1
	  END

	  SET @CMS_POSCode = SUBSTRING(@CMS_POSCode, @CurrentPtr, @StrLen);
   END


   /* Removes 'Trailing Zeros' from the Code being formatted, if 'Trailing Zeros' are to be removed from the
	  formatted code (RemoveTrailingZeros = 1). */
   IF @RemoveTrailingZeros = 1
   BEGIN
	  SET @StrLen = LEN(@CMS_POSCode);

	  WHILE (@StrLen > 1)
	  BEGIN
		 IF SUBSTRING(@CMS_POSCode, @StrLen, 1) <> '0'
			BREAK;

		 SET @StrLen = @StrLen - 1;

	  END

	  SET @CMS_POSCode = SUBSTRING(@CMS_POSCode, 1, @StrLen);
   END


   /* Checks and verifies that the Code meets the 'Numeric Digits' requirement of the type of the
	  Formatted Code.  Otherwise, no Code (NULL) is outputed. */
   SET @StrLen = LEN(@CMS_POSCode);

   SET @StrChr = SUBSTRING(@CMS_POSCode, 1, @StrLen);

   IF (ISNUMERIC(@StrChr) = 0) OR (@StrChr LIKE '%.%')
	  SET @CMS_POSCode = NULL;


   /* Checks if the Formatted Code exceeds the MINIMUM 'Code Length' requirement of its Code Type.  If Yes, the Formatted Code
	  is padded with Leading Zeros, upto the MINIMUM 'Code Length' of the Code Type of the Code. */
   IF (LEN(@CMS_POSCode) >= 1) AND (LEN(@CMS_POSCode) < @MinimumNumDigits)
   BEGIN
	  IF @PadWithLeadingZeros = 1
		 SET @CMS_POSCode = '0' + @CMS_POSCode;
   END


   /* Checks if the Formatted Code exceeds the MAXIMUM 'Code Length' requirement of its Code Type.  If Yes, not Code (NULL)
	  is outputed. */
   IF (LEN(@CMS_POSCode) > @MinimumNumDigits) OR (LEN(@CMS_POSCode) > @MaximumNumDigits)
	  SET @CMS_POSCode = NULL;


   -- Outputs the Formatted Code, or NULL. --
   RETURN (@CMS_POSCode);

END;

