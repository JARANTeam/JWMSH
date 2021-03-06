
USE [JWMSH_2016]
GO
/****** Object:  StoredProcedure [dbo].[GenRoleFunction]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GenRoleFunction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:upjd
-- Create date:20140803
-- Description:	创建默认权限
-- =============================================
CREATE PROCEDURE [dbo].[GenRoleFunction]
	@rCode nvarchar(30)
AS
BEGIN
	INSERT INTO BRoleFunction
	(
		rCode,
		fCode
	)
	SELECT @rCode,cFunction 
	FROM BFunction  WHERE cFunction NOT IN (SELECT fCode FROM BRoleFunction  WHERE rCode=@rCode)
	
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[GetRecordPage]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetRecordPage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--获取记录并翻页
Create PROCEDURE [dbo].[GetRecordPage]
@PageIndex    int = 1,            -- 页码
@TableRecord nvarchar(50),
@fldName      nvarchar(255),       -- 字段名
@PageSize     int = 10,           -- 页尺寸
@strWhere     nvarchar(255) = '''',  -- 查询条件(注意: 不要加where)
@PageCount int output,  --总页数，作为返回值
@RecordCount int output
AS
declare @i int
declare @j int
declare @strSQL   nvarchar(4000)       -- 主语句
declare @strOrder nvarchar(500)        -- 排序类型

begin

set @strOrder = '' order by ['' + @fldName +''] desc''
set @j=(@PageIndex-1)*@PageSize
set @strSQL = ''SELECT top '' + str(@PageSize) + '' *
     FROM ''+@TableRecord+''
     where ['' + @fldName + ''] not in(SELECT TOP ''+ str(@j)+ '' ['' + @fldName + '']
     FROM ''+@TableRecord+'' ''+ @strOrder + '') ''+ @strOrder
end
if @strWhere != ''''
begin
    set @strSQL = ''select top '' + str(@PageSize) + '' * from [''
        + @TableRecord + ''] where ['' + @fldName + ''] not in(select top '' + str(@j) + '' [''
        + @fldName + ''] from ['' + @TableRecord + ''] where '' + @strWhere + '' ''
        + @strOrder + '') and '' + @strWhere + '' '' + @strOrder
end
exec (@strSQL)
if @strWhere != ''''
	begin
		set @strSQL = ''select @i=count('' + @fldName + '') from ['' + @TableRecord + ''] where '' + @strWhere + '' ''--用来获取总记录数
	end
else
	begin
		set @strSQL = ''select @i=count('' + @fldName + '') from ['' + @TableRecord + '']''--用来获取总记录数
	end
exec   sp_executesql   @strSQL,N''@i    int    output'' ,@i  output
set @RecordCount = @i
/*得到总页数，注意使用convert先转换整型为浮点型，防止小数部分丢失*/
set @PageCount = ceiling ( convert( float,@i)/@PageSize)
return 





