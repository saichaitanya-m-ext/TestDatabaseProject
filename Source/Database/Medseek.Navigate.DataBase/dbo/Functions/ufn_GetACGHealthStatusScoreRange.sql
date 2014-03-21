/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetACGHealthStatusScoreRange           
Description   : This Function is used to get the HealthStatusScoreRange Value               
Created By    : NagaBabu             
Created Date  : 10-Feb-2011                
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION 
06-Dec-2011 NagaBabu Added Convert keyword to DateDetermined,@i_DateDetermined               
------------------------------------------------------------------------------                
*/     
CREATE FUNCTION [dbo].[ufn_GetACGHealthStatusScoreRange]
(
	@i_PatientID KeyID ,
	@i_DateDetermined UserDate ,
	@i_HealthStatusScoreID KeyID ,
	@d_Score DECIMAL(10,2)
)	
RETURNS VARCHAR(10)
AS
BEGIN

	DECLARE @vc_RangeGood1 VARCHAR(4),
			@vc_RangeFair1 VARCHAR(4),
			@vc_RangePoor1 VARCHAR(4),
			@vc_MeasureGoodTextValue VARCHAR(500),
			@vc_MeasurePoorTextValue VARCHAR(500),
			@vc_MeasureFairTextValue VARCHAR(500),
			@vc_GoalValue VARCHAR(10)

	SELECT @vc_RangeGood1 =
			   CASE 
				  WHEN Operator1forGoodScore = 'BETWEEN' THEN
				       CASE
						  WHEN Operator2forGoodScore = '<' THEN
							   (SELECT 'Good' WHERE (@d_Score BETWEEN Operator1Value1forGoodScore AND Operator1Value2forGoodScore)  AND @d_Score < Operator2Value1forGoodScore)
						  WHEN Operator2forGoodScore = '<=' THEN
							   (SELECT 'Good' WHERE (@d_Score BETWEEN Operator1Value1forGoodScore AND Operator1Value2forGoodScore)  AND @d_Score <= Operator2Value1forGoodScore)    
						  WHEN Operator2forGoodScore = '<>' THEN
							   (SELECT 'Good' WHERE (@d_Score BETWEEN Operator1Value1forGoodScore AND Operator1Value2forGoodScore)  AND @d_Score <> Operator2Value1forGoodScore)         
						  WHEN Operator2forGoodScore = '>' THEN
							   (SELECT 'Good' WHERE (@d_Score BETWEEN Operator1Value1forGoodScore AND Operator1Value2forGoodScore)  AND @d_Score > Operator2Value1forGoodScore)
						  WHEN Operator2forGoodScore = '>=' THEN
							   (SELECT 'Good' WHERE (@d_Score BETWEEN Operator1Value1forGoodScore AND Operator1Value2forGoodScore)  AND @d_Score >= Operator2Value1forGoodScore)         
						  WHEN Operator2forGoodScore = 'BETWEEN' THEN
							   (SELECT 'Good' WHERE (@d_Score BETWEEN Operator1Value1forGoodScore AND Operator1Value2forGoodScore)  AND (@d_Score BETWEEN Operator2Value1forGoodScore AND Operator2Value2forGoodScore) )
						  WHEN Operator2forGoodScore = '=' THEN 
							   (SELECT 'Good' WHERE (@d_Score BETWEEN Operator1Value1forGoodScore AND Operator1Value2forGoodScore)  AND @d_Score = Operator2Value1forGoodScore)             
						  WHEN Operator2forGoodScore IS NULL THEN     
							   (SELECT 'Good' WHERE (@d_Score BETWEEN Operator1Value1forGoodScore AND Operator1Value2forGoodScore))          
                       END     
				  WHEN Operator1forGoodScore = '>' THEN  
				      CASE
                          WHEN Operator2forGoodScore = '<' THEN
                               (SELECT 'Good' WHERE @d_Score > Operator1Value1forGoodScore AND @d_Score < Operator2Value1forGoodScore)
                          WHEN Operator2forGoodScore = '<=' THEN
                               (SELECT 'Good' WHERE @d_Score > Operator1Value1forGoodScore AND @d_Score <= Operator2Value1forGoodScore)    
                          WHEN Operator2forGoodScore = '<>' THEN
                               (SELECT 'Good' WHERE @d_Score > Operator1Value1forGoodScore AND @d_Score <> Operator2Value1forGoodScore)         
                          WHEN Operator2forGoodScore = '>' THEN
                               (SELECT 'Good' WHERE @d_Score > Operator1Value1forGoodScore AND @d_Score > Operator2Value1forGoodScore)
                          WHEN Operator2forGoodScore = '>=' THEN
                               (SELECT 'Good' WHERE @d_Score > Operator1Value1forGoodScore AND @d_Score >= Operator2Value1forGoodScore)         
                          WHEN Operator2forGoodScore = 'BETWEEN' THEN
                               (SELECT 'Good' WHERE @d_Score > Operator1Value1forGoodScore AND (@d_Score BETWEEN Operator2Value1forGoodScore AND Operator2Value2forGoodScore) )
                          WHEN Operator2forGoodScore = '=' THEN 
                               (SELECT 'Good' WHERE @d_Score > Operator1Value1forGoodScore AND @d_Score = Operator2Value1forGoodScore)             
                          WHEN Operator2forGoodScore IS NULL THEN      
                                (SELECT 'Good' WHERE @d_Score > Operator1Value1forGoodScore)          
                       END        
					                                                   
				  WHEN Operator1forGoodScore = '<' THEN  
				       CASE
                          WHEN Operator2forGoodScore = '<' THEN
                               (SELECT 'Good' WHERE @d_Score < Operator1Value1forGoodScore AND @d_Score < Operator2Value1forGoodScore)
                          WHEN Operator2forGoodScore = '<=' THEN
                               (SELECT 'Good' WHERE @d_Score < Operator1Value1forGoodScore AND @d_Score <= Operator2Value1forGoodScore)    
                          WHEN Operator2forGoodScore = '<>' THEN
                               (SELECT 'Good' WHERE @d_Score < Operator1Value1forGoodScore AND @d_Score <> Operator2Value1forGoodScore)         
                          WHEN Operator2forGoodScore = '>' THEN
                               (SELECT 'Good' WHERE @d_Score < Operator1Value1forGoodScore AND @d_Score > Operator2Value1forGoodScore)
                          WHEN Operator2forGoodScore = '>=' THEN
                               (SELECT 'Good' WHERE @d_Score < Operator1Value1forGoodScore AND @d_Score >= Operator2Value1forGoodScore)         
                          WHEN Operator2forGoodScore = 'BETWEEN' THEN
                               (SELECT 'Good' WHERE @d_Score < Operator1Value1forGoodScore AND (@d_Score BETWEEN Operator2Value1forGoodScore AND Operator2Value2forGoodScore) )
                          WHEN Operator2forGoodScore = '=' THEN 
                               (SELECT 'Good' WHERE @d_Score < Operator1Value1forGoodScore AND @d_Score = Operator2Value1forGoodScore)             
                          WHEN Operator2forGoodScore IS NULL THEN      
                               (SELECT 'Good' WHERE @d_Score < Operator1Value1forGoodScore)               
                       END  
				  WHEN Operator1forGoodScore = '=' THEN 
				       CASE
                          WHEN Operator2forGoodScore = '<' THEN
                               (SELECT 'Good' WHERE @d_Score = Operator1Value1forGoodScore AND @d_Score < Operator2Value1forGoodScore)
                          WHEN Operator2forGoodScore = '<=' THEN
                               (SELECT 'Good' WHERE @d_Score = Operator1Value1forGoodScore AND @d_Score <= Operator2Value1forGoodScore)    
                          WHEN Operator2forGoodScore = '<>' THEN
                               (SELECT 'Good' WHERE @d_Score = Operator1Value1forGoodScore AND @d_Score <> Operator2Value1forGoodScore)         
                          WHEN Operator2forGoodScore = '>' THEN
                               (SELECT 'Good' WHERE @d_Score = Operator1Value1forGoodScore AND @d_Score > Operator2Value1forGoodScore)
                          WHEN Operator2forGoodScore = '>=' THEN
                               (SELECT 'Good' WHERE @d_Score = Operator1Value1forGoodScore AND @d_Score >= Operator2Value1forGoodScore)         
                          WHEN Operator2forGoodScore = 'BETWEEN' THEN
                               (SELECT 'Good' WHERE @d_Score = Operator1Value1forGoodScore AND (@d_Score BETWEEN Operator2Value1forGoodScore AND Operator2Value2forGoodScore) )
                          WHEN Operator2forGoodScore = '=' THEN 
                               (SELECT 'Good' WHERE @d_Score = Operator1Value1forGoodScore AND @d_Score = Operator2Value1forGoodScore)             
                          WHEN Operator2forGoodScore IS NULL THEN      
                                (SELECT 'Good' WHERE @d_Score = Operator1Value1forGoodScore)               
                       END  				  
				  WHEN Operator1forGoodScore = '>=' THEN 
				       CASE
						  WHEN Operator2forGoodScore = '<' THEN
							   (SELECT 'Good' WHERE @d_Score >= Operator1Value1forGoodScore AND @d_Score < Operator2Value1forGoodScore)
						  WHEN Operator2forGoodScore = '<=' THEN
							   (SELECT 'Good' WHERE @d_Score >= Operator1Value1forGoodScore AND @d_Score <= Operator2Value1forGoodScore)    
						  WHEN Operator2forGoodScore = '<>' THEN
							   (SELECT 'Good' WHERE @d_Score >= Operator1Value1forGoodScore AND @d_Score <> Operator2Value1forGoodScore)         
						  WHEN Operator2forGoodScore = '>' THEN
							   (SELECT 'Good' WHERE @d_Score >= Operator1Value1forGoodScore AND @d_Score > Operator2Value1forGoodScore)
						  WHEN Operator2forGoodScore = '>=' THEN
							   (SELECT 'Good' WHERE @d_Score >= Operator1Value1forGoodScore AND @d_Score >= Operator2Value1forGoodScore)         
						  WHEN Operator2forGoodScore = 'BETWEEN' THEN
							   (SELECT 'Good' WHERE @d_Score >= Operator1Value1forGoodScore AND (@d_Score BETWEEN Operator2Value1forGoodScore AND Operator2Value2forGoodScore) )
						  WHEN Operator2forGoodScore = '=' THEN 
							   (SELECT 'Good' WHERE @d_Score >= Operator1Value1forGoodScore AND @d_Score = Operator2Value1forGoodScore)             
						  WHEN Operator2forGoodScore IS NULL THEN      
								(SELECT 'Good' WHERE @d_Score >= Operator1Value1forGoodScore)               
					   END  	
				  WHEN Operator1forGoodScore = '<=' THEN 
				       CASE
                          WHEN Operator2forGoodScore = '<' THEN
                               (SELECT 'Good' WHERE @d_Score <= Operator1Value1forGoodScore AND @d_Score < Operator2Value1forGoodScore)
                          WHEN Operator2forGoodScore = '<=' THEN
                               (SELECT 'Good' WHERE @d_Score <= Operator1Value1forGoodScore AND @d_Score <= Operator2Value1forGoodScore)    
                          WHEN Operator2forGoodScore = '<>' THEN
                               (SELECT 'Good' WHERE @d_Score <= Operator1Value1forGoodScore AND @d_Score <> Operator2Value1forGoodScore)         
                          WHEN Operator2forGoodScore = '>' THEN
                               (SELECT 'Good' WHERE @d_Score <= Operator1Value1forGoodScore AND @d_Score > Operator2Value1forGoodScore)
                          WHEN Operator2forGoodScore = '>=' THEN
                               (SELECT 'Good' WHERE @d_Score <= Operator1Value1forGoodScore AND @d_Score >= Operator2Value1forGoodScore)         
                          WHEN Operator2forGoodScore = 'BETWEEN' THEN
                               (SELECT 'Good' WHERE @d_Score <= Operator1Value1forGoodScore AND (@d_Score BETWEEN Operator2Value1forGoodScore AND Operator2Value2forGoodScore) )
                          WHEN Operator2forGoodScore = '=' THEN 
                               (SELECT 'Good' WHERE @d_Score <= Operator1Value1forGoodScore AND @d_Score = Operator2Value1forGoodScore)             
                          WHEN Operator2forGoodScore IS NULL THEN      
                                (SELECT 'Good' WHERE @d_Score <= Operator1Value1forGoodScore)               
                       END  	
				  WHEN Operator1forGoodScore = '<>' THEN 
				       CASE
                          WHEN Operator2forGoodScore = '<' THEN
                               (SELECT 'Good' WHERE @d_Score <> Operator1Value1forGoodScore AND @d_Score < Operator2Value1forGoodScore)
                          WHEN Operator2forGoodScore = '<=' THEN
                               (SELECT 'Good' WHERE @d_Score <> Operator1Value1forGoodScore AND @d_Score <= Operator2Value1forGoodScore)    
                          WHEN Operator2forGoodScore = '<>' THEN
                               (SELECT 'Good' WHERE @d_Score <> Operator1Value1forGoodScore AND @d_Score <> Operator2Value1forGoodScore)         
                          WHEN Operator2forGoodScore = '>' THEN
                               (SELECT 'Good' WHERE @d_Score <> Operator1Value1forGoodScore AND @d_Score > Operator2Value1forGoodScore)
                          WHEN Operator2forGoodScore = '>=' THEN
                               (SELECT 'Good' WHERE @d_Score <> Operator1Value1forGoodScore AND @d_Score >= Operator2Value1forGoodScore)         
                          WHEN Operator2forGoodScore = 'BETWEEN' THEN
                               (SELECT 'Good' WHERE @d_Score <> Operator1Value1forGoodScore AND (@d_Score BETWEEN Operator2Value1forGoodScore AND Operator2Value2forGoodScore) )
                          WHEN Operator2forGoodScore = '=' THEN 
                               (SELECT 'Good' WHERE @d_Score <> Operator1Value1forGoodScore AND @d_Score = Operator2Value1forGoodScore)             
                          WHEN Operator2forGoodScore IS NULL THEN      
                                (SELECT 'Good' WHERE @d_Score <> Operator1Value1forGoodScore)               
                       END  	
				  ELSE ''
			   END,
		   @vc_RangeFair1 = 
			  CASE 
				  WHEN Operator1forFairScore = 'BETWEEN' THEN 
				       CASE
                          WHEN Operator2forFairScore = '<' THEN
                               (SELECT 'Fair' WHERE (@d_Score BETWEEN Operator1Value1forFairScore AND Operator1Value2forFairScore)  AND @d_Score < Operator2Value1forFairScore)
                          WHEN Operator2forFairScore = '<=' THEN
                               (SELECT 'Fair' WHERE (@d_Score BETWEEN Operator1Value1forFairScore AND Operator1Value2forFairScore)  AND @d_Score <= Operator2Value1forFairScore)    
                          WHEN Operator2forFairScore = '<>' THEN
                               (SELECT 'Fair' WHERE (@d_Score BETWEEN Operator1Value1forFairScore AND Operator1Value2forFairScore)  AND @d_Score <> Operator2Value1forFairScore)         
                          WHEN Operator2forFairScore = '>' THEN
                               (SELECT 'Fair' WHERE (@d_Score BETWEEN Operator1Value1forFairScore AND Operator1Value2forFairScore)  AND @d_Score > Operator2Value1forFairScore)
                          WHEN Operator2forFairScore = '>=' THEN
                               (SELECT 'Fair' WHERE (@d_Score BETWEEN Operator1Value1forFairScore AND Operator1Value2forFairScore)  AND @d_Score >= Operator2Value1forFairScore)         
                          WHEN Operator2forFairScore = 'BETWEEN' THEN
                               (SELECT 'Fair' WHERE (@d_Score BETWEEN Operator1Value1forFairScore AND Operator1Value2forFairScore)  AND (@d_Score BETWEEN Operator2Value1forFairScore AND Operator2Value2forFairScore) )
                          WHEN Operator2forFairScore = '=' THEN 
                               (SELECT 'Fair' WHERE (@d_Score BETWEEN Operator1Value1forFairScore AND Operator1Value2forFairScore)  AND @d_Score = Operator2Value1forFairScore)             
                          WHEN Operator2forFairScore IS NULL THEN      
                               (SELECT 'Fair' WHERE (@d_Score BETWEEN Operator1Value1forFairScore AND Operator1Value2forFairScore))               
                       END     
				  WHEN Operator1forFairScore = '>' THEN  
				       CASE
                          WHEN Operator2forFairScore = '<' THEN
                               (SELECT 'Fair' WHERE @d_Score > Operator1Value1forFairScore AND @d_Score < Operator2Value1forFairScore)
                          WHEN Operator2forFairScore = '<=' THEN
                               (SELECT 'Fair' WHERE @d_Score > Operator1Value1forFairScore AND @d_Score <= Operator2Value1forFairScore)    
                          WHEN Operator2forFairScore = '<>' THEN
                               (SELECT 'Fair' WHERE @d_Score > Operator1Value1forFairScore AND @d_Score <> Operator2Value1forFairScore)         
                          WHEN Operator2forFairScore = '>' THEN
                               (SELECT 'Fair' WHERE @d_Score > Operator1Value1forFairScore AND @d_Score > Operator2Value1forFairScore)
                          WHEN Operator2forFairScore = '>=' THEN
                               (SELECT 'Fair' WHERE @d_Score > Operator1Value1forFairScore AND @d_Score >= Operator2Value1forFairScore)         
                          WHEN Operator2forFairScore = 'BETWEEN' THEN
                               (SELECT 'Fair' WHERE @d_Score > Operator1Value1forFairScore AND (@d_Score BETWEEN Operator2Value1forFairScore AND Operator2Value2forFairScore) )
                          WHEN Operator2forFairScore = '=' THEN 
                               (SELECT 'Fair' WHERE @d_Score > Operator1Value1forFairScore AND @d_Score = Operator2Value1forFairScore)             
                          WHEN Operator2forFairScore IS NULL THEN      
                               (SELECT 'Fair' WHERE @d_Score > Operator1Value1forFairScore)               
                       END        
					                                                   
				  WHEN Operator1forFairScore = '<' THEN  
				       CASE
                          WHEN Operator2forFairScore = '<' THEN
                               (SELECT 'Fair' WHERE @d_Score < Operator1Value1forFairScore AND @d_Score < Operator2Value1forFairScore)
                          WHEN Operator2forFairScore = '<=' THEN
                               (SELECT 'Fair' WHERE @d_Score < Operator1Value1forFairScore AND @d_Score <= Operator2Value1forFairScore)    
                          WHEN Operator2forFairScore = '<>' THEN
                               (SELECT 'Fair' WHERE @d_Score < Operator1Value1forFairScore AND @d_Score <> Operator2Value1forFairScore)         
                          WHEN Operator2forFairScore = '>' THEN
                               (SELECT 'Fair' WHERE @d_Score < Operator1Value1forFairScore AND @d_Score > Operator2Value1forFairScore)
                          WHEN Operator2forFairScore = '>=' THEN
                               (SELECT 'Fair' WHERE @d_Score < Operator1Value1forFairScore AND @d_Score >= Operator2Value1forFairScore)         
                          WHEN Operator2forFairScore = 'BETWEEN' THEN
                               (SELECT 'Fair' WHERE @d_Score < Operator1Value1forFairScore AND (@d_Score BETWEEN Operator2Value1forFairScore AND Operator2Value2forFairScore) )
                          WHEN Operator2forFairScore = '=' THEN 
                               (SELECT 'Fair' WHERE @d_Score < Operator1Value1forFairScore AND @d_Score = Operator2Value1forFairScore)             
                          WHEN Operator2forFairScore IS NULL THEN      
                                (SELECT 'Fair' WHERE @d_Score < Operator1Value1forFairScore)     
                       END  
				  WHEN Operator1forFairScore = '=' THEN 
				       CASE
                          WHEN Operator2forFairScore = '<' THEN
                               (SELECT 'Fair' WHERE @d_Score = Operator1Value1forFairScore AND @d_Score < Operator2Value1forFairScore)
                          WHEN Operator2forFairScore = '<=' THEN
                               (SELECT 'Fair' WHERE @d_Score = Operator1Value1forFairScore AND @d_Score <= Operator2Value1forFairScore)    
                          WHEN Operator2forFairScore = '<>' THEN
                               (SELECT 'Fair' WHERE @d_Score = Operator1Value1forFairScore AND @d_Score <> Operator2Value1forFairScore)         
                          WHEN Operator2forFairScore = '>' THEN
                               (SELECT 'Fair' WHERE @d_Score = Operator1Value1forFairScore AND @d_Score > Operator2Value1forFairScore)
                          WHEN Operator2forFairScore = '>=' THEN
                               (SELECT 'Fair' WHERE @d_Score = Operator1Value1forFairScore AND @d_Score >= Operator2Value1forFairScore)         
                          WHEN Operator2forFairScore = 'BETWEEN' THEN
                               (SELECT 'Fair' WHERE @d_Score = Operator1Value1forFairScore AND (@d_Score BETWEEN Operator2Value1forFairScore AND Operator2Value2forFairScore) )
                          WHEN Operator2forFairScore = '=' THEN 
                               (SELECT 'Fair' WHERE @d_Score = Operator1Value1forFairScore AND @d_Score = Operator2Value1forFairScore)             
                          WHEN Operator2forFairScore IS NULL THEN      
                               (SELECT 'Fair' WHERE @d_Score = Operator1Value1forFairScore)     
                       END  				  
				  WHEN Operator1forFairScore = '>=' THEN 
				       CASE
                          WHEN Operator2forFairScore = '<' THEN
                               (SELECT 'Fair' WHERE @d_Score >= Operator1Value1forFairScore AND @d_Score < Operator2Value1forFairScore)
                          WHEN Operator2forFairScore = '<=' THEN
                               (SELECT 'Fair' WHERE @d_Score >= Operator1Value1forFairScore AND @d_Score <= Operator2Value1forFairScore)    
                          WHEN Operator2forFairScore = '<>' THEN
                               (SELECT 'Fair' WHERE @d_Score >= Operator1Value1forFairScore AND @d_Score <> Operator2Value1forFairScore)         
                          WHEN Operator2forFairScore = '>' THEN
                               (SELECT 'Fair' WHERE @d_Score >= Operator1Value1forFairScore AND @d_Score > Operator2Value1forFairScore)
                          WHEN Operator2forFairScore = '>=' THEN
                               (SELECT 'Fair' WHERE @d_Score >= Operator1Value1forFairScore AND @d_Score >= Operator2Value1forFairScore)         
                          WHEN Operator2forFairScore = 'BETWEEN' THEN
                               (SELECT 'Fair' WHERE @d_Score >= Operator1Value1forFairScore AND (@d_Score BETWEEN Operator2Value1forFairScore AND Operator2Value2forFairScore) )
                          WHEN Operator2forFairScore = '=' THEN 
                               (SELECT 'Fair' WHERE @d_Score >= Operator1Value1forFairScore AND @d_Score = Operator2Value1forFairScore)             
                          WHEN Operator2forFairScore IS NULL THEN      
                               (SELECT 'Fair' WHERE @d_Score >= Operator1Value1forFairScore)     
                       END  	
				  WHEN Operator1forFairScore = '<=' THEN 
				       CASE
                          WHEN Operator2forFairScore = '<' THEN
                               (SELECT 'Fair' WHERE @d_Score <= Operator1Value1forFairScore AND @d_Score < Operator2Value1forFairScore)
                          WHEN Operator2forFairScore = '<=' THEN
                               (SELECT 'Fair' WHERE @d_Score <= Operator1Value1forFairScore AND @d_Score <= Operator2Value1forFairScore)    
                          WHEN Operator2forFairScore = '<>' THEN
                               (SELECT 'Fair' WHERE @d_Score <= Operator1Value1forFairScore AND @d_Score <> Operator2Value1forFairScore)         
                          WHEN Operator2forFairScore = '>' THEN
                               (SELECT 'Fair' WHERE @d_Score <= Operator1Value1forFairScore AND @d_Score > Operator2Value1forFairScore)
                          WHEN Operator2forFairScore = '>=' THEN
                               (SELECT 'Fair' WHERE @d_Score <= Operator1Value1forFairScore AND @d_Score >= Operator2Value1forFairScore)         
                          WHEN Operator2forFairScore = 'BETWEEN' THEN
                               (SELECT 'Fair' WHERE @d_Score <= Operator1Value1forFairScore AND (@d_Score BETWEEN Operator2Value1forFairScore AND Operator2Value2forFairScore) )
                          WHEN Operator2forFairScore = '=' THEN 
                               (SELECT 'Fair' WHERE @d_Score <= Operator1Value1forFairScore AND @d_Score = Operator2Value1forFairScore)             
                          WHEN Operator2forFairScore IS NULL THEN      
                               (SELECT 'Fair' WHERE @d_Score <= Operator1Value1forFairScore)     
                       END  	
				  WHEN Operator1forFairScore = '<>' THEN 
				       CASE
						  WHEN Operator2forFairScore = '<' THEN
							   (SELECT 'Fair' WHERE @d_Score <> Operator1Value1forFairScore AND @d_Score < Operator2Value1forFairScore)
						  WHEN Operator2forFairScore = '<=' THEN
							   (SELECT 'Fair' WHERE @d_Score <> Operator1Value1forFairScore AND @d_Score <= Operator2Value1forFairScore)    
						  WHEN Operator2forFairScore = '<>' THEN
							   (SELECT 'Fair' WHERE @d_Score <> Operator1Value1forFairScore AND @d_Score <> Operator2Value1forFairScore)         
						  WHEN Operator2forFairScore = '>' THEN
							   (SELECT 'Fair' WHERE @d_Score <> Operator1Value1forFairScore AND @d_Score > Operator2Value1forFairScore)
						  WHEN Operator2forFairScore = '>=' THEN
							   (SELECT 'Fair' WHERE @d_Score <> Operator1Value1forFairScore AND @d_Score >= Operator2Value1forFairScore)         
						  WHEN Operator2forFairScore = 'BETWEEN' THEN
							   (SELECT 'Fair' WHERE @d_Score <> Operator1Value1forFairScore AND (@d_Score BETWEEN Operator2Value1forFairScore AND Operator2Value2forFairScore) )
						  WHEN Operator2forFairScore = '=' THEN 
							   (SELECT 'Fair' WHERE @d_Score <> Operator1Value1forFairScore AND @d_Score = Operator2Value1forFairScore)             
						  WHEN Operator2forFairScore IS NULL THEN      
								(SELECT 'Fair' WHERE @d_Score <> Operator1Value1forFairScore)     
					   END  	
				  ELSE ''
			   END,		   
		@vc_RangePoor1 = 
			   CASE 
				  WHEN Operator1forPoorScore = 'BETWEEN' THEN 
				       CASE
                          WHEN Operator2forPoorScore = '<' THEN
                               (SELECT 'Poor' WHERE (@d_Score BETWEEN Operator1Value1forPoorScore AND Operator1Value2forPoorScore)  AND @d_Score < Operator2Value1forPoorScore)
                          WHEN Operator2forPoorScore = '<=' THEN
                               (SELECT 'Poor' WHERE (@d_Score BETWEEN Operator1Value1forPoorScore AND Operator1Value2forPoorScore)  AND @d_Score <= Operator2Value1forPoorScore)    
                          WHEN Operator2forPoorScore = '<>' THEN
                               (SELECT 'Poor' WHERE (@d_Score BETWEEN Operator1Value1forPoorScore AND Operator1Value2forPoorScore)  AND @d_Score <> Operator2Value1forPoorScore)         
                          WHEN Operator2forPoorScore = '>' THEN
                               (SELECT 'Poor' WHERE (@d_Score BETWEEN Operator1Value1forPoorScore AND Operator1Value2forPoorScore)  AND @d_Score > Operator2Value1forPoorScore)
                          WHEN Operator2forPoorScore = '>=' THEN
                               (SELECT 'Poor' WHERE (@d_Score BETWEEN Operator1Value1forPoorScore AND Operator1Value2forPoorScore)  AND @d_Score >= Operator2Value1forPoorScore)         
                          WHEN Operator2forPoorScore = 'BETWEEN' THEN
                               (SELECT 'Poor' WHERE (@d_Score BETWEEN Operator1Value1forPoorScore AND Operator1Value2forPoorScore)  AND (@d_Score BETWEEN Operator2Value1forPoorScore AND Operator2Value2forPoorScore) )
                          WHEN Operator2forPoorScore = '=' THEN 
                               (SELECT 'Poor' WHERE (@d_Score BETWEEN Operator1Value1forPoorScore AND Operator1Value2forPoorScore)  AND @d_Score = Operator2Value1forPoorScore)             
                          WHEN Operator2forPoorScore IS NULL THEN      
                               (SELECT 'Poor' WHERE (@d_Score BETWEEN Operator1Value1forPoorScore AND Operator1Value2forPoorScore))     
                       END     
				  WHEN Operator1forPoorScore = '>' THEN  
				       CASE
                          WHEN Operator2forPoorScore = '<' THEN
                               (SELECT 'Poor' WHERE @d_Score > Operator1Value1forPoorScore AND @d_Score < Operator2Value1forPoorScore)
                          WHEN Operator2forPoorScore = '<=' THEN
                               (SELECT 'Poor' WHERE @d_Score > Operator1Value1forPoorScore AND @d_Score <= Operator2Value1forPoorScore)    
                          WHEN Operator2forPoorScore = '<>' THEN
                               (SELECT 'Poor' WHERE @d_Score > Operator1Value1forPoorScore AND @d_Score <> Operator2Value1forPoorScore)         
                          WHEN Operator2forPoorScore = '>' THEN
                               (SELECT 'Poor' WHERE @d_Score > Operator1Value1forPoorScore AND @d_Score > Operator2Value1forPoorScore)
                          WHEN Operator2forPoorScore = '>=' THEN
                               (SELECT 'Poor' WHERE @d_Score > Operator1Value1forPoorScore AND @d_Score >= Operator2Value1forPoorScore)         
                          WHEN Operator2forPoorScore = 'BETWEEN' THEN
                               (SELECT 'Poor' WHERE @d_Score > Operator1Value1forPoorScore AND (@d_Score BETWEEN Operator2Value1forPoorScore AND Operator2Value2forPoorScore) )
                          WHEN Operator2forPoorScore = '=' THEN 
                               (SELECT 'Poor' WHERE @d_Score > Operator1Value1forPoorScore AND @d_Score = Operator2Value1forPoorScore)             
                          WHEN Operator2forPoorScore IS NULL THEN      
                               (SELECT 'Poor' WHERE @d_Score > Operator1Value1forPoorScore)     
                       END        
					                                                   
				  WHEN Operator1forPoorScore = '<' THEN  
				       CASE
                          WHEN Operator2forPoorScore = '<' THEN
                               (SELECT 'Poor' WHERE @d_Score < Operator1Value1forPoorScore AND @d_Score < Operator2Value1forPoorScore)
                          WHEN Operator2forPoorScore = '<=' THEN
                               (SELECT 'Poor' WHERE @d_Score < Operator1Value1forPoorScore AND @d_Score <= Operator2Value1forPoorScore)    
                          WHEN Operator2forPoorScore = '<>' THEN
                               (SELECT 'Poor' WHERE @d_Score < Operator1Value1forPoorScore AND @d_Score <> Operator2Value1forPoorScore)         
                          WHEN Operator2forPoorScore = '>' THEN
                               (SELECT 'Poor' WHERE @d_Score < Operator1Value1forPoorScore AND @d_Score > Operator2Value1forPoorScore)
                          WHEN Operator2forPoorScore = '>=' THEN
                               (SELECT 'Poor' WHERE @d_Score < Operator1Value1forPoorScore AND @d_Score >= Operator2Value1forPoorScore)         
                          WHEN Operator2forPoorScore = 'BETWEEN' THEN
                               (SELECT 'Poor' WHERE @d_Score < Operator1Value1forPoorScore AND (@d_Score BETWEEN Operator2Value1forPoorScore AND Operator2Value2forPoorScore) )
                          WHEN Operator2forPoorScore = '=' THEN 
                               (SELECT 'Poor' WHERE @d_Score < Operator1Value1forPoorScore AND @d_Score = Operator2Value1forPoorScore)             
                          WHEN Operator2forPoorScore IS NULL THEN      
                                (SELECT 'Poor' WHERE @d_Score < Operator1Value1forPoorScore)     
                       END  
				  WHEN Operator1forPoorScore = '=' THEN 
				       CASE
                          WHEN Operator2forPoorScore = '<' THEN
                               (SELECT 'Poor' WHERE @d_Score = Operator1Value1forPoorScore AND @d_Score < Operator2Value1forPoorScore)
                          WHEN Operator2forPoorScore = '<=' THEN
                               (SELECT 'Poor' WHERE @d_Score = Operator1Value1forPoorScore AND @d_Score <= Operator2Value1forPoorScore)    
                          WHEN Operator2forPoorScore = '<>' THEN
                               (SELECT 'Poor' WHERE @d_Score = Operator1Value1forPoorScore AND @d_Score <> Operator2Value1forPoorScore)         
                          WHEN Operator2forPoorScore = '>' THEN
                               (SELECT 'Poor' WHERE @d_Score = Operator1Value1forPoorScore AND @d_Score > Operator2Value1forPoorScore)
                          WHEN Operator2forPoorScore = '>=' THEN
                               (SELECT 'Poor' WHERE @d_Score = Operator1Value1forPoorScore AND @d_Score >= Operator2Value1forPoorScore)         
                          WHEN Operator2forPoorScore = 'BETWEEN' THEN
                               (SELECT 'Poor' WHERE @d_Score = Operator1Value1forPoorScore AND (@d_Score BETWEEN Operator2Value1forPoorScore AND Operator2Value2forPoorScore) )
                          WHEN Operator2forPoorScore = '=' THEN 
                               (SELECT 'Poor' WHERE @d_Score = Operator1Value1forPoorScore AND @d_Score = Operator2Value1forPoorScore)             
                          WHEN Operator2forPoorScore IS NULL THEN      
                               (SELECT 'Poor' WHERE @d_Score = Operator1Value1forPoorScore)     
                       END  				  
				  WHEN Operator1forPoorScore = '>=' THEN 
				       CASE
                          WHEN Operator2forPoorScore = '<' THEN
                               (SELECT 'Poor' WHERE @d_Score >= Operator1Value1forPoorScore AND @d_Score < Operator2Value1forPoorScore)
                          WHEN Operator2forPoorScore = '<=' THEN
                               (SELECT 'Poor' WHERE @d_Score >= Operator1Value1forPoorScore AND @d_Score <= Operator2Value1forPoorScore)    
                          WHEN Operator2forPoorScore = '<>' THEN
                               (SELECT 'Poor' WHERE @d_Score >= Operator1Value1forPoorScore AND @d_Score <> Operator2Value1forPoorScore)         
                          WHEN Operator2forPoorScore = '>' THEN
                               (SELECT 'Poor' WHERE @d_Score >= Operator1Value1forPoorScore AND @d_Score > Operator2Value1forPoorScore)
                          WHEN Operator2forPoorScore = '>=' THEN
                               (SELECT 'Poor' WHERE @d_Score >= Operator1Value1forPoorScore AND @d_Score >= Operator2Value1forPoorScore)         
                          WHEN Operator2forPoorScore = 'BETWEEN' THEN
                               (SELECT 'Poor' WHERE @d_Score >= Operator1Value1forPoorScore AND (@d_Score BETWEEN Operator2Value1forPoorScore AND Operator2Value2forPoorScore) )
                          WHEN Operator2forPoorScore = '=' THEN 
                               (SELECT 'Poor' WHERE @d_Score >= Operator1Value1forPoorScore AND @d_Score = Operator2Value1forPoorScore)             
                          WHEN Operator2forPoorScore IS NULL THEN      
                               (SELECT 'Poor' WHERE @d_Score >= Operator1Value1forPoorScore)
                       END  	
				  WHEN Operator1forPoorScore = '<=' THEN 
				       CASE
                          WHEN Operator2forPoorScore = '<' THEN
                               (SELECT 'Poor' WHERE @d_Score <= Operator1Value1forPoorScore AND @d_Score < Operator2Value1forPoorScore)
                          WHEN Operator2forPoorScore = '<=' THEN
                               (SELECT 'Poor' WHERE @d_Score <= Operator1Value1forPoorScore AND @d_Score <= Operator2Value1forPoorScore)    
                          WHEN Operator2forPoorScore = '<>' THEN
                               (SELECT 'Poor' WHERE @d_Score <= Operator1Value1forPoorScore AND @d_Score <> Operator2Value1forPoorScore)         
                          WHEN Operator2forPoorScore = '>' THEN
                               (SELECT 'Poor' WHERE @d_Score <= Operator1Value1forPoorScore AND @d_Score > Operator2Value1forPoorScore)
                          WHEN Operator2forPoorScore = '>=' THEN
                               (SELECT 'Poor' WHERE @d_Score <= Operator1Value1forPoorScore AND @d_Score >= Operator2Value1forPoorScore)         
                          WHEN Operator2forPoorScore = 'BETWEEN' THEN
                               (SELECT 'Poor' WHERE @d_Score <= Operator1Value1forPoorScore AND (@d_Score BETWEEN Operator2Value1forPoorScore AND Operator2Value2forPoorScore) )
                          WHEN Operator2forPoorScore = '=' THEN 
                               (SELECT 'Poor' WHERE @d_Score <= Operator1Value1forPoorScore AND @d_Score = Operator2Value1forPoorScore)             
                          WHEN Operator2forPoorScore IS NULL THEN      
                               (SELECT 'Poor' WHERE @d_Score <= Operator1Value1forPoorScore)     
                       END  	
				  WHEN Operator1forPoorScore = '<>' THEN 
				       CASE
                          WHEN Operator2forPoorScore = '<' THEN
                               (SELECT 'Poor' WHERE @d_Score <> Operator1Value1forPoorScore AND @d_Score < Operator2Value1forPoorScore)
                          WHEN Operator2forPoorScore = '<=' THEN
                               (SELECT 'Poor' WHERE @d_Score <> Operator1Value1forPoorScore AND @d_Score <= Operator2Value1forPoorScore)    
                          WHEN Operator2forPoorScore = '<>' THEN
                               (SELECT 'Poor' WHERE @d_Score <> Operator1Value1forPoorScore AND @d_Score <> Operator2Value1forPoorScore)         
                          WHEN Operator2forPoorScore = '>' THEN
                               (SELECT 'Poor' WHERE @d_Score <> Operator1Value1forPoorScore AND @d_Score > Operator2Value1forPoorScore)
                          WHEN Operator2forPoorScore = '>=' THEN
                               (SELECT 'Poor' WHERE @d_Score <> Operator1Value1forPoorScore AND @d_Score >= Operator2Value1forPoorScore)         
                          WHEN Operator2forPoorScore = 'BETWEEN' THEN
                               (SELECT 'Poor' WHERE @d_Score <> Operator1Value1forPoorScore AND (@d_Score BETWEEN Operator2Value1forPoorScore AND Operator2Value2forPoorScore) )
                          WHEN Operator2forPoorScore = '=' THEN 
                               (SELECT 'Poor' WHERE @d_Score <> Operator1Value1forPoorScore AND @d_Score = Operator2Value1forPoorScore)             
                          WHEN Operator2forPoorScore IS NULL THEN      
                               (SELECT 'Poor' WHERE @d_Score <> Operator1Value1forPoorScore)     
                       END  	
				  ELSE ''
			   END 
	  
	     FROM 
			 HealthStatusScoreType
	     INNER JOIN UserHealthStatusScore
			 ON HealthStatusScoreType.HealthStatusScoreId = UserHealthStatusScore.HealthStatusScoreId	
		 WHERE 
			 CONVERT(VARCHAR,DateDetermined,101) = CONVERT(VARCHAR,@i_DateDetermined,101)
		 AND HealthStatusScoreType.HealthStatusScoreId = @i_HealthStatusScoreID	
		  
	
	SET @vc_GoalValue =
		    (SUBSTRING( ISNULL(@vc_RangeGood1,'')  + ISNULL(@vc_RangeFair1,'') +
			ISNULL(@vc_RangePoor1,''),1,4)) 
	IF @vc_GoalValue = ''
		SELECT @vc_GoalValue = 'UnDefined'		
	
	RETURN @vc_GoalValue
END