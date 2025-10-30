USE QLCUAHANGTAPHOA;
CREATE TABLE dbo.NguoiDung (
  MaNguoiDung   INT IDENTITY(1,1) PRIMARY KEY,
  TenDangNhap   NVARCHAR(50)  NOT NULL UNIQUE,
  MatKhauHash   VARBINARY(256) NOT NULL,
  VaiTro        NVARCHAR(20)  NOT NULL
                   CHECK (VaiTro IN (N'ADMIN', N'QUAN_LY', N'BAN_HANG', N'KHO'))
);

CREATE TABLE dbo.NhanVien (
  MaNhanVien    INT IDENTITY(1,1) PRIMARY KEY,
  HoTen         NVARCHAR(100) NOT NULL,
  ChucVu        NVARCHAR(50)  NULL,
  SoDienThoai   NVARCHAR(20)  NULL,
  DiaChi        NVARCHAR(200) NULL,
  MaNguoiDung   INT NULL UNIQUE,
  CONSTRAINT FK_NhanVien_NguoiDung
    FOREIGN KEY (MaNguoiDung) REFERENCES dbo.NguoiDung(MaNguoiDung)
    ON DELETE SET NULL
);

CREATE TABLE dbo.KhachHang (
  MaKhachHang   INT IDENTITY(1,1) PRIMARY KEY,
  HoTen         NVARCHAR(100) NOT NULL,
  SoDienThoai   NVARCHAR(20)  NULL UNIQUE,
  DiaChi        NVARCHAR(200) NULL,
  DiemTichLuy   INT NOT NULL DEFAULT 0 CHECK (DiemTichLuy >= 0),
  MaNhanVien    INT NULL,
  CONSTRAINT FK_KhachHang_NhanVien
    FOREIGN KEY (MaNhanVien) REFERENCES dbo.NhanVien(MaNhanVien)
    ON DELETE SET NULL
);

CREATE TABLE dbo.NhaCungCap (
  MaNCC         INT IDENTITY(1,1) PRIMARY KEY,
  TenNCC        NVARCHAR(150) NOT NULL,
  SoDienThoai   NVARCHAR(20)  NULL,
  DiaChi        NVARCHAR(200) NULL,
  MaNhanVien    INT NOT NULL,
  CONSTRAINT FK_NhaCungCap_NhanVien
    FOREIGN KEY (MaNhanVien) REFERENCES dbo.NhanVien(MaNhanVien)
    ON DELETE NO ACTION
);

