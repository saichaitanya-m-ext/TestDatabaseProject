

CREATE FUNCTION [dbo].[ufn_FormatMasterCode_ICD10Diag]
(
	@ICD10Code varchar(10)
)
RETURNS varchar(7)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @ICD10Code = The ICD-10-CM Diagnosis Code to be formatted.

	 @MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.

	 @MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.

	 @RemoveALLBlanks = Indicator of whether to remove or filter-out ALL Blanks or Empty String (" ") from the ICD-10-CM Diagnosis Code to be
						formatted.

	 @RemoveLeadingZeros = Indicator of whether to remove or filter-out Leading Zeros (0's) from the ICD-10-CM Diagnosis Code to be formatted.

	 @RemoveTrailingZeros = Indicator of whether to remove or filter-out Trailing Zeros (0's) from the ICD-10-CM Diagnosis Code to be formatted.
	 
	 @PadWithLeadingZeros = Indicator of whether to pad or fill-in Leading Zeros (0's) from the ICD-10-CM Diagnosis Code to be formatted.

	 @PadWithTrailingZeros = Indicator of whether to pad or fill-in Trailing Zeros (0's) from the ICD-10-CM Procedure Code to be formatted.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint,
	
			@RemoveALLBlanks bit,
			@RemoveLeadingZeros bit,
			@RemoveTrailingZeros bit,
			@PadWithLeadingZeros bit,
			@PadWithTrailingZeros bit,

			@ICD10Code_NEW varchar(10),
			@StrLen int,
			@CurrentPtr int,
			@StrChars varchar(3)


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits],
		  @RemoveALLBlanks = [RemoveALLBlanks], @RemoveLeadingZeros = [RemoveLeadingZeros],
		  @RemoveTrailingZeros = [RemoveTrailingZeros], @PadWithLeadingZeros = [PadWithLeadingZeros],
		  @PadWithTrailingZeros = [PadWithTrailingZeros]

   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'ICD-10-CM-Diag'


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
   	  
   	  WHILE @CurrentPtr < @StrLen
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

	  WHILE @StrLen > 1
	  BEGIN
		 IF SUBSTRING(@ICD10Code, @StrLen, 1) <> '0'
			BREAK;

		 SET @StrLen = @StrLen - 1;
	  END

	  SET @ICD10Code = SUBSTRING(@ICD10Code, 1, @StrLen);
   END
   
   
   /* Checks and confirms that the FIRST (1st) Digit of the Code is an Alphabetic character.
	  Otherwise, the function Returns a NULL value. */
   IF SUBSTRING(@ICD10Code, 1, 1) NOT LIKE '[a-z]'
	  SET @ICD10Code = NULL;


   /* The Code includes a Decimal Point '.'.  And, if Yes, additional processing will be performed to
	  ensure that the Code meets the 'Code with Decimal Point' requirement -- Number of Digits (a
	  Minimum of THREE (3)) BEFORE the Decimal Point, PLUS optional FOURTH and FIFTH numeric digits
	  after the Decimal Point. */
   IF @ICD10Code LIKE '%.%'
   BEGIN
	  -- Checks and confirms that the FIRST (1st) digit of the Code is an Alphabet Character (ANY). --
	  IF SUBSTRING(@ICD10Code, 1, 1) NOT LIKE '[a-z]'
		 SET @ICD10Code = NULL;

	  /* Checks the Code for the Number of Digits it has BEFORE the Decimal Point.  The Code is PADDED
		 with Leading Zeros, if necessary, to meet the 'Minimum 3 Digits' BEFORE the Decimal Point.
		 But, if the Number of Digits is GREATER THAN 3, the function Exits and Returns a NULL value. */
	  SET @CurrentPtr = CHARINDEX('.', @ICD10Code, 1);

	  SET @StrChars = SUBSTRING(@ICD10Code, 1, @CurrentPtr - 1);

	  IF LEN(@StrChars) > @MinimumNumDigits
		 SET @ICD10Code = NULL;
	  ELSE
	  BEGIN
		 IF @PadWithLeadingZeros = 1
			SET @ICD10Code = REPLICATE('0', @MinimumNumDigits - LEN(@StrChars)) + @ICD10Code;
	  END

	  /* Checks the Code for the Number of Optional Digits it has AFTER the Decimal Point.  If the
		 Number of Digits is GREATER THAN 2, the function Exits and Returns a NULL value.  And, if
		 required, the Code is PADDED with a Trailing Zero. */
	  SET @CurrentPtr = CHARINDEX('.', @ICD10Code, 1);

	  SET @StrChars = SUBSTRING(@ICD10Code, @CurrentPtr + 1, LEN(@ICD10Code));

	  IF LEN(@StrChars) > 2
		 SET @ICD10Code = NULL;
	  ELSE
	  BEGIN
		 IF (@PadWithTrailingZeros = 1) AND (LEN(@StrChars) < 2)
			SET @ICD10Code = @ICD10Code + '0';
	  END
   END
   ELSE
   BEGIN
	  /* Checks the Total Number of Digits that the Code has.  The Code is PADDED with Leading Zeros,
		 if necessary, to meet the 'Minimum 3 Digits' length requirement. */
	  IF LEN(@ICD10Code) < @MinimumNumDigits
	  BEGIN
		 IF @PadWithLeadingZeros = 1
			SET @ICD10Code = REPLICATE('0', @MinimumNumDigits - LEN(@ICD10Code)) + @ICD10Code;
	  END

	  /* Checks the Total Number of Digits that the Code has.  The Code is PADDED with Leading Zeros,
		 if necessary, to meet the 'Minimum 3 Digits' length requirement.  But, if the Number of
		 Digits of the Code is GREATER THAN 5, the function Exits and Returns a NULL value. */
	  IF (LEN(@ICD10Code) < @MaximumNumDigits - 1)
	  BEGIN
		 IF @PadWithTrailingZeros = 1
			SET @ICD10Code = @ICD10Code + '0';
	  END
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

