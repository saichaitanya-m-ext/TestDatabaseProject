/*    
------------------------------------------------------------------------------    
Procedure Name: usp_ProgramProcedureFrequency_Insert    
Description   : This procedure is used to insert record into ProgramProcedureFrequency table
Created By    : Aditya    
Created Date  : 24-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
26-Apr-2011  RamaChandra added two parameter @b_NeverSchedule and @v_ExclusionReason
11-MAY-2011 Rathnam added @i_LabTestId one more parameter for inserting labtestid
24-May-2011 Rathnam added @d_EffectiveStartDate one more parameter 
06-Jun-2011 Rathnam added @b_IsPreventive, @i_DiseaseID two more parameters 
10-Aug-2011 NagaBabu Added If else condition and one tabletype parameter and @v_FrequencyCondition Parameter 
11-Aug-2011 NagaBabu Added @t_ProgramProcedureFrequency variable for split the values coming from table type parameter
22-Aug-2011 NagaBabu modified Monthly as Month(s), Yearly as Year(s)
24-Aug-2011 NagaBabu Added the condition to resctrict program,procedure multiple times in ProgramProcedureFrequency
26-Aug-2011 NagaBabu Added @t_ProgramProcedureTherapeuticDrugFrequency as input parameter and added insertstatement 
						 ProgramProcedureTherapeuticDrugFrequency table 
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_ProgramProcedureFrequency_Insert]  
(  
	@i_AppUserId KEYID,  
	@i_ProgramId KEYID,
	@i_ProcedureId KEYID,
	@vc_StatusCode StatusCode = NULL,
	@i_FrequencyNumber KeyID = NULL,
	@vc_Frequency VARCHAR(1)= NULL,
	@b_NeverSchedule BIT = NULL ,
	@vc_ExclusionReason ShortDescription = NULL,
	@i_LabTestId KEYID = NULL,
	@d_EffectiveStartDate UserDate = NULL,
	@i_DiseaseID KeyID = NULL,
    @b_IsPreventive IsIndicator = NULL,
    @t_ProgramProcedureConditionalFrequency ProgramProcedureConditionalFrequency READONLY,
    @v_FrequencyCondition SourceName,
    @t_ProgramProcedureTherapeuticDrugFrequency ProgramProcedureTherapeuticDrugFrequency READONLY 
)  
AS  
BEGIN TRY
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsInserted INT   
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR 
		   ( N'Invalid Application User ID %d passed.' ,  
		     17 ,  
		     1 ,  
		     @i_AppUserId
		   )  
	END  
------------------------------------------------------------------------------------
	
	IF @v_FrequencyCondition <> 'None'
			BEGIN
				--IF NOT EXISTS (SELECT
				--				   1
				--			   FROM 
				--					ProgramProcedureFrequency
				--			   WHERE ProgramId = @i_ProgramId
				--			   AND ProcedureId = @i_ProcedureId)
							   
				--	BEGIN				   				   
						INSERT INTO ProgramProcedureFrequency
						   ( 
								ProgramId,
								ProcedureId,
								StatusCode,
								FrequencyNumber,
								Frequency,
								CreatedByUserId,
								NeverSchedule,
								ExclusionReason,
								LabTestId,
								EffectiveStartDate,
								DiseaseID,
								IsPreventive,
								FrequencyCondition
						   )
						VALUES
						   ( 
								@i_ProgramId,
								@i_ProcedureId,
								@vc_StatusCode,
								@i_FrequencyNumber,
								@vc_Frequency,
								@i_AppUserId,
								@b_NeverSchedule,
								@vc_ExclusionReason,
								@i_LabTestId,
								@d_EffectiveStartDate,
								@i_DiseaseID,
								@b_IsPreventive,
								@v_FrequencyCondition
							)
								
						IF @v_FrequencyCondition = 'TerapeuticClassOrDrugName'
							BEGIN
								DECLARE @t_ProgramProcedureTherapeuticDrug TABLE
								(
									TherapeuticID KeyId ,
									DrugCodeId KeyId ,
									Duration SMALLINT ,
									DurationType VARCHAR(10) ,
									Frequency SMALLINT ,
									FrequencyUOM VARCHAR(10)
								)
								
								INSERT INTO @t_ProgramProcedureTherapeuticDrug
								(
									TherapeuticID ,
									DrugCodeId ,
									Duration ,
									DurationType ,
									Frequency ,
									FrequencyUOM
								)	
								SELECT
									TherapeuticID ,
									DrugCodeId ,
									CAST(SUBSTRING(DurationAndType,1,CHARINDEX(' ',DurationAndType,1)-1)AS SMALLINT) AS Duration,
									SUBSTRING(DurationAndType,CHARINDEX(' ',DurationAndType,1)+1,LEN(DurationAndType)) AS DurationType,
									CAST(SUBSTRING(FrequencyAndUOM,1,CHARINDEX(' ',FrequencyAndUOM,1)-1)AS SMALLINT) AS Frequency,
									SUBSTRING(FrequencyAndUOM,CHARINDEX(' ',FrequencyAndUOM,1)+1,LEN(FrequencyAndUOM)) AS FrequencyUOM
								FROM
									@t_ProgramProcedureTherapeuticDrugFrequency	
									
								INSERT INTO ProgramProcedureTherapeuticDrugFrequency
								(
									ProgramId ,
									ProcedureId ,
									TherapeuticID ,
									DrugCodeId ,
									Duration ,
									DurationType ,
									Frequency ,
									FrequencyUOM ,
									CreatedByUserId	
								)
								SELECT
									@i_ProgramId ,
									@i_ProcedureId ,
									TherapeuticID ,
									DrugCodeId ,
									Duration ,
									CASE DurationType
										WHEN 'Day(s)' THEN 'D'
										WHEN 'Week(s)' THEN 'W'
										WHEN 'Month(s)' THEN 'M'
										WHEN 'Year(s)' THEN 'Y'
									END AS DurationType ,	
									Frequency ,
									CASE FrequencyUOM
										WHEN 'Day(s)' THEN 'D'
										WHEN 'Week(s)' THEN 'W'
										WHEN 'Month(s)' THEN 'M'
										WHEN 'Year(s)' THEN 'Y'
									END AS FrequencyUOM ,	
									@i_AppUserId
								FROM 
									@t_ProgramProcedureTherapeuticDrug PPTD
									
								SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
							     
									IF @l_numberOfRecordsInserted < 1          
									BEGIN          
										RAISERROR      
											(  N'Invalid row count %d in insert ProgramProcedureTherapeuticDrugFrequency'
												,17      
												,1      
												,@l_numberOfRecordsInserted                 
											)              
									END  
								RETURN 0				
							END 
						ELSE
							BEGIN	
								DECLARE @t_ProgramProcedureFrequency TABLE
								(
									MeasureID KeyId ,
									FromOperatorForMeasure VARCHAR(5) ,
									FromValueforMeasure DECIMAL(10,2) ,
									ToOperatorforMeasure VARCHAR(5) ,
									ToValueforMeasure DECIMAL(10,2) ,
									MeasureTextValue SourceName ,
									FromOperatorforAge VARCHAR(5) , 
									FromValueforAge SMALLINT ,
									ToOperatorforAge VARCHAR(5) , 
									ToValueforAge SMALLINT ,
									Frequency SMALLINT ,
									FrequencyUOM VARCHAR(10)
								)
								
								INSERT INTO @t_ProgramProcedureFrequency
								(
									MeasureID ,
									FromOperatorForMeasure ,
									FromValueforMeasure ,
									ToOperatorforMeasure ,
									ToValueforMeasure ,
									MeasureTextValue ,
									FromOperatorforAge , 
									FromValueforAge ,
									ToOperatorforAge , 
									ToValueforAge ,
									Frequency ,
									FrequencyUOM 
								)		
								SELECT
									MeasureID ,
									SUBSTRING(FromOperatorWithValue,1,CHARINDEX(' ',FromOperatorWithValue,1)-1) AS FromOperatorForMeasure,
									CAST(SUBSTRING(FromOperatorWithValue,CHARINDEX(' ',FromOperatorWithValue,1)+1,LEN(FromOperatorWithValue)) AS DECIMAL(10,2)) AS FromValueforMeasure,
									SUBSTRING(ToOperatorWithValue,1,CHARINDEX(' ',ToOperatorWithValue,1)-1) AS ToOperatorforMeasure,
									CAST(SUBSTRING(ToOperatorWithValue,CHARINDEX(' ',ToOperatorWithValue,1)+1,LEN(ToOperatorWithValue)) AS DECIMAL(10,2))AS ToValueforMeasure,
									MeasureTextValue ,
									SUBSTRING(FromOperatorWithAge,1,CHARINDEX(' ',FromOperatorWithAge,1)-1) AS FromOperatorforAge,
									CAST(SUBSTRING(FromOperatorWithAge,CHARINDEX(' ',FromOperatorWithAge,1)+1,LEN(FromOperatorWithAge)) AS SMALLINT) AS FromValueforAge,
									SUBSTRING(ToOperatorWithAge,1,CHARINDEX(' ',ToOperatorWithAge,1)-1) AS ToOperatorforAge,
									CAST(SUBSTRING(ToOperatorWithAge,CHARINDEX(' ',ToOperatorWithAge,1)+1,LEN(ToOperatorWithAge)) AS SMALLINT) ToValueforAge,
									CAST(SUBSTRING(FrequencyNumberUOM,1,CHARINDEX(' ',FrequencyNumberUOM,1)-1) AS SMALLINT) AS Frequency ,
									SUBSTRING(FrequencyNumberUOM,CHARINDEX(' ',FrequencyNumberUOM,1)+1,LEN(FrequencyNumberUOM)) AS FrequencyUOM
								FROM
									@t_ProgramProcedureConditionalFrequency	
								
							
								INSERT INTO ProgramProcedureConditionalFrequency
								(
									ProgramID ,
									ProcedureID ,
									MeasureID ,
									FromOperatorforMeasure ,
									FromValueforMeasure ,
									ToOperatorforMeasure ,
									ToValueforMeasure ,
									MeasureTextValue ,
									FromOperatorforAge ,
									FromValueforAge ,
									ToOperatorforAge ,
									ToValueforAge ,
									FrequencyUOM ,
									Frequency ,
									CreatedByUserId 
								)
								SELECT
									@i_ProgramId ,
									@i_ProcedureId ,
									TPPCF.MeasureID ,
									TPPCF.FromOperatorforMeasure ,	
									TPPCF.FromValueforMeasure ,
									TPPCF.ToOperatorforMeasure ,
									TPPCF.ToValueforMeasure ,
									TPPCF.MeasureTextValue ,
									TPPCF.FromOperatorforAge ,
									TPPCF.FromValueforAge ,
									TPPCF.ToOperatorforAge ,
									TPPCF.ToValueforAge ,
									CASE TPPCF.FrequencyUOM 
										WHEN 'Day(s)' THEN 'D'
										WHEN 'Week(s)' THEN 'W'
										WHEN 'Month(s)' THEN 'M'
										WHEN 'Year(s)' THEN 'Y'
									END AS FrequencyUOM,
									TPPCF.Frequency ,
									@i_AppUserId
								FROM 
									@t_ProgramProcedureFrequency TPPCF	
						        				
		   						SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
							     
									IF @l_numberOfRecordsInserted < 1          
									BEGIN          
										RAISERROR      
											(  N'Invalid row count %d in insert ProgramProcedureConditionalFrequency'
												,17      
												,1      
												,@l_numberOfRecordsInserted                 
											)              
									END  
								RETURN 0
							END	
					--END	
			END
		ELSE
			BEGIN
				INSERT INTO ProgramProcedureFrequency
				   ( 
						ProgramId,
						ProcedureId,
						StatusCode,
						FrequencyNumber,
						Frequency,
						CreatedByUserId,
						NeverSchedule,
						ExclusionReason,
						LabTestId,
						EffectiveStartDate,
						DiseaseID,
						IsPreventive,
						FrequencyCondition
				   )
				VALUES
				   ( 
						@i_ProgramId,
						@i_ProcedureId,
						@vc_StatusCode,
						@i_FrequencyNumber,
						@vc_Frequency,
						@i_AppUserId,
						@b_NeverSchedule,
						@vc_ExclusionReason,
						@i_LabTestId,
						@d_EffectiveStartDate,
						@i_DiseaseID,
						@b_IsPreventive,
						@v_FrequencyCondition
					)
					
				SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
					 IF @l_numberOfRecordsInserted <> 1          
					 BEGIN          
						 RAISERROR      
							 (  N'Invalid row count %d in insert ProgramProcedureFrequency'
								 ,17      
								 ,1      
								 ,@l_numberOfRecordsInserted                 
							 )              
					 END 
				RETURN 0	                 	
			END				

END TRY    
--------------------------------------------------------     
BEGIN CATCH    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ProgramProcedureFrequency_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