CREATE TABLE dbo.LoaiSP (
  MaLoai        INT IDENTITY(1,1) PRIMARY KEY,
  TenLoai       NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dbo.DonViTinh (
  MaDVT         INT IDENTITY(1,1) PRIMARY KEY,
  TenDVT        NVARCHAR(50) NOT NULL UNIQUE
);
CREATE TABLE dbo.SanPham (
  MaSP          INT IDENTITY(1,1) PRIMARY KEY,
  TenSP         NVARCHAR(150) NOT NULL,
  DonGia        DECIMAL(18,2) NOT NULL CHECK (DonGia >= 0),
  SoLuong       INT NOT NULL DEFAULT 0 CHECK (SoLuong >= 0),
  HanSuDung     DATE NULL,
  MaLoai        INT NOT NULL,
  MaDVT         INT NOT NULL,
  MaNCC         INT NULL,
  MaNhanVien    INT NULL,
  CONSTRAINT FK_SanPham_Loai   FOREIGN KEY (MaLoai)     REFERENCES dbo.LoaiSP(MaLoai),
  CONSTRAINT FK_SanPham_DVT    FOREIGN KEY (MaDVT)      REFERENCES dbo.DonViTinh(MaDVT),
  CONSTRAINT FK_SanPham_NCC    FOREIGN KEY (MaNCC)      REFERENCES dbo.NhaCungCap(MaNCC) ON DELETE SET NULL,
  CONSTRAINT FK_SanPham_NV     FOREIGN KEY (MaNhanVien) REFERENCES dbo.NhanVien(MaNhanVien) ON DELETE SET NULL
);

CREATE TABLE dbo.HoaDon (
  MaHD          INT IDENTITY(1,1) PRIMARY KEY,
  NgayLap       DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
  TongTien      DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (TongTien >= 0),
  MaKhachHang   INT NULL,
  MaNhanVien    INT NOT NULL,
  CONSTRAINT FK_HoaDon_KhachHang FOREIGN KEY (MaKhachHang) REFERENCES dbo.KhachHang(MaKhachHang) ON DELETE SET NULL,
  CONSTRAINT FK_HoaDon_NhanVien  FOREIGN KEY (MaNhanVien)  REFERENCES dbo.NhanVien(MaNhanVien)
);

CREATE TABLE dbo.ChiTietHoaDon (
  MaHD          INT NOT NULL,
  MaSP          INT NOT NULL,
  SoLuong       INT NOT NULL CHECK (SoLuong > 0),
  DonGia        DECIMAL(18,2) NOT NULL CHECK (DonGia >= 0),
  CONSTRAINT PK_ChiTietHoaDon PRIMARY KEY (MaHD, MaSP),
  CONSTRAINT FK_CTHD_HoaDon FOREIGN KEY (MaHD) REFERENCES dbo.HoaDon(MaHD) ON DELETE CASCADE,
  CONSTRAINT FK_CTHD_SanPham FOREIGN KEY (MaSP) REFERENCES dbo.SanPham(MaSP)
);

CREATE TABLE dbo.GiaoDichKho (
  MaGD          INT IDENTITY(1,1) PRIMARY KEY,
  LoaiGD        NVARCHAR(20) NOT NULL CHECK (LoaiGD IN (N'NHAP', N'XUAT', N'DIEU_CHINH')),
  NgayGD        DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
  MaNCC         INT NULL,
  MaNhanVien    INT NOT NULL,
  CONSTRAINT CK_GDK_NCC_NHAP CHECK (NOT(LoaiGD = N'NHAP' AND MaNCC IS NULL)),
  CONSTRAINT FK_GDK_NCC      FOREIGN KEY (MaNCC)      REFERENCES dbo.NhaCungCap(MaNCC) ON DELETE SET NULL,
  CONSTRAINT FK_GDK_NhanVien FOREIGN KEY (MaNhanVien) REFERENCES dbo.NhanVien(MaNhanVien)
);

CREATE TABLE dbo.ChiTietGiaoDichKho (
  MaGD          INT NOT NULL,
  MaSP          INT NOT NULL,
  SoLuong       INT NOT NULL CHECK (SoLuong > 0),
  CONSTRAINT PK_CTGD PRIMARY KEY (MaGD, MaSP),
  CONSTRAINT FK_CTGD_GDK FOREIGN KEY (MaGD) REFERENCES dbo.GiaoDichKho(MaGD) ON DELETE CASCADE,
  CONSTRAINT FK_CTGD_SP  FOREIGN KEY (MaSP) REFERENCES dbo.SanPham(MaSP)
);

CREATE TABLE dbo.CongNV (
  MaNV          INT NOT NULL,
  Ky            NVARCHAR(20) NOT NULL,   -- ví dụ '2025-10'
  SoNgayLam     INT NULL,
  SoGioLam      DECIMAL(10,2) NULL,
  LuongTheoGio  DECIMAL(18,2) NULL,
  DoanhThuCa    DECIMAL(18,2) NULL,
  HoaHongBanHang DECIMAL(10,4) NULL,     -- 0..1
  DoanhThuKhuVuc DECIMAL(18,2) NULL,
  TyLeDoanhThu  DECIMAL(10,4) NULL,      -- 0..1
  LuongCoBan    DECIMAL(18,2) NULL,
  HeSoLuong     DECIMAL(10,4) NULL,
  PhuCap        DECIMAL(18,2) NULL,
  Thuong        DECIMAL(18,2) NULL,
  KhauTru       DECIMAL(18,2) NULL,
  PhuCapCaDem   DECIMAL(18,2) NULL,
  PhuCapAdmin   DECIMAL(18,2) NULL,
  ThuongQTHT    DECIMAL(18,2) NULL,
  CONSTRAINT PK_CongNV PRIMARY KEY (MaNV, Ky),
  CONSTRAINT FK_CongNV_NhanVien FOREIGN KEY (MaNV) REFERENCES dbo.NhanVien(MaNhanVien)
);
DECLARE @u_admin INT, @u_ql INT, @u_bh1 INT, @u_kho1 INT;

INSERT INTO dbo.NguoiDung (TenDangNhap, MatKhauHash, VaiTro)
VALUES (N'admin',   HASHBYTES('SHA2_256', N'Admin@123'),   N'ADMIN');
SET @u_admin = SCOPE_IDENTITY();

INSERT INTO dbo.NguoiDung (TenDangNhap, MatKhauHash, VaiTro)
VALUES (N'quanly',  HASHBYTES('SHA2_256', N'QuanLy@123'),  N'QUAN_LY');
SET @u_ql = SCOPE_IDENTITY();

INSERT INTO dbo.NguoiDung (TenDangNhap, MatKhauHash, VaiTro)
VALUES (N'banhang1',HASHBYTES('SHA2_256', N'BanHang@123'), N'BAN_HANG');
SET @u_bh1 = SCOPE_IDENTITY();

INSERT INTO dbo.NguoiDung (TenDangNhap, MatKhauHash, VaiTro)
VALUES (N'kho1',    HASHBYTES('SHA2_256', N'Kho@123'),     N'KHO');
SET @u_kho1 = SCOPE_IDENTITY();

------------------------------------------------------------
-- 2) Nhân viên (gắn với NguoiDung)
------------------------------------------------------------
-- Chèn NhanVien bằng JOIN, không cần biến
INSERT dbo.NhanVien(HoTen, ChucVu, SoDienThoai, DiaChi, MaNguoiDung)
SELECT N'Nguyễn An',  N'Admin',    N'0901000001', N'Bình Dương', ND.MaNguoiDung
FROM dbo.NguoiDung ND
WHERE ND.TenDangNhap=N'admin'
  AND NOT EXISTS (SELECT 1 FROM dbo.NhanVien WHERE SoDienThoai=N'0901000001');

INSERT dbo.NhanVien(HoTen, ChucVu, SoDienThoai, DiaChi, MaNguoiDung)
SELECT N'Trần Bình',  N'Quản lý',  N'0902000002', N'Bình Dương', ND.MaNguoiDung
FROM dbo.NguoiDung ND
WHERE ND.TenDangNhap=N'quanly'
  AND NOT EXISTS (SELECT 1 FROM dbo.NhanVien WHERE SoDienThoai=N'0902000002');

INSERT dbo.NhanVien(HoTen, ChucVu, SoDienThoai, DiaChi, MaNguoiDung)
SELECT N'Lê Chi',     N'Bán hàng', N'0903000003', N'Bình Dương', ND.MaNguoiDung
FROM dbo.NguoiDung ND
WHERE ND.TenDangNhap=N'banhang1'
  AND NOT EXISTS (SELECT 1 FROM dbo.NhanVien WHERE SoDienThoai=N'0903000003');

