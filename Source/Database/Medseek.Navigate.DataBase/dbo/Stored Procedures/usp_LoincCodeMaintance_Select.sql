      
CREATE PROCEDURE [dbo].[usp_LoincCodeMaintance_Select]--64,null,null,null,null,2
       @i_AppUserId KEYID ,      
       @vc_LoincCode VARCHAR(5) = NULL ,      
       @vc_LoincCodeOption VARCHAR(12) = NULL,      
       @vc_LoincName SOURCENAME = NULL ,      
       @vc_LoincNameOption VARCHAR(12) = NULL,      
       @i_LoincCodeId KEYID = NULL,      
       @v_StatusCode StatusCode = NULL  
AS       
BEGIN TRY             
            
 -- Check if valid Application User ID is passed            
      IF ( @i_AppUserId IS NULL )      
      OR ( @i_AppUserId <= 0 )      
         BEGIN      
               RAISERROR ( N'Invalid Application User ID %d passed.' ,      
               17 ,      
               1 ,      
               @i_AppUserId )      
         END            
      DECLARE @v_LoincCode VARCHAR(7),      
        @v_LoincName VARCHAR(52)      
           
------------ Select the Option  ------------            
      SELECT      
          @v_LoincCode = CASE	@vc_LoincCodeOption      
                                WHEN 'Contains' THEN '%' + @vc_LoincCode + '%'      
                                WHEN 'Starts With' THEN @vc_LoincCode + '%'      
                                WHEN 'Equals' THEN @vc_LoincCode
                                ELSE @vc_LoincCode      
								END ,      
          @v_LoincName = CASE	@vc_LoincNameOption      
                                WHEN 'Contains' THEN '%' + @vc_LoincName + '%'      
                                WHEN 'Starts With' THEN @vc_LoincName + '%'      
                                WHEN 'Equals' THEN @vc_LoincName 
                                ELSE @vc_LoincName
                              END                  
---------Select based on the criteria starts here -------------------          
      
      SELECT      
            LoincCodeId
			,LoincCode
			,ShortDescription
			,LongDescription
			,Component
			,Property
			,TimeAspect
			,[System]
			,ScaleType
			,MethodType
			,Class
			,CreatedByUserId
			,CreatedDate
			,LastModifiedByUserId
			,LastModifiedDate
			,'' Status
          ,STUFF(( SELECT 
                          ',' + CSP.ProcedureCode + '-' + CSP.ProcedureName
                      FROM
                          CodeSetProcedure CSP
                      Left Outer  JOIN LoinCodeProcedure LCP
                          ON CSP.ProcedureCodeID = LCP.ProcedureId
                          
                      WHERE
                          lcp.LoincCodeId = CodeSetLoinc.LoincCodeId
                      FOR
                          XML PATH('') ) , 1 , 1 , '') AS MappedProcedureName  
          ,STUFF(( SELECT 
                          ',' + Measure.Name
                      FROM
                          Measure 
                      Left Outer  JOIN LoinCodeMeasure LCM
                          ON Measure.MeasureId = LCM.MeasureId
                      WHERE
                          LCM.LoinCodeId = CodeSetLoinc.LoincCodeId
                      FOR
                          XML PATH('') ) , 1 , 1 , '') AS MappedMeasureName 
          ,STUFF(( SELECT Distinct
                          ',' + CodeSetProcedure.ProcedureCode+'-'+CodeSetProcedure.ProcedureName
                      FROM
							LoinCodeMeasure 
					  INNER JOIN ProcedureMeasure 
							ON ProcedureMeasure.MeasureId= LoinCodeMeasure.MeasureId
					  INNER JOIN CodeSetProcedure 
							ON CodeSetProcedure.ProcedureCodeID=ProcedureMeasure.ProcedureId
                      WHERE
                          LoinCodeMeasure.LoinCodeId = CodeSetLoinc.LoincCodeId
                      FOR
                          XML PATH('') ) , 1 , 1 , '') AS AssociatedProcedureName        
                              
                   
      FROM      
          CodeSetLoinc     
      WHERE      
            ( LoincCode LIKE @v_LoincCode      
              OR @v_LoincCode IS NULL      
              OR @v_LoincCode = '' )      
        AND ( ShortDescription LIKE @v_LoincName      
              OR @v_LoincName IS NULL      
              OR @v_LoincName = '' )      
        AND ( LoincCodeId = @i_LoincCodeId      
              OR @i_LoincCodeId IS NULL )      
        --AND ( @v_StatusCode IS NULL OR StatusCode = @v_StatusCode )    
        
	ORDER BY
			CreatedDate DESC
                              
END TRY      
BEGIN CATCH            
            
    -- Handle exception            
      DECLARE @i_ReturnedErrorID INT      
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId      
      
      RETURN @i_ReturnedErrorID      
END CATCH


 
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LoincCodeMaintance_Select] TO [FE_rohit.r-ext]
    AS [dbo];

