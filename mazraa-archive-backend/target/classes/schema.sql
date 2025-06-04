USE [master]
GO
/****** Object:  Database [mazraa_archive]    Script Date: 25/05/2025 21:53:56 ******/
CREATE DATABASE [mazraa_archive]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'mazraa_archive', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\mazraa_archive.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'mazraa_archive_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\mazraa_archive_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [mazraa_archive] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [mazraa_archive].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [mazraa_archive] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [mazraa_archive] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [mazraa_archive] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [mazraa_archive] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [mazraa_archive] SET ARITHABORT OFF 
GO
ALTER DATABASE [mazraa_archive] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [mazraa_archive] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [mazraa_archive] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [mazraa_archive] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [mazraa_archive] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [mazraa_archive] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [mazraa_archive] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [mazraa_archive] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [mazraa_archive] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [mazraa_archive] SET  ENABLE_BROKER 
GO
ALTER DATABASE [mazraa_archive] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [mazraa_archive] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [mazraa_archive] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [mazraa_archive] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [mazraa_archive] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [mazraa_archive] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [mazraa_archive] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [mazraa_archive] SET RECOVERY FULL 
GO
ALTER DATABASE [mazraa_archive] SET  MULTI_USER 
GO
ALTER DATABASE [mazraa_archive] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [mazraa_archive] SET DB_CHAINING OFF 
GO
ALTER DATABASE [mazraa_archive] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [mazraa_archive] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [mazraa_archive] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [mazraa_archive] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'mazraa_archive', N'ON'
GO
ALTER DATABASE [mazraa_archive] SET QUERY_STORE = ON
GO
ALTER DATABASE [mazraa_archive] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [mazraa_archive]
GO
/****** Object:  User [mazraa_admin]    Script Date: 25/05/2025 21:53:56 ******/
CREATE USER [mazraa_admin] FOR LOGIN [mazraa_admin] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [mazraa_admin]
GO
/****** Object:  Table [dbo].[audit_logs]    Script Date: 25/05/2025 21:53:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[audit_logs](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[user_id] [bigint] NOT NULL,
	[action] [varchar](50) NOT NULL,
	[entity_type] [varchar](50) NOT NULL,
	[entity_id] [bigint] NULL,
	[details] [text] NULL,
	[created_at] [datetime] NOT NULL,
	[ip_address] [varchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[document_types]    Script Date: 25/05/2025 21:53:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[document_types](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[name] [varchar](100) NOT NULL,
	[code] [varchar](50) NOT NULL,
	[description] [text] NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime] NOT NULL,
	[updated_at] [datetime] NOT NULL,
	[updated_by_id] [bigint] NULL,
	[created_by_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[documents]    Script Date: 25/05/2025 21:53:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[documents](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](max) NULL,
	[barcode] [varchar](100) NOT NULL,
	[document_type_id] [bigint] NOT NULL,
	[storage_location_id] [bigint] NULL,
	[status] [varchar](50) NOT NULL,
	[description] [nvarchar](max) NULL,
	[created_at] [datetime] NOT NULL,
	[updated_at] [datetime] NOT NULL,
	[archived_at] [datetime] NULL,
	[archived] [bit] NOT NULL,
	[archived_by] [bigint] NULL,
	[created_by] [bigint] NULL,
	[updated_by] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[barcode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[storage_locations]    Script Date: 25/05/2025 21:53:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[storage_locations](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[name] [varchar](100) NOT NULL,
	[code] [varchar](50) NOT NULL,
	[capacity] [bigint] NULL,
	[description] [text] NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime] NOT NULL,
	[updated_at] [datetime] NOT NULL,
	[active] [bit] NOT NULL,
	[box] [varchar](255) NOT NULL,
	[row] [varchar](255) NOT NULL,
	[shelf] [varchar](255) NOT NULL,
	[used_space] [bigint] NOT NULL,
	[created_by] [bigint] NULL,
	[updated_by] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sync_logs]    Script Date: 25/05/2025 21:53:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sync_logs](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[action] [varchar](255) NOT NULL,
	[client_data] [text] NULL,
	[client_version] [bigint] NOT NULL,
	[created_at] [datetime2](6) NOT NULL,
	[device_id] [varchar](255) NOT NULL,
	[entity_id] [bigint] NOT NULL,
	[entity_type] [varchar](255) NOT NULL,
	[resolution] [varchar](255) NULL,
	[resolved] [bit] NOT NULL,
	[server_data] [text] NULL,
	[server_version] [bigint] NOT NULL,
	[synced] [bit] NOT NULL,
	[synced_at] [datetime2](6) NULL,
	[updated_at] [datetime2](6) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[users]    Script Date: 25/05/2025 21:53:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[users](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[email] [varchar](255) NOT NULL,
	[password] [varchar](255) NOT NULL,
	[roles] [varchar](255) NOT NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime] NOT NULL,
	[updated_at] [datetime] NOT NULL,
	[device_id] [varchar](255) NULL,
	[enabled] [bit] NOT NULL,
	[full_name] [varchar](255) NOT NULL,
	[role] [varchar](255) NOT NULL,
	[username] [varchar](255) NOT NULL,
	[created_by] [bigint] NULL,
	[updated_by] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_r43af9ap4edm43mmtq01oddj6] UNIQUE NONCLUSTERED 
(
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [idx_audit_logs_created_at]    Script Date: 25/05/2025 21:53:56 ******/
CREATE NONCLUSTERED INDEX [idx_audit_logs_created_at] ON [dbo].[audit_logs]
(
	[created_at] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_documents_barcode]    Script Date: 25/05/2025 21:53:56 ******/
