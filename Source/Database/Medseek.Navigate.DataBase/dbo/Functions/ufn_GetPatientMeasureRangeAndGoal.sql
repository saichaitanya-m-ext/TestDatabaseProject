/*                
------------------------------------------------------------------------------                
Function Name: [ufn_GetPatientMeasureRangeAndGoal]           
Description   : This Function is used to get the MeasureRange and Goal Value for a patient and measure.               
Created By    : Pramod                
Created Date  : 28-June-2010                
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION                
11-Jan-2010 Rathnam Removed the if clause and placed @i_DerviedLabMeasureId for getting goalvalue
14-Mar-2011 RamaChandra added one more parameter @v_MeasureValueText and select statement at the end
17-Aug-2011 NagaBabu Added Undefined if @vc_GoalValue is not in Good,Fair,Poor
18-Aug-2011 NagaBabu Added IF @vc_GoalValue = '' SET @vc_GoalValue = 'Undefined' 
------------------------------------------------------------------------------                
*/
CREATE FUNCTION [dbo].[ufn_GetPatientMeasureRangeAndGoal]
(
  @i_MeasureId KeyID , 
  @i_PatientUserId KeyID ,
  @d_MeasureValue DECIMAL(10,2) = NULL,
  @v_MeasureValueText VARCHAR(200) 
)
RETURNS VARCHAR(500)
AS
BEGIN

	DECLARE @vc_RangeGood1 VARCHAR(4),
			@vc_RangeFair1 VARCHAR(4),
			@vc_RangePoor1 VARCHAR(4),
			@vc_MeasureGoodTextValue VARCHAR(500),
			@vc_MeasurePoorTextValue VARCHAR(500),
			@vc_MeasureFairTextValue VARCHAR(500),
			@vc_GoalValue VARCHAR(15),
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
			   END,
		@vc_MeasureGoodTextValue =
			  CASE 
	             WHEN ((LabMeasure.TextValueForGoodControl IS NULL OR LabMeasure.TextValueForGoodControl = '') AND (Operator1forGoodControl IS NOT NULL AND Operator2forGoodControl IS NOT NULL)) THEN
					COALESCE    
					((ISNULL(LabMeasure.Operator1forGoodControl,'') 
					+ ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') 
					+ ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'') 
					+ ' AND '
					+ ISNULL(LabMeasure.Operator2forGoodControl,'') 
					+ ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') 
					+ ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'') 
					  ),''    
					 )
				   WHEN ((LabMeasure.TextValueForGoodControl IS NULL OR LabMeasure.TextValueForGoodControl = '') AND (Operator1forGoodControl IS NOT NULL AND Operator2forGoodControl IS NULL)) THEN
					COALESCE    
					(( ISNULL(LabMeasure.Operator1forGoodControl,'') 
					+ ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') 
					+ ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'') 
					  ),''    
					 )
				 WHEN ((LabMeasure.TextValueForGoodControl IS NULL OR LabMeasure.TextValueForGoodControl = '') AND (Operator1forGoodControl IS NULL AND Operator2forGoodControl IS NOT NULL)) THEN
					COALESCE    
					((ISNULL(LabMeasure.Operator2forGoodControl,'') 
					+ ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'') 
					  ),''    
					 )		 		 			  
	           ELSE
				   LabMeasure.TextValueForGoodControl
			 END,
			 @vc_MeasurePoorTextValue =
			  CASE 
	             WHEN ((LabMeasure.TextValueForPoorControl IS NULL OR LabMeasure.TextValueForPoorControl = '') AND (Operator1forPoorControl IS NOT NULL AND Operator2forPoorControl IS NOT NULL)) THEN
					COALESCE    
					(( ISNULL(LabMeasure.Operator1forPoorControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forPoorControl AS VARCHAR(20)),'') 
					+ ISNULL(CAST(LabMeasure.Operator1Value2forPoorControl AS VARCHAR(20)),'')
					+ ' AND '
					+ ISNULL(LabMeasure.Operator2forPoorControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forPoorControl AS VARCHAR(20)),'') 
					+ ISNULL(CAST(LabMeasure.Operator2Value2forPoorControl AS VARCHAR(20)),'') 
					  ),''    
					 )
				  WHEN ((LabMeasure.TextValueForPoorControl IS NULL OR LabMeasure.TextValueForPoorControl = '') AND (Operator1forPoorControl IS NOT NULL AND Operator2forPoorControl IS NULL)) THEN
					COALESCE    
					(( ISNULL(LabMeasure.Operator1forPoorControl,'') 
					+ ISNULL(CAST(LabMeasure.Operator1Value1forPoorControl AS VARCHAR(20)),'') 
					+ ISNULL(CAST(LabMeasure.Operator1Value2forPoorControl AS VARCHAR(20)),'') 
					  ),''    
					 )
				 WHEN ((LabMeasure.TextValueForPoorControl IS NULL OR LabMeasure.TextValueForPoorControl = '') AND (Operator1forPoorControl IS NULL AND Operator2forPoorControl IS NOT NULL)) THEN
					COALESCE    
					(( ISNULL(LabMeasure.Operator2forPoorControl,'') 
					+ ISNULL(CAST(LabMeasure.Operator2Value1forPoorControl AS VARCHAR(20)),'') 
					+ ISNULL(CAST(LabMeasure.Operator2Value2forPoorControl AS VARCHAR(20)),'') 
					  ),''    
					 )	 	 	 			  
	           ELSE
				   LabMeasure.TextValueForPoorControl
			 END,
			 @vc_MeasureFairTextValue =
			  CASE 
	             WHEN ((LabMeasure.TextValueForFairControl IS NULL OR LabMeasure.TextValueForFairControl = '') AND (Operator1forFairControl IS NOT NULL AND  Operator2forFairControl IS NOT NULL))THEN
					COALESCE    
					(( ISNULL(LabMeasure.Operator1forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forFairControl AS VARCHAR(20)),'')
					+ ISNULL(CAST(LabMeasure.Operator1Value2forFairControl AS VARCHAR(20)),'')
					+ ' AND '
					+ ISNULL(LabMeasure.Operator2forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forFairControl AS VARCHAR(20)),'') 
					+ ISNULL(CAST(LabMeasure.Operator2Value2forFairControl AS VARCHAR(20)),'') 
					  ),''    
					 )
				   WHEN ((LabMeasure.TextValueForFairControl IS NULL OR LabMeasure.TextValueForFairControl = '') AND (Operator1forFairControl IS NOT NULL AND  Operator2forFairControl IS NULL))THEN
					COALESCE    
					(( ISNULL(LabMeasure.Operator1forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forFairControl AS VARCHAR(20)),'')    
					+ ISNULL(CAST(LabMeasure.Operator1Value2forFairControl AS VARCHAR(20)),'')
					  ),''    
					 )	
					 WHEN ((LabMeasure.TextValueForFairControl IS NULL OR LabMeasure.TextValueForFairControl = '') AND (Operator1forFairControl IS  NULL AND  Operator2forFairControl IS NOT NULL))THEN
					COALESCE    
					(( ISNULL(LabMeasure.Operator2forFairControl,'')     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forFairControl AS VARCHAR(20)),'') 
					+ ISNULL(CAST(LabMeasure.Operator2Value2forFairControl AS VARCHAR(20)),'')
					  ),''    
					 )		  	 			  
	           ELSE
				   LabMeasure.TextValueForFairControl
			 END	     
	     FROM LabMeasure
		 WHERE LabMeasureId = @i_DerviedLabMeasureId
	
	   SET @vc_GoalValue =
		    (SUBSTRING( ISNULL(@vc_RangeGood1,'')  + ISNULL(@vc_RangeFair1,'') +
			ISNULL(@vc_RangePoor1,''),1,4)) 
			IF @vc_GoalValue = ''
				SET @vc_GoalValue = 'Undefined'
			END
		IF @v_MeasureValueText IS NOT NULL 
		BEGIN
			SELECT @vc_GoalValue =  
					   CASE 
						  WHEN @v_MeasureValueText = LabMeasure.TextValueForGoodControl THEN 'Good'
						  WHEN @v_MeasureValueText = LabMeasure.TextValueForPoorControl THEN 'Poor'
						  WHEN @v_MeasureValueText = LabMeasure.TextValueForFairControl THEN 'Fair'
						  ELSE 'Undefined'
					   END
			FROM
				LabMeasure
			WHERE
				 LabMeasureId = @i_DerviedLabMeasureId
		END
		
	RETURN @vc_GoalValue + '-' + 
			CASE @vc_GoalValue 
				WHEN 'Good' THEN @vc_MeasureGoodTextValue 
				WHEN 'Poor' THEN @vc_MeasurePoorTextValue
				WHEN 'Fair' THEN @vc_MeasureFairTextValue
				ELSE ''
			END
	--RETURN @vc_GoalValue + '-' + @vc_MeasureValue 
END
