
CREATE PROCEDURE [dbo].[usp_dbAdmin_CheckDependencies] --- 1996/08/09 16:51
	@objname NVARCHAR(MAX) -- the object we want to check
	 ,
	@IsReferenced BIT = 0
AS
	DECLARE @objid INT -- the id of the object we want
	DECLARE @found_some BIT -- flag for dependencies found
	DECLARE @dbname SYSNAME
	
	--  Make sure the @objname is local to the current database.
	SELECT @dbname = PARSENAME(@objname, 3)
	
	IF @dbname IS NOT NULL
	   AND @dbname <> DB_NAME()
	BEGIN
	    RAISERROR (15250, - 1, - 1)
	    
	    RETURN (1)
	END
	
	--  See if @objname exists.
	SELECT @objid = OBJECT_ID(@objname)
	
	IF @objid IS NULL
	BEGIN
	    SELECT @dbname = DB_NAME()
	    
	    RAISERROR (15009, - 1, - 1, @objname, @dbname)
	    
	    RETURN (1)
	END
	
	--  Initialize @found_some to indicate that we haven't seen any dependencies.
	SELECT @found_some = 0
	
	SET NOCOUNT ON
	
	--  Print out the particulars about the local dependencies.
	IF EXISTS (
	       SELECT *
	       FROM   sysdepends
	       WHERE  id = @objid
	   )
	BEGIN
	    RAISERROR (15459, - 1, - 1)
	    
	    SELECT 'name' = (s6.NAME + '.' + o1.NAME),
	           TYPE         = SUBSTRING(v2.NAME, 5, 66),	-- spt_values.name is nvarchar(70)
	           updated      = SUBSTRING(u4.NAME, 1, 7),
	           selected     = SUBSTRING(w5.NAME, 1, 8),
	           'column' = COL_NAME(d3.depid, d3.depnumber)
	    FROM   sys.objects               o1,
	           MASTER.dbo.spt_values     v2,
	           sysdepends                d3,
	           MASTER.dbo.spt_values     u4,
	           MASTER.dbo.spt_values     w5 --11667
	           ,
	           sys.schemas               s6
	    WHERE  o1.object_id = d3.depid
	           AND o1.type = SUBSTRING(v2.NAME, 1, 2) COLLATE database_default
	           AND v2.type = 'O9T'
	           AND u4.type = 'B'
	           AND u4.number = d3.resultobj
	           AND w5.type = 'B'
	           AND w5.number = d3.readobj | d3.selall
	           AND d3.id = @objid
	           AND o1.schema_id = s6.schema_id
	           AND deptype < 2
	    
	    SELECT @found_some = 1
	END
	
	--  Now check for things that depend on the object.
	IF EXISTS (
	       SELECT *
	       FROM   sysdepends
	       WHERE  depid = @objid
	   )
	   AND @IsReferenced = 1
	BEGIN
	    RAISERROR (15460, - 1, - 1)
	    
	    SELECT DISTINCT 'name' = (s.NAME + '.' + o.NAME),
	           TYPE = SUBSTRING(v.NAME, 5, 66) -- spt_values.name is nvarchar(70)
	    FROM   sys.objects               o,
	           MASTER.dbo.spt_values     v,
	           sysdepends                d,
	           sys.schemas               s
	    WHERE  o.object_id = d.id
	           AND o.type = SUBSTRING(v.NAME, 1, 2) COLLATE database_default
	           AND v.type = 'O9T'
	           AND d.depid = @objid
	           AND o.schema_id = s.schema_id
	           AND deptype < 2
	    
	    SELECT @found_some = 1
	END
	
	--  Did we find anything in sysdepends?
	IF @found_some = 0
	    RAISERROR (15461, - 1, - 1)
	
	SET NOCOUNT OFF
	
	RETURN (0) -- sp_depends
	

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_dbAdmin_CheckDependencies] TO [FE_rohit.r-ext]
    AS [dbo];