CREATE NONCLUSTERED INDEX [idx_documents_barcode] ON [dbo].[documents]
(
	[barcode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_documents_status]    Script Date: 25/05/2025 21:53:56 ******/
CREATE NONCLUSTERED INDEX [idx_documents_status] ON [dbo].[documents]
(
	[status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[audit_logs] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[document_types] ADD  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[document_types] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[document_types] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[documents] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[documents] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[storage_locations] ADD  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[storage_locations] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[storage_locations] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[audit_logs]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[document_types]  WITH CHECK ADD  CONSTRAINT [FKo6jeht3ogfm2jk3ss7pj0rjcy] FOREIGN KEY([updated_by_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[document_types] CHECK CONSTRAINT [FKo6jeht3ogfm2jk3ss7pj0rjcy]
GO
ALTER TABLE [dbo].[document_types]  WITH CHECK ADD  CONSTRAINT [FKq2g9d0qmr2xylxrbdrfosrhjv] FOREIGN KEY([created_by_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[document_types] CHECK CONSTRAINT [FKq2g9d0qmr2xylxrbdrfosrhjv]
GO
ALTER TABLE [dbo].[documents]  WITH CHECK ADD FOREIGN KEY([document_type_id])
REFERENCES [dbo].[document_types] ([id])
GO
ALTER TABLE [dbo].[documents]  WITH CHECK ADD FOREIGN KEY([storage_location_id])
REFERENCES [dbo].[storage_locations] ([id])
GO
ALTER TABLE [dbo].[documents]  WITH CHECK ADD  CONSTRAINT [FKet0jevlnon20fpck24irdbj9f] FOREIGN KEY([created_by])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[documents] CHECK CONSTRAINT [FKet0jevlnon20fpck24irdbj9f]
GO
ALTER TABLE [dbo].[documents]  WITH CHECK ADD  CONSTRAINT [FKk74isbaufwmp0ft8ha51ybjci] FOREIGN KEY([archived_by])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[documents] CHECK CONSTRAINT [FKk74isbaufwmp0ft8ha51ybjci]
GO
ALTER TABLE [dbo].[documents]  WITH CHECK ADD  CONSTRAINT [FKlfu07w7hnk9fl1wvnj5i1ota0] FOREIGN KEY([updated_by])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[documents] CHECK CONSTRAINT [FKlfu07w7hnk9fl1wvnj5i1ota0]
GO
ALTER TABLE [dbo].[storage_locations]  WITH CHECK ADD  CONSTRAINT [FKqu5oqquiyg43oukx93b190ame] FOREIGN KEY([created_by])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[storage_locations] CHECK CONSTRAINT [FKqu5oqquiyg43oukx93b190ame]
GO
ALTER TABLE [dbo].[storage_locations]  WITH CHECK ADD  CONSTRAINT [FKrm59i0oyesn6kmpynyolt50yu] FOREIGN KEY([updated_by])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[storage_locations] CHECK CONSTRAINT [FKrm59i0oyesn6kmpynyolt50yu]
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [FKci7xr690rvyv3bnfappbyh8x0] FOREIGN KEY([updated_by])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [FKci7xr690rvyv3bnfappbyh8x0]
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [FKibk1e3kaxy5sfyeekp8hbhnim] FOREIGN KEY([created_by])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [FKibk1e3kaxy5sfyeekp8hbhnim]
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD CHECK  (([role]='USER' OR [role]='ADMIN'))
GO
USE [master]
GO
ALTER DATABASE [mazraa_archive] SET  READ_WRITE 
GO