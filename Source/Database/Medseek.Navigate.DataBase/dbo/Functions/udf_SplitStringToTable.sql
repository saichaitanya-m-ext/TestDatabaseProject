


CREATE FUNCTION [dbo].[udf_SplitStringToTable]
(
  @string varchar(max) ,
  @delimiter char(1)
)
RETURNS @output TABLE
(
  KeyValue varchar(256)
)
BEGIN
      DECLARE
              @start int ,
              @end int
      SELECT
          @start = 1 ,
          @end = CHARINDEX(@delimiter , @string)
      WHILE @start < LEN(@string) + 1
            BEGIN
                  IF @end = 0
                     SET @end = LEN(@string) + 1

                  INSERT INTO
                      @output
                      (
                        KeyValue
                      )
                  VALUES
                      (
                        LTRIM(RTRIM(SUBSTRING(@string , @start , @end - @start))) )
                  SET @start = @end + 1
                  SET @end = CHARINDEX(@delimiter , @string , @start)
            END

      RETURN
END