INSERT dbo.NhanVien(HoTen, ChucVu, SoDienThoai, DiaChi, MaNguoiDung)
SELECT N'Phạm Dũng',  N'Kho',      N'0904000004', N'Bình Dương', ND.MaNguoiDung
FROM dbo.NguoiDung ND
WHERE ND.TenDangNhap=N'kho1'
  AND NOT EXISTS (SELECT 1 FROM dbo.NhanVien WHERE SoDienThoai=N'0904000004');

------------------------------------------------------------
-- 3) Danh mục dùng chung
------------------------------------------------------------
-- Đơn vị tính
DECLARE @dvt_cai INT, @dvt_goi INT, @dvt_chai INT, @dvt_lon INT, @dvt_kg INT;

INSERT INTO dbo.DonViTinh (TenDVT) VALUES (N'cái');  SET @dvt_cai = SCOPE_IDENTITY();
INSERT INTO dbo.DonViTinh (TenDVT) VALUES (N'gói');  SET @dvt_goi = SCOPE_IDENTITY();
INSERT INTO dbo.DonViTinh (TenDVT) VALUES (N'chai'); SET @dvt_chai = SCOPE_IDENTITY();
INSERT INTO dbo.DonViTinh (TenDVT) VALUES (N'lon');  SET @dvt_lon = SCOPE_IDENTITY();
INSERT INTO dbo.DonViTinh (TenDVT) VALUES (N'kg');   SET @dvt_kg  = SCOPE_IDENTITY();

-- Loại sản phẩm
DECLARE @loai_banhkeo INT, @loai_douong INT, @loai_giavi INT, @loai_hoamypham INT, @loai_sua INT;

INSERT INTO dbo.LoaiSP (TenLoai) VALUES (N'Bánh kẹo');     SET @loai_banhkeo   = SCOPE_IDENTITY();
INSERT INTO dbo.LoaiSP (TenLoai) VALUES (N'Đồ uống');      SET @loai_douong    = SCOPE_IDENTITY();
INSERT INTO dbo.LoaiSP (TenLoai) VALUES (N'Gia vị');       SET @loai_giavi     = SCOPE_IDENTITY();
INSERT INTO dbo.LoaiSP (TenLoai) VALUES (N'Hóa mỹ phẩm');  SET @loai_hoamypham = SCOPE_IDENTITY();
INSERT INTO dbo.LoaiSP (TenLoai) VALUES (N'Sữa');          SET @loai_sua       = SCOPE_IDENTITY();

------------------------------------------------------------
-- 4) Nhà cung cấp (bắt buộc MaNhanVien theo schema)
------------------------------------------------------------
DECLARE @ncc_vinamilk INT, @ncc_pepsico INT, @ncc_bibica INT, @ncc_masan INT;

-- gán NV quản lý = nhân viên liên kết user 'quanly'
-- (ĐÃ có NhanVien ở bước 2)
INSERT INTO dbo.NhaCungCap (TenNCC, SoDienThoai, DiaChi, MaNhanVien)
SELECT N'Vinamilk',       N'028-1234567', N'HCM',  NV.MaNhanVien
FROM dbo.NhanVien NV 
JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung
WHERE ND.TenDangNhap = N'quanly'
  AND NOT EXISTS (SELECT 1 FROM dbo.NhaCungCap WHERE TenNCC=N'Vinamilk');

INSERT INTO dbo.NhaCungCap (TenNCC, SoDienThoai, DiaChi, MaNhanVien)
SELECT N'PepsiCo Việt Nam', N'028-2345678', N'HCM', NV.MaNhanVien
FROM dbo.NhanVien NV 
JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung
WHERE ND.TenDangNhap = N'quanly'
  AND NOT EXISTS (SELECT 1 FROM dbo.NhaCungCap WHERE TenNCC=N'PepsiCo Việt Nam');

INSERT INTO dbo.NhaCungCap (TenNCC, SoDienThoai, DiaChi, MaNhanVien)
SELECT N'Bibica',         N'028-3456789', N'Bình Dương', NV.MaNhanVien
FROM dbo.NhanVien NV 
JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung
WHERE ND.TenDangNhap = N'quanly'
  AND NOT EXISTS (SELECT 1 FROM dbo.NhaCungCap WHERE TenNCC=N'Bibica');

INSERT INTO dbo.NhaCungCap (TenNCC, SoDienThoai, DiaChi, MaNhanVien)
SELECT N'Masan Consumer', N'028-4567890', N'HCM',  NV.MaNhanVien
FROM dbo.NhanVien NV 
JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung
WHERE ND.TenDangNhap = N'quanly'
  AND NOT EXISTS (SELECT 1 FROM dbo.NhaCungCap WHERE TenNCC=N'Masan Consumer');

-- Lấy ID NCC để dùng cho phần Sản phẩm bên dưới
SELECT @ncc_vinamilk = MaNCC FROM dbo.NhaCungCap WHERE TenNCC=N'Vinamilk';
SELECT @ncc_pepsico  = MaNCC FROM dbo.NhaCungCap WHERE TenNCC=N'PepsiCo Việt Nam';
SELECT @ncc_bibica   = MaNCC FROM dbo.NhaCungCap WHERE TenNCC=N'Bibica';
SELECT @ncc_masan    = MaNCC FROM dbo.NhaCungCap WHERE TenNCC=N'Masan Consumer';

------------------------------------------------------------
-- 5) Sản phẩm (không dùng biến, lookup trực tiếp)
-- Yêu cầu: LoaiSP, DonViTinh, NhaCungCap, NhanVien đã có
------------------------------------------------------------

-- Helper: lấy MaNV của user 'kho1'
DECLARE @MaNVKho INT = (
    SELECT NV.MaNhanVien
    FROM dbo.NhanVien NV
    JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung
    WHERE ND.TenDangNhap = N'kho1'
);