' 
END
GO
/****** Object:  StoredProcedure [dbo].[proc_Bar_RawMaterialInsert]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_Bar_RawMaterialInsert]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		upjd
-- Create date: 20160110
-- Description:	新增原料标签记录
-- =============================================
CREATE PROCEDURE [dbo].[proc_Bar_RawMaterialInsert]
	@AutoID int = NULL output,
	@cSerialNumber nvarchar(155) = NULL output,
	@FitemID nvarchar(50)= NULL,
	@cInvCode nvarchar(50) = NULL,
	@cInvName nvarchar(255) = NULL,
	@cInvStd nvarchar(50) = NULL,
	@cFullName nvarchar(255),
	@cVendor nvarchar(50) = NULL,
	@cLotNo nvarchar(255) = NULL,
	@iQuantity float = NULL,
	@dDate datetime = NULL,
	@cMemo nvarchar(255) = NULL,
	@cDefaultLoc nvarchar(50)=null,
	@cDefaultSP nvarchar(50)=null
AS
BEGIN
	--定义变量
	declare  @temp nvarchar(50),@itemp int
	--取年月日121116
	set @temp=right((select convert(varchar(10),getdate(),112)),6)
	--判断当天是否开始入库
	set @itemp=(select COUNT(*) from RmLabel where substring(cSerialNumber,len(cSerialNumber)-9,6) =@temp)
	--如果大于零则是开始采购
	if @itemp>0
	set @cSerialNumber=''RM''+(select top 1 @temp+
	Right(''0000''+cast(convert(integer,right(cSerialNumber,4))+1 as varchar),4)
	from RmLabel where substring(cSerialNumber,len(cSerialNumber)-9,6) =@temp
	order by cSerialNumber desc)
	else
	set @cSerialNumber=''RM''+(@temp+''0001'')



	INSERT INTO [dbo].[RmLabel]
           ([cSerialNumber]
           ,[FitemID]
           ,[cInvCode]
           ,[cInvName]
           ,[cInvStd]
           ,[cFullName]
           ,[cDefaultLoc]
           ,[cDefaultSP]
           ,[cLotNo]
           ,[cVendor]
           ,[iQuantity]
           ,[dDate]
           ,[cMemo]
           ,[cDefine1]
           ,[cDefine2]
           ,[cDefine3]
           ,[cDefine4])
     VALUES
           (
			@cSerialNumber,
			@FitemID,
			@cInvCode,
			@cInvName,
			@cInvStd,
			@cFullName,
			@cDefaultLoc,
			@cDefaultSP,
			@cLotNo,
			@cVendor,
			@iQuantity,
			@dDate,
			@cMemo,
			'''',
			'''',
			'''',
			'''')
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[proc_Bar_RawMaterialUpdate]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_Bar_RawMaterialUpdate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		upjd
-- Create date: 20160110
-- Description:	修改原料标签记录
-- =============================================
CREATE PROCEDURE [dbo].[proc_Bar_RawMaterialUpdate]
	@AutoID int = NULL,
	@FitemID nvarchar(50)= NULL,
	@cInvCode nvarchar(50) = NULL,
	@cInvName nvarchar(255) = NULL,
	@cInvStd nvarchar(50) = NULL,
	@cFullName nvarchar(255),
	@cVendor nvarchar(50) = NULL,
	@cLotNo nvarchar(255) = NULL,
	@iQuantity float = NULL,
	@dDate datetime = NULL,
	@cMemo nvarchar(255) = NULL,
	@cDefaultLoc nvarchar(50)=null,
	@cDefaultSP nvarchar(50)=null
AS
BEGIN
	SET NOCOUNT OFF
	DECLARE @Err int
	UPDATE RmLabel
	SET
		[cLotNo] = @cLotNo,
		[iQuantity] = @iQuantity,
		[dDate] = @dDate,
		[cInvCode] = @cInvCode,
		[cInvName] = @cInvName,
		[cInvStd] = @cInvStd,
		cFullName = @cFullName,
		[cVendor] = @cVendor,
		[cMemo] = @cMemo,
		cDefaultLoc=@cDefaultLoc,
		cDefaultSP=@cDefaultSP

	WHERE
		[AutoID] = @AutoID


	SET @Err = @@Error


	RETURN @Err
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[SaveGridStyle]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SaveGridStyle]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- =============================================
-- Author:		<Author,,zqs>
-- Create date: <Create Date,,20140605>
-- Description:	<Description,,保存表格样式>
-- =============================================
CREATE PROCEDURE [dbo].[SaveGridStyle]
	@cFormID NVARCHAR(50),
	@cFormName NVARCHAR(50),
	@cKey NVARCHAR(50),
	@cCaption NVARCHAR(50),
	@iVisualPosition INT,
	@iWidth INT=null,
	@bHide bit
AS
BEGIN
	IF EXISTS(SELECT * FROM ColumnSeting WHERE cFormID=@cFormID AND cKey=@cKey)
		BEGIN
			UPDATE ColumnSeting SET cCaption =@cCaption,iVisualPosition = @iVisualPosition,bHide = @bHide,iWidth=@iWidth
			WHERE cFormID=@cFormID AND cKey=@cKey
		END
	ELSE
		BEGIN
			insert into ColumnSeting(cFormId,cFormName,cKey,cCaption,iVisualPosition,bHide,iWidth) Values(@cFormId,@cFormName,@cKey,@cCaption,@iVisualPosition,@bHide,@iWidth)
		
		END
END





' 
END
GO
/****** Object:  Table [dbo].[BDepartment]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BDepartment]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BDepartment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[cDepCode] [nvarchar](30) NULL,
	[cDepName] [nvarchar](50) NULL,
	[cDepPerSon] [nvarchar](50) NULL,
	[dAddTime] [datetime] NULL DEFAULT (getdate()),
	[bEnable] [bit] NULL DEFAULT ((1)),
 CONSTRAINT [PK_BDEPARTMENT] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[BFunction]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BFunction]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BFunction](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[cFunction] [nvarchar](20) NULL,
	[cModule] [nvarchar](20) NULL,
	[bMenu] [bit] NULL,
	[cClass] [nvarchar](255) NULL,
 CONSTRAINT [PK_BFUNCTION] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[BLogAction]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BLogAction]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BLogAction](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[cFunction] [nvarchar](255) NULL,
	[cDescription] [nvarchar](255) NULL,
	[dDate] [datetime] NULL,
	[dAddTime] [datetime] NULL,
 CONSTRAINT [PK_BLOGACTION] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[BPrinter]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BPrinter]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BPrinter](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[cCaption] [nvarchar](50) NULL,
	[cIpAddress] [nvarchar](50) NULL,
	[cMemo] [nvarchar](50) NULL,
	[dAddtime] [datetime] NULL,
 CONSTRAINT [PK_BPrinter] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[BRole]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BRole]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BRole](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[cCode] [nvarchar](20) NULL,
	[cName] [nvarchar](30) NULL,
	[dAddTime] [datetime] NULL CONSTRAINT [DF_BRole_dAddTime]  DEFAULT (getdate()),
	[bEnable] [bit] NULL CONSTRAINT [DF_BRole_bEnable]  DEFAULT ((1)),
 CONSTRAINT [PK_BROLE] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[BRoleFunction]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BRoleFunction]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BRoleFunction](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[rCode] [nvarchar](20) NULL,
	[fCode] [nvarchar](20) NULL,
	[bRight] [bit] NULL,
 CONSTRAINT [PK_BROLEFUNCTION] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[BSetting]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BSetting]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BSetting](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[cName] [nvarchar](50) NULL,
	[cValue] [nvarchar](255) NULL,
	[cMemo] [nvarchar](255) NULL,
	[cDefine1] [nvarchar](255) NULL,
	[cDefine2] [int] NULL,
	[cDefine3] [decimal](16, 6) NULL,
 CONSTRAINT [PK_BSetting] PRIMARY KEY CLUSTERED 
(
	[AutoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[BTempletList]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BTempletList]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BTempletList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[cFunction] [nvarchar](50) NULL,
	[cCaption] [nvarchar](50) NULL,
	[cTempletPath] [nvarchar](100) NULL,
	[cPrinter] [nvarchar](100) NULL,
	[bDefault] [bit] NULL CONSTRAINT [DF_BTempletList_bDefault]  DEFAULT ((0)),
	[dAddTime] [datetime] NULL,
 CONSTRAINT [PK_BTEMPLETLIST] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[BUser]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BUser]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BUser](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[uCode] [nvarchar](20) NULL,
	[uName] [nvarchar](50) NULL,
	[uPassword] [nvarchar](50) NULL,
	[uRole] [nvarchar](20) NULL,
	[uDepartment] [nvarchar](20) NULL,
	[dAddTime] [datetime] NULL CONSTRAINT [DF_BUser_dAddTime]  DEFAULT (getdate()),
	[bEnable] [bit] NULL CONSTRAINT [DF_BUser_bEnable]  DEFAULT ((1)),
	[bOperator] [bit] NULL CONSTRAINT [DF_BUser_bOperator]  DEFAULT ((1)),
 CONSTRAINT [PK_BUSER] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[ColumnSeting]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ColumnSeting]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ColumnSeting](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[cFormID] [nvarchar](100) NULL,
	[cFormName] [nvarchar](100) NULL,
	[cKey] [nvarchar](100) NULL,
	[cCaption] [nvarchar](100) NULL,
	[iVisualPosition] [int] NULL,
	[bHide] [bit] NULL,
	[iWidth] [int] NULL CONSTRAINT [DF_ColumnSeting_iWidth]  DEFAULT ((100)),
 CONSTRAINT [PK_BCOLUMNSETTING] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[RmLabel]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RmLabel]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RmLabel](
	[AutoID] [bigint] IDENTITY(1,1) NOT NULL,
	[cSerialNumber] [nvarchar](155) NULL,
	[FitemID] [nvarchar](50) NULL,
	[cInvCode] [nvarchar](50) NULL,
	[cInvName] [nvarchar](255) NULL,
	[cInvStd] [nvarchar](255) NULL,
	[cFullName] [nvarchar](255) NULL,
	[cDefaultLoc] [nvarchar](50) NULL,
	[cDefaultSP] [nvarchar](50) NULL,
	[cLotNo] [nvarchar](50) NULL,
	[cVendor] [nvarchar](255) NULL,
	[iQuantity] [decimal](18, 4) NULL,
	[dDate] [date] NULL,
	[cMemo] [nvarchar](255) NULL,
	[cDefine1] [nvarchar](255) NULL,
	[cDefine2] [nvarchar](255) NULL,
	[cDefine3] [nvarchar](255) NULL,
	[cDefine4] [nvarchar](255) NULL,
 CONSTRAINT [PK_RmLabel] PRIMARY KEY CLUSTERED 
(
	[AutoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[Tb_Collect]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tb_Collect]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Tb_Collect](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[eKey] [nvarchar](50) NOT NULL,
	[cName] [nvarchar](100) NOT NULL,
	[tName] [nvarchar](50) NOT NULL,
	[cType] [nvarchar](50) NULL,
 CONSTRAINT [PK_Tb_Collect] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  View [dbo].[View_BUserRole]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_BUserRole]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[View_BUserRole]
AS
SELECT   dbo.BRole.cCode AS rCode, dbo.BRole.cName AS rName, dbo.BUser.uCode AS cCode, dbo.BUser.uName AS cName, 
                dbo.BUser.uPassword AS cPwd, dbo.BUser.uDepartment, dbo.BUser.bOperator
FROM      dbo.BRole RIGHT OUTER JOIN
                dbo.BUser ON dbo.BRole.cCode = dbo.BUser.uRole
' 
GO
/****** Object:  View [dbo].[View_RoleAndUser]    Script Date: 2016/1/10 17:55:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_RoleAndUser]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[View_RoleAndUser]
AS
SELECT   id, cCode, cName
FROM      BRole
union all 
SELECT   id, uCode, uName
FROM      BUser

' 
GO
SET IDENTITY_INSERT [dbo].[BDepartment] ON 

GO
INSERT [dbo].[BDepartment] ([ID], [cDepCode], [cDepName], [cDepPerSon], [dAddTime], [bEnable]) VALUES (1, N'D001', N'Huaxiang', N'demo', CAST(N'2016-01-09 15:45:38.213' AS DateTime), 1)
GO
SET IDENTITY_INSERT [dbo].[BDepartment] OFF
GO
SET IDENTITY_INSERT [dbo].[BFunction] ON 

GO
INSERT [dbo].[BFunction] ([ID], [cFunction], [cModule], [bMenu], [cClass]) VALUES (1, N'原料标签打印', N'原料入库管理
', 1, N'JWMSH.WorkRmLabelPrint')
GO
INSERT [dbo].[BFunction] ([ID], [cFunction], [cModule], [bMenu], [cClass]) VALUES (2, N'金蝶采购订单', N'原料入库管理
', 1, N'JWMSH.WorkRmPurchaseOrder')
GO
INSERT [dbo].[BFunction] ([ID], [cFunction], [cModule], [bMenu], [cClass]) VALUES (3, N'产成品BOM管理', N'生产追溯管理
', 1, N'JWMSH.WorkTrackBom')
GO
INSERT [dbo].[BFunction] ([ID], [cFunction], [cModule], [bMenu], [cClass]) VALUES (4, N'产成品BOM查询', N'生产追溯管理
', 1, N'JWMSH.WorkTrackBomQuery')
GO
INSERT [dbo].[BFunction] ([ID], [cFunction], [cModule], [bMenu], [cClass]) VALUES (5, N'班次制令单', N'生产追溯管理
', 1, N'JWMSH.WorkTrackShiftOrder')
GO
INSERT [dbo].[BFunction] ([ID], [cFunction], [cModule], [bMenu], [cClass]) VALUES (6, N'产成品标签打印', N'生产追溯管理
', 1, N'JWMSH.WorkTrackProductLabelPrint')
GO
INSERT [dbo].[BFunction] ([ID], [cFunction], [cModule], [bMenu], [cClass]) VALUES (7, N'产成品拆箱', N'生产追溯管理
', 1, N'JWMSH.WorkTrackProductTransferBox')
GO
INSERT [dbo].[BFunction] ([ID], [cFunction], [cModule], [bMenu], [cClass]) VALUES (8, N'产成品出库指令单', N'生产追溯管理
', 1, N'JWMSH.WorkTrackDeliveryOrder')
GO
INSERT [dbo].[BFunction] ([ID], [cFunction], [cModule], [bMenu], [cClass]) VALUES (9, N'打印调拨单', N'生产追溯管理
', 1, N'JWMSH.WorkTrackPrintTransfer')
GO
INSERT [dbo].[BFunction] ([ID], [cFunction], [cModule], [bMenu], [cClass]) VALUES (10, N'打印盘点单', N'生产追溯管理
', 1, N'JWMSH.WorkTrackPrintCheck')
GO
INSERT [dbo].[BFunction] ([ID], [cFunction], [cModule], [bMenu], [cClass]) VALUES (11, N'原料标签打印记录表', N'报表管理', 1, N'JWMSH.RptRmLabelPrint')
GO
INSERT [dbo].[BFunction] ([ID], [cFunction], [cModule], [bMenu], [cClass]) VALUES (12, N'原料采购入库明细表', N'报表管理', 1, N'JWMSH.RptRmStoreDetail')
GO
INSERT [dbo].[BFunction] ([ID], [cFunction], [cModule], [bMenu], [cClass]) VALUES (13, N'用户管理', N'维护中心', 1, N'JWMSH.BaseUser')
GO
INSERT [dbo].[BFunction] ([ID], [cFunction], [cModule], [bMenu], [cClass]) VALUES (14, N'角色权限管理', N'维护中心', 1, N'JWMSH.BaseRoleFunction')
GO
INSERT [dbo].[BFunction] ([ID], [cFunction], [cModule], [bMenu], [cClass]) VALUES (15, N'表格样式维护', N'维护中心', 1, N'JWMSH.Base_ColumnSetting')
GO
INSERT [dbo].[BFunction] ([ID], [cFunction], [cModule], [bMenu], [cClass]) VALUES (16, N'标签模版维护', N'维护中心', 1, N'JWMSH.Base_Templet')
GO
SET IDENTITY_INSERT [dbo].[BFunction] OFF
GO
SET IDENTITY_INSERT [dbo].[BRole] ON 

GO
INSERT [dbo].[BRole] ([ID], [cCode], [cName], [dAddTime], [bEnable]) VALUES (1, N'01', N'Admin', CAST(N'2016-01-09 14:34:14.300' AS DateTime), 1)
GO
SET IDENTITY_INSERT [dbo].[BRole] OFF
GO
SET IDENTITY_INSERT [dbo].[BRoleFunction] ON 

GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (1, N'01', N'原料标签打印', 1)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (2, N'01', N'金蝶采购订单', 1)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (3, N'01', N'产成品BOM管理', 1)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (4, N'01', N'产成品BOM查询', 1)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (5, N'01', N'班次制令单', 1)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (6, N'01', N'产成品标签打印', 1)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (7, N'01', N'产成品拆箱', 1)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (8, N'01', N'产成品出库指令单', 1)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (9, N'01', N'打印调拨单', 1)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (10, N'01', N'打印盘点单', 1)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (11, N'01', N'原料标签打印记录表', 1)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (12, N'01', N'原料采购入库明细表', 0)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (13, N'01', N'用户管理', 1)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (14, N'01', N'角色权限管理', 1)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (15, N'01', N'表格样式维护', 1)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (16, N'demo', N'原料标签打印', NULL)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (17, N'demo', N'金蝶采购订单', NULL)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (18, N'demo', N'产成品BOM管理', NULL)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (19, N'demo', N'产成品BOM查询', NULL)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (20, N'demo', N'班次制令单', NULL)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (21, N'demo', N'产成品标签打印', NULL)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (22, N'demo', N'产成品拆箱', NULL)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (23, N'demo', N'产成品出库指令单', NULL)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (24, N'demo', N'打印调拨单', NULL)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (25, N'demo', N'打印盘点单', NULL)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (26, N'demo', N'原料标签打印记录表', NULL)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (27, N'demo', N'原料采购入库明细表', NULL)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (28, N'demo', N'用户管理', NULL)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (29, N'demo', N'角色权限管理', NULL)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (30, N'demo', N'表格样式维护', NULL)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (31, N'01', N'标签模版维护', 1)
GO
INSERT [dbo].[BRoleFunction] ([ID], [rCode], [fCode], [bRight]) VALUES (32, N'demo', N'标签模版维护', NULL)
GO
SET IDENTITY_INSERT [dbo].[BRoleFunction] OFF
GO
SET IDENTITY_INSERT [dbo].[BTempletList] ON 

GO
INSERT [dbo].[BTempletList] ([ID], [cFunction], [cCaption], [cTempletPath], [cPrinter], [bDefault], [dAddTime]) VALUES (1, N'原料标签', N'原料标准标签', N'原料标准标签.repx', N'Adobe PDF', 1, NULL)
GO
SET IDENTITY_INSERT [dbo].[BTempletList] OFF
GO
SET IDENTITY_INSERT [dbo].[BUser] ON 

GO
INSERT [dbo].[BUser] ([ID], [uCode], [uName], [uPassword], [uRole], [uDepartment], [dAddTime], [bEnable], [bOperator]) VALUES (1, N'demo', N'Demo', N'a994daa0c4a76b6a4ef640d41777ec0a', N'01', N'D001', CAST(N'2016-01-09 14:33:28.110' AS DateTime), 1, 1)
GO
SET IDENTITY_INSERT [dbo].[BUser] OFF
GO
SET IDENTITY_INSERT [dbo].[ColumnSeting] ON 

GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (1, N'-876654441', N'金蝶物料档案', N'FItemID', N'KID', 0, 0, 68)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (2, N'-876654441', N'金蝶物料档案', N'FNumber', N'编码', 1, 0, 118)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (3, N'-876654441', N'金蝶物料档案', N'FName', N'名称', 2, 0, 118)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (4, N'-876654441', N'金蝶物料档案', N'FModel', N'型号', 3, 0, 118)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (5, N'-876654441', N'金蝶物料档案', N'FFullName', N'全称', 4, 0, 118)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (6, N'-876654441', N'金蝶物料档案', N'FDefaultLoc', N'默认仓库', 5, 0, 85)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (7, N'-876654441', N'金蝶物料档案', N'FSPID', N'默认仓位', 6, 0, 68)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (8, N'269846084', N'原料标签打印', N'AutoID', N'AutoID', 0, 1, 93)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (9, N'269846084', N'原料标签打印', N'cSerialNumber', N'序列号', 3, 0, 118)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (10, N'269846084', N'原料标签打印', N'FitemID', N'FitemID', 1, 1, 118)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (11, N'269846084', N'原料标签打印', N'cInvCode', N'编码', 2, 0, 77)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (12, N'269846084', N'原料标签打印', N'cInvName', N'名称', 6, 0, 132)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (13, N'269846084', N'原料标签打印', N'cInvStd', N'规格', 7, 0, 101)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (14, N'269846084', N'原料标签打印', N'cFullName', N'全称', 8, 0, 118)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (15, N'269846084', N'原料标签打印', N'cDefaultLoc', N'默认仓库', 9, 0, 118)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (16, N'269846084', N'原料标签打印', N'cDefaultSP', N'默认仓位', 10, 0, 118)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (17, N'269846084', N'原料标签打印', N'cLotNo', N'批号', 4, 0, 118)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (18, N'269846084', N'原料标签打印', N'cVendor', N'供应商', 11, 0, 118)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (19, N'269846084', N'原料标签打印', N'iQuantity', N'数量', 5, 0, 93)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (20, N'269846084', N'原料标签打印', N'dDate', N'生产日期', 12, 0, 94)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (21, N'269846084', N'原料标签打印', N'cMemo', N'备注', 15, 0, 118)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (22, N'269846084', N'原料标签打印', N'cDefine1', N'cDefine1', 13, 1, 118)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (23, N'269846084', N'原料标签打印', N'cDefine2', N'cDefine2', 14, 1, 118)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (24, N'269846084', N'原料标签打印', N'cDefine3', N'cDefine3', 16, 1, 118)
GO
INSERT [dbo].[ColumnSeting] ([ID], [cFormID], [cFormName], [cKey], [cCaption], [iVisualPosition], [bHide], [iWidth]) VALUES (25, N'269846084', N'原料标签打印', N'cDefine4', N'cDefine4', 17, 1, 118)
GO
SET IDENTITY_INSERT [dbo].[ColumnSeting] OFF
GO
SET IDENTITY_INSERT [dbo].[RmLabel] ON 

GO
INSERT [dbo].[RmLabel] ([AutoID], [cSerialNumber], [FitemID], [cInvCode], [cInvName], [cInvStd], [cFullName], [cDefaultLoc], [cDefaultSP], [cLotNo], [cVendor], [iQuantity], [dDate], [cMemo], [cDefine1], [cDefine2], [cDefine3], [cDefine4]) VALUES (1, N'RM1601100001', N'1975', N'10.01.01.05.330080058', N'插板', N'1', N'成品_上海大众_Santana B2_发动机仓件_插板', N'0', N'0', N'S2012', N'1', CAST(123.0000 AS Decimal(18, 4)), CAST(N'2016-01-10' AS Date), N'1', N'', N'', N'', N'')
GO
INSERT [dbo].[RmLabel] ([AutoID], [cSerialNumber], [FitemID], [cInvCode], [cInvName], [cInvStd], [cFullName], [cDefaultLoc], [cDefaultSP], [cLotNo], [cVendor], [iQuantity], [dDate], [cMemo], [cDefine1], [cDefine2], [cDefine3], [cDefine4]) VALUES (2, N'RM1601100002', N'1977', N'10.01.01.05.330121407', N'补偿容器', N'330 121 407', N'成品_上海大众_Santana B2_发动机仓件_补偿容器', N'0', N'0', N'S00220', N'上海桃柯贸易有限公司', CAST(2032.0000 AS Decimal(18, 4)), CAST(N'2016-01-10' AS Date), N'', N'', N'', N'', N'')
GO
SET IDENTITY_INSERT [dbo].[RmLabel] OFF
GO
SET IDENTITY_INSERT [dbo].[Tb_Collect] ON 

GO
INSERT [dbo].[Tb_Collect] ([id], [eKey], [cName], [tName], [cType]) VALUES (1, N'cSerialNumber', N'序列号', N'RmLabel', N'DataType.String')
GO
INSERT [dbo].[Tb_Collect] ([id], [eKey], [cName], [tName], [cType]) VALUES (3, N'FitemID', N'KisID', N'RmLabel', N'DataType.String')
GO
INSERT [dbo].[Tb_Collect] ([id], [eKey], [cName], [tName], [cType]) VALUES (6, N'cInvCode', N'编码', N'RmLabel', N'DataType.String')
GO
INSERT [dbo].[Tb_Collect] ([id], [eKey], [cName], [tName], [cType]) VALUES (7, N'cInvName', N'名称', N'RmLabel', N'DataType.String')
GO
INSERT [dbo].[Tb_Collect] ([id], [eKey], [cName], [tName], [cType]) VALUES (13, N'cInvStd', N'规格', N'RmLable', N'DataType.String')
GO
INSERT [dbo].[Tb_Collect] ([id], [eKey], [cName], [tName], [cType]) VALUES (15, N'cFullName', N'全称', N'RmLable', N'DataType.String')
GO
INSERT [dbo].[Tb_Collect] ([id], [eKey], [cName], [tName], [cType]) VALUES (16, N'cDefaultLoc', N'默认仓库', N'RmLable', N'DataType.String')
GO
INSERT [dbo].[Tb_Collect] ([id], [eKey], [cName], [tName], [cType]) VALUES (17, N'cDefaultSP', N'默认库位', N'RmLable', N'DataType.String')
GO
INSERT [dbo].[Tb_Collect] ([id], [eKey], [cName], [tName], [cType]) VALUES (18, N'cLotNo', N'批号', N'RmLable', N'DataType.String')
GO
INSERT [dbo].[Tb_Collect] ([id], [eKey], [cName], [tName], [cType]) VALUES (19, N'cVendor', N'供应商', N'RmLable', N'DataType.String')
GO
INSERT [dbo].[Tb_Collect] ([id], [eKey], [cName], [tName], [cType]) VALUES (22, N'iQuantity', N'数量', N'RmLable', N'DataType.String')
GO
INSERT [dbo].[Tb_Collect] ([id], [eKey], [cName], [tName], [cType]) VALUES (23, N'dDate', N'入库日期', N'RmLable', N'DataType.String')
GO
INSERT [dbo].[Tb_Collect] ([id], [eKey], [cName], [tName], [cType]) VALUES (24, N'cMemo', N'备注', N'RmLable', N'DataType.String')
GO
SET IDENTITY_INSERT [dbo].[Tb_Collect] OFF
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_BLogAction_dDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BLogAction] ADD  CONSTRAINT [DF_BLogAction_dDate]  DEFAULT (getdate()) FOR [dDate]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_BLogAction_dAddTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BLogAction] ADD  CONSTRAINT [DF_BLogAction_dAddTime]  DEFAULT (getdate()) FOR [dAddTime]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_BPrinter_dAddtime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[BPrinter] ADD  CONSTRAINT [DF_BPrinter_dAddtime]  DEFAULT (getdate()) FOR [dAddtime]
END

GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BFunction', N'COLUMN',N'ID'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自增ID
   ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BFunction', @level2type=N'COLUMN',@level2name=N'ID'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BFunction', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'功能表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BFunction'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BRole', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BRole'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'BRoleFunction', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色功能表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BRoleFunction'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'View_BUserRole', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[12] 4[7] 2[37] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "BRole"
            Begin Extent = 
               Top = 14
               Left = 354
               Bottom = 153
               Right = 503
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "BUser"
            Begin Extent = 
               Top = 14
               Left = 50
               Bottom = 208
               Right = 215
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_BUserRole'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'View_BUserRole', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_BUserRole'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'View_RoleAndUser', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_RoleAndUser'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'View_RoleAndUser', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_RoleAndUser'
GO
USE [master]
GO
ALTER DATABASE [JWMSH_2016] SET  READ_WRITE 
GO
