


CREATE FUNCTION [dbo].[udf_QualityMeasureSelect]
(
  @i_AppUserId keyid ,
  @i_PQRIQualityMeasureID keyid ,
  @vc_PerformanceType varchar(3)
)
RETURNS @temptable TABLE
(
  PQRIQualityMeasureID keyid ,
  PerformanceType varchar(3) ,
  CriteriaText varchar(8000)
)
AS
BEGIN
      DECLARE @idx int
      DECLARE @slice varchar(8000)
      DECLARE @criteriaText varchar(8000)
      DECLARE @Delimiter char(1)

      SET @Delimiter = '|'

      SELECT
          @criteriaText = criteriaText
      FROM
          PQRIQualityMeasureNumerator
      WHERE
          PQRIQualityMeasureID = @i_PQRIQualityMeasureID
          AND PerformanceType = @vc_PerformanceType

      SELECT
          @idx = 1
      IF LEN(@criteriaText) < 1
      OR @criteriaText IS NULL
         RETURN
      WHILE @idx != 0
            BEGIN
                  SET @idx = CHARINDEX(@Delimiter , @criteriaText)
                  IF @idx != 0
                     SET @slice = LEFT(@criteriaText , @idx - 1)
                  ELSE
                     SET @slice = @criteriaText

                  IF ( LEN(@slice) > 0 )
                     INSERT INTO
                         @temptable
                         (
                           PQRIQualityMeasureID ,
                           PerformanceType ,
                           CriteriaText
                         )
                     VALUES
                         (
                           @i_PQRIQualityMeasureID ,
                           @vc_PerformanceType ,
                           @slice )

                  SET @criteriaText = RIGHT(@criteriaText , LEN(@criteriaText) - @idx)
                  IF LEN(@criteriaText) = 0
                     BREAK
            END
      RETURN
END


