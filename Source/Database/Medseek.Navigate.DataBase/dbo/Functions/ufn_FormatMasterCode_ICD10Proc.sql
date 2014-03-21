

CREATE FUNCTION [dbo].[ufn_FormatMasterCode_ICD10Proc]
(
	@ICD10Code varchar(10)
)
RETURNS varchar(7)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @ICD10Code = The ICD-10-CM Procedure Code to be formatted.

	 @MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.

	 @MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.

	 @RemoveALLBlanks = Indicator of whether to remove or filter-out ALL Blanks or Empty String (" ") from the ICD-10-CM Procedure Code to be
						formatted.

	 @RemoveLeadingZeros = Indicator of whether to remove or filter-out Leading Zeros (0's) from the ICD-10-CM Procedure Code to be formatted.

	 @RemoveTrailingZeros = Indicator of whether to remove or filter-out Trailing Zeros (0's) from the ICD-10-CM Procedure Code to be formatted.

	 @PadWithLeadingZeros = Indicator of whether to pad or fill-in Leading Zeros (0's) from the ICD-10-CM Procedure Code to be formatted.

	 @PadWithTrailingZeros = Indicator of whether to pad or fill-in Trailing Zeros (0's) from the ICD-10-CM Procedure Code to be formatted.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint,
	
			@RemoveALLBlanks bit,
			@RemoveLeadingZeros bit,
			@RemoveTrailingZeros bit,
			@PadWithLeadingZeros bit,
			@PadWithTrailingZeros bit,

			@StrLen int,
			@CurrentPtr int,
			@StrChars varchar(3)


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits],
		  @RemoveALLBlanks = [RemoveALLBlanks], @RemoveLeadingZeros = [RemoveLeadingZeros],
		  @RemoveTrailingZeros = [RemoveTrailingZeros], @PadWithLeadingZeros = [PadWithLeadingZeros],
		  @PadWithTrailingZeros = [PadWithTrailingZeros]

   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'ICD-10-CM-Proc'


   /* Removes Blanks (" ") from the Code to be formatted. */

   -- Removes both 'Leading' and 'Trailing' Blanks (" ") from the Code to be formmated. --
   SET @ICD10Code = RTRIM(LTRIM(@ICD10Code));

   -- Removes ALL Other Blanks (" ") from the Code to be formatted. --
   IF @RemoveALLBlanks = 1
	  SET @ICD10Code = REPLACE(@ICD10Code, ' ', '');


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @ICD10Code = ''
	  SET @ICD10Code = NULL;


   /* Removes 'Leading Zeros' from the Code being formatted, if 'Leading Zeros' are to be removed from the
	  formatted code (RemoveLeadingZeros = 1). */
   IF @RemoveLeadingZeros = 1
   BEGIN
   	  SET @StrLen = LEN(@ICD10Code);
   	  
   	  SET @CurrentPtr = 1;
   	  
   	  WHILE (@CurrentPtr < @StrLen)
   	  BEGIN
		 IF SUBSTRING(@ICD10Code, @CurrentPtr, 1) <> '0'
			BREAK;

		 SET @CurrentPtr = @CurrentPtr + 1
	  END

	  SET @ICD10Code = SUBSTRING(@ICD10Code, @CurrentPtr, @StrLen);
   END


   /* Removes 'Trailing Zeros' from the Code being formatted, if 'Trailing Zeros' are to be removed from the
	  formatted code (RemoveTrailingZeros = 1). */
   IF @RemoveTrailingZeros = 1
   BEGIN
	  SET @StrLen = LEN(@ICD10Code);

	  WHILE (@StrLen > 1)
	  BEGIN
		 IF SUBSTRING(@ICD10Code, @StrLen, 1) <> '0'
			BREAK;

		 SET @StrLen = @StrLen - 1;

	  END

	  SET @ICD10Code = SUBSTRING(@ICD10Code, 1, @StrLen);
   END


   /* Checks if the Code meets the Code Digits requirement for Code of its Code Type, Numeric
	  Characters ONLY.  If not, no Code (NULL) will be outputed. */
   IF (@ICD10Code LIKE '[a-z]')
	  SET @ICD10Code = NULL;


   IF (@ICD10Code LIKE '%.%')
   BEGIN  -- Code includes the Decimal Point '.'; further processing and checks will be performed. --

	  /* Checks if the Code meets the 'Code Length' requirement for Code of its Code Type, the Number of
		 Numeric Characters BEFORE the Decimal Point (.).  If not, no Code (NULL) will be outputed. */
	  SET @CurrentPtr = CHARINDEX('.', @ICD10Code, 1);

	  SET @StrChars = SUBSTRING(@ICD10Code, 1, @CurrentPtr - 1);

	  IF (LEN(@StrChars) > 5)
		 SET @ICD10Code = NULL;
	  ELSE
	  BEGIN
		 IF @PadWithLeadingZeros = 1
			SET @ICD10Code = REPLICATE('0', 5 - LEN(@StrChars)) + @ICD10Code;
	  END


	  /* Checks if the Code meets the 'Code Length' requirement for Code of its Code Type, the Number of
		 Numeric Characters AFTER the Decimal Point (.).  If not, no Code (NULL) will be outputed. */
	  SET @StrChars = SUBSTRING(@ICD10Code, @CurrentPtr + 1, LEN(@ICD10Code));

	  IF (LEN(@StrChars) > 2)
		 SET @ICD10Code = NULL;
	  ELSE
	  BEGIN
		 IF (@PadWithTrailingZeros = 1) AND (LEN(@StrChars) = 0)
			SET @ICD10Code = @ICD10Code + '0';
	  END
   END
   BEGIN
	  IF (@PadWithLeadingZeros = 1) AND (LEN(@ICD10Code) < @MinimumNumDigits)
		 SET @ICD10Code = REPLICATE('0', 7 - LEN(@ICD10Code)) + @ICD10Code;
   END


   /* Removes the Decimal Point (.) from the Code being formatted. */
   SET @ICD10Code = REPLACE(@ICD10Code, '.', '');


   /* Outputs the formatted code, if it meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM -- of Codes
	  of its Code Type.  Otherwise, no Code (NULL) is outputed. */
   IF (LEN(@ICD10Code) < @MinimumNumDigits) OR (LEN(@ICD10Code) > @MaximumNumDigits)
	  SET @ICD10Code = NULL;


   -- Outputs the Formatted Code, or NULL. --
   RETURN (@ICD10Code);

END;

