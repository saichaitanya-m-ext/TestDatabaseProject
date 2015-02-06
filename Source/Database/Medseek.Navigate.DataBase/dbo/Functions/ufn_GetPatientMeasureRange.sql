/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetPatientMeasureRange           
Description   : This Function is used to get the MeasureRange Value               
Created By    : Pramod                
Created Date  : 25-June-2010                
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION                
12-Jan-2011 Rathnam changed the case statement.
11-March-2011 Rathnam Added one more parameter @v_MeasureValueText and select statement at the end.
15-Mar-2011 NagaBabu Added IF @vc_GoalValue = '' condition 
23-Mar-2011 NagaBabu Replaced 'IF ( @v_MeasureValueText IS NOT NULL )' by 'ELSE IF ( @v_MeasureValueText IS NOT NULL AND @v_MeasureValueText <> '' )'
------------------------------------------------------------------------------                
*/  
  
CREATE FUNCTION [dbo].[ufn_GetPatientMeasureRange]
(
  @i_MeasureId KeyID , 
  @i_PatientUserId KeyID ,
  @d_MeasureValue DECIMAL(10,2),
  @v_MeasureValueText VARCHAR(200)
)
RETURNS VARCHAR(10)
AS
BEGIN

	DECLARE @vc_RangeGood1 VARCHAR(4),
			@vc_RangeFair1 VARCHAR(4),
			@vc_RangePoor1 VARCHAR(4),
			@vc_GoalValue VARCHAR(10),
			@i_DerviedLabMeasureId INT
    SELECT 
        @i_DerviedLabMeasureId = LabMeasureId 
	FROM
	    LabMeasure 
	WHERE MeasureId = @i_MeasureId 
	  AND PatientUserID = @i_PatientUserId
	  AND ProgramId IS NULL
	  
	IF @@ROWCOUNT = 0
	BEGIN 
			 SELECT 
				 @i_DerviedLabMeasureId = LabMeasureId 
			 FROM 
				 LabMeasure
			 INNER JOIN Patient
				 ON LabMeasure.PatientUserID = Patient.UserId
			 INNER JOIN PatientProgram
				 ON PatientProgram.PatientID = Patient.PatientID
			 WHERE LabMeasure.MeasureId = @i_MeasureId 
			   AND PatientProgram.PatientID = @i_PatientUserId
			   AND LabMeasure.ProgramId IS NOT NULL
			   AND LabMeasure.PatientUserID IS NULL

			 IF @@ROWCOUNT = 0
			    BEGIN
					  SELECT 
					      @i_DerviedLabMeasureId = LabMeasureId 
					  FROM 
					      LabMeasure
					  WHERE LabMeasure.MeasureId = @i_MeasureId 
					    AND LabMeasure.PatientUserID IS NULL
					    AND LabMeasure.ProgramId IS NULL
			    END 

	END	
			
    IF @d_MeasureValue IS NOT NULL
	BEGIN
			SELECT @vc_RangeGood1 =
					   CASE 
						  WHEN Operator1forGoodControl = 'BETWEEN' THEN
							   CASE
								  WHEN Operator2forGoodControl = '<' THEN
									   (SELECT 'Good' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forGoodControl AND Operator1Value2forGoodControl)  AND @d_MeasureValue < LabMeasure.Operator2Value1forGoodControl)
								  WHEN Operator2forGoodControl = '<=' THEN
									   (SELECT 'Good' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forGoodControl AND Operator1Value2forGoodControl)  AND @d_MeasureValue <= LabMeasure.Operator2Value1forGoodControl)    
								  WHEN Operator2forGoodControl = '<>' THEN
									   (SELECT 'Good' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forGoodControl AND Operator1Value2forGoodControl)  AND @d_MeasureValue <> LabMeasure.Operator2Value1forGoodControl)         
								  WHEN Operator2forGoodControl = '>' THEN
									   (SELECT 'Good' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forGoodControl AND Operator1Value2forGoodControl)  AND @d_MeasureValue > LabMeasure.Operator2Value1forGoodControl)
								  WHEN Operator2forGoodControl = '>=' THEN
									   (SELECT 'Good' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forGoodControl AND Operator1Value2forGoodControl)  AND @d_MeasureValue >= LabMeasure.Operator2Value1forGoodControl)         
								  WHEN Operator2forGoodControl = 'BETWEEN' THEN
									   (SELECT 'Good' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forGoodControl AND Operator1Value2forGoodControl)  AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forGoodControl AND Operator2Value2forGoodControl) )
								  WHEN Operator2forGoodControl = '=' THEN 
									   (SELECT 'Good' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forGoodControl AND Operator1Value2forGoodControl)  AND @d_MeasureValue = LabMeasure.Operator2Value1forGoodControl)             
								  WHEN Operator2forGoodControl IS NULL THEN      
									   (SELECT 'Good' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forGoodControl AND Operator1Value2forGoodControl))          
							   END     
						  WHEN Operator1forGoodControl = '>' THEN  
							  CASE
								  WHEN Operator2forGoodControl = '<' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue < LabMeasure.Operator2Value1forGoodControl)
								  WHEN Operator2forGoodControl = '<=' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forGoodControl)    
								  WHEN Operator2forGoodControl = '<>' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forGoodControl)         
								  WHEN Operator2forGoodControl = '>' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue > LabMeasure.Operator2Value1forGoodControl)
								  WHEN Operator2forGoodControl = '>=' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forGoodControl)         
								  WHEN Operator2forGoodControl = 'BETWEEN' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forGoodControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forGoodControl AND Operator2Value2forGoodControl) )
								  WHEN Operator2forGoodControl = '=' THEN 
									   (SELECT 'Good' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue = LabMeasure.Operator2Value1forGoodControl)             
								  WHEN Operator2forGoodControl IS NULL THEN      
										(SELECT 'Good' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forGoodControl)          
							   END        
							                                                   
						  WHEN Operator1forGoodControl = '<' THEN  
							   CASE
								  WHEN Operator2forGoodControl = '<' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue < LabMeasure.Operator2Value1forGoodControl)
								  WHEN Operator2forGoodControl = '<=' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forGoodControl)    
								  WHEN Operator2forGoodControl = '<>' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forGoodControl)         
								  WHEN Operator2forGoodControl = '>' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue > LabMeasure.Operator2Value1forGoodControl)
								  WHEN Operator2forGoodControl = '>=' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forGoodControl)         
								  WHEN Operator2forGoodControl = 'BETWEEN' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forGoodControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forGoodControl AND Operator2Value2forGoodControl) )
								  WHEN Operator2forGoodControl = '=' THEN 
									   (SELECT 'Good' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue = LabMeasure.Operator2Value1forGoodControl)             
								  WHEN Operator2forGoodControl IS NULL THEN      
									   (SELECT 'Good' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forGoodControl)               
							   END  
						  WHEN Operator1forGoodControl = '=' THEN 
							   CASE
								  WHEN Operator2forGoodControl = '<' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue < LabMeasure.Operator2Value1forGoodControl)
								  WHEN Operator2forGoodControl = '<=' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forGoodControl)    
								  WHEN Operator2forGoodControl = '<>' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forGoodControl)         
								  WHEN Operator2forGoodControl = '>' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue > LabMeasure.Operator2Value1forGoodControl)
								  WHEN Operator2forGoodControl = '>=' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forGoodControl)         
								  WHEN Operator2forGoodControl = 'BETWEEN' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forGoodControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forGoodControl AND Operator2Value2forGoodControl) )
								  WHEN Operator2forGoodControl = '=' THEN 
									   (SELECT 'Good' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue = LabMeasure.Operator2Value1forGoodControl)             
								  WHEN Operator2forGoodControl IS NULL THEN      
										(SELECT 'Good' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forGoodControl)               
							   END  				  
						  WHEN Operator1forGoodControl = '>=' THEN 
							   CASE
								  WHEN Operator2forGoodControl = '<' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue < LabMeasure.Operator2Value1forGoodControl)
								  WHEN Operator2forGoodControl = '<=' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forGoodControl)    
								  WHEN Operator2forGoodControl = '<>' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forGoodControl)         
								  WHEN Operator2forGoodControl = '>' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue > LabMeasure.Operator2Value1forGoodControl)
								  WHEN Operator2forGoodControl = '>=' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forGoodControl)         
								  WHEN Operator2forGoodControl = 'BETWEEN' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forGoodControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forGoodControl AND Operator2Value2forGoodControl) )
								  WHEN Operator2forGoodControl = '=' THEN 
									   (SELECT 'Good' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue = LabMeasure.Operator2Value1forGoodControl)             
								  WHEN Operator2forGoodControl IS NULL THEN      
										(SELECT 'Good' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forGoodControl)               
							   END  	
						  WHEN Operator1forGoodControl = '<=' THEN 
							   CASE
								  WHEN Operator2forGoodControl = '<' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue < LabMeasure.Operator2Value1forGoodControl)
								  WHEN Operator2forGoodControl = '<=' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forGoodControl)    
								  WHEN Operator2forGoodControl = '<>' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forGoodControl)         
								  WHEN Operator2forGoodControl = '>' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue > LabMeasure.Operator2Value1forGoodControl)
								  WHEN Operator2forGoodControl = '>=' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forGoodControl)         
								  WHEN Operator2forGoodControl = 'BETWEEN' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forGoodControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forGoodControl AND Operator2Value2forGoodControl) )
								  WHEN Operator2forGoodControl = '=' THEN 
									   (SELECT 'Good' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue = LabMeasure.Operator2Value1forGoodControl)             
								  WHEN Operator2forGoodControl IS NULL THEN      
										(SELECT 'Good' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forGoodControl)               
							   END  	
						  WHEN Operator1forGoodControl = '<>' THEN 
							   CASE
								  WHEN Operator2forGoodControl = '<' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue < LabMeasure.Operator2Value1forGoodControl)
								  WHEN Operator2forGoodControl = '<=' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forGoodControl)    
								  WHEN Operator2forGoodControl = '<>' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forGoodControl)         
								  WHEN Operator2forGoodControl = '>' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue > LabMeasure.Operator2Value1forGoodControl)
								  WHEN Operator2forGoodControl = '>=' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forGoodControl)         
								  WHEN Operator2forGoodControl = 'BETWEEN' THEN
									   (SELECT 'Good' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forGoodControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forGoodControl AND Operator2Value2forGoodControl) )
								  WHEN Operator2forGoodControl = '=' THEN 
									   (SELECT 'Good' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forGoodControl AND @d_MeasureValue = LabMeasure.Operator2Value1forGoodControl)             
								  WHEN Operator2forGoodControl IS NULL THEN      
										(SELECT 'Good' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forGoodControl)               
							   END  	
						  ELSE ''
					   END,
				   @vc_RangeFair1 = 
					  CASE 
						  WHEN Operator1forFairControl = 'BETWEEN' THEN 
							   CASE
								  WHEN Operator2forFairControl = '<' THEN
									   (SELECT 'Fair' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forFairControl AND Operator1Value2forFairControl)  AND @d_MeasureValue < LabMeasure.Operator2Value1forFairControl)
								  WHEN Operator2forFairControl = '<=' THEN
									   (SELECT 'Fair' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forFairControl AND Operator1Value2forFairControl)  AND @d_MeasureValue <= LabMeasure.Operator2Value1forFairControl)    
								  WHEN Operator2forFairControl = '<>' THEN
									   (SELECT 'Fair' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forFairControl AND Operator1Value2forFairControl)  AND @d_MeasureValue <> LabMeasure.Operator2Value1forFairControl)         
								  WHEN Operator2forFairControl = '>' THEN
									   (SELECT 'Fair' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forFairControl AND Operator1Value2forFairControl)  AND @d_MeasureValue > LabMeasure.Operator2Value1forFairControl)
								  WHEN Operator2forFairControl = '>=' THEN
									   (SELECT 'Fair' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forFairControl AND Operator1Value2forFairControl)  AND @d_MeasureValue >= LabMeasure.Operator2Value1forFairControl)         
								  WHEN Operator2forFairControl = 'BETWEEN' THEN
									   (SELECT 'Fair' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forFairControl AND Operator1Value2forFairControl)  AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forFairControl AND Operator2Value2forFairControl) )
								  WHEN Operator2forFairControl = '=' THEN 
									   (SELECT 'Fair' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forFairControl AND Operator1Value2forFairControl)  AND @d_MeasureValue = LabMeasure.Operator2Value1forFairControl)             
								  WHEN Operator2forFairControl IS NULL THEN      
									   (SELECT 'Fair' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forFairControl AND Operator1Value2forFairControl))               
							   END     
						  WHEN Operator1forFairControl = '>' THEN  
							   CASE
								  WHEN Operator2forFairControl = '<' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue < LabMeasure.Operator2Value1forFairControl)
								  WHEN Operator2forFairControl = '<=' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forFairControl)    
								  WHEN Operator2forFairControl = '<>' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forFairControl)         
								  WHEN Operator2forFairControl = '>' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue > LabMeasure.Operator2Value1forFairControl)
								  WHEN Operator2forFairControl = '>=' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forFairControl)         
								  WHEN Operator2forFairControl = 'BETWEEN' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forFairControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forFairControl AND Operator2Value2forFairControl) )
								  WHEN Operator2forFairControl = '=' THEN 
									   (SELECT 'Fair' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue = LabMeasure.Operator2Value1forFairControl)             
								  WHEN Operator2forFairControl IS NULL THEN      
									   (SELECT 'Fair' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forFairControl)               
							   END        
							                                                   
						  WHEN Operator1forFairControl = '<' THEN  
							   CASE
								  WHEN Operator2forFairControl = '<' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue < LabMeasure.Operator2Value1forFairControl)
								  WHEN Operator2forFairControl = '<=' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forFairControl)    
								  WHEN Operator2forFairControl = '<>' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forFairControl)         
								  WHEN Operator2forFairControl = '>' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue > LabMeasure.Operator2Value1forFairControl)
								  WHEN Operator2forFairControl = '>=' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forFairControl)         
								  WHEN Operator2forFairControl = 'BETWEEN' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forFairControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forFairControl AND Operator2Value2forFairControl) )
								  WHEN Operator2forFairControl = '=' THEN 
									   (SELECT 'Fair' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue = LabMeasure.Operator2Value1forFairControl)             
								  WHEN Operator2forFairControl IS NULL THEN      
										(SELECT 'Fair' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forFairControl)     
							   END  
						  WHEN Operator1forFairControl = '=' THEN 
							   CASE
								  WHEN Operator2forFairControl = '<' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue < LabMeasure.Operator2Value1forFairControl)
								  WHEN Operator2forFairControl = '<=' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forFairControl)    
								  WHEN Operator2forFairControl = '<>' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forFairControl)         
								  WHEN Operator2forFairControl = '>' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue > LabMeasure.Operator2Value1forFairControl)
								  WHEN Operator2forFairControl = '>=' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forFairControl)         
								  WHEN Operator2forFairControl = 'BETWEEN' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forFairControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forFairControl AND Operator2Value2forFairControl) )
								  WHEN Operator2forFairControl = '=' THEN 
									   (SELECT 'Fair' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue = LabMeasure.Operator2Value1forFairControl)             
								  WHEN Operator2forFairControl IS NULL THEN      
									   (SELECT 'Fair' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forFairControl)     
							   END  				  
						  WHEN Operator1forFairControl = '>=' THEN 
							   CASE
								  WHEN Operator2forFairControl = '<' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue < LabMeasure.Operator2Value1forFairControl)
								  WHEN Operator2forFairControl = '<=' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forFairControl)    
								  WHEN Operator2forFairControl = '<>' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forFairControl)         
								  WHEN Operator2forFairControl = '>' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue > LabMeasure.Operator2Value1forFairControl)
								  WHEN Operator2forFairControl = '>=' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forFairControl)         
								  WHEN Operator2forFairControl = 'BETWEEN' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forFairControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forFairControl AND Operator2Value2forFairControl) )
								  WHEN Operator2forFairControl = '=' THEN 
									   (SELECT 'Fair' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue = LabMeasure.Operator2Value1forFairControl)             
								  WHEN Operator2forFairControl IS NULL THEN      
									   (SELECT 'Fair' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forFairControl)     
							   END  	
						  WHEN Operator1forFairControl = '<=' THEN 
							   CASE
								  WHEN Operator2forFairControl = '<' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue < LabMeasure.Operator2Value1forFairControl)
								  WHEN Operator2forFairControl = '<=' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forFairControl)    
								  WHEN Operator2forFairControl = '<>' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forFairControl)         
								  WHEN Operator2forFairControl = '>' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue > LabMeasure.Operator2Value1forFairControl)
								  WHEN Operator2forFairControl = '>=' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forFairControl)         
								  WHEN Operator2forFairControl = 'BETWEEN' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forFairControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forFairControl AND Operator2Value2forFairControl) )
								  WHEN Operator2forFairControl = '=' THEN 
									   (SELECT 'Fair' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue = LabMeasure.Operator2Value1forFairControl)             
								  WHEN Operator2forFairControl IS NULL THEN      
									   (SELECT 'Fair' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forFairControl)     
							   END  	
						  WHEN Operator1forFairControl = '<>' THEN 
							   CASE
								  WHEN Operator2forFairControl = '<' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue < LabMeasure.Operator2Value1forFairControl)
								  WHEN Operator2forFairControl = '<=' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forFairControl)    
								  WHEN Operator2forFairControl = '<>' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forFairControl)         
								  WHEN Operator2forFairControl = '>' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue > LabMeasure.Operator2Value1forFairControl)
								  WHEN Operator2forFairControl = '>=' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forFairControl)         
								  WHEN Operator2forFairControl = 'BETWEEN' THEN
									   (SELECT 'Fair' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forFairControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forFairControl AND Operator2Value2forFairControl) )
								  WHEN Operator2forFairControl = '=' THEN 
									   (SELECT 'Fair' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forFairControl AND @d_MeasureValue = LabMeasure.Operator2Value1forFairControl)             
								  WHEN Operator2forFairControl IS NULL THEN      
										(SELECT 'Fair' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forFairControl)     
							   END  	
						  ELSE ''
					   END,		   
				@vc_RangePoor1 = 
					   CASE 
						  WHEN Operator1forPoorControl = 'BETWEEN' THEN 
							   CASE
								  WHEN Operator2forPoorControl = '<' THEN
									   (SELECT 'Poor' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forPoorControl AND Operator1Value2forPoorControl)  AND @d_MeasureValue < LabMeasure.Operator2Value1forPoorControl)
								  WHEN Operator2forPoorControl = '<=' THEN
									   (SELECT 'Poor' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forPoorControl AND Operator1Value2forPoorControl)  AND @d_MeasureValue <= LabMeasure.Operator2Value1forPoorControl)    
								  WHEN Operator2forPoorControl = '<>' THEN
									   (SELECT 'Poor' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forPoorControl AND Operator1Value2forPoorControl)  AND @d_MeasureValue <> LabMeasure.Operator2Value1forPoorControl)         
								  WHEN Operator2forPoorControl = '>' THEN
									   (SELECT 'Poor' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forPoorControl AND Operator1Value2forPoorControl)  AND @d_MeasureValue > LabMeasure.Operator2Value1forPoorControl)
								  WHEN Operator2forPoorControl = '>=' THEN
									   (SELECT 'Poor' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forPoorControl AND Operator1Value2forPoorControl)  AND @d_MeasureValue >= LabMeasure.Operator2Value1forPoorControl)         
								  WHEN Operator2forPoorControl = 'BETWEEN' THEN
									   (SELECT 'Poor' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forPoorControl AND Operator1Value2forPoorControl)  AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forPoorControl AND Operator2Value2forPoorControl) )
								  WHEN Operator2forPoorControl = '=' THEN 
									   (SELECT 'Poor' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forPoorControl AND Operator1Value2forPoorControl)  AND @d_MeasureValue = LabMeasure.Operator2Value1forPoorControl)             
								  WHEN Operator2forPoorControl IS NULL THEN      
									   (SELECT 'Poor' WHERE (@d_MeasureValue BETWEEN LabMeasure.Operator1Value1forPoorControl AND Operator1Value2forPoorControl))     
							   END     
						  WHEN Operator1forPoorControl = '>' THEN  
							   CASE
								  WHEN Operator2forPoorControl = '<' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue < LabMeasure.Operator2Value1forPoorControl)
								  WHEN Operator2forPoorControl = '<=' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forPoorControl)    
								  WHEN Operator2forPoorControl = '<>' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forPoorControl)         
								  WHEN Operator2forPoorControl = '>' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue > LabMeasure.Operator2Value1forPoorControl)
								  WHEN Operator2forPoorControl = '>=' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forPoorControl)         
								  WHEN Operator2forPoorControl = 'BETWEEN' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forPoorControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forPoorControl AND Operator2Value2forPoorControl) )
								  WHEN Operator2forPoorControl = '=' THEN 
									   (SELECT 'Poor' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue = LabMeasure.Operator2Value1forPoorControl)             
								  WHEN Operator2forPoorControl IS NULL THEN      
									   (SELECT 'Poor' WHERE @d_MeasureValue > LabMeasure.Operator1Value1forPoorControl)     
							   END        
							                                                   
						  WHEN Operator1forPoorControl = '<' THEN  
							   CASE
								  WHEN Operator2forPoorControl = '<' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue < LabMeasure.Operator2Value1forPoorControl)
								  WHEN Operator2forPoorControl = '<=' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forPoorControl)    
								  WHEN Operator2forPoorControl = '<>' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forPoorControl)         
								  WHEN Operator2forPoorControl = '>' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue > LabMeasure.Operator2Value1forPoorControl)
								  WHEN Operator2forPoorControl = '>=' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forPoorControl)         
								  WHEN Operator2forPoorControl = 'BETWEEN' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forPoorControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forPoorControl AND Operator2Value2forPoorControl) )
								  WHEN Operator2forPoorControl = '=' THEN 
									   (SELECT 'Poor' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue = LabMeasure.Operator2Value1forPoorControl)             
								  WHEN Operator2forPoorControl IS NULL THEN      
										(SELECT 'Poor' WHERE @d_MeasureValue < LabMeasure.Operator1Value1forPoorControl)     
							   END  
						  WHEN Operator1forPoorControl = '=' THEN 
							   CASE
								  WHEN Operator2forPoorControl = '<' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue < LabMeasure.Operator2Value1forPoorControl)
								  WHEN Operator2forPoorControl = '<=' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forPoorControl)    
								  WHEN Operator2forPoorControl = '<>' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forPoorControl)         
								  WHEN Operator2forPoorControl = '>' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue > LabMeasure.Operator2Value1forPoorControl)
								  WHEN Operator2forPoorControl = '>=' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forPoorControl)         
								  WHEN Operator2forPoorControl = 'BETWEEN' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forPoorControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forPoorControl AND Operator2Value2forPoorControl) )
								  WHEN Operator2forPoorControl = '=' THEN 
									   (SELECT 'Poor' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue = LabMeasure.Operator2Value1forPoorControl)             
								  WHEN Operator2forPoorControl IS NULL THEN      
									   (SELECT 'Poor' WHERE @d_MeasureValue = LabMeasure.Operator1Value1forPoorControl)     
							   END  				  
						  WHEN Operator1forPoorControl = '>=' THEN 
							   CASE
								  WHEN Operator2forPoorControl = '<' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue < LabMeasure.Operator2Value1forPoorControl)
								  WHEN Operator2forPoorControl = '<=' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forPoorControl)    
								  WHEN Operator2forPoorControl = '<>' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forPoorControl)         
								  WHEN Operator2forPoorControl = '>' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue > LabMeasure.Operator2Value1forPoorControl)
								  WHEN Operator2forPoorControl = '>=' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forPoorControl)         
								  WHEN Operator2forPoorControl = 'BETWEEN' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forPoorControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forPoorControl AND Operator2Value2forPoorControl) )
								  WHEN Operator2forPoorControl = '=' THEN 
									   (SELECT 'Poor' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue = LabMeasure.Operator2Value1forPoorControl)             
								  WHEN Operator2forPoorControl IS NULL THEN      
									   (SELECT 'Poor' WHERE @d_MeasureValue >= LabMeasure.Operator1Value1forPoorControl)
							   END  	
						  WHEN Operator1forPoorControl = '<=' THEN 
							   CASE
								  WHEN Operator2forPoorControl = '<' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue < LabMeasure.Operator2Value1forPoorControl)
								  WHEN Operator2forPoorControl = '<=' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forPoorControl)    
								  WHEN Operator2forPoorControl = '<>' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forPoorControl)         
								  WHEN Operator2forPoorControl = '>' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue > LabMeasure.Operator2Value1forPoorControl)
								  WHEN Operator2forPoorControl = '>=' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forPoorControl)         
								  WHEN Operator2forPoorControl = 'BETWEEN' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forPoorControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forPoorControl AND Operator2Value2forPoorControl) )
								  WHEN Operator2forPoorControl = '=' THEN 
									   (SELECT 'Poor' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue = LabMeasure.Operator2Value1forPoorControl)             
								  WHEN Operator2forPoorControl IS NULL THEN      
									   (SELECT 'Poor' WHERE @d_MeasureValue <= LabMeasure.Operator1Value1forPoorControl)     
							   END  	
						  WHEN Operator1forPoorControl = '<>' THEN 
							   CASE
								  WHEN Operator2forPoorControl = '<' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue < LabMeasure.Operator2Value1forPoorControl)
								  WHEN Operator2forPoorControl = '<=' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue <= LabMeasure.Operator2Value1forPoorControl)    
								  WHEN Operator2forPoorControl = '<>' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue <> LabMeasure.Operator2Value1forPoorControl)         
								  WHEN Operator2forPoorControl = '>' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue > LabMeasure.Operator2Value1forPoorControl)
								  WHEN Operator2forPoorControl = '>=' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue >= LabMeasure.Operator2Value1forPoorControl)         
								  WHEN Operator2forPoorControl = 'BETWEEN' THEN
									   (SELECT 'Poor' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forPoorControl AND (@d_MeasureValue BETWEEN LabMeasure.Operator2Value1forPoorControl AND Operator2Value2forPoorControl) )
								  WHEN Operator2forPoorControl = '=' THEN 
									   (SELECT 'Poor' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forPoorControl AND @d_MeasureValue = LabMeasure.Operator2Value1forPoorControl)             
								  WHEN Operator2forPoorControl IS NULL THEN      
									   (SELECT 'Poor' WHERE @d_MeasureValue <> LabMeasure.Operator1Value1forPoorControl)     
							   END  	
						  ELSE ''
					   END 
			  
				 FROM LabMeasure
				 WHERE LabMeasureId = @i_DerviedLabMeasureId
			
			SET @vc_GoalValue =
					(SUBSTRING( ISNULL(@vc_RangeGood1,'')  + ISNULL(@vc_RangeFair1,'') +
					ISNULL(@vc_RangePoor1,''),1,4)) 
		
	END
	ELSE IF ( @v_MeasureValueText IS NOT NULL AND @v_MeasureValueText <> '' )
	BEGIN
			SELECT @vc_GoalValue =  
					   CASE 
						  WHEN @v_MeasureValueText = LabMeasure.TextValueForGoodControl THEN 'Good'
						  WHEN @v_MeasureValueText = LabMeasure.TextValueForPoorControl THEN 'Poor'
						  WHEN @v_MeasureValueText = LabMeasure.TextValueForFairControl THEN 'Fair'
						  ELSE ''
					   END
			FROM
				LabMeasure
			WHERE
				 LabMeasureId = @i_DerviedLabMeasureId
	END
	IF @vc_GoalValue = '' OR @vc_GoalValue IS NULL
		SET @vc_GoalValue = 'Undefined'

	RETURN @vc_GoalValue
END
