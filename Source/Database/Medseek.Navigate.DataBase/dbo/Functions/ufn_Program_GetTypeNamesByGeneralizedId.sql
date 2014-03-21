/*                
------------------------------------------------------------------------------                
Function Name: ufn_Program_GetTypeNamesByGeneralizedId
Description   : This Function Returns TypeName by TypeID 
Created By    : Rathnam
Created Date  : 03-Oct-2012
------------------------------------------------------------------------------
Log History :
DD-MM-YYYY     BY      DESCRIPTION
------------------------------------------------------------------------------                
*/
CREATE FUNCTION [dbo].[ufn_Program_GetTypeNamesByGeneralizedId]
     (
        @v_TaskTypeName VARCHAR(1)
       ,@i_TypeId KEYID
     )
RETURNS VARCHAR(500)
AS
BEGIN
      DECLARE @v_TypeName VARCHAR(50)
    
    
         IF @v_TaskTypeName = 'Q'
            BEGIN
                 SELECT
                     @v_TypeName = Questionaire.QuestionaireName
                 FROM
                     Questionaire
                 WHERE
                     Questionaire.QuestionaireId = @i_TypeId
            END
      ELSE
         IF @v_TaskTypeName = 'P'
            BEGIN
                  SELECT
                      @v_TypeName = CodeGrouping.CodeGroupingName
                  FROM
                      CodeGrouping
                  WHERE
                      CodeGrouping.CodeGroupingID = @i_TypeId
            END
	  ELSE 
	     IF @v_TaskTypeName='O'
        	BEGIN
	              SELECT 
	                  @v_TypeName = Name
	              FROM AdhocTask
	              WHERE AdhocTaskId = @i_TypeId    
	        END
      ELSE 
	     IF @v_TaskTypeName='E'
        	BEGIN
	              SELECT 
	                  @v_TypeName = Name
	              FROM 
	                  EducationMaterial 
	              WHERE 
	                  EducationMaterialID = @i_TypeId
	        END
      RETURN @v_TypeName
END