-- 1. Sữa tươi Vinamilk 1L
INSERT dbo.SanPham (TenSP, DonGia, SoLuong, HanSuDung, MaLoai, MaDVT, MaNCC, MaNhanVien)
SELECT N'Sữa tươi tiệt trùng Vinamilk 1L', 32000, 100, DATEFROMPARTS(2026,6,30),
       (SELECT MaLoai FROM dbo.LoaiSP WHERE TenLoai=N'Sữa'),
       (SELECT MaDVT  FROM dbo.DonViTinh WHERE TenDVT=N'chai'),
       (SELECT MaNCC  FROM dbo.NhaCungCap WHERE TenNCC=N'Vinamilk'),
       @MaNVKho
WHERE NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE TenSP=N'Sữa tươi tiệt trùng Vinamilk 1L');

-- 2. Pepsi lon 330ml
INSERT dbo.SanPham (TenSP, DonGia, SoLuong, HanSuDung, MaLoai, MaDVT, MaNCC, MaNhanVien)
SELECT N'Nước ngọt Pepsi lon 330ml', 8000, 200, DATEFROMPARTS(2026,12,31),
       (SELECT MaLoai FROM dbo.LoaiSP WHERE TenLoai=N'Đồ uống'),
       (SELECT MaDVT  FROM dbo.DonViTinh WHERE TenDVT=N'lon'),
       (SELECT MaNCC  FROM dbo.NhaCungCap WHERE TenNCC=N'PepsiCo Việt Nam'),
       @MaNVKho
WHERE NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE TenSP=N'Nước ngọt Pepsi lon 330ml');

-- 3. Bánh quy Cosy 300g
INSERT dbo.SanPham (TenSP, DonGia, SoLuong, HanSuDung, MaLoai, MaDVT, MaNCC, MaNhanVien)
SELECT N'Bánh quy Cosy 300g', 25000, 150, DATEFROMPARTS(2026,9,30),
       (SELECT MaLoai FROM dbo.LoaiSP WHERE TenLoai=N'Bánh kẹo'),
       (SELECT MaDVT  FROM dbo.DonViTinh WHERE TenDVT=N'gói'),
       (SELECT MaNCC  FROM dbo.NhaCungCap WHERE TenNCC=N'Bibica'),
       @MaNVKho
WHERE NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE TenSP=N'Bánh quy Cosy 300g');

-- 4. Nước mắm Nam Ngư 500ml
INSERT dbo.SanPham (TenSP, DonGia, SoLuong, HanSuDung, MaLoai, MaDVT, MaNCC, MaNhanVien)
SELECT N'Nước mắm Nam Ngư 500ml', 30000, 80, DATEFROMPARTS(2027,3,31),
       (SELECT MaLoai FROM dbo.LoaiSP WHERE TenLoai=N'Gia vị'),
       (SELECT MaDVT  FROM dbo.DonViTinh WHERE TenDVT=N'chai'),
       (SELECT MaNCC  FROM dbo.NhaCungCap WHERE TenNCC=N'Masan Consumer'),
       @MaNVKho
WHERE NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE TenSP=N'Nước mắm Nam Ngư 500ml');

-- 5. Dầu gội Clear 650g
INSERT dbo.SanPham (TenSP, DonGia, SoLuong, HanSuDung, MaLoai, MaDVT, MaNCC, MaNhanVien)
SELECT N'Dầu gội Clear 650g', 120000, 40, DATEFROMPARTS(2027,12,31),
       (SELECT MaLoai FROM dbo.LoaiSP WHERE TenLoai=N'Hóa mỹ phẩm'),
       (SELECT MaDVT  FROM dbo.DonViTinh WHERE TenDVT=N'cái'),
       (SELECT MaNCC  FROM dbo.NhaCungCap WHERE TenNCC=N'Masan Consumer'),
       @MaNVKho
WHERE NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE TenSP=N'Dầu gội Clear 650g');

------------------------------------------------------------
-- 1) KHÁCH HÀNG (gán NV bán hàng quản lý qua TenDangNhap)
------------------------------------------------------------
-- KH: Hoa (NV banhang1)
INSERT dbo.KhachHang(HoTen, SoDienThoai, DiaChi, DiemTichLuy, MaNhanVien)
SELECT N'Nguyễn Thị Hoa', N'0911000011', N'Thuận An, Bình Dương', 20, NV.MaNhanVien
FROM dbo.NhanVien NV JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung
WHERE ND.TenDangNhap=N'banhang1'
  AND NOT EXISTS (SELECT 1 FROM dbo.KhachHang WHERE SoDienThoai=N'0911000011');

-- KH: Lâm (NV banhang1)
INSERT dbo.KhachHang(HoTen, SoDienThoai, DiaChi, DiemTichLuy, MaNhanVien)
SELECT N'Phạm Văn Lâm', N'0912000022', N'Dĩ An, Bình Dương', 5, NV.MaNhanVien
FROM dbo.NhanVien NV JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung
WHERE ND.TenDangNhap=N'banhang1'
  AND NOT EXISTS (SELECT 1 FROM dbo.KhachHang WHERE SoDienThoai=N'0912000022');

-- KH: Quang (NV banhang1)
INSERT dbo.KhachHang(HoTen, SoDienThoai, DiaChi, DiemTichLuy, MaNhanVien)
SELECT N'Đặng Quốc Quang', N'0913000033', N'Thuận Giao, Thuận An', 0, NV.MaNhanVien
FROM dbo.NhanVien NV JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung
WHERE ND.TenDangNhap=N'banhang1'
  AND NOT EXISTS (SELECT 1 FROM dbo.KhachHang WHERE SoDienThoai=N'0913000033');

