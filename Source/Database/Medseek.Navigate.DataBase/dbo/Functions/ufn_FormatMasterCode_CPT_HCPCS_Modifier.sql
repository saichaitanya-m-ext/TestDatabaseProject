

CREATE FUNCTION [dbo].[ufn_FormatMasterCode_CPT_HCPCS_Modifier]
(
	@CPT_HCPCS_ModifierCode varchar(10)
)
RETURNS varchar(2)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @CPT_HCPCS_ModifierCode = The CPT/HCPCS Modifier Code to be formatted.

	 @MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.

	 @MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.

	 @RemoveALLBlanks = Indicator of whether to remove or filter-out ALL Blanks or Empty String (" ") from the CPT/HCPCS Modifier Code to be
						formatted.

	 @RemoveLeadingZeros = Indicator of whether to remove or filter-out Leading Zeros (0's) from the CPT/HCPCS Modifier Code to be formatted.

	 @RemoveTrailingZeros = Indicator of whether to remove or filter-out Trailing Zeros (0's) from the CPT/HCPCS Modifier Code to be formatted.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint,
	
			@RemoveALLBlanks bit,
			@RemoveLeadingZeros bit,
			@RemoveTrailingZeros bit,

			@StrLen int,
			@CurrentPtr int


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits],
		  @RemoveALLBlanks = [RemoveALLBlanks], @RemoveLeadingZeros = [RemoveLeadingZeros],
		  @RemoveTrailingZeros = [RemoveTrailingZeros]
   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'CPT_HCPCS_Modifier'


   /* Removes Blanks (" ") from the Code to be formatted. */

   -- Removes both 'Leading' and 'Trailing' Blanks (" ") from the Code to be formmated. --
   SET @CPT_HCPCS_ModifierCode = RTRIM(LTRIM(@CPT_HCPCS_ModifierCode));

   -- Removes ALL Other Blanks (" ") from the Code to be formatted. --
   IF @RemoveALLBlanks = 1
	  SET @CPT_HCPCS_ModifierCode = REPLACE(@CPT_HCPCS_ModifierCode, ' ', '');


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @CPT_HCPCS_ModifierCode = ''
	  SET @CPT_HCPCS_ModifierCode = NULL;


   /* Removes 'Leading Zeros' from the Code being formatted, if 'Leading Zeros' are to be removed from the
	  formatted code (RemoveLeadingZeros = 1). */
   IF @RemoveLeadingZeros = 1
   BEGIN
   	  SET @StrLen = LEN(@CPT_HCPCS_ModifierCode);
   	  
   	  SET @CurrentPtr = 1;
   	  
   	  WHILE (@CurrentPtr < @StrLen)
   	  BEGIN
		 IF SUBSTRING(@CPT_HCPCS_ModifierCode, @CurrentPtr, 1) <> '0'
			BREAK;

		 SET @CurrentPtr = @CurrentPtr + 1
	  END

	  SET @CPT_HCPCS_ModifierCode = SUBSTRING(@CPT_HCPCS_ModifierCode, @CurrentPtr, @StrLen);
   END


   /* Removes 'Trailing Zeros' from the Code being formatted, if 'Trailing Zeros' are to be removed from the
	  formatted code (RemoveTrailingZeros = 1). */
   IF @RemoveTrailingZeros = 1
   BEGIN
	  SET @StrLen = LEN(@CPT_HCPCS_ModifierCode);

	  WHILE (@StrLen > 1)
	  BEGIN
		 IF SUBSTRING(@CPT_HCPCS_ModifierCode, @StrLen, 1) <> '0'
			BREAK;

		 SET @StrLen = @StrLen - 1;

	  END

	  SET @CPT_HCPCS_ModifierCode = SUBSTRING(@CPT_HCPCS_ModifierCode, 1, @StrLen);
   END


   /* Checks and verifies that the Code does not contain a Decimal Point. */
   IF @CPT_HCPCS_ModifierCode LIKE '%.%'
	  SET @CPT_HCPCS_ModifierCode = NULL;


   /* Outputs the formatted code, if it meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM -- of Codes
	  of its Code Type.  Otherwise, no Code (NULL) is outputed. */
   IF (LEN(@CPT_HCPCS_ModifierCode) < @MinimumNumDigits) OR (LEN(@CPT_HCPCS_ModifierCode) > @MaximumNumDigits)
	  SET @CPT_HCPCS_ModifierCode = NULL;


   -- Outputs the Formatted Code, or NULL. --
   RETURN (@CPT_HCPCS_ModifierCode);

END;

