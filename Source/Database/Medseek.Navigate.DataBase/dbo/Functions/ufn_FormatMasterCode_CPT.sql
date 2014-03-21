

CREATE FUNCTION [dbo].[ufn_FormatMasterCode_CPT]
(
	@CPTCode varchar(10)
)
RETURNS varchar(5)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @CPTCode = The CPT Procedure Code (CPT-I, CPT-II, and CPT-III) to be formatted.

	 @MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.

	 @MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.

	 @RemoveALLBlanks = Indicator of whether to remove or filter-out ALL Blanks or Empty String (" ") from the CPT Procedure Code to be formatted.

	 @RemoveLeadingZeros = Indicator of whether to remove or filter-out Leading Zeros (0's) from the CPT Procedure Code to be formatted.

	 @RemoveTrailingZeros = Indicator of whether to remove or filter-out Trailing Zeros (0's) from the CPT Procedure Code to be formatted.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint,
	
			@RemoveALLBlanks bit,
			@RemoveLeadingZeros bit,
			@RemoveTrailingZeros bit,

			@StrLen int,
			@CurrentPtr int,
			@StrChr varchar(10)


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits],
		  @RemoveALLBlanks = [RemoveALLBlanks], @RemoveLeadingZeros = [RemoveLeadingZeros],
		  @RemoveTrailingZeros = [RemoveTrailingZeros]
   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'CPT'


   /* Removes Blanks (" ") from the Code to be formatted. */

   -- Removes both 'Leading' and 'Trailing' Blanks (" ") from the Code to be formmated. --
   SET @CPTCode = RTRIM(LTRIM(@CPTCode));

   -- Removes ALL Other Blanks (" ") from the Code to be formatted. --
   IF @RemoveALLBlanks = 1
	  SET @CPTCode = REPLACE(@CPTCode, ' ', '');


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @CPTCode = ''
	  SET @CPTCode = NULL;


   /* Removes 'Leading Zeros' from the Code being formatted, if 'Leading Zeros' are to be removed from the
	  formatted code (RemoveLeadingZeros = 1). */
   IF @RemoveLeadingZeros = 1
   BEGIN
   	  SET @StrLen = LEN(@CPTCode);
   	  
   	  SET @CurrentPtr = 1;
   	  
   	  WHILE (@CurrentPtr < @StrLen)
   	  BEGIN
		 IF SUBSTRING(@CPTCode, @CurrentPtr, 1) <> '0'
			BREAK;

		 SET @CurrentPtr = @CurrentPtr + 1
	  END

	  SET @CPTCode = SUBSTRING(@CPTCode, @CurrentPtr, @StrLen);
   END


   /* Removes 'Trailing Zeros' from the Code being formatted, if 'Trailing Zeros' are to be removed from the
	  formatted code (RemoveTrailingZeros = 1). */
   IF @RemoveTrailingZeros = 1
   BEGIN
	  SET @StrLen = LEN(@CPTCode);

	  WHILE (@StrLen > 1)
	  BEGIN
		 IF SUBSTRING(@CPTCode, @StrLen, 1) <> '0'
			BREAK;

		 SET @StrLen = @StrLen - 1;

	  END

	  SET @CPTCode = SUBSTRING(@CPTCode, 1, @StrLen);
   END


   /* Checks and verifies that the Code meets the 'Numeric Digits' requirement of the type of the
	  Formatted Code.  Otherwise, no Code (NULL) is outputed. */
   SET @StrLen = LEN(@CPTCode);

   SET @StrChr = SUBSTRING(@CPTCode, 1, @StrLen - 1);

   IF (ISNUMERIC(@StrChr) = 0) OR (@StrChr LIKE '%.%')
	  SET @CPTCode = NULL;


   /* Checks and verifies that the Code meets the 'LAST-Digit' coding requirement of the type of
	  the Formatted Code.  Otherwise, no Code (NULL) is outputed. */
   SET @StrChr = SUBSTRING(@CPTCode, @StrLen, 1);

   -- Sets the value of the Code to NULL, if the Formatted Code DOES NOT meets the 'LAST-Digit' --
   -- requirements of the Code. --
   IF (ISNUMERIC(@StrChr) = 0) AND (@StrChr <> 'F') AND (@StrChr <> 'T')
	  SET @CPTCode = NULL;


   /* Verifies that the code being formatted code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM -- of Codes
	  of its Code Type. */
   IF (LEN(@CPTCode) < @MinimumNumDigits) OR (LEN(@CPTCode) > @MaximumNumDigits)
	  SET @CPTCode = NULL;


   -- Outputs the Formatted Code, or NULL. --
   RETURN (@CPTCode);

END;

