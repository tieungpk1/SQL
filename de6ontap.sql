﻿USE master
GO
IF EXISTS(SELECT name
		FROM sys.databases
		WHERE name='QLHANG')
	DROP DATABASE QLHANG
GO
CREATE DATABASE QLHANG
GO
USE QLHANG
GO
CREATE TABLE HANG
(
MaHang char(5) PRIMARY KEY,
TenHang nvarchar(50) not null,
SoLuongCo int not null)
GO
INSERT INTO HANG VALUES('SP001',N'Tên hàng 1',120)
INSERT INTO HANG VALUES('SP002',N'Tên hàng 2',200)
INSERT INTO HANG VALUES('SP003',N'Tên hàng 3',135)
GO
--
CREATE TABLE HDBan(
MaHD chaR(5) PRIMARY KEY,
NgayBan date NOT NULL,
HoTenKH nvarchar(50) NOT NULL,)
GO
-- 
INSERT INTO HDBan VALUES ('HD001', '2021/05/20',N'Nguyễn Văn A')
INSERT INTO HDBan VALUES ('HD002', '2021/03/03',N'Nguyễn Văn B')
INSERT INTO HDBan VALUES ('HD003', '2021/09/09',N'Nguyễn Văn C')
GO
--
CREATE TABLE HangBan(
MaHD char(5),
MaHang char(5),
DonGiaBan money NOT NULL,
SoLuongBan int NOT NULL,
CONSTRAINT pk_hb PRIMARY KEY(MaHD,MaHang),
CONSTRAINT fk_hd FOREIGN KEY(MaHD) REFERENCES HDBan(MaHD),
CONSTRAINT fk_h FOREIGN KEY(MaHang) REFERENCES HANG(MaHang))
GO
--
INSERT INTO HangBan VALUES('HD001','SP001',300000,12)
INSERT INTO HangBan VALUES('HD002','SP001',350000,12)
INSERT INTO HangBan VALUES('HD001','SP002',250000,12)
INSERT INTO HangBan VALUES('HD003','SP002',410000,12)
INSERT INTO HangBan VALUES('HD002','SP003',320000,12)
GO
SELECT * FROM HANG
SELECT * FROM HangBan
SELECT * FROM HDBan
GO
--CAU2
CREATE FUNCTION Hang_ban(@x DATE, @y date)
RETURNS TABLE
AS 
RETURN SELECT H.MaHang, TenHang, SUM(SoLuongBan) AS TONGHANG
		FROM HangBan HB INNER JOIN HANG H ON H.MaHang=HB.MaHang
						INNER JOIN HDBan HD ON HB.MaHD=HD.MaHD
		WHERE NgayBan>=@x AND NgayBan<=@y
		GROUP BY H.MaHang, TenHang
GO
--
SELECT * FROM Hang_ban ('2021/03/03','2021/05/20')
GO
--CAU3
CREATE PROC HangBan_Them(@maHd char(5), @ten nvarchar(50), @dongia money, @soluongban int)
AS
BEGIN 
IF not EXISTS (SELECT TenHang FROM HANG WHERE TenHang=@ten)
BEGIN
	DECLARE @TB NVARCHAR(100)=@ten +N' không tồn tại không thêm được'
	RAISERROR(@TB,16,1)
	RETURN
END
	DECLARE @MAH CHAR(5)
	SELECT @MAH=MaHang FROM HANG WHERE TenHang=@ten
	INSERT INTO HangBan VALUES(@maHd,@MAH,@dongia,@soluongban)
END
GO
--
EXEC HangBan_Them 'HD003',N'Tên hàng 1',350000,45--THEM DUOC
GO
EXEC HangBan_Them 'HD003',N'Tên hàng 4',350000,45--THEM DUOC
GO
SELECT * FROM HangBan
GO
--cau4
CREATE TRIGGER THEM_XOA ON HangBan FOR INSERT, DELETE
AS
IF EXISTS(SELECT * FROM inserted)
BEGIN
	DECLARE @SLBAN INT
	SELECT @SLBAN=SoLuongBan FROM inserted
	IF(@SLBAN>(SELECT SoLuongCo FROM HANG INNER JOIN inserted ON HANG.MaHang=inserted.MaHang))
	BEGIN
		DECLARE @TB NVARCHAR(100)=N'KHÔNG ĐỦ SỐ LƯỢNG'
		RAISERROR(@TB,16,1)
		ROLLBACK TRAN
	END
	UPDATE HANG 
	SET SoLuongCo=SoLuongCo-@SLBAN
	FROM HANG INNER JOIN inserted ON HANG.MaHang=inserted.MaHang
END
IF EXISTS(SELECT * FROM deleted)
BEGIN
	DECLARE @SL INT
	SELECT @SL=SoLuongBan FROM deleted
	UPDATE HANG 
	SET SoLuongCo=SoLuongCo+ @SL
	FROM HANG INNER JOIN deleted ON HANG.MaHang=deleted.MaHang
END
GO
--
INSERT INTO HangBan VALUES('HD003','SP003',300000,136)--LOI
GO
INSERT INTO HangBan VALUES('HD003','SP003',300000,100)-- SLCO=35
GO
DELETE FROM HangBan
WHERE MaHD='HD001' AND MaHang='SP001'---SLC=132
GO
SELECT * FROM HangBan
SELECT * FROM HANG
GO