-- KH: Trâm (NV banhang1)
INSERT dbo.KhachHang(HoTen, SoDienThoai, DiaChi, DiemTichLuy, MaNhanVien)
SELECT N'Lương Thị Trâm', N'0914000044', N'An Phú, Thuận An', 0, NV.MaNhanVien
FROM dbo.NhanVien NV JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung
WHERE ND.TenDangNhap=N'banhang1'
  AND NOT EXISTS (SELECT 1 FROM dbo.KhachHang WHERE SoDienThoai=N'0914000044');

-- KH: Nga (NV banhang1)
INSERT dbo.KhachHang(HoTen, SoDienThoai, DiaChi, DiemTichLuy, MaNhanVien)
SELECT N'Ngô Thu Nga', N'0915000055', N'Dĩ An', 0, NV.MaNhanVien
FROM dbo.NhanVien NV JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung
WHERE ND.TenDangNhap=N'banhang1'
  AND NOT EXISTS (SELECT 1 FROM dbo.KhachHang WHERE SoDienThoai=N'0915000055');

------------------------------------------------------------
-- GIAO DỊCH KHO: Phiếu NHẬP + chi tiết (IDEMPOTENT)
------------------------------------------------------------

-- NHẬP Vinamilk (2025-10-01): Sữa 1L (100)
IF NOT EXISTS (
    SELECT 1 FROM dbo.GiaoDichKho
    WHERE LoaiGD=N'NHAP'
      AND CONVERT(date,NgayGD)='2025-10-01'
      AND MaNCC=(SELECT MaNCC FROM dbo.NhaCungCap WHERE TenNCC=N'Vinamilk')
)
BEGIN
    DECLARE @g1 TABLE(MaGD INT);
    INSERT dbo.GiaoDichKho(LoaiGD, NgayGD, MaNCC, MaNhanVien)
    OUTPUT inserted.MaGD INTO @g1
    SELECT N'NHAP', DATETIMEFROMPARTS(2025,10,1,9,0,0,0),
           (SELECT MaNCC FROM dbo.NhaCungCap WHERE TenNCC=N'Vinamilk'),
           (SELECT NV.MaNhanVien
            FROM dbo.NhanVien NV
            JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung
            WHERE ND.TenDangNhap = N'kho1');

    INSERT dbo.ChiTietGiaoDichKho(MaGD, MaSP, SoLuong)
    SELECT g.MaGD, (SELECT MaSP FROM dbo.SanPham WHERE TenSP=N'Sữa tươi tiệt trùng Vinamilk 1L'), 100
    FROM @g1 g;

    UPDATE S SET SoLuong = SoLuong + 100
    FROM dbo.SanPham S WHERE S.TenSP=N'Sữa tươi tiệt trùng Vinamilk 1L';
END

-- NHẬP PepsiCo (2025-10-02): Pepsi 330ml (200)
IF NOT EXISTS (
    SELECT 1 FROM dbo.GiaoDichKho
    WHERE LoaiGD=N'NHAP'
      AND CONVERT(date,NgayGD)='2025-10-02'
      AND MaNCC=(SELECT MaNCC FROM dbo.NhaCungCap WHERE TenNCC=N'PepsiCo Việt Nam')
)
BEGIN
    DECLARE @g2 TABLE(MaGD INT);
    INSERT dbo.GiaoDichKho(LoaiGD, NgayGD, MaNCC, MaNhanVien)
    OUTPUT inserted.MaGD INTO @g2
    SELECT N'NHAP', DATETIMEFROMPARTS(2025,10,2,10,0,0,0),
           (SELECT MaNCC FROM dbo.NhaCungCap WHERE TenNCC=N'PepsiCo Việt Nam'),
           (SELECT NV.MaNhanVien
            FROM dbo.NhanVien NV
            JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung
            WHERE ND.TenDangNhap = N'kho1');

    INSERT dbo.ChiTietGiaoDichKho(MaGD, MaSP, SoLuong)
    SELECT g.MaGD, (SELECT MaSP FROM dbo.SanPham WHERE TenSP=N'Nước ngọt Pepsi lon 330ml'), 200
    FROM @g2 g;

    UPDATE S SET SoLuong = SoLuong + 200
    FROM dbo.SanPham S WHERE S.TenSP=N'Nước ngọt Pepsi lon 330ml';
END

-- NHẬP Masan (2025-10-07): Nam Ngư (150) + Clear 650g (90)
IF NOT EXISTS (
    SELECT 1 FROM dbo.GiaoDichKho
    WHERE LoaiGD=N'NHAP'
      AND CONVERT(date,NgayGD)='2025-10-07'
      AND MaNCC=(SELECT MaNCC FROM dbo.NhaCungCap WHERE TenNCC=N'Masan Consumer')
)
BEGIN
    DECLARE @g3 TABLE(MaGD INT);
    INSERT dbo.GiaoDichKho(LoaiGD, NgayGD, MaNCC, MaNhanVien)
    OUTPUT inserted.MaGD INTO @g3
    SELECT N'NHAP', DATETIMEFROMPARTS(2025,10,7,14,0,0,0),
           (SELECT MaNCC FROM dbo.NhaCungCap WHERE TenNCC=N'Masan Consumer'),
           (SELECT NV.MaNhanVien
            FROM dbo.NhanVien NV
            JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung
            WHERE ND.TenDangNhap = N'kho1');

    INSERT dbo.ChiTietGiaoDichKho(MaGD, MaSP, SoLuong)
    SELECT g.MaGD, (SELECT MaSP FROM dbo.SanPham WHERE TenSP=N'Nước mắm Nam Ngư 500ml'), 150 FROM @g3 g
    UNION ALL
    SELECT g.MaGD, (SELECT MaSP FROM dbo.SanPham WHERE TenSP=N'Dầu gội Clear 650g'), 90  FROM @g3 g;

    UPDATE S SET SoLuong = SoLuong + 150
    FROM dbo.SanPham S WHERE S.TenSP=N'Nước mắm Nam Ngư 500ml';
    UPDATE S SET SoLuong = SoLuong + 90
    FROM dbo.SanPham S WHERE S.TenSP=N'Dầu gội Clear 650g';
