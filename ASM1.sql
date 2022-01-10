-- Kiểm tra xem có CSDL ASM1_Task9 chưa
if exists (select * from sys.databases where name ='ASM1_Task9')
	drop database ASM1_Task9
go
-- tạo lại CSDL ASM1_Task9
create database ASM1_Task9
go
-- Sử dụng CSDL Task04_Task9
use ASM1_Task9
go
-- Tạo bảng lưu trữ thông tin khách hàng
create table Customer(
	CustomerID int primary key,
	CustomerName nvarchar(150),
	CustomerAddress nvarchar(300),
	Tel varchar(40)
)
select * from Customer
select * from Product
select * from Orders
select * from OrderDetails
go
-- Tạo bảng lưu trữ sản phẩm trong kho
create table Product(
	ProductID varchar(40) primary key,
	ProductName nvarchar(200),
	Unit nvarchar(40),
	Price money,
	Quantity int,
	ProductStatus nvarchar(300)
)
go
-- Tạo bảng lưu trữ Đơn Hàng
create table Orders(
	OrderID varchar(40) primary key,
	CustomerID int foreign key references Customer(CustomerID),
	OrderDate date
)
go
-- Tạo bảng lưu trữ thông tin chi tiết Đơn hàng
create table OrderDetails(
	OrderID varchar(40) foreign key references Orders(OrderID),
	ProductID varchar(40) foreign key references Product(ProductID),
	OrderStatus nvarchar(300),
	Price money,
	Quantity int
)
go
-- Thêm dữ liệu vào các bảng
insert into Customer(CustomerID, CustomerName, CustomerAddress, Tel)
	values
		(123, N'Đinh Quang Anh', N'Hà Đông-Hà Nội', '(+84) 395100761'),
		(124, N'Vũ Viết Quý', N'Thái Bình', '(+84) 123456789'),
		(125, N'Tạ Duy Linh', N'Thái Nguyên', '(+84) 987654321')
go
insert into Product(ProductID, ProductName, ProductStatus, Unit, Price, Quantity)
	values
		('LAP1', N'Laptop Lenovo ThinkBook', N'Hàng mới về', N'Chiếc', 23999000, 50),
		('LAP2', N'Laptop ASUS', N'Hàng tồn kho', N'Chiếc', 13499000, 10),
		('SMP1', N'SmartPhone SamSung Z Flip3', N'Điện thoại đang hot', N'Chiếc', 69999000, 20)
go
insert into Orders (OrderID, CustomerID, OrderDate)
	values
		('ord1', 123, '20211224'),
		('ord2', 124, '20211225'),
		('ord3', 125, '20211226'),
		('ord4', 123, '20211224')
go
insert into OrderDetails(OrderID, ProductID, OrderStatus, Price, Quantity)
	values
		('ord1', 'LAP1', N'Đã nhận đơn', 23999000, 2),
		('ord1', 'LAP2', N'Đã nhận đơn', 13499000, 3),
		('ord2', 'LAP1', N'Đang Kiểm Tra', 13499000, 3),
		('ord3', 'SMP1', N'Đang giao hàng', 6999000, 10),
		('ord4', 'SMP1', N'Đang giao hàng', 6999000, 10)
-- 4. Câu lệnh truy vấn
	-- Liệt kê danh sách khách hàng đã mua ở cửa hàng
	select CustomerName from Customer 
	where CustomerID in (
		select CustomerID from Orders
	)
	-- Liệt kê danh sách sản phẩm của cửa hàng
	select ProductName from Product
	-- Liệt kê danh sách các đơn hàng của cửa hàng
	select OrderID from Orders
-- 5. Câu lệnh truy vấn
	-- Liệt kê danh sách khách hàng theo thứ tự alphabet
	select CustomerName from Customer
	order by CustomerName 
	-- Liệt kê danh sách sản phẩm của cửa hàng theo thứ từ giá giảm dần
	select ProductName,Price from Product
	order by Price DESC
	-- Liệt kê sản phẩm mà khách hàng Đinh Quang Anh đã mua
	select ProductName from Product
	where ProductID in (
		select ProductID from OrderDetails
		where OrderID in (
			select OrderID from Orders
			where CustomerID = 123
		)
	)
-- 6. Câu lệnh truy vấn
	-- Số khách hàng đã mua hàng
	select COUNT (Distinct CustomerID) from Orders
	-- Số maẹt hàng mà cửa hàng bán
	select count (ProductID) from Product
	-- Tổng tiền của từng đơn hàng
	select OrderID, sum(Price*Quantity) as 'TotalAmount' from OrderDetails
	group by OrderID 
-- 7. thay Đổi thông tin
	-- Thay đổi trường giá tiền của từng mặt hàng >0
	alter table Product
		add constraint Ck_Product_Price Check(Price > 0) 
	alter table OrderDetails
		add constraint Ck_OrdDetails_Price Check(Price > 0)
	-- Thay đổi ngày đặt hàng nhỏ hơn ngày hiện tại
	alter table Orders
		add constraint Ck_Ord_Date Check (OrderDate < getDate())
	-- Thêm trường ngày xuất hiện của sản phẩm trên thị trường
	alter table Product
		add PublicDate date		 
-- 8. a, Đặt chỉ mục (index) cho cột Tên hàng và Người đặt hàng để tăng tốc độ truy vấn dữ liệu trên các cột này.
create index Product on Product(ProductName)
create index Customer on Customer(CustomerName)
go
-- 8.b, 
create view View_KhachHang as
select distinct Customer.CustomerName, Customer.CustomerAddress, Customer.Tel from Customer
join Orders
on Orders.CustomerID = Customer.CustomerID
go
create view View_SanPham as 
select Product.ProductName, Product.Price from Product
go
create view View_KhachHang_SanPham as
select Customer.CustomerName, Customer.Tel, Product.ProductName, Product.Quantity, Orders.OrderDate from Product
join OrderDetails
on OrderDetails.ProductID = Product.ProductID
join Orders
on Orders.OrderID = OrderDetails.OrderID
join Customer
on Customer.CustomerID = Orders.CustomerID
go
-- 8.c 
-- SP_TimKH_MaKH: Tìm khách hàng theo mã khách hàng
Create Procedure SP_TimKH_MaKH 
		@CusID int
as
select CustomerName from Customer
where @CusID = Customer.CustomerID
go
execute SP_TimKH_MaKH 123		-- Em tìm thử với mã khách hàng là 123
go
-- SP_TimKH_MaHD: Tìm thông tin khách hàng theo mã hóa đơn
Create Procedure SP_TimKH_MaHD
	@OrderID varchar(40)
as
select * from Customer
join Orders
on Orders.CustomerID = Customer.CustomerID
where @OrderID = Orders.OrderID
go
execute SP_TimKH_MaHD 'ord1'	-- Em tìm thử với mã hợp đồng là ord1
go
-- SP_SanPham_MaKH: Liệt kê các sản phẩm được mua bởi khách hàng có mã được truyền vào Store.
Create Procedure SP_SanPham_MaKH
	@CusID int
as 
select ProductName from Product
join OrderDetails
on OrderDetails.ProductID = Product.ProductID
join Orders
on Orders.OrderID = OrderDetails.OrderID
join Customer
on Customer.CustomerID = Orders.CustomerID
where @CusID = Customer.CustomerID
go
execute SP_SanPham_MaKH 123
go