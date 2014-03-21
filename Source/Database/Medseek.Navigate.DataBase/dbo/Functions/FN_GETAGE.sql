CREATE FUNCTION [dbo].[FN_GETAGE]
(@IN_DOB AS DATETIME)
RETURNS INT
AS
BEGIN


      DECLARE @date datetime, @tmpdate datetime, @years int, @months int, @days int
      SELECT @date = @in_DOB

      SELECT @tmpdate = @date

      SELECT @years = DATEDIFF(yy, @tmpdate, GETDATE()) - CASE WHEN (MONTH(@date) > MONTH(GETDATE())) OR (MONTH(@date) = MONTH(GETDATE()) AND DAY(@date) > DAY(GETDATE())) THEN 1 ELSE 0 END
      SELECT @tmpdate = DATEADD(yy, @years, @tmpdate)
      SELECT @months = DATEDIFF(m, @tmpdate, GETDATE()) - CASE WHEN DAY(@date) > DAY(GETDATE()) THEN 1 ELSE 0 END
      SELECT @tmpdate = DATEADD(m, @months, @tmpdate)
      SELECT @days = DATEDIFF(d, @tmpdate, GETDATE())

      --SELECT Convert(Varchar(Max),@years)+' Years '+ Convert(Varchar(max),@months) + ' Months' + Convert(Varchar(max),@days) + ' Days' 

      RETURN @years

END
