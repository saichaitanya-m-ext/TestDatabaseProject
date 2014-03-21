




CREATE FUNCTION [dbo].[ufn_ConvertListToTable_Int32]
(
  @StringList varchar(max) ,
  @ElementLen int = NULL ,
  @StrDelimiter varchar(5) = ','
)
RETURNS @Int32_Table TABLE
(
  [ElementVal] int NOT NULL
                   PRIMARY KEY CLUSTERED
)
AS
BEGIN
/************************************************************ INPUT PARAMETERS ************************************************************

	 @StringList = String list of Integer values to be loaded into a Table of Integer values.

	 @ElementLen = Maximum Size or Length of each String value to be retrieved from the String List for conversion to an Integer value and
				   loading into a Table of Integer values.

	 @StrDelimiter = String Delimiter that acts as a separation of values in the String List.  Delimiter Examples:  ',', ';', '|', etc.

	 *********************************************************************************************************************************************/


      DECLARE
              @CurrentPtr int ,
              @NextPtr int ,
              @StringListLen int ,
              @ElementVal int


      SET @StringListLen = LEN(@StringList) ;

      SET @CurrentPtr = 1 ;
      SET @NextPtr = @CurrentPtr ;
      WHILE @NextPtr > 0
            BEGIN
                  SET @NextPtr = CHARINDEX(@StrDelimiter , @StringList , @CurrentPtr)

                  IF @NextPtr = 0
                     SET @ElementVal = SUBSTRING(@StringList , @CurrentPtr , @StringListLen - @CurrentPtr + 1)
                  ELSE
                     BEGIN
                           IF @ElementLen IS NULL
                              SET @ElementVal = SUBSTRING(@StringList , @CurrentPtr , @NextPtr - @CurrentPtr)
                           ELSE
                              BEGIN
                                    IF @ElementLen < @NextPtr - @CurrentPtr
                                       SET @ElementVal = SUBSTRING(@StringList , @CurrentPtr , @ElementLen)
                                    ELSE
                                       SET @ElementVal = SUBSTRING(@StringList , @CurrentPtr , @NextPtr - @CurrentPtr)
                              END
                     END

                  SET @ElementVal = RTRIM(LTRIM(@ElementVal))

                  INSERT INTO
                      @Int32_Table
                      SELECT
                          CONVERT(int , @ElementVal)

                  SET @CurrentPtr = @NextPtr + 1 ;
            END

      RETURN
END ;



