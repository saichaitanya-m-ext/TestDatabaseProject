CREATE FUNCTION [dbo].[Ufn_GetRelationByRelationId]
(
  @i_RelationId KeyId
)
RETURNS ShortDescription
AS
BEGIN
      DECLARE @return ShortDescription
      SELECT
          @return = Description 
      FROM
          Relation
      WHERE
          RelationId = @i_RelationId
      RETURN @return
END