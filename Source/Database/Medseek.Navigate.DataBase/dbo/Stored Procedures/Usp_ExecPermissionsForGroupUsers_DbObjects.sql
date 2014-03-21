/*          
------------------------------------------------------------------------------          
Procedure Name: [Usp_ExecPermissionsForGroupUsers_DbObjects]
Description   : This procedure is used to Give the Execute permissions to Assigned group users
				on created database objects (DevTeam,QAteam,BATeam)
    table.        
Created By    : Sivakrishna
Created Date  : 06-Nov-2012          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------          
*/

CREATE PROC Usp_ExecPermissionsForGroupUsers_DbObjects
(
  @i_AppUserId KeyId =NULL
  )
AS
BEGIN TRY
	

	
	DECLARE @ExecDate DATETIME = GETDATE()
	DECLARE @DateDiff DATETIME = DATEADD(MI,-60,GETDATE())
	DECLARE @Min INT 
	DECLARE @Max INT 
	DECLARE @ObjectName VARCHAR(1000)
	DECLARE @ObjectType CHAR(2)
	DECLARE @User1 VARCHAR(50)= '[PERFMDB\DevTeam]'
	DECLARE @User2 VARCHAR(50)= '[PERFMDB\QATeam]'
	DECLARE @OwnerName VARCHAR(10) = 'Dbo'

    DECLARE  @t_Objects TABLE (Id INT IDENTITY(1,1),ObjectName VARCHAR(1000),ObjectType CHAR(2))
    
    
    INSERT @t_Objects
    SELECT 
    --so.Name,
    --st.Name,
      CASE WHEN so.Name IS NULL AND  st.name IS NOT NULL THEN  st.name 
           WHEN so.Name IS NOT NULL AND  st.name IS  NULL THEN  so.name 
           WHEN so.Name IS NOT NULL AND  st.name IS  NOT NULL AND so.Type ='TT' THEN  st.name END AS NAME  ,
           Type
    FROM 
	 Sys.objects so
    LEFT JOIN (SELECT 
					type_table_object_id,
					Name 
			   FROM sys.table_types 
			   WHERE is_user_defined = 1) st
      ON st.type_table_object_id = so.object_id
	WHERE 
	  create_date >=@DateDiff  AND create_date <=@ExecDate AND 
	 so.type IN('P','V','FN' ,'TR','IF' ,'TF','U','TT')
	 AND so.name <>'Usp_ExecPermissionsForGroupUsers_DbObjects'
	 --AND so.Name IS NOT NULL AND st.name IS NOT NULL
    SELECT @Min =MIN(Id),@Max =MAX(ID) FROM @t_Objects 
      
      WHILE @Min <=@Max
       BEGIN 
         SELECT 
            @ObjectName = ObjectName,@ObjectType=ObjectType
         FROM 
           @t_Objects WHERE Id  = @Min
         
			DECLARE @Str1 VARCHAR(MAX)
			DECLARE @Str2 VARCHAR(MAX)
			
			IF @ObjectType <>'TT'
			BEGIN
				SET @Str1 =  'GRANT EXEC ON ' + '[' + @OwnerName + ']' + '.' + '[' + @ObjectName + ']' + ' TO '+ @User1
				SET @Str2 =  'GRANT EXEC ON ' + '[' + @OwnerName + ']' + '.' + '[' + @ObjectName + ']' + ' TO '+ @User2
			END
			ELSE
			BEGIN
				SET @Str1 =  'GRANT EXECUTE , view definition ON TYPE::' + '[' + @ObjectName + ']' + ' TO [' + @User1 + ']'
				SET @Str2 =  'GRANT EXECUTE , view definition ON TYPE::' + '[' + @ObjectName + ']' + ' TO [' + @User2 + ']'
			END
			
			PRINT(@Str1)
			PRINT(@Str2)
			EXEC(@Str1)
			EXEC(@Str2)
			SET  @Min = @Min+1
		END

	END TRY
  BEGIN CATCH
   DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
			RETURN @i_ReturnedErrorID
      END CATCH

    
  


  

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[Usp_ExecPermissionsForGroupUsers_DbObjects] TO [FE_rohit.r-ext]
    AS [dbo];