END
------------------------------------------------------------
-- Helper: MaNV bán hàng (không dùng biến, subquery inline)
------------------------------------------------------------
-- HD #A (12/10) — KH: Hoa — 1 Sữa + 3 Pepsi = 56,000
IF NOT EXISTS (
  SELECT 1 FROM dbo.HoaDon
  WHERE CONVERT(date,NgayLap)='2025-10-12'
    AND MaKhachHang=(SELECT MaKhachHang FROM dbo.KhachHang WHERE SoDienThoai=N'0911000011')
)
BEGIN
  DECLARE @hdA TABLE(MaHD INT);
  INSERT dbo.HoaDon(NgayLap,TongTien,MaKhachHang,MaNhanVien)
  OUTPUT inserted.MaHD INTO @hdA
  SELECT DATETIMEFROMPARTS(2025,10,12,11,10,0,0),0,
         (SELECT MaKhachHang FROM dbo.KhachHang WHERE SoDienThoai=N'0911000011'),
         (SELECT NV.MaNhanVien FROM dbo.NhanVien NV JOIN dbo.NguoiDung ND ON ND.MaNguoiDung=NV.MaNguoiDung WHERE ND.TenDangNhap=N'banhang1');

  INSERT dbo.ChiTietHoaDon(MaHD,MaSP,SoLuong,DonGia)
  SELECT h.MaHD, (SELECT MaSP FROM dbo.SanPham WHERE TenSP=N'Sữa tươi tiệt trùng Vinamilk 1L'), 1, 32000 FROM @hdA h
  UNION ALL
  SELECT h.MaHD, (SELECT MaSP FROM dbo.SanPham WHERE TenSP=N'Nước ngọt Pepsi lon 330ml'), 3,  8000 FROM @hdA h;

  UPDATE H SET TongTien=T.Tong
  FROM dbo.HoaDon H JOIN @hdA x ON x.MaHD=H.MaHD
  CROSS APPLY (SELECT SUM(SoLuong*DonGia) Tong FROM dbo.ChiTietHoaDon CT WHERE CT.MaHD=H.MaHD) T;
END

-- HD #B (15/10) — KH: Lâm — 2 Cosy + 1 Clear = 170,000
IF NOT EXISTS (
  SELECT 1 FROM dbo.HoaDon
  WHERE CONVERT(date,NgayLap)='2025-10-15'
    AND MaKhachHang=(SELECT MaKhachHang FROM dbo.KhachHang WHERE SoDienThoai=N'0912000022')
)
BEGIN
  DECLARE @hdB TABLE(MaHD INT);
  INSERT dbo.HoaDon(NgayLap,TongTien,MaKhachHang,MaNhanVien)
  OUTPUT inserted.MaHD INTO @hdB
  SELECT DATETIMEFROMPARTS(2025,10,15,9,5,0,0),0,
         (SELECT MaKhachHang FROM dbo.KhachHang WHERE SoDienThoai=N'0912000022'),
         (SELECT NV.MaNhanVien FROM dbo.NhanVien NV JOIN dbo.NguoiDung ND ON ND.MaNguoiDung=NV.MaNguoiDung WHERE ND.TenDangNhap=N'banhang1');

  INSERT dbo.ChiTietHoaDon(MaHD,MaSP,SoLuong,DonGia)
  SELECT h.MaHD, (SELECT MaSP FROM dbo.SanPham WHERE TenSP=N'Bánh quy Cosy 300g'), 2, 25000 FROM @hdB h
  UNION ALL
  SELECT h.MaHD, (SELECT MaSP FROM dbo.SanPham WHERE TenSP=N'Dầu gội Clear 650g'), 1,120000 FROM @hdB h;

  UPDATE H SET TongTien=T.Tong
  FROM dbo.HoaDon H JOIN @hdB x ON x.MaHD=H.MaHD
  CROSS APPLY (SELECT SUM(SoLuong*DonGia) Tong FROM dbo.ChiTietHoaDon CT WHERE CT.MaHD=H.MaHD) T;
END

-- HD #C (18/10) — KH: Quang — 1 Sữa + 1 Nam Ngư + 2 Pepsi = 78,000
IF NOT EXISTS (
  SELECT 1 FROM dbo.HoaDon
  WHERE CONVERT(date,NgayLap)='2025-10-18'
    AND MaKhachHang=(SELECT MaKhachHang FROM dbo.KhachHang WHERE SoDienThoai=N'0913000033')
)
BEGIN
  DECLARE @hdC TABLE(MaHD INT);
  INSERT dbo.HoaDon(NgayLap,TongTien,MaKhachHang,MaNhanVien)
  OUTPUT inserted.MaHD INTO @hdC
  SELECT DATETIMEFROMPARTS(2025,10,18,18,20,0,0),0,
         (SELECT MaKhachHang FROM dbo.KhachHang WHERE SoDienThoai=N'0913000033'),
         (SELECT NV.MaNhanVien FROM dbo.NhanVien NV JOIN dbo.NguoiDung ND ON ND.MaNguoiDung=NV.MaNguoiDung WHERE ND.TenDangNhap=N'banhang1');

  INSERT dbo.ChiTietHoaDon(MaHD,MaSP,SoLuong,DonGia)
  SELECT h.MaHD, (SELECT MaSP FROM dbo.SanPham WHERE TenSP=N'Sữa tươi tiệt trùng Vinamilk 1L'), 1, 32000 FROM @hdC h
  UNION ALL
  SELECT h.MaHD, (SELECT MaSP FROM dbo.SanPham WHERE TenSP=N'Nước mắm Nam Ngư 500ml'),      1, 30000 FROM @hdC h
  UNION ALL
  SELECT h.MaHD, (SELECT MaSP FROM dbo.SanPham WHERE TenSP=N'Nước ngọt Pepsi lon 330ml'),   2,  8000 FROM @hdC h;

  UPDATE H SET TongTien=T.Tong
  FROM dbo.HoaDon H JOIN @hdC x ON x.MaHD=H.MaHD
  CROSS APPLY (SELECT SUM(SoLuong*DonGia) Tong FROM dbo.ChiTietHoaDon CT WHERE CT.MaHD=H.MaHD) T;
