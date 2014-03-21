CREATE FUNCTION [dbo].[ReturnTaskTypeID]
(
  @TaskTypeName SOURCENAME
)
RETURNS INT
AS
BEGIN
      DECLARE @return INT
      SELECT
          @return = TaskTypeID
      FROM
          TaskType
      WHERE
          TaskTypeName = @TaskTypeName
      RETURN @return
END
