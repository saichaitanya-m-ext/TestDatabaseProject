CREATE FUNCTION [dbo].[ReturnTimeLineTypeID]
(
  @TimeLineType SOURCENAME
)
RETURNS INT
AS
BEGIN
      DECLARE @return INT
      SELECT
          @return = TimeLineTypeID
      FROM
          TimeLineType
      WHERE
          TimeLineType = @TimeLineType
      RETURN @return
END