END

-- HD #D (22/10) — KH: Trâm — 5 Pepsi + 1 Cosy = 65,000
IF NOT EXISTS (
  SELECT 1 FROM dbo.HoaDon
  WHERE CONVERT(date,NgayLap)='2025-10-22'
    AND MaKhachHang=(SELECT MaKhachHang FROM dbo.KhachHang WHERE SoDienThoai=N'0914000044')
)
BEGIN
  DECLARE @hdD TABLE(MaHD INT);
  INSERT dbo.HoaDon(NgayLap,TongTien,MaKhachHang,MaNhanVien)
  OUTPUT inserted.MaHD INTO @hdD
  SELECT DATETIMEFROMPARTS(2025,10,22,13,45,0,0),0,
         (SELECT MaKhachHang FROM dbo.KhachHang WHERE SoDienThoai=N'0914000044'),
         (SELECT NV.MaNhanVien FROM dbo.NhanVien NV JOIN dbo.NguoiDung ND ON ND.MaNguoiDung=NV.MaNguoiDung WHERE ND.TenDangNhap=N'banhang1');

  INSERT dbo.ChiTietHoaDon(MaHD,MaSP,SoLuong,DonGia)
  SELECT h.MaHD, (SELECT MaSP FROM dbo.SanPham WHERE TenSP=N'Nước ngọt Pepsi lon 330ml'), 5,  8000 FROM @hdD h
  UNION ALL
  SELECT h.MaHD, (SELECT MaSP FROM dbo.SanPham WHERE TenSP=N'Bánh quy Cosy 300g'),        1, 25000 FROM @hdD h;

  UPDATE H SET TongTien=T.Tong
  FROM dbo.HoaDon H JOIN @hdD x ON x.MaHD=H.MaHD
  CROSS APPLY (SELECT SUM(SoLuong*DonGia) Tong FROM dbo.ChiTietHoaDon CT WHERE CT.MaHD=H.MaHD) T;
END

-- HD #E (30/10) — KH: Nga — 1 Clear + 1 Nam Ngư = 150,000
IF NOT EXISTS (
  SELECT 1 FROM dbo.HoaDon
  WHERE CONVERT(date,NgayLap)='2025-10-30'
    AND MaKhachHang=(SELECT MaKhachHang FROM dbo.KhachHang WHERE SoDienThoai=N'0915000055')
)
BEGIN
  DECLARE @hdE TABLE(MaHD INT);
  INSERT dbo.HoaDon(NgayLap,TongTien,MaKhachHang,MaNhanVien)
  OUTPUT inserted.MaHD INTO @hdE
  SELECT DATETIMEFROMPARTS(2025,10,30,17,55,0,0),0,
         (SELECT MaKhachHang FROM dbo.KhachHang WHERE SoDienThoai=N'0915000055'),
         (SELECT NV.MaNhanVien FROM dbo.NhanVien NV JOIN dbo.NguoiDung ND ON ND.MaNguoiDung=NV.MaNguoiDung WHERE ND.TenDangNhap=N'banhang1');

  INSERT dbo.ChiTietHoaDon(MaHD,MaSP,SoLuong,DonGia)
  SELECT h.MaHD, (SELECT MaSP FROM dbo.SanPham WHERE TenSP=N'Dầu gội Clear 650g'),       1,120000 FROM @hdE h
  UNION ALL
  SELECT h.MaHD, (SELECT MaSP FROM dbo.SanPham WHERE TenSP=N'Nước mắm Nam Ngư 500ml'),   1, 30000 FROM @hdE h;

  UPDATE H SET TongTien=T.Tong
  FROM dbo.HoaDon H JOIN @hdE x ON x.MaHD=H.MaHD
  CROSS APPLY (SELECT SUM(SoLuong*DonGia) Tong FROM dbo.ChiTietHoaDon CT WHERE CT.MaHD=H.MaHD) T;
END

-- XEM trước khi xóa
SELECT * FROM dbo.CongNV WHERE Ky = N'2025-10';

-- XÓA
DELETE FROM dbo.CongNV
WHERE Ky = N'2025-10';

------------------------------------------------------------
-- Chèn bản ghi CongNV kỳ 2025-10 (idempotent)
------------------------------------------------------------
-- NV bán hàng: banhang1
INSERT dbo.CongNV (MaNV, Ky, SoNgayLam, SoGioLam, LuongTheoGio, HoaHongBanHang,
                   LuongCoBan, HeSoLuong, PhuCap, KhauTru)
SELECT NV.MaNhanVien, N'2025-10', 24, 192, 22000, 0.0050,
       4500000, 1.00, 300000, 0
FROM dbo.NhanVien NV
JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung AND ND.TenDangNhap = N'banhang1'
WHERE NOT EXISTS (SELECT 1 FROM dbo.CongNV C WHERE C.MaNV = NV.MaNhanVien AND C.Ky = N'2025-10');

