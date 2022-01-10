create database ASM2_Task9
use ASM2_Task9

-- Tạo bảng lưu tên các hãng sản xuất
create table Manufacturer (
	ManufacturerID int primary key,
	ManufacturerName nvarchar(250) not null,
	Address nvarchar(400),
	Tel varchar(40)
)

-- Tạo bảng loại sản phẩm
create table Product_Type (
	TypeID int primary key,
	TypeName nvarchar(200) not null,
	ManufacturerID int foreign key references Manufacturer(ManufacturerID)
)

-- Tạo bảng lưu các sản phẩm
create table Product (
	ProductID int primary key,
	ProductName nvarchar(300) not null,
	Status nvarchar(500),
	Unit nvarchar(50),
	Price money,
	CurrentQuantity int,
	ProductTypeID int foreign key references Product_Type(TypeID),
	ManufacturerID int foreign key references Manufacturer(ManufacturerID)
)

-- Thêm các dữ liệu vào bảng
Insert into Manufacturer (ManufacturerID, ManufacturerName, Address, Tel)
	values
		(123, N'Asus', N'USA', '983232'),
		(456, N'Lenovo', N'Hong Kong', '123456'),
		(789, N'Apple', N'Viet Name', '456789')

Insert into Product_Type (TypeID, TypeName, ManufacturerID) 
	values 
		(1, N'Máy Tính', 123),
		(2, N'Máy Tính', 456),
		(3, N'Điện Thoại', 789),
		(4, N'Điện Thoại', 123),
		(5, N'Máy in', 123),
		(6, N'Máy in', 789)

insert into Product (ProductID, ProductName, Status, Unit, Price, CurrentQuantity, ManufacturerID)
	values
		(1, N'Máy tính T450', N'Máy Nhập Cũ', N'Chiếc', 1000, 10, 123),
		(2, N'Điện thoại NOKIA5670', N'Điện thoại đang hot', N'Chiếc', 200, 200, 123),
		(3, N'Máy in SamSung 450', N'Máy in tầm trung', N'Chiếc', 100, 10, 123),
		(4, N'Điện thoại Iphone15 Pro Max', N'Điện thoại dành cho các chủ tịch', N'Chiếc', 2000, 5, 789),
		(5, N'Máy in A100', N'Máy in xịn', N'Chiếc', 200, 20, 789),
		(6, N'Máy tính Lenovo ThinkPad', N'Máy tính hạng sang', N'Chiếc', 1500, 8, 456)
-- 4.a, Viết câu lệnh hiển thị các hãng sản xuất
select ManufacturerName from Manufacturer
-- 4.b, Hiển thị tất cả các sản phẩm
select ProductName from Product
-- 5.a, Liệt kê danh sách hãng theo thứ tự ngược lại
select ManufacturerName from Manufacturer
order by  ManufacturerName DESC
-- 5.b, Liệt kê danh sách sản phẩm theo thứ tự giá giảm dần
select ProductName from Product
order by Price DESC
-- 5.c, Hiển thị thông tin của hãng Asus
select * from Manufacturer
where ManufacturerName = N'Asus'
-- 5.d, Liệt kê danh sách sản phẩm còn ít hơn 11 chiếc trong kho
select ProductName from Product
where CurrentQuantity < 11
-- 5.e, Liệt kê danh sách sản phẩm của hãng Asus
select ProductName from Product
where ManufacturerID in (
	select ManufacturerID from Manufacturer
	where ManufacturerName = N'Asus'
)
-- 6.a, Số hãng sản phẩm mà cửa hàng đang có
select count (distinct ManufacturerID)
from Manufacturer
-- 6.b, Số mặt hàng mà cửa hàng đang bán
select count (distinct TypeName)
from Product_Type
-- 6.c,d Em không hiểu đề bài?
--7.a, Viết câu lệnh để thay đổi trường giá tiền của từng mặt hàng là dương(>0).
alter table Product
	add constraint check_gia check (price > 0)
-- 7.b, Viết câu lệnh để thay đổi số điện thoại phải bắt đầu bằng 0.
alter table Manufacturer
	add constraint check_tel check (left(tel,1) = '0')
go
-- 8.a, Thiết lập chỉ mục (Index) cho các cột sau: Tên hàng và Mô tả hàng để tăng hiệu suất truy vấn dữ liệu từ 2 cột này
create index IX_PRD on Product(ProductName, Status)
go
-- 8.b
create view View_SanPham as
select Product.ProductID, Product.ProductName, Product.Price from Product
go
create view View_SanPham_Hang as
select Product.ProductID, Product.ProductName, Manufacturer.ManufacturerName from Product
join Manufacturer
on Manufacturer.ManufacturerID = Product.ManufacturerID
go
-- 8.c
-- SP_SanPham_TenHang: Liệt kê các sản phẩm với tên hãng truyền vào store
create procedure SP_SanPham_TenHang
	@MnFactureName nvarchar(250)
as
select ProductName from Product
join Manufacturer
on Manufacturer.ManufacturerID = Product.ManufacturerID
where @MnFactureName = Manufacturer.ManufacturerName
go
execute SP_SanPham_TenHang N'Lenovo'
go
-- SP_SanPham_Gia: Liệt kê các sản phẩm có giá bán lớn hơn hoặc bằng giá bán truyền vào
create procedure SP_SanPham_Gia
	@Price money
as
select ProductName from Product
where @Price < Price
go
execute SP_SanPham_Gia '1000'
go
-- SP_SanPham_HetHang: Liệt kê các sản phẩm đã hết hàng (số lượng = 0)
create procedure SP_SanPham_HetHang
as
select ProductName from Product
where CurrentQuantity = 0
go
execute SP_SanPham_HetHang
go