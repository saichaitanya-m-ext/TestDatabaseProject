

CREATE FUNCTION [dbo].[ufn_ConvertListToTable_String]
(
  @StringList varchar(max) ,
  @ElementLen int = NULL ,
  @StrDelimiter varchar(5) = ','
)
RETURNS @strTable TABLE
(
  [ElementVal] varchar(900) NOT NULL
                            UNIQUE CLUSTERED
)
AS
BEGIN
/************************************************************ INPUT PARAMETERS ************************************************************

	 @StringList = String list of character (varchar) values to be loaded into a Table of Character (i.e. varchar) values.

	 @ElementLen = Maximum Size or Length of each String value to be retrieved from the String List for loading into a Table of Character
				   (i.e. varchar) values.

	 @StrDelimiter = String Delimiter that acts as a separation of values in the String List.  Delimiter Examples:  ',', ';', '|', etc.

	 *********************************************************************************************************************************************/


      DECLARE
              @CurrentPtr int ,
              @NextPtr int ,
              @StringListLen int ,
              @ElementVal varchar(1000)


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
                      @strTable
                      SELECT
                          @ElementVal

                  SET @CurrentPtr = @NextPtr + 1 ;
            END

      RETURN
END ;




