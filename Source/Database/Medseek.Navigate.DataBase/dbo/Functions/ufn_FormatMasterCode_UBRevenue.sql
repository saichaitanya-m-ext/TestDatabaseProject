

CREATE FUNCTION [dbo].[ufn_FormatMasterCode_UBRevenue]
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

	 @RemoveALLBlanks = Indicator of whether to remove or filter-out ALL Blanks or Empty String (" ") from the UB Revenue Code to be formatted.

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
   WHERE [CodeTypeCode] = 'UB-Revenue'


   /* Removes Blanks (" ") from the Code to be formatted. */

   -- Removes both 'Leading' and 'Trailing' Blanks (" ") from the Code to be formmated. --
   SET @UBRevenueCode = RTRIM(LTRIM(@UBRevenueCode));

   -- Removes ALL Other Blanks (" ") from the Code to be formatted. --
   IF @RemoveALLBlanks = 1
	  SET @UBRevenueCode = REPLACE(@UBRevenueCode, ' ', '');


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @UBRevenueCode = ''
	  SET @UBRevenueCode = NULL;


   /* Removes 'Leading Zeros' from the Code being formatted, if 'Leading Zeros' are to be removed from the
	  formatted code (RemoveLeadingZeros = 1). */
   IF @RemoveLeadingZeros = 1
   BEGIN
   	  SET @StrLen = LEN(@UBRevenueCode);

   	  SET @CurrentPtr = 1;

   	  WHILE (@CurrentPtr < @StrLen)
   	  BEGIN
		 IF SUBSTRING(@UBRevenueCode, @CurrentPtr, @CurrentPtr) <> '0'
			BREAK;

		 SET @CurrentPtr = @CurrentPtr + 1
	  END

	  SET @UBRevenueCode = SUBSTRING(@UBRevenueCode, @CurrentPtr, @StrLen);
   END


   /* Removes 'Trailing Zeros' from the Code being formatted, if 'Trailing Zeros' are to be removed from the
	  formatted code (RemoveTrailingZeros = 1). */
   IF @RemoveTrailingZeros = 1
   BEGIN
	  SET @StrLen = LEN(@UBRevenueCode);

	  WHILE (@StrLen > 1)
	  BEGIN
		 IF (SUBSTRING(@UBRevenueCode, @StrLen, @StrLen) = '0')
			SET @StrLen = @StrLen - 1
		 ELSE
			BREAK
	  END

	  SET @UBRevenueCode = SUBSTRING(@UBRevenueCode, 1, @StrLen);
   END


   /* Checks and verifies that the Code meets the 'Numeric Digits' requirement of the type of the
	  Formatted Code.  Otherwise, no Code (NULL) is outputed. */
   SET @StrLen = LEN(@UBRevenueCode);

   SET @StrChr = SUBSTRING(@UBRevenueCode, 1, @StrLen);

   IF (ISNUMERIC(@StrChr) = 0) OR (@StrChr LIKE '%.%')
	  SET @UBRevenueCode = NULL;


   /* Checks if the Formatted Code exceeds the MINIMUM 'Code Length' requirement of its Code Type.  If Yes, the Formatted Code
	  is padded with Leading Zeros, upto the MINIMUM 'Code Length' of the Code Type of the Code. */
   IF @UBRevenueCode = '1'
	  SET @UBRevenueCode = '000' + @UBRevenueCode;
   ELSE
   BEGIN
	  IF (LEN(@UBRevenueCode) >= 1) AND (LEN(@UBRevenueCode) < @MinimumNumDigits)
	  BEGIN
		 IF @PadWithLeadingZeros = 1
			SET @UBRevenueCode = '0' + @UBRevenueCode;
	  END
   END


   /* Checks if the Formatted Code exceeds the MAXIMUM 'Code Length' requirement of its Code Type.  If Yes, not Code (NULL)
	  is outputed. */
   IF (LEN(@UBRevenueCode) < @MinimumNumDigits) OR (LEN(@UBRevenueCode) > @MaximumNumDigits)
	  SET @UBRevenueCode = NULL;


   -- Outputs the Formatted Code, or NULL. --
   RETURN (@UBRevenueCode);

END;

