CREATE PROCEDURE [dbo].[usp_UserNotes_Select]
(    
	@i_AppUserId KEYID,    
	@i_UserId KEYID = NULL,    
    @v_StatusCode StatusCode = NULL,    
    @v_NoteType CHAR(1) = NULL,  -- P - Patient note, V - Visit Plan (From User, 'V' need to be passed)    
    @b_ShowLastOneYearData BIT = 0
)    
     
AS    
BEGIN TRY     
    
 -- Check if valid Application User ID is passed    
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )    
         BEGIN    
               RAISERROR ( N'Invalid Application User ID %d passed.' ,    
               17 ,    
               1 ,    
               @i_AppUserId )    
         END    
    
------------ Selection from UserNotes table starts here ------------    
      CREATE TABLE #tblCallNotes
      (
		UserNotesId INT ,    
		UserId INT ,    
		Note VARCHAR(500),    
		ViewableByPatient BIT ,    
		UserNoteDate DATETIME ,    
		NoteType VARCHAR(50) ,    
		CreatedByUserId INT ,    
		CreatedDate DATETIME ,    
		LastModifiedByUserId INT ,    
		LastModifiedDate DATETIME ,    
		[Status] VARCHAR(10) ,
		ProviderName VARCHAR(50)  
      )
      INSERT INTO #tblCallNotes
      (
		UserNotesId ,    
		UserId ,    
		Note ,    
		ViewableByPatient ,    
		UserNoteDate ,    
		NoteType ,    
		CreatedByUserId ,    
		CreatedDate ,    
		LastModifiedByUserId ,    
		LastModifiedDate ,    
		[Status],
		ProviderName 
      )
      SELECT    
		   PatientNotesId UserNotesId,    
		   PatientId UserId,    
		   Note ,    
		   ViewableByPatient,    
		   UserNoteDate,    
		   CASE NoteType    
			WHEN 'P' THEN 'Patient Note'    
			WHEN 'V' THEN 'Visit Plan'    
		   END AS NoteType,    
		   CreatedByUserId,    
		   CreatedDate,    
		   LastModifiedByUserId,    
		   LastModifiedDate,    
		   CASE StatusCode    
			WHEN 'A' THEN 'Active'    
			WHEN 'I' THEN 'InActive'    
		   END AS Status ,
		   dbo.ufn_GetUserNameByID(PatientNotes.CreatedByUserId) AS ProviderName   
      FROM    
          PatientNotes    
      WHERE PatientId = @i_UserId     
        AND ( @v_StatusCode IS NULL or StatusCode = @v_StatusCode )
        AND NoteType = 'P'       
        AND ( @v_NoteType IS NULL OR NoteType = @v_NoteType )
        AND ( @b_ShowLastOneYearData = 0 OR
				( @b_ShowLastOneYearData = 1 AND
				  UserNoteDate > DATEADD(YEAR, -1, GETDATE())
				)  
			)
	    AND ((ViewableByPatient = 1 AND @i_AppUserId = ISNULL(@i_UserId,0)) OR (@i_AppUserId <> ISNULL(@i_UserId,0)))		
	  --ORDER BY
   --       UserNoteDate DESC,Note     
          
       INSERT INTO #tblCallNotes
      (
		UserNotesId ,    
		UserId ,    
		Note ,    
		ViewableByPatient ,    
		UserNoteDate ,    
		NoteType ,    
		CreatedByUserId ,    
		CreatedDate ,    
		LastModifiedByUserId ,    
		LastModifiedDate ,    
		[Status],
		ProviderName 
      )
      SELECT    
		   PatientNotesId UserNotesId,    
		   PatientId UserId,    
		   Note ,    
		   ViewableByPatient,    
		   UserNoteDate,    
		   CASE NoteType    
			WHEN 'P' THEN 'Patient Note'    
			WHEN 'V' THEN 'Visit Plan'    
		   END AS NoteType,    
		   CreatedByUserId,    
		   CreatedDate,    
		   LastModifiedByUserId,    
		   LastModifiedDate,    
		   CASE StatusCode    
			WHEN 'A' THEN 'Active'    
			WHEN 'I' THEN 'InActive'    
		   END AS Status ,
		   dbo.ufn_GetUserNameByID(PatientNotes.CreatedByUserId) AS ProviderName   
      FROM    
          PatientNotes    
      WHERE PatientId = @i_UserId     
        AND ( @v_StatusCode IS NULL or StatusCode = @v_StatusCode )
        AND NoteType = 'V'       
        AND ( @v_NoteType IS NULL OR NoteType = @v_NoteType )
        AND ( @b_ShowLastOneYearData = 0 OR
				( @b_ShowLastOneYearData = 1 AND
				  UserNoteDate > DATEADD(YEAR, -1, GETDATE())
				)  
			)
	    AND ((ViewableByPatient = 1 AND @i_AppUserId = ISNULL(@i_UserId,0)) OR (@i_AppUserId <> ISNULL(@i_UserId,0)))	
	    AND NOT EXISTS (SELECT 1
						FROM #tblCallNotes TCN
						WHERE TCN.Note = PatientNotes.Note	
						AND TCN.ProviderName = dbo.ufn_GetUserNameByID(PatientNotes.CreatedByUserId)
						AND TCN.UserNoteDate = PatientNotes.UserNoteDate)
	  --ORDER BY
   --       UserNoteDate DESC,Note  
          
	SELECT
		UserNotesId ,    
		UserId ,    
		Note ,    
		ViewableByPatient ,    
		UserNoteDate ,    
		NoteType ,    
		CreatedByUserId ,    
		CreatedDate ,    
		LastModifiedByUserId ,    
		LastModifiedDate ,    
		[Status],
		ProviderName   
	FROM
		#tblCallNotes
	ORDER BY  UserNoteDate DESC,Note  	 	               
          
END TRY    
BEGIN CATCH    
    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserNotes_Select] TO [FE_rohit.r-ext]
    AS [dbo];