-- NV kho: kho1
INSERT dbo.CongNV (MaNV, Ky, SoNgayLam, SoGioLam, LuongTheoGio,
                   LuongCoBan, HeSoLuong, PhuCap, PhuCapCaDem, KhauTru)
SELECT NV.MaNhanVien, N'2025-10', 26, 208, 20000,
       4200000, 1.00, 400000, 100000, 0
FROM dbo.NhanVien NV
JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung AND ND.TenDangNhap = N'kho1'
WHERE NOT EXISTS (SELECT 1 FROM dbo.CongNV C WHERE C.MaNV = NV.MaNhanVien AND C.Ky = N'2025-10');

-- Quản lý: quanly
INSERT dbo.CongNV (MaNV, Ky, LuongCoBan, HeSoLuong, TyLeDoanhThu, PhuCap)
SELECT NV.MaNhanVien, N'2025-10', 7000000, 1.20, 0.0100, 600000
FROM dbo.NhanVien NV
JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung AND ND.TenDangNhap = N'quanly'
WHERE NOT EXISTS (SELECT 1 FROM dbo.CongNV C WHERE C.MaNV = NV.MaNhanVien AND C.Ky = N'2025-10');

-- Admin: admin
INSERT dbo.CongNV (MaNV, Ky, LuongCoBan, HeSoLuong, PhuCapAdmin)
SELECT NV.MaNhanVien, N'2025-10', 8000000, 1.30, 500000
FROM dbo.NhanVien NV
JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung AND ND.TenDangNhap = N'admin'
WHERE NOT EXISTS (SELECT 1 FROM dbo.CongNV C WHERE C.MaNV = NV.MaNhanVien AND C.Ky = N'2025-10');

------------------------------------------------------------
-- 2) Tính doanh thu tháng 10/2025 và cập nhật thưởng (không biến)
------------------------------------------------------------
-- NV bán hàng 'banhang1': DoanhThuCa & Thuong theo HoaHongBanHang
UPDATE C
SET  DoanhThuCa = ISNULL((
        SELECT SUM(H.TongTien)
        FROM dbo.HoaDon H
        WHERE H.NgayLap >= '2025-10-01' AND H.NgayLap < '2025-11-01'
          AND H.MaNhanVien = C.MaNV), 0),
     Thuong = ROUND(
        ISNULL(C.HoaHongBanHang,0) * ISNULL((
            SELECT SUM(H.TongTien)
            FROM dbo.HoaDon H
            WHERE H.NgayLap >= '2025-10-01' AND H.NgayLap < '2025-11-01'
              AND H.MaNhanVien = C.MaNV), 0), 0)
FROM dbo.CongNV C
JOIN dbo.NhanVien NV  ON NV.MaNhanVien = C.MaNV
JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung AND ND.TenDangNhap = N'banhang1'
WHERE C.Ky = N'2025-10';

-- Quản lý 'quanly': doanh thu khu vực (tổng cửa hàng) & thưởng theo tỷ lệ
UPDATE C
SET  DoanhThuKhuVuc = ISNULL((
        SELECT SUM(H.TongTien)
        FROM dbo.HoaDon H
        WHERE H.NgayLap >= '2025-10-01' AND H.NgayLap < '2025-11-01'), 0),
     ThuongQTHT = ROUND(
        ISNULL(C.TyLeDoanhThu,0) * ISNULL((
            SELECT SUM(H.TongTien)
            FROM dbo.HoaDon H
            WHERE H.NgayLap >= '2025-10-01' AND H.NgayLap < '2025-11-01'), 0), 0)
FROM dbo.CongNV C
JOIN dbo.NhanVien NV  ON NV.MaNhanVien = C.MaNV
JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung AND ND.TenDangNhap = N'quanly'
WHERE C.Ky = N'2025-10';

-- NV kho 'kho1': thưởng thêm nếu > 200 giờ
UPDATE C
SET Thuong = ISNULL(C.Thuong,0) + CASE WHEN ISNULL(C.SoGioLam,0) > 200 THEN 200000 ELSE 0 END
FROM dbo.CongNV C
JOIN dbo.NhanVien NV  ON NV.MaNhanVien = C.MaNV
JOIN dbo.NguoiDung ND ON ND.MaNguoiDung = NV.MaNguoiDung AND ND.TenDangNhap = N'kho1'
WHERE C.Ky = N'2025-10';

------------------------------------------------------------
-- 3) Xem kết quả lương đề xuất
------------------------------------------------------------
SELECT
    NV.MaNhanVien, NV.HoTen, C.Ky,
    C.LuongCoBan, C.HeSoLuong, C.SoGioLam, C.LuongTheoGio,
    C.PhuCap, C.PhuCapCaDem, C.PhuCapAdmin,
    C.DoanhThuCa, C.HoaHongBanHang, C.Thuong,
    C.DoanhThuKhuVuc, C.TyLeDoanhThu, C.ThuongQTHT, C.KhauTru,
    LGio = ISNULL(C.SoGioLam,0)*ISNULL(C.LuongTheoGio,0),
    LuongThucNhan = ROUND(
        ISNULL(C.LuongCoBan,0)*ISNULL(C.HeSoLuong,1)
      + ISNULL(C.SoGioLam,0)*ISNULL(C.LuongTheoGio,0)
      + ISNULL(C.PhuCap,0)+ISNULL(C.PhuCapCaDem,0)+ISNULL(C.PhuCapAdmin,0)
      + ISNULL(C.Thuong,0)+ISNULL(C.ThuongQTHT,0)
      - ISNULL(C.KhauTru,0), 0)
FROM dbo.CongNV C
JOIN dbo.NhanVien NV ON NV.MaNhanVien = C.MaNV
WHERE C.Ky = N'2025-10'
ORDER BY NV.MaNhanVien;