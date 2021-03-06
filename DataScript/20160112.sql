USE [JWMSH_2016]
GO
/****** Object:  StoredProcedure [dbo].[proc_BomInsert]    Script Date: 2016/1/12 21:20:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		upjd
-- Create date: 20160112
-- Description:	新增BOM
-- =============================================
CREATE PROCEDURE [dbo].[proc_BomInsert] 
	@AutoID bigint output,
	@cFitemID nvarchar(30),
	@cInvCode nvarchar(50),
	@cInvName nvarchar(255),
	@cInvStd nvarchar(255),
	@cFullName nvarchar(255),
	@cMemo nvarchar(255)
AS
BEGIN
	if exists (select * from Bom where cInvCode=@cInvCode)
		return -1
	
	INSERT INTO [dbo].[Bom]
           ([cFitemID]
           ,[cInvCode]
           ,[cInvName]
           ,[cInvStd]
           ,[cFullName]
           ,[cMemo]
           ,[dAddTime])
     VALUES
           (@cFitemID
		   ,@cInvCode
		   ,@cInvName
		   ,@cInvStd
		   ,@cFullName
		   ,@cMemo
		   ,getdate())

	set @AutoID=@@IDENTITY
END

GO
/****** Object:  StoredProcedure [dbo].[proc_BomUpdate]    Script Date: 2016/1/12 21:20:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		upjd
-- Create date: 20160112
-- Description:	更新BOM
-- =============================================
CREATE PROCEDURE [dbo].[proc_BomUpdate] 
	@AutoID bigint,
	@cFitemID nvarchar(30),
	@cInvCode nvarchar(50),
	@cInvName nvarchar(255),
	@cInvStd nvarchar(255),
	@cFullName nvarchar(255),
	@cMemo nvarchar(255)
AS
BEGIN
	if not exists (select * from Bom where AutoID=@AutoID)
		return -1
	
	update Bom
	 SET [cFitemID] = @cFitemID
	    ,[cInvCode] = @cInvCode
	    ,[cInvName] = @cInvName
	    ,[cInvStd] = @cInvStd
	    ,[cFullName] =@cFullName
	    ,[cMemo] = @cMemo
	where AutoID=@AutoID
END

GO
/****** Object:  Table [dbo].[Bom]    Script Date: 2016/1/12 21:20:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bom](
	[AutoID] [bigint] IDENTITY(1,1) NOT NULL,
	[cFitemID] [nvarchar](30) NULL,
	[cInvCode] [nvarchar](50) NULL,
	[cInvName] [nvarchar](255) NULL,
	[cInvStd] [nvarchar](255) NULL,
	[cFullName] [nvarchar](255) NULL,
	[cMemo] [nvarchar](50) NULL,
	[dAddTime] [datetime] NULL,
 CONSTRAINT [PK_Bom] PRIMARY KEY CLUSTERED 
(
	[AutoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BomDetail]    Script Date: 2016/1/12 21:20:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BomDetail](
	[AutoID] [bigint] IDENTITY(1,1) NOT NULL,
	[BomID] [bigint] NOT NULL,
	[cFitemID] [nvarchar](30) NULL,
	[cInvCode] [nvarchar](50) NULL,
	[cInvName] [nvarchar](255) NULL,
	[iQuantity] [decimal](18, 4) NULL,
	[cUnitID] [nvarchar](50) NULL,
	[cUnitName] [nvarchar](50) NULL,
	[cInvStd] [nvarchar](255) NULL,
	[cFullName] [nvarchar](255) NULL,
	[cMemo] [nvarchar](50) NULL,
	[dAddTime] [datetime] NULL,
 CONSTRAINT [PK_BomDetail] PRIMARY KEY CLUSTERED 
(
	[AutoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
