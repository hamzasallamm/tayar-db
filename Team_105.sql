CREATE DATABASE LocalDeliveryMarketplace_Team_105;
GO

USE LocalDeliveryMarketplace_Team_105;
GO

-- Student 4: Youssef Elbeltagy (64-12228)
CREATE PROCEDURE createAllTables
AS
BEGIN
    CREATE TABLE Zone
    (
        zone_id INT IDENTITY(1,1) PRIMARY KEY,
        zone_name VARCHAR(50) NOT NULL UNIQUE,
        delivery_fee DECIMAL(10,2) NOT NULL CHECK (delivery_fee >= 0)
    );


    CREATE TABLE Users
    (
        user_id INT IDENTITY(1,1) PRIMARY KEY,
        first_name VARCHAR(30) NOT NULL,
        middle_name VARCHAR(30) NULL,
        last_name VARCHAR(30) NOT NULL,
        username VARCHAR(30) NOT NULL UNIQUE,
        password VARCHAR(30) NOT NULL,
        email VARCHAR(100) NOT NULL UNIQUE,
        dob DATE NULL,
        account_status VARCHAR(20) NOT NULL DEFAULT 'Active'
    );


    CREATE TABLE User_Phone
    (
        user_id INT NOT NULL,
        phone CHAR(11) NOT NULL,
        PRIMARY KEY (user_id, phone),
        FOREIGN KEY (user_id) REFERENCES Users(user_id)
    );


    CREATE TABLE Admin
    (
        admin_id INT PRIMARY KEY,
        role VARCHAR(20) NOT NULL DEFAULT 'Super Admin',
        zone_id INT NULL,
        FOREIGN KEY (admin_id) REFERENCES Users(user_id),
        FOREIGN KEY (zone_id) REFERENCES Zone(zone_id)
    );


    CREATE TABLE Partner
    (
        partner_id INT PRIMARY KEY,
        FOREIGN KEY (partner_id) REFERENCES Users(user_id)
    );


    CREATE TABLE Rider
    (
        rider_id INT PRIMARY KEY,
        vehicle_type VARCHAR(30) NOT NULL,
        plate_no VARCHAR(15) NOT NULL UNIQUE,
        license_no VARCHAR(20) NOT NULL UNIQUE,
        is_available BIT NOT NULL DEFAULT 1,
        zone_id INT NOT NULL,
        FOREIGN KEY (rider_id) REFERENCES Users(user_id),
        FOREIGN KEY (zone_id) REFERENCES Zone(zone_id)
    );


    CREATE TABLE Customer
    (
        customer_id INT PRIMARY KEY,
        wallet_balance DECIMAL(10,2) NOT NULL DEFAULT 0
            CHECK (wallet_balance >= 0),
        FOREIGN KEY (customer_id) REFERENCES Users(user_id)
    );


    CREATE TABLE Address
    (
        address_id INT IDENTITY(1,1) PRIMARY KEY,
        description VARCHAR(150) NOT NULL,
        is_active BIT NOT NULL DEFAULT 1,
        customer_id INT NOT NULL,
        zone_id INT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
        FOREIGN KEY (zone_id) REFERENCES Zone(zone_id)
    );


    CREATE TABLE Card
    (
        card_id INT IDENTITY(1,1) PRIMARY KEY,
        card_no CHAR(16) NOT NULL,
        card_holder_name VARCHAR(100) NOT NULL,
        expiration_date DATE NOT NULL,
        customer_id INT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
        UNIQUE (customer_id, card_no)
    );


    CREATE TABLE Business
    (
        business_id INT IDENTITY(1,1) PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        description VARCHAR(255) NULL,
        link_website VARCHAR(255) NULL,
        opening_hour TIME NOT NULL,
        closing_hour TIME NOT NULL,
        expected_delivery_time INT NOT NULL CHECK (expected_delivery_time > 0),
        status VARCHAR(20) NOT NULL DEFAULT 'Pending',
        suspension_reason VARCHAR(255) NULL,
        partner_id INT NOT NULL UNIQUE,
        zone_id INT NOT NULL,
        FOREIGN KEY (partner_id) REFERENCES Partner(partner_id),
        FOREIGN KEY (zone_id) REFERENCES Zone(zone_id)
    );


    CREATE TABLE Business_Phone
    (
        business_id INT NOT NULL,
        phone CHAR(11) NOT NULL,
        PRIMARY KEY (business_id, phone),
        FOREIGN KEY (business_id) REFERENCES Business(business_id)
    );


    CREATE TABLE Restaurant
    (
        business_id INT PRIMARY KEY,
        cuisine_type VARCHAR(50) NOT NULL,
        food_category VARCHAR(50) NOT NULL,
        FOREIGN KEY (business_id) REFERENCES Business(business_id)
    );


    CREATE TABLE Pharmacy
    (
        business_id INT PRIMARY KEY,
        pharmacy_type VARCHAR(50) NOT NULL,
        FOREIGN KEY (business_id) REFERENCES Business(business_id)
    );


    CREATE TABLE Blacklist
    (
        customer_id INT PRIMARY KEY,
        admin_id INT NOT NULL,
        reason VARCHAR(255) NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
        FOREIGN KEY (admin_id) REFERENCES Admin(admin_id)
    );


    CREATE TABLE Product
    (
        product_id INT IDENTITY(1,1) PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        description VARCHAR(255) NULL,
        category VARCHAR(50) NOT NULL,
        price DECIMAL(10,2) NOT NULL CHECK (price > 0),
        discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
        is_available BIT NOT NULL DEFAULT 1,
        business_id INT NOT NULL,
        FOREIGN KEY (business_id) REFERENCES Business(business_id),
        CHECK (discount_amount >= 0 AND discount_amount <= 0.5 * price)
    );


    CREATE TABLE Favorite_Business
    (
        customer_id INT NOT NULL,
        business_id INT NOT NULL,
        PRIMARY KEY (customer_id, business_id),
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
        FOREIGN KEY (business_id) REFERENCES Business(business_id)
    );

    CREATE TABLE Favorite_Product
    (
        customer_id INT NOT NULL,
        product_id INT NOT NULL,
        PRIMARY KEY (customer_id, product_id),
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
        FOREIGN KEY (product_id) REFERENCES Product(product_id)
    );

    CREATE TABLE Voucher
    (
        voucher_id INT IDENTITY(1,1) PRIMARY KEY,
        promo_code VARCHAR(30) NOT NULL UNIQUE,
        is_percentage BIT NOT NULL,
        amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
        expiry_date DATE NOT NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'Unused',
        customer_id INT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
    );


    CREATE TABLE Cart
    (
        cart_id INT IDENTITY(1,1) PRIMARY KEY,
        status VARCHAR(20) NOT NULL DEFAULT 'Active',
        created_at DATETIME NOT NULL DEFAULT GETDATE(),
        customer_id INT NOT NULL,
        address_id INT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
        FOREIGN KEY (address_id) REFERENCES Address(address_id)
    );


    CREATE TABLE CartItem
    (
        cart_id INT NOT NULL,
        product_id INT NOT NULL,
        quantity INT NOT NULL CHECK (quantity BETWEEN 1 AND 10),
        notes VARCHAR(255) NULL,
        unit_price DECIMAL(10,2) NULL,
        PRIMARY KEY (cart_id, product_id),
        FOREIGN KEY (cart_id) REFERENCES Cart(cart_id),
        FOREIGN KEY (product_id) REFERENCES Product(product_id)
    );


    CREATE TABLE Orders
    (
        order_id INT IDENTITY(1,1) PRIMARY KEY,
        order_date DATETIME NOT NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'Placed',
        discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
        total_amount DECIMAL(10,2) NOT NULL,
        cart_id INT NOT NULL UNIQUE,
        zone_id INT NOT NULL,
        voucher_id INT NULL,
        FOREIGN KEY (cart_id) REFERENCES Cart(cart_id),
        FOREIGN KEY (zone_id) REFERENCES Zone(zone_id),
        FOREIGN KEY (voucher_id) REFERENCES Voucher(voucher_id)
    );


    CREATE TABLE SubOrder
    (
        suborder_id INT IDENTITY(1,1) PRIMARY KEY,
        status VARCHAR(20) NOT NULL DEFAULT 'Placed',
        total_price DECIMAL(10,2) NOT NULL,
        delivery_fee DECIMAL(10,2) NOT NULL,
        order_id INT NOT NULL,
        business_id INT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES Orders(order_id),
        FOREIGN KEY (business_id) REFERENCES Business(business_id),
        UNIQUE (order_id, business_id)
    );


    CREATE TABLE Delivery
    (
        delivery_id INT IDENTITY(1,1) PRIMARY KEY,
        assigned_at DATETIME NOT NULL,
        picked_up_at DATETIME NULL,
        delivered_at DATETIME NULL,
        tracking_time INT NULL,
        rider_rating INT NULL CHECK (rider_rating BETWEEN 1 AND 5),
        suborder_id INT NOT NULL UNIQUE,
        rider_id INT NOT NULL,
        FOREIGN KEY (suborder_id) REFERENCES SubOrder(suborder_id),
        FOREIGN KEY (rider_id) REFERENCES Rider(rider_id)
    );


    CREATE TABLE Payment
    (
        payment_id INT IDENTITY(1,1) PRIMARY KEY,
        amount DECIMAL(10,2) NOT NULL,
        currency VARCHAR(3) NOT NULL DEFAULT 'EGP',
        method VARCHAR(20) NOT NULL,
        transaction_date DATETIME NOT NULL,
        refunded_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
        order_id INT NOT NULL UNIQUE,
        card_id INT NULL,
        FOREIGN KEY (order_id) REFERENCES Orders(order_id),
        FOREIGN KEY (card_id) REFERENCES Card(card_id),
        CHECK (refunded_amount <= amount)
    );


    CREATE TABLE Feedback
    (
        feedback_id INT IDENTITY(1,1) PRIMARY KEY,
        headline VARCHAR(100) NOT NULL,
        description VARCHAR(500) NULL,
        rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
        feedback_date DATETIME NOT NULL DEFAULT GETDATE(),
        suborder_id INT NOT NULL UNIQUE,
        FOREIGN KEY (suborder_id) REFERENCES SubOrder(suborder_id)
    );
END;
GO

-- Student 4: Youssef Elbeltagy (64-12228)
CREATE PROCEDURE dropAllTables
AS
BEGIN
    DROP TABLE Feedback;
    DROP TABLE Payment;
    DROP TABLE Delivery;
    DROP TABLE SubOrder;
    DROP TABLE Orders;
    DROP TABLE CartItem;
    DROP TABLE Cart;
    DROP TABLE Voucher;
    DROP TABLE Favorite_Product;
    DROP TABLE Favorite_Business;
    DROP TABLE Product;
    DROP TABLE Blacklist;
    DROP TABLE Pharmacy;
    DROP TABLE Restaurant;
    DROP TABLE Business_Phone;
    DROP TABLE Business;
    DROP TABLE Card;
    DROP TABLE Address;
    DROP TABLE Customer;
    DROP TABLE Rider;
    DROP TABLE Partner;
    DROP TABLE Admin;
    DROP TABLE User_Phone;
    DROP TABLE Users;
    DROP TABLE Zone;
END;
GO

-- Student 4: Youssef Elbeltagy (64-12228)
CREATE PROCEDURE dropAllProceduresFunctionsViews
AS
BEGIN
    DROP VIEW allBusinessProfiles;
    DROP VIEW BusinessesPerZone;
    DROP VIEW BusinessRatingsSummary;
    DROP VIEW ActiveVouchers;
    DROP VIEW PendingBusinessApprovals;
    DROP VIEW RiderPerformanceSummary;
    DROP VIEW TopSellingProducts;
    DROP VIEW ZoneDeliveryPerformance;
    DROP VIEW Customer_Ordered_Items;
    DROP VIEW Zone_Avg_Delivery_Time;

    DROP FUNCTION CustomerLoginValidation;
    DROP FUNCTION PartnerLoginValidation;
    DROP FUNCTION RiderLoginValidation;
    DROP FUNCTION AdminLoginValidation;
    DROP FUNCTION ZoneOrderReport;
    DROP FUNCTION TopRiders;
    DROP FUNCTION Daily_Revenue_Report;
    DROP FUNCTION BusinessSalesReport;
    DROP FUNCTION BusinessFeedbackOverview;
    DROP FUNCTION Calculate_Voucher_Discount;
    DROP FUNCTION My_Order_History;
    DROP FUNCTION My_Favorites;
    DROP FUNCTION Recommended_Products;
    DROP FUNCTION My_Active_Deliveries;
    DROP FUNCTION My_Earnings;
    DROP FUNCTION My_Rating_Summary;
    DROP FUNCTION My_Delivery_History;
    DROP FUNCTION Search_Platform;
    DROP FUNCTION Reconcile_Order_Totals;
    DROP FUNCTION Nearby_Businesses_By_Category;
    DROP FUNCTION Platform_Health_Snapshot;
    DROP FUNCTION Validate_New_User;
    DROP FUNCTION Cancellable_Orders;

    DROP PROCEDURE createAllTables;
    DROP PROCEDURE dropAllTables;
    DROP PROCEDURE clearAllTables;
    DROP PROCEDURE Customer_Register;
    DROP PROCEDURE Partner_Register;
    DROP PROCEDURE Rider_Register;
    DROP PROCEDURE Change_Password;
    DROP PROCEDURE Create_Admin;
    DROP PROCEDURE Approve_Business;
    DROP PROCEDURE Reject_Business;
    DROP PROCEDURE Suspend_Business;
    DROP PROCEDURE Reinstate_Business;
    DROP PROCEDURE Create_Zone;
    DROP PROCEDURE Update_Zone_Fee;
    DROP PROCEDURE Assign_Admin_Zone;
    DROP PROCEDURE Issue_Voucher;
    DROP PROCEDURE Blacklist_Customer;
    DROP PROCEDURE Lift_Customer_Blacklist;
    DROP PROCEDURE Register_Business;
    DROP PROCEDURE Update_Business_Info;
    DROP PROCEDURE Upsert_Product;
    DROP PROCEDURE Toggle_Product_Status;
    DROP PROCEDURE Set_Product_Promotion;
    DROP PROCEDURE Add_Customer_Address;
    DROP PROCEDURE Update_Delete_Customer_Address;
    DROP PROCEDURE Change_Active_Address;
    DROP PROCEDURE Add_Card;
    DROP PROCEDURE Create_Cart;
    DROP PROCEDURE Add_To_Cart;
    DROP PROCEDURE Remove_From_Cart;
    DROP PROCEDURE Checkout_Cart;
    DROP PROCEDURE Cancel_Order;
    DROP PROCEDURE Reorder;
    DROP PROCEDURE Submit_Feedback;
    DROP PROCEDURE Rate_Rider;
    DROP PROCEDURE Toggle_Favorite;
    DROP PROCEDURE Set_Rider_Availability;
    DROP PROCEDURE Mark_Picked_Up;
    DROP PROCEDURE Mark_Delivered;
END;
GO

-- Student 4: Youssef Elbeltagy (64-12228)
CREATE PROCEDURE clearAllTables
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Dropping and recreating the tables removes every row and restarts every ID at 1.
        EXEC dropAllTables;
        EXEC createAllTables;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN -1;
    END CATCH;

    RETURN 0;
END;
GO

-- The tables must exist before the views and functions below are created.
EXEC createAllTables;
GO

-- Student 2: Karim Salah (64-13699)
CREATE VIEW allBusinessProfiles
AS
SELECT
    B.business_id,
    B.name AS business_name,
    CASE
        WHEN R.business_id IS NOT NULL THEN 'Restaurant'
        WHEN P.business_id IS NOT NULL THEN 'Pharmacy'
    END AS business_type,
    Z.zone_name,
    U.first_name + ' ' + U.last_name AS partner_name,
    B.status,
    B.opening_hour,
    B.closing_hour
FROM Business B
INNER JOIN Zone Z ON Z.zone_id = B.zone_id
INNER JOIN Users U ON U.user_id = B.partner_id
LEFT OUTER JOIN Restaurant R ON R.business_id = B.business_id
LEFT OUTER JOIN Pharmacy P ON P.business_id = B.business_id;
GO

-- Student 4: Youssef Elbeltagy (64-12228)
CREATE VIEW BusinessesPerZone
AS
SELECT
    Z.zone_id,
    Z.zone_name,
    COUNT(B.business_id) AS business_count
FROM Zone Z
LEFT JOIN Business B
    ON B.zone_id = Z.zone_id
   AND B.status = 'Active'
GROUP BY Z.zone_id, Z.zone_name;
GO

-- Student 1: Hamza Sallam (64-5469)
create view ActiveVouchers as
select v.voucher_id, v.promo_code, v.customer_id, v.is_percentage, v.amount, v.expiry_date
from Voucher v
where v.status = 'Unused' and v.expiry_date >= cast(getdate() as date);
GO

-- Student 2: Karim Salah (64-13699)
CREATE VIEW PendingBusinessApprovals
AS
SELECT business_id, business_name, business_type, zone_name, partner_name
FROM allBusinessProfiles
WHERE status = 'Pending';
GO

-- Student 2: Karim Salah (64-13699)
CREATE VIEW TopSellingProducts
AS
SELECT TOP 10
    P.product_id,
    P.name AS product_name,
    A.business_name,
    A.business_type,
    SUM(CI.quantity) AS units_sold,
    CAST(SUM(CI.quantity * CI.unit_price) AS DECIMAL(10,2)) AS total_revenue
FROM CartItem CI
INNER JOIN Product P ON P.product_id = CI.product_id
INNER JOIN Orders O ON O.cart_id = CI.cart_id
INNER JOIN SubOrder S ON S.order_id = O.order_id AND S.business_id = P.business_id
INNER JOIN allBusinessProfiles A ON A.business_id = P.business_id
WHERE S.status <> 'Cancelled'
GROUP BY P.product_id, P.name, A.business_name, A.business_type
ORDER BY units_sold DESC, P.product_id;
GO

-- Student 1: Hamza Sallam (64-5469)
create function dbo.Validate_New_User(@first_name varchar(30), @last_name varchar(30), @username varchar(30),
@password varchar(30), @email varchar(100), @phone char(11), @dob date)
returns int as begin
    if @first_name is null or @first_name='' or @last_name is null or @last_name='' or @username is null or @username='' or @password is null or @password='' or @email is null or @email='' or @phone is null or len(@phone) <> 11 or @phone like '%[^0-9]%' or @email not like '%_@_%._%' or @dob > cast(getdate() as date)
        return -1;
    if exists(select 1 from Users where username = @username or email = @email)
        return -2;

    return 0;
end;
GO

-- Student 1: Hamza Sallam (64-5469)
create procedure Customer_Register(@first_name varchar(30), @middle_name varchar(30), @last_name varchar(30), @username varchar(30),
@password varchar(30), @email varchar(100), @phone char(11), @dob date)
as begin
    declare @result int;
    declare @new_id int;

    select @result = dbo.Validate_New_User(@first_name, @last_name, @username, @password, @email, @phone, @dob);
    if @result <> 0
        return @result;

    begin try
        begin transaction;
        insert into Users (first_name, middle_name, last_name, username, password, email, dob)
        values (@first_name, @middle_name, @last_name, @username, @password, @email, @dob);
        select @new_id = user_id from Users where username = @username;
        insert into User_Phone (user_id, phone) values (@new_id, @phone);
        insert into Customer (customer_id) values (@new_id);
        commit transaction;
    end try
    begin catch
        rollback transaction;
        return -1;
    end catch;
    return 0;
end;
GO

-- Student 1: Hamza Sallam (64-5469)
create procedure Partner_Register(@first_name varchar(30), @middle_name varchar(30), @last_name varchar(30), @username varchar(30),
@password varchar(30), @email varchar(100), @phone char(11), @dob date)
as begin
    declare @result int;
    declare @new_id int;

    select @result = dbo.Validate_New_User(@first_name, @last_name, @username, @password, @email, @phone, @dob);
    if @result <> 0
        return @result;

    begin try
        begin transaction;
        insert into Users (first_name, middle_name, last_name, username, password, email, dob)
        values (@first_name, @middle_name, @last_name, @username, @password, @email, @dob);
        select @new_id = user_id from Users where username = @username;
        insert into User_Phone (user_id, phone) values (@new_id, @phone);
        insert into Partner (partner_id) values (@new_id);
        commit transaction;
    end try
    begin catch
        rollback transaction;
        return -1;
    end catch;
    return 0;
end;
GO

-- Student 1: Hamza Sallam (64-5469)
create procedure Rider_Register(@first_name varchar(30), @middle_name varchar(30), @last_name varchar(30), @username varchar(30),
@password varchar(30), @email varchar(100), @phone char(11), @dob date, @vehicle_type varchar(30), @plate_no varchar(15), @license_no varchar(20), @zone_id int)
as begin
    declare @result int;
    declare @new_id int;

    select @result = dbo.Validate_New_User(@first_name, @last_name, @username, @password, @email, @phone, @dob);
    if @result <> 0
        return @result;

    if @vehicle_type is null or @vehicle_type = '' or @plate_no is null or @plate_no = '' or @license_no is null or @license_no = '' or @zone_id is null
        return -1;
    
    if not exists(select 1 from Zone where zone_id = @zone_id)
        return -1;
    
    if exists(select 1 from Rider where plate_no = @plate_no or license_no = @license_no)
        return -2;

    begin try
        begin transaction;
        insert into Users (first_name, middle_name, last_name, username, password, email, dob)
        values (@first_name, @middle_name, @last_name, @username, @password, @email, @dob);
        select @new_id = user_id from Users where username = @username;
        insert into User_Phone (user_id, phone) values (@new_id, @phone);
        insert into Rider (rider_id, vehicle_type, plate_no, license_no, zone_id) values (@new_id, @vehicle_type, @plate_no, @license_no, @zone_id);
        commit transaction;
    end try
    begin catch
        rollback transaction;
        return -1;
    end catch;
    return 0;
end;
GO


-- Student 1: Hamza Sallam (64-5469)
create function dbo.CustomerLoginValidation(@username varchar(30), @password varchar(30))
returns bit as
begin
    if exists(
        select 1
        from Users u inner join Customer c on u.user_id = c.customer_id
        where u.username = @username and u.password = @password and u.account_status = 'Active'
    )
        return 1;

    return 0;
end;
GO

-- Student 1: Hamza Sallam (64-5469)
create function dbo.PartnerLoginValidation(@username varchar(30), @password varchar(30))
returns bit as
begin
    if exists(
        select 1
        from Users u inner join Partner p on u.user_id = p.partner_id
        where u.username = @username and u.password = @password and u.account_status = 'Active'
    )
        return 1;

    return 0;
end;
GO

-- Student 1: Hamza Sallam (64-5469)
create function dbo.RiderLoginValidation(@username varchar(30), @password varchar(30))
returns bit as
begin
    if exists(
        select 1
        from Users u inner join Rider r on u.user_id = r.rider_id
        where u.username = @username and u.password = @password and u.account_status = 'Active'
    )
        return 1;

    return 0;
end;
GO

-- Student 1: Hamza Sallam (64-5469)
create function dbo.AdminLoginValidation(@username varchar(30), @password varchar(30))
returns bit as
begin
    if exists(
        select 1
        from Users u inner join Admin a on u.user_id = a.admin_id
        where u.username = @username and u.password = @password and u.account_status = 'Active'
    )
        return 1;

    return 0;
end;
GO

-- Student 1: Hamza Sallam (64-5469)
create procedure Change_Password(@user_id int, @old_password varchar(30), @new_password varchar(30), @new_password_repeat varchar(30), @success bit output)
as begin
    select @success = 0;

    if @new_password is null or @new_password = ''
        return -1;
    if @new_password <> @new_password_repeat or @new_password_repeat is null or @new_password_repeat = ''
        return -1;
    if @new_password = @old_password
        return -1;
    if not exists(select 1 from Users where user_id = @user_id and password = @old_password)
        return -1;
    update Users set password = @new_password where user_id = @user_id;

    select @success = 1;
    return 0;
end;
GO

--Student 1: Hamza Sallam (64-5469)
create procedure Create_Admin(@first_name varchar(30), @middle_name varchar(30), @last_name varchar(30), @username varchar(30),
@password varchar(30), @email varchar(100), @phone char(11), @dob date, @role varchar(20), @zone_id int, @super_admin_id int)
as begin
    declare @result int;
    declare @new_id int;

    if not exists(select 1 from Admin where admin_id = @super_admin_id and role = 'Super Admin')
        return -3;
    select @result = dbo.Validate_New_User(@first_name, @last_name, @username, @password, @email, @phone, @dob);
    if @result <> 0
        return @result;

    if @role is null select @role = 'Super Admin';
    if @role not in ('Super Admin', 'Zone Admin')
        return -1;
    if @role = 'Super Admin' and @zone_id is not null
        return -1;
    if @role = 'Zone Admin' and not exists(select 1 from Zone where zone_id = @zone_id)
        return -1;

    begin try
        begin transaction;
        insert into Users (first_name, middle_name, last_name, username, password, email, dob)
        values (@first_name, @middle_name, @last_name, @username, @password, @email, @dob);
        select @new_id = user_id from Users where username = @username;
        insert into User_Phone (user_id, phone) values (@new_id, @phone);
        insert into Admin (admin_id, role, zone_id) values (@new_id, @role, @zone_id);
        commit transaction;
    end try
    begin catch
        rollback transaction;
        return -1;
    end catch;
    return 0;
end;
GO

-- Student 1: Hamza Sallam (64-5469)
create procedure Approve_Business(@business_id int, @admin_id int)
as begin
    if not exists(select 1 from Admin a
    inner join Business b on b.business_id = @business_id
    where a.admin_id = @admin_id and (a.role = 'Super Admin' or (a.role = 'Zone Admin' and a.zone_id = b.zone_id)))
        return -3;

    if not exists(select 1 from Business where business_id = @business_id and status = 'Pending')
        return -4;

    update Business set status = 'Active' where business_id = @business_id;
    return 0;
end;
GO

-- Student 1: Hamza Sallam (64-5469)
create procedure Reject_Business(@business_id int, @admin_id int)
as begin
    if not exists(select 1 from Admin a
    inner join Business b on b.business_id = @business_id
    where a.admin_id = @admin_id and (a.role = 'Super Admin' or (a.role = 'Zone Admin' and a.zone_id = b.zone_id)))
        return -3;

    if not exists(select 1 from Business where business_id = @business_id and status = 'Pending')
        return -4;

    update Business set status = 'Rejected' where business_id = @business_id;
    return 0;
end;
GO   

    

-- Student 4: Youssef Elbeltagy (64-12228)
CREATE PROCEDURE Suspend_Business
    @business_id INT,
    @admin_id INT,
    @reason VARCHAR(255)
AS
BEGIN
    IF @business_id IS NULL OR @admin_id IS NULL OR @reason IS NULL OR @reason = ''
    BEGIN
        RETURN -1;
    END;

    IF NOT EXISTS (SELECT 1 FROM Business WHERE business_id = @business_id)
    BEGIN
        RETURN -1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Admin A
        INNER JOIN Business B ON B.business_id = @business_id
        WHERE A.admin_id = @admin_id
          AND
          (
              A.role = 'Super Admin'
              OR (A.role = 'Zone Admin' AND A.zone_id = B.zone_id)
          )
    )
    BEGIN
        RETURN -3;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Business
        WHERE business_id = @business_id
          AND status = 'Active'
    )
    BEGIN
        RETURN -4;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Business
        SET status = 'Suspended',
            suspension_reason = @reason
        WHERE business_id = @business_id;

        UPDATE Product
        SET is_available = 0
        WHERE business_id = @business_id;

        -- Refund to the wallet, except for Cash. The refund is capped at what is left on the payment.
        UPDATE Customer
        SET wallet_balance = wallet_balance +
        (
            SELECT SUM(
                CASE
                    WHEN S.total_price + S.delivery_fee < P.amount - P.refunded_amount
                        THEN S.total_price + S.delivery_fee
                    ELSE P.amount - P.refunded_amount
                END)
            FROM SubOrder S
            INNER JOIN Orders O ON O.order_id = S.order_id
            INNER JOIN Cart C ON C.cart_id = O.cart_id
            INNER JOIN Payment P ON P.order_id = O.order_id
            WHERE S.business_id = @business_id
              AND S.status IN ('Placed', 'Assigned')
              AND P.method <> 'Cash'
              AND C.customer_id = Customer.customer_id
        )
        WHERE customer_id IN
        (
            SELECT C.customer_id
            FROM SubOrder S
            INNER JOIN Orders O ON O.order_id = S.order_id
            INNER JOIN Cart C ON C.cart_id = O.cart_id
            INNER JOIN Payment P ON P.order_id = O.order_id
            WHERE S.business_id = @business_id
              AND S.status IN ('Placed', 'Assigned')
              AND P.method <> 'Cash'
        );

        -- Record the same refund on each payment.
        UPDATE Payment
        SET refunded_amount = refunded_amount +
        (
            SELECT
                CASE
                    WHEN S.total_price + S.delivery_fee < Payment.amount - Payment.refunded_amount
                        THEN S.total_price + S.delivery_fee
                    ELSE Payment.amount - Payment.refunded_amount
                END
            FROM SubOrder S
            WHERE S.order_id = Payment.order_id
              AND S.business_id = @business_id
              AND S.status IN ('Placed', 'Assigned')
        )
        WHERE order_id IN
        (
            SELECT order_id
            FROM SubOrder
            WHERE business_id = @business_id
              AND status IN ('Placed', 'Assigned')
        );

        UPDATE SubOrder
        SET status = 'Cancelled'
        WHERE business_id = @business_id
          AND status IN ('Placed', 'Assigned');

        -- Recompute the status of every order of this business (BR-11).
        UPDATE Orders
        SET status =
            CASE
                WHEN NOT EXISTS
                (
                    SELECT 1 FROM SubOrder S
                    WHERE S.order_id = Orders.order_id
                      AND S.status <> 'Cancelled'
                )
                    THEN 'Cancelled'

                WHEN NOT EXISTS
                (
                    SELECT 1 FROM SubOrder S
                    WHERE S.order_id = Orders.order_id
                      AND S.status <> 'Cancelled'
                      AND S.status <> 'Delivered'
                )
                    THEN 'Delivered'

                WHEN EXISTS
                (
                    SELECT 1 FROM SubOrder S
                    WHERE S.order_id = Orders.order_id
                      AND S.status IN ('Picked Up', 'Delivered')
                )
                    THEN 'In Progress'

                ELSE 'Placed'
            END
        WHERE order_id IN (SELECT order_id FROM SubOrder WHERE business_id = @business_id);

        -- Give back the voucher of every order that is now fully cancelled.
        UPDATE Voucher
        SET status = 'Unused'
        WHERE voucher_id IN
        (
            SELECT voucher_id
            FROM Orders
            WHERE status = 'Cancelled'
              AND order_id IN (SELECT order_id FROM SubOrder WHERE business_id = @business_id)
        );

        UPDATE Orders
        SET voucher_id = NULL
        WHERE status = 'Cancelled'
          AND order_id IN (SELECT order_id FROM SubOrder WHERE business_id = @business_id);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN -1;
    END CATCH;

    RETURN 0;
END;
GO


-- Student 4: Youssef Elbeltagy (64-12228)
CREATE PROCEDURE Reinstate_Business
    @business_id INT,
    @super_admin_id INT
AS
BEGIN
    IF @business_id IS NULL OR @super_admin_id IS NULL
    BEGIN
        RETURN -1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Admin
        WHERE admin_id = @super_admin_id
          AND role = 'Super Admin'
          AND zone_id IS NULL
    )
    BEGIN
        RETURN -3;
    END;

    IF NOT EXISTS (SELECT 1 FROM Business WHERE business_id = @business_id)
    BEGIN
        RETURN -1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Business
        WHERE business_id = @business_id
          AND status = 'Suspended'
    )
    BEGIN
        RETURN -4;
    END;

    UPDATE Business
    SET status = 'Active',
        suspension_reason = NULL
    WHERE business_id = @business_id;

    RETURN 0;
END;
GO

-- Student 4: Youssef Elbeltagy (64-12228)
CREATE PROCEDURE Create_Zone
    @zone_name VARCHAR(50),
    @delivery_fee DECIMAL(10,2),
    @super_admin_id INT
AS
BEGIN
    IF @zone_name IS NULL OR @zone_name = ''
       OR @delivery_fee IS NULL OR @delivery_fee < 0
    BEGIN
        RETURN -1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Admin
        WHERE admin_id = @super_admin_id
          AND role = 'Super Admin'
          AND zone_id IS NULL
    )
    BEGIN
        RETURN -3;
    END;

    IF EXISTS (SELECT 1 FROM Zone WHERE zone_name = @zone_name)
    BEGIN
        RETURN -2;
    END;

    INSERT INTO Zone (zone_name, delivery_fee)
    VALUES (@zone_name, @delivery_fee);

    RETURN 0;
END;
GO

-- Student 4: Youssef Elbeltagy (64-12228)
CREATE PROCEDURE Update_Zone_Fee
    @zone_id INT,
    @new_fee DECIMAL(10,2),
    @super_admin_id INT
AS
BEGIN
    IF @zone_id IS NULL OR @new_fee IS NULL OR @new_fee < 0
    BEGIN
        RETURN -1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Admin
        WHERE admin_id = @super_admin_id
          AND role = 'Super Admin'
          AND zone_id IS NULL
    )
    BEGIN
        RETURN -3;
    END;

    IF NOT EXISTS (SELECT 1 FROM Zone WHERE zone_id = @zone_id)
    BEGIN
        RETURN -1;
    END;

    UPDATE Zone
    SET delivery_fee = @new_fee
    WHERE zone_id = @zone_id;

    RETURN 0;
END;
GO

-- Student 1: Hamza Sallam (64-5469)
create procedure Assign_Admin_Zone(@admin_id int, @zone_id int, @super_admin_id int)
as begin
    if not exists(select 1 from Admin where admin_id=@super_admin_id and role = 'Super Admin')
        return -3;
    if not exists(select 1 from Admin where admin_id=@admin_id and role = 'Zone Admin')
        return -1;
    if not exists(select 1 from Zone where zone_id=@zone_id)
        return -1;
    update Admin set zone_id = @zone_id where admin_id = @admin_id;
    return 0;
end;
GO

-- Student 1: Hamza Sallam (64-5469)
create procedure Issue_Voucher(@customer_id int, @promo_code varchar(30), @is_percentage bit, @amount decimal(10,2),
@expiry_date date, @admin_id int)
as begin
    if not exists(select 1 from Admin where admin_id = @admin_id)
        return -3;

    if @promo_code is null or @promo_code = '' or @is_percentage is null or @amount is null or @amount <= 0
       or @expiry_date is null or @expiry_date < cast(getdate() as date)
        return -1;
    if @is_percentage = 1 and (@amount < 1 or @amount > 100)
        return -1;

    if exists(select 1 from Users where user_id = @customer_id and account_status = 'Blacklisted')
        return -3;

    if exists(select 1 from Voucher where promo_code = @promo_code)
        return -2;

    insert into Voucher (promo_code, is_percentage, amount, expiry_date, customer_id)
    values (@promo_code, @is_percentage, @amount, @expiry_date, @customer_id);
    return 0;
end;
GO

--Student 1: Hamza Sallam (64-5469) (Helper function)
create function dbo.Cancellable_Orders(@customer_id int)
returns table as return(select o.order_id from orders o
inner join cart c on c.cart_id = o.cart_id where
c.customer_id = @customer_id and o.status <> 'Cancelled' and not exists(
    select 1 from suborder s where s.order_id = o.order_id and (s.status = 'Picked Up' or s.status = 'Delivered')
));
GO

--Student 1: Hamza Sallam (64-5469)
create procedure Blacklist_Customer(@customer_id int, @admin_id int, @reason varchar(255))
as begin
    declare @refund decimal(10,2);
    if @reason is null or @reason = ''
        return -1;
    if not exists(select 1 from admin a where a.admin_id = @admin_id and (a.role = 'Super Admin' or (a.role = 'Zone Admin' and a.zone_id in (select ad.zone_id from Address ad where ad.customer_id=@customer_id))))
        return -3;
    if exists(select 1 from Users where user_id = @customer_id and account_status = 'Blacklisted')
        return -4;
    begin try
        begin transaction;
        update Users set account_status = 'Blacklisted' where user_id = @customer_id;
        insert into Blacklist (customer_id, admin_id, reason) values (@customer_id, @admin_id, @reason);
        select @refund = sum(p.amount - p.refunded_amount) from payment p
        where p.method <> 'Cash' and p.order_id in (select order_id from dbo.Cancellable_Orders(@customer_id));
        if @refund is not null
            update Customer set wallet_balance=wallet_balance+ @refund where customer_id=@customer_id;
        update payment set refunded_amount=amount where order_id in (select order_id from dbo.Cancellable_Orders(@customer_id));
        update voucher set status='Unused' where voucher_id in (select o.voucher_id from orders o where o.order_id in (select order_id from dbo.Cancellable_Orders(@customer_id)));
        update orders set voucher_id=null where order_id in (select order_id from dbo.Cancellable_Orders(@customer_id));
        update suborder set status='Cancelled' where order_id in (select order_id from dbo.Cancellable_Orders(@customer_id));
        update orders set status='Cancelled' where order_id in (select order_id from dbo.Cancellable_Orders(@customer_id));
        delete from voucher where customer_id=@customer_id and status='Unused';
        commit transaction;
    end try
    begin catch
        rollback transaction;
        return -1;
    end catch;
    return 0;
end;
GO

--Student 1: Hamza Sallam (64-5469)
create procedure Lift_Customer_Blacklist(@customer_id int, @admin_id int)
as begin
    if not exists(select 1 from Blacklist where customer_id = @customer_id)
        return -4;
    if not exists(select 1 from Blacklist where customer_id = @customer_id and admin_id = @admin_id)
        return -3;
    
    begin try
    begin transaction;
        update Users set account_status = 'Active' where user_id = @customer_id;
        delete from Blacklist where customer_id=@customer_id;
    commit transaction;
    end try
    begin catch
        rollback transaction;
        return -1;
    end catch;
    return 0;
end;
GO

-- Student 4: Youssef Elbeltagy (64-12228)
CREATE FUNCTION ZoneOrderReport
(
    @zone_id INT,
    @from_date DATE,
    @to_date DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        Z.zone_id,
        Z.zone_name,
        COUNT(O.order_id) AS number_of_orders,
        CAST(AVG(O.total_amount) AS DECIMAL(10,2)) AS avg_order_total,
        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM Orders O2
                INNER JOIN SubOrder S ON S.order_id = O2.order_id
                WHERE O2.zone_id = Z.zone_id
                  AND CAST(O2.order_date AS DATE) BETWEEN @from_date AND @to_date
                  AND S.status <> 'Cancelled'
            )
            THEN
            (
                SELECT CAST(SUM(S.total_price * 0.10) AS DECIMAL(10,2))
                FROM Orders O2
                INNER JOIN SubOrder S ON S.order_id = O2.order_id
                WHERE O2.zone_id = Z.zone_id
                  AND CAST(O2.order_date AS DATE) BETWEEN @from_date AND @to_date
                  AND S.status <> 'Cancelled'
            )
            ELSE 0
        END AS platform_commission
    FROM Zone Z
    LEFT JOIN Orders O
        ON O.zone_id = Z.zone_id
       AND O.status <> 'Cancelled'
       AND CAST(O.order_date AS DATE) BETWEEN @from_date AND @to_date
    WHERE Z.zone_id = @zone_id
      AND @from_date <= @to_date
    GROUP BY Z.zone_id, Z.zone_name
);
GO

-- Student 4: Youssef Elbeltagy (64-12228)
CREATE FUNCTION Daily_Revenue_Report
(
    @report_date DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        Z.zone_name,
        CASE WHEN R.business_id IS NULL THEN 'Pharmacy' ELSE 'Restaurant' END AS business_type,
        COUNT(S.suborder_id) AS number_of_suborders,
        SUM(S.total_price) AS gross_sales,
        SUM(S.delivery_fee) AS delivery_fees,
        CAST(SUM(S.total_price * 0.10) AS DECIMAL(10,2)) AS platform_commission
    FROM Orders O
    INNER JOIN SubOrder S ON S.order_id = O.order_id
    INNER JOIN Business B ON B.business_id = S.business_id
    INNER JOIN Zone Z ON Z.zone_id = O.zone_id
    LEFT JOIN Restaurant R ON R.business_id = B.business_id
    WHERE CAST(O.order_date AS DATE) = @report_date
      AND S.status <> 'Cancelled'
    GROUP BY
        Z.zone_name,
        CASE WHEN R.business_id IS NULL THEN 'Pharmacy' ELSE 'Restaurant' END
);
GO

-- Student 2: Karim Salah (64-13699)
CREATE PROCEDURE Register_Business
    @partner_id INT,
    @name VARCHAR(100),
    @description VARCHAR(255),
    @link_website VARCHAR(255),
    @zone_id INT,
    @opening_hour TIME,
    @closing_hour TIME,
    @expected_delivery_time INT,
    @phone CHAR(11),
    @business_type VARCHAR(20),
    @cuisine_type VARCHAR(50),
    @food_category VARCHAR(50),
    @pharmacy_type VARCHAR(50)
AS
BEGIN
    DECLARE @business_id INT;

    IF @name IS NULL OR @name = ''
       OR @opening_hour IS NULL OR @closing_hour IS NULL
       OR @expected_delivery_time IS NULL OR @expected_delivery_time <= 0
       OR @phone IS NULL OR LEN(@phone) <> 11 OR @phone LIKE '%[^0-9]%'
       OR @business_type IS NULL OR @business_type NOT IN ('Restaurant', 'Pharmacy')
        RETURN -1;

    IF @business_type = 'Restaurant'
       AND (@cuisine_type IS NULL OR @cuisine_type = '' OR @food_category IS NULL OR @food_category = '')
        RETURN -1;

    IF @business_type = 'Pharmacy' AND (@pharmacy_type IS NULL OR @pharmacy_type = '')
        RETURN -1;

    IF NOT EXISTS (SELECT 1 FROM Zone WHERE zone_id = @zone_id)
        RETURN -1;

    IF NOT EXISTS (SELECT 1 FROM Partner WHERE partner_id = @partner_id)
        RETURN -3;

    IF EXISTS (SELECT 1 FROM Business WHERE partner_id = @partner_id AND status <> 'Rejected')
        RETURN -2;

    SELECT @business_id = business_id FROM Business WHERE partner_id = @partner_id;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @business_id IS NULL
        BEGIN
            INSERT INTO Business (name, description, link_website, opening_hour, closing_hour,
                                  expected_delivery_time, partner_id, zone_id)
            VALUES (@name, @description, @link_website, @opening_hour, @closing_hour,
                    @expected_delivery_time, @partner_id, @zone_id);

            SELECT @business_id = business_id FROM Business WHERE partner_id = @partner_id;
        END
        ELSE
        BEGIN
            UPDATE Business
            SET name = @name,
                description = @description,
                link_website = @link_website,
                opening_hour = @opening_hour,
                closing_hour = @closing_hour,
                expected_delivery_time = @expected_delivery_time,
                status = 'Pending',
                suspension_reason = NULL,
                zone_id = @zone_id
            WHERE business_id = @business_id;

            DELETE FROM Business_Phone WHERE business_id = @business_id;
            DELETE FROM Restaurant WHERE business_id = @business_id;
            DELETE FROM Pharmacy WHERE business_id = @business_id;
        END;

        INSERT INTO Business_Phone (business_id, phone)
        VALUES (@business_id, @phone);

        IF @business_type = 'Restaurant'
            INSERT INTO Restaurant (business_id, cuisine_type, food_category)
            VALUES (@business_id, @cuisine_type, @food_category);
        ELSE
            INSERT INTO Pharmacy (business_id, pharmacy_type)
            VALUES (@business_id, @pharmacy_type);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN -1;
    END CATCH;

    RETURN 0;
END;
GO

-- Student 2: Karim Salah (64-13699)
CREATE PROCEDURE Update_Business_Info
    @business_id INT,
    @opening_hour TIME,
    @closing_hour TIME,
    @phone CHAR(11),
    @link_website VARCHAR(255)
AS
BEGIN
    IF @opening_hour IS NULL OR @closing_hour IS NULL
        RETURN -1;

    IF @phone IS NOT NULL AND (LEN(@phone) <> 11 OR @phone LIKE '%[^0-9]%')
        RETURN -1;

    IF EXISTS (SELECT 1 FROM Business_Phone WHERE business_id = @business_id AND phone = @phone)
        RETURN -2;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Business
        SET opening_hour = @opening_hour,
            closing_hour = @closing_hour,
            link_website = @link_website
        WHERE business_id = @business_id;

        IF @phone IS NOT NULL
            INSERT INTO Business_Phone (business_id, phone)
            VALUES (@business_id, @phone);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN -1;
    END CATCH;

    RETURN 0;
END;
GO

-- Student 2: Karim Salah (64-13699)
CREATE PROCEDURE Upsert_Product
    @business_id INT,
    @product_id INT,
    @name VARCHAR(100),
    @description VARCHAR(255),
    @category VARCHAR(50),
    @price DECIMAL(10,2),
    @is_available BIT
AS
BEGIN
    IF @name IS NULL OR @name = ''
       OR @category IS NULL OR @category = ''
       OR @price IS NULL OR @price <= 0
       OR @is_available IS NULL
        RETURN -1;

    IF EXISTS (SELECT 1 FROM Business WHERE business_id = @business_id AND status = 'Suspended')
        RETURN -4;

    IF @product_id IS NULL
    BEGIN
        INSERT INTO Product (name, description, category, price, is_available, business_id)
        VALUES (@name, @description, @category, @price, @is_available, @business_id);
        RETURN 0;
    END;

    IF NOT EXISTS (SELECT 1 FROM Product WHERE product_id = @product_id AND business_id = @business_id)
        RETURN -3;

    IF EXISTS (SELECT 1 FROM Product WHERE product_id = @product_id AND discount_amount > 0.5 * @price)
        RETURN -1;

    UPDATE Product
    SET name = @name,
        description = @description,
        category = @category,
        price = @price,
        is_available = @is_available
    WHERE product_id = @product_id;

    RETURN 0;
END;
GO

-- Student 2: Karim Salah (64-13699)
CREATE PROCEDURE Toggle_Product_Status
    @product_id INT,
    @is_available BIT
AS
BEGIN
    IF @is_available IS NULL
        RETURN -1;

    IF @is_available = 1 AND EXISTS
    (
        SELECT 1
        FROM Product P
        INNER JOIN Business B ON B.business_id = P.business_id
        WHERE P.product_id = @product_id AND B.status = 'Suspended'
    )
        RETURN -4;

    UPDATE Product SET is_available = @is_available WHERE product_id = @product_id;

    RETURN 0;
END;
GO

-- Student 2: Karim Salah (64-13699)
CREATE PROCEDURE Set_Product_Promotion
    @product_id INT,
    @discount_amount DECIMAL(10,2)
AS
BEGIN
    IF @discount_amount IS NULL OR @discount_amount < 0
        RETURN -1;

    IF EXISTS (SELECT 1 FROM Product WHERE product_id = @product_id AND @discount_amount > 0.5 * price)
        RETURN -1;

    UPDATE Product SET discount_amount = @discount_amount WHERE product_id = @product_id;

    RETURN 0;
END;
GO

-- Student 2: Karim Salah (64-13699)
CREATE FUNCTION dbo.BusinessSalesReport (@business_id INT, @from_date DATE, @to_date DATE)
RETURNS TABLE
AS
RETURN
(
    SELECT
        P.product_id,
        P.name AS product_name,
        SUM(CI.quantity) AS units_sold,
        CAST(SUM(CI.quantity * CI.unit_price) AS DECIMAL(10,2)) AS revenue_per_product
    FROM CartItem CI
    INNER JOIN Product P ON P.product_id = CI.product_id
    INNER JOIN Orders O ON O.cart_id = CI.cart_id
    INNER JOIN SubOrder S ON S.order_id = O.order_id AND S.business_id = P.business_id
    WHERE P.business_id = @business_id
      AND S.status <> 'Cancelled'
      AND CAST(O.order_date AS DATE) BETWEEN @from_date AND @to_date
    GROUP BY P.product_id, P.name
);
GO

-- Student 3: Omar Mohamed (64-7954)
CREATE PROCEDURE Add_Customer_Address
    @customer_id INT,
    @description VARCHAR(150),
    @zone_id INT
AS
BEGIN
    IF @description IS NULL OR @description = ''
        RETURN -1;

    IF NOT EXISTS (SELECT 1 FROM Zone WHERE zone_id = @zone_id)
        RETURN -1;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Address SET is_active = 0 WHERE customer_id = @customer_id;

        INSERT INTO Address (description, is_active, customer_id, zone_id)
        VALUES (@description, 1, @customer_id, @zone_id);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN -1;
    END CATCH;

    RETURN 0;
END;
GO

-- Student 3: Omar Mohamed (64-7954)
CREATE PROCEDURE Update_Delete_Customer_Address
    @customer_id INT,
    @address_id INT,
    @description VARCHAR(150),
    @zone_id INT,
    @action VARCHAR(20)
AS
BEGIN
    IF @action IS NULL OR @action NOT IN ('Update', 'Delete')
        RETURN -1;

    IF NOT EXISTS (SELECT 1 FROM Address WHERE address_id = @address_id AND customer_id = @customer_id)
        RETURN -3;

    IF EXISTS
    (
        SELECT 1
        FROM Orders O
        INNER JOIN Cart C ON C.cart_id = O.cart_id
        WHERE C.address_id = @address_id AND O.status IN ('Placed', 'In Progress')
    )
        RETURN -4;

    IF @action = 'Update'
    BEGIN
        IF @description IS NULL OR @description = ''
            RETURN -1;

        IF NOT EXISTS (SELECT 1 FROM Zone WHERE zone_id = @zone_id)
            RETURN -1;

        UPDATE Address
        SET description = @description,
            zone_id = @zone_id
        WHERE address_id = @address_id;

        RETURN 0;
    END;

    IF EXISTS (SELECT 1 FROM Cart WHERE address_id = @address_id)
        RETURN -4;

    IF EXISTS (SELECT 1 FROM Address WHERE address_id = @address_id AND is_active = 1)
        RETURN -4;

    DELETE FROM Address WHERE address_id = @address_id;

    RETURN 0;
END;
GO

-- Student 3: Omar Mohamed (64-7954)
CREATE PROCEDURE Change_Active_Address
    @customer_id INT,
    @new_address_id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Address WHERE address_id = @new_address_id AND customer_id = @customer_id)
        RETURN -3;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Address SET is_active = 0 WHERE customer_id = @customer_id;
        UPDATE Address SET is_active = 1 WHERE address_id = @new_address_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN -1;
    END CATCH;

    RETURN 0;
END;
GO

-- Student 3: Omar Mohamed (64-7954)
CREATE PROCEDURE Add_Card
    @customer_id INT,
    @card_no CHAR(16),
    @card_holder_name VARCHAR(100),
    @expiration_date DATE
AS
BEGIN
    IF @card_no IS NULL OR LEN(@card_no) <> 16 OR @card_no LIKE '%[^0-9]%'
       OR @card_holder_name IS NULL OR @card_holder_name = ''
       OR @expiration_date IS NULL OR @expiration_date < CAST(GETDATE() AS DATE)
        RETURN -1;

    IF EXISTS (SELECT 1 FROM Card WHERE customer_id = @customer_id AND card_no = @card_no)
        RETURN -2;

    INSERT INTO Card (card_no, card_holder_name, expiration_date, customer_id)
    VALUES (@card_no, @card_holder_name, @expiration_date, @customer_id);

    RETURN 0;
END;
GO

-- Student 3: Omar Mohamed (64-7954)
CREATE PROCEDURE Create_Cart
    @customer_id INT
AS
BEGIN
    DECLARE @address_id INT;

    IF EXISTS (SELECT 1 FROM Users WHERE user_id = @customer_id AND account_status = 'Blacklisted')
        RETURN -3;

    SELECT @address_id = address_id
    FROM Address
    WHERE customer_id = @customer_id AND is_active = 1;

    IF @address_id IS NULL
        RETURN -1;

    IF EXISTS (SELECT 1 FROM Cart WHERE address_id = @address_id AND status = 'Active')
        RETURN -2;

    INSERT INTO Cart (customer_id, address_id)
    VALUES (@customer_id, @address_id);

    RETURN 0;
END;
GO

-- Student 3: Omar Mohamed (64-7954)
CREATE PROCEDURE Add_To_Cart
    @cart_id INT,
    @product_id INT,
    @quantity INT,
    @notes VARCHAR(255)
AS
BEGIN
    DECLARE @old_quantity INT;

    IF @quantity IS NULL OR @quantity < 1
        RETURN -1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cart C
        INNER JOIN Address A ON A.address_id = C.address_id
        WHERE C.cart_id = @cart_id AND C.status = 'Active' AND A.is_active = 1
    )
        RETURN -4;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Product P
        INNER JOIN Business B ON B.business_id = P.business_id
        WHERE P.product_id = @product_id AND P.is_available = 1 AND B.status = 'Active'
    )
        RETURN -4;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cart C
        INNER JOIN Address A ON A.address_id = C.address_id
        INNER JOIN Business B ON B.zone_id = A.zone_id
        INNER JOIN Product P ON P.business_id = B.business_id
        WHERE C.cart_id = @cart_id AND P.product_id = @product_id
    )
        RETURN -5;

    SELECT @old_quantity = quantity
    FROM CartItem
    WHERE cart_id = @cart_id AND product_id = @product_id;

    IF @old_quantity IS NULL
        SET @old_quantity = 0;

    IF @old_quantity + @quantity > 10
        RETURN -6;

    IF @old_quantity = 0
        INSERT INTO CartItem (cart_id, product_id, quantity, notes)
        VALUES (@cart_id, @product_id, @quantity, @notes);
    ELSE
        UPDATE CartItem
        SET quantity = quantity + @quantity,
            notes = CASE WHEN @notes IS NULL THEN notes ELSE @notes END
        WHERE cart_id = @cart_id AND product_id = @product_id;

    RETURN 0;
END;
GO

-- Student 3: Omar Mohamed (64-7954)
CREATE PROCEDURE Remove_From_Cart
    @cart_id INT,
    @product_id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Cart WHERE cart_id = @cart_id AND status = 'Active')
        RETURN -4;

    IF NOT EXISTS (SELECT 1 FROM CartItem WHERE cart_id = @cart_id AND product_id = @product_id)
        RETURN -9;

    DELETE FROM CartItem WHERE cart_id = @cart_id AND product_id = @product_id;

    RETURN 0;
END;
GO

-- Student 3: Omar Mohamed (64-7954)
CREATE FUNCTION dbo.Calculate_Voucher_Discount (@voucher_id INT, @order_subtotal DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @is_percentage BIT;
    DECLARE @amount DECIMAL(10,2);
    DECLARE @discount DECIMAL(10,2);

    IF @order_subtotal IS NULL OR @order_subtotal < 0
        RETURN -1;

    SELECT @is_percentage = is_percentage, @amount = amount
    FROM Voucher
    WHERE voucher_id = @voucher_id
      AND status = 'Unused'
      AND expiry_date >= CAST(GETDATE() AS DATE);

    IF @amount IS NULL
        RETURN 0;

    IF @is_percentage = 1
        SET @discount = @order_subtotal * @amount / 100;
    ELSE
        SET @discount = @amount;

    IF @discount > @order_subtotal
        SET @discount = @order_subtotal;

    RETURN @discount;
END;
GO

-- Student 3: Omar Mohamed (64-7954)
CREATE PROCEDURE Checkout_Cart
    @cart_id INT,
    @voucher_id INT,
    @payment_method VARCHAR(20),
    @card_id INT
AS
BEGIN
    DECLARE @customer_id INT;
    DECLARE @address_id INT;
    DECLARE @zone_id INT;
    DECLARE @delivery_fee DECIMAL(10,2);
    DECLARE @now TIME;
    DECLARE @subtotal DECIMAL(10,2);
    DECLARE @business_count INT;
    DECLARE @discount DECIMAL(10,2);
    DECLARE @total DECIMAL(10,2);
    DECLARE @order_id INT;
    DECLARE @suborder_id INT;
    DECLARE @rider_id INT;

    IF @payment_method IS NULL OR @payment_method NOT IN ('Cash', 'Card', 'Wallet')
        RETURN -1;

    IF NOT EXISTS (SELECT 1 FROM Cart WHERE cart_id = @cart_id AND status = 'Active')
        RETURN -4;

    IF NOT EXISTS (SELECT 1 FROM CartItem WHERE cart_id = @cart_id)
        RETURN -9;

    SELECT @customer_id = C.customer_id, @address_id = C.address_id, @zone_id = A.zone_id
    FROM Cart C
    INNER JOIN Address A ON A.address_id = C.address_id
    WHERE C.cart_id = @cart_id;

    IF EXISTS (SELECT 1 FROM Users WHERE user_id = @customer_id AND account_status = 'Blacklisted')
        RETURN -3;

    IF NOT EXISTS (SELECT 1 FROM Address WHERE address_id = @address_id AND is_active = 1)
        RETURN -4;

    -- every product must be available and its business Active (BR-5)
    IF EXISTS
    (
        SELECT 1
        FROM CartItem CI
        INNER JOIN Product P ON P.product_id = CI.product_id
        INNER JOIN Business B ON B.business_id = P.business_id
        WHERE CI.cart_id = @cart_id AND (P.is_available = 0 OR B.status <> 'Active')
    )
        RETURN -4;

    -- every business must be in the zone of the active address (BR-8)
    IF EXISTS
    (
        SELECT 1
        FROM CartItem CI
        INNER JOIN Product P ON P.product_id = CI.product_id
        INNER JOIN Business B ON B.business_id = P.business_id
        WHERE CI.cart_id = @cart_id AND B.zone_id <> @zone_id
    )
        RETURN -5;

    -- every business must be open now (BR-6)
    SET @now = CAST(GETDATE() AS TIME);

    IF EXISTS
    (
        SELECT 1
        FROM CartItem CI
        INNER JOIN Product P ON P.product_id = CI.product_id
        INNER JOIN Business B ON B.business_id = P.business_id
        WHERE CI.cart_id = @cart_id
          AND NOT (B.opening_hour = B.closing_hour
                   OR (B.opening_hour < B.closing_hour AND @now >= B.opening_hour AND @now < B.closing_hour)
                   OR (B.opening_hour > B.closing_hour AND (@now >= B.opening_hour OR @now < B.closing_hour)))
    )
        RETURN -4;

    -- the voucher must be the customer's, Unused and not expired (BR-13)
    IF @voucher_id IS NOT NULL AND NOT EXISTS
    (
        SELECT 1
        FROM Voucher
        WHERE voucher_id = @voucher_id
          AND customer_id = @customer_id
          AND status = 'Unused'
          AND expiry_date >= CAST(GETDATE() AS DATE)
    )
        RETURN -1;

    -- prices (BR-9)
    SELECT @subtotal = SUM(CI.quantity * (P.price - P.discount_amount)),
           @business_count = COUNT(DISTINCT P.business_id)
    FROM CartItem CI
    INNER JOIN Product P ON P.product_id = CI.product_id
    WHERE CI.cart_id = @cart_id;

    SELECT @delivery_fee = delivery_fee FROM Zone WHERE zone_id = @zone_id;

    SET @discount = dbo.Calculate_Voucher_Discount(@voucher_id, @subtotal);
    SET @total = @subtotal + @business_count * @delivery_fee - @discount;

    -- payment (BR-10)
    IF @payment_method = 'Card' AND NOT EXISTS
    (
        SELECT 1
        FROM Card
        WHERE card_id = @card_id
          AND customer_id = @customer_id
          AND expiration_date >= CAST(GETDATE() AS DATE)
    )
        RETURN -7;

    IF @payment_method = 'Wallet'
       AND EXISTS (SELECT 1 FROM Customer WHERE customer_id = @customer_id AND wallet_balance < @total)
        RETURN -7;

    IF @payment_method <> 'Card'
        SET @card_id = NULL;

    -- the zone needs at least one available rider (BR-12)
    IF NOT EXISTS
    (
        SELECT 1
        FROM Rider R
        INNER JOIN Users U ON U.user_id = R.rider_id
        WHERE R.zone_id = @zone_id AND R.is_available = 1 AND U.account_status = 'Active'
    )
        RETURN -8;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- freeze the effective unit prices
        UPDATE CartItem
        SET unit_price = (SELECT P.price - P.discount_amount FROM Product P WHERE P.product_id = CartItem.product_id)
        WHERE cart_id = @cart_id;

        INSERT INTO Orders (order_date, status, discount_amount, total_amount, cart_id, zone_id, voucher_id)
        VALUES (GETDATE(), 'Placed', @discount, @total, @cart_id, @zone_id, @voucher_id);

        SELECT @order_id = order_id FROM Orders WHERE cart_id = @cart_id;

        -- one SubOrder per business
        INSERT INTO SubOrder (status, total_price, delivery_fee, order_id, business_id)
        SELECT 'Placed', SUM(CI.quantity * CI.unit_price), @delivery_fee, @order_id, P.business_id
        FROM CartItem CI
        INNER JOIN Product P ON P.product_id = CI.product_id
        WHERE CI.cart_id = @cart_id
        GROUP BY P.business_id;

        IF @voucher_id IS NOT NULL
            UPDATE Voucher SET status = 'Used' WHERE voucher_id = @voucher_id;

        -- one Delivery per SubOrder, each given to the least-busy rider at that moment (BR-12)
        SET @suborder_id = NULL;
        SELECT TOP 1 @suborder_id = suborder_id
        FROM SubOrder
        WHERE order_id = @order_id AND status = 'Placed'
        ORDER BY business_id;

        WHILE @suborder_id IS NOT NULL
        BEGIN
            SELECT TOP 1 @rider_id = R.rider_id
            FROM Rider R
            INNER JOIN Users U ON U.user_id = R.rider_id
            LEFT OUTER JOIN Delivery D ON D.rider_id = R.rider_id
            LEFT OUTER JOIN SubOrder S ON S.suborder_id = D.suborder_id AND S.status IN ('Assigned', 'Picked Up')
            WHERE R.zone_id = @zone_id AND R.is_available = 1 AND U.account_status = 'Active'
            GROUP BY R.rider_id
            ORDER BY COUNT(S.suborder_id), R.rider_id;

            INSERT INTO Delivery (assigned_at, suborder_id, rider_id)
            VALUES (GETDATE(), @suborder_id, @rider_id);

            UPDATE SubOrder SET status = 'Assigned' WHERE suborder_id = @suborder_id;

            SET @suborder_id = NULL;
            SELECT TOP 1 @suborder_id = suborder_id
            FROM SubOrder
            WHERE order_id = @order_id AND status = 'Placed'
            ORDER BY business_id;
        END;

        INSERT INTO Payment (amount, currency, method, transaction_date, refunded_amount, order_id, card_id)
        VALUES (@total, 'EGP', @payment_method, GETDATE(), 0, @order_id, @card_id);

        IF @payment_method = 'Wallet'
            UPDATE Customer SET wallet_balance = wallet_balance - @total WHERE customer_id = @customer_id;

        UPDATE Cart SET status = 'Checked Out' WHERE cart_id = @cart_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN -1;
    END CATCH;

    RETURN 0;
END;
GO

-- Student 3: Omar Mohamed (64-7954)
CREATE PROCEDURE Cancel_Order
    @order_id INT
AS
BEGIN
    DECLARE @customer_id INT;
    DECLARE @refund DECIMAL(10,2);
    DECLARE @method VARCHAR(20);

    IF EXISTS (SELECT 1 FROM Orders WHERE order_id = @order_id AND status = 'Cancelled')
        RETURN -4;

    IF EXISTS (SELECT 1 FROM SubOrder WHERE order_id = @order_id AND status IN ('Picked Up', 'Delivered'))
        RETURN -4;

    SELECT @customer_id = C.customer_id
    FROM Orders O
    INNER JOIN Cart C ON C.cart_id = O.cart_id
    WHERE O.order_id = @order_id;

    SELECT @refund = amount - refunded_amount, @method = method
    FROM Payment
    WHERE order_id = @order_id;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- refund the remaining amount (BR-14)
        IF @refund IS NOT NULL
        BEGIN
            UPDATE Payment SET refunded_amount = amount WHERE order_id = @order_id;

            IF @method <> 'Cash'
                UPDATE Customer SET wallet_balance = wallet_balance + @refund WHERE customer_id = @customer_id;
        END;

        UPDATE Voucher
        SET status = 'Unused'
        WHERE voucher_id IN (SELECT voucher_id FROM Orders WHERE order_id = @order_id);

        UPDATE SubOrder SET status = 'Cancelled' WHERE order_id = @order_id;

        UPDATE Orders
        SET status = 'Cancelled',
            voucher_id = NULL
        WHERE order_id = @order_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN -1;
    END CATCH;

    RETURN 0;
END;
GO

-- Student 3: Omar Mohamed (64-7954)
CREATE PROCEDURE Reorder
    @order_id INT,
    @address_id INT
AS
BEGIN
    DECLARE @customer_id INT;
    DECLARE @old_cart_id INT;
    DECLARE @order_zone INT;
    DECLARE @new_cart_id INT;

    SELECT @customer_id = C.customer_id, @old_cart_id = C.cart_id, @order_zone = O.zone_id
    FROM Orders O
    INNER JOIN Cart C ON C.cart_id = O.cart_id
    WHERE O.order_id = @order_id;

    IF EXISTS (SELECT 1 FROM Users WHERE user_id = @customer_id AND account_status = 'Blacklisted')
        RETURN -3;

    IF NOT EXISTS (SELECT 1 FROM Address WHERE address_id = @address_id AND customer_id = @customer_id)
        RETURN -3;

    IF NOT EXISTS (SELECT 1 FROM Address WHERE address_id = @address_id AND zone_id = @order_zone)
        RETURN -5;

    IF EXISTS (SELECT 1 FROM Cart WHERE address_id = @address_id AND status = 'Active')
        RETURN -2;

    IF NOT EXISTS
    (
        SELECT 1
        FROM CartItem CI
        INNER JOIN Product P ON P.product_id = CI.product_id
        INNER JOIN Business B ON B.business_id = P.business_id
        WHERE CI.cart_id = @old_cart_id AND P.is_available = 1 AND B.status = 'Active'
    )
        RETURN -9;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Address SET is_active = 0 WHERE customer_id = @customer_id;
        UPDATE Address SET is_active = 1 WHERE address_id = @address_id;

        INSERT INTO Cart (customer_id, address_id)
        VALUES (@customer_id, @address_id);

        SELECT @new_cart_id = cart_id
        FROM Cart
        WHERE address_id = @address_id AND status = 'Active';

        -- copy only the products that can still be ordered
        INSERT INTO CartItem (cart_id, product_id, quantity, notes)
        SELECT @new_cart_id, CI.product_id, CI.quantity, CI.notes
        FROM CartItem CI
        INNER JOIN Product P ON P.product_id = CI.product_id
        INNER JOIN Business B ON B.business_id = P.business_id
        WHERE CI.cart_id = @old_cart_id AND P.is_available = 1 AND B.status = 'Active';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN -1;
    END CATCH;

    RETURN 0;
END;
GO

-- Student 3: Omar Mohamed (64-7954)
CREATE FUNCTION dbo.My_Order_History (@customer_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
        O.order_id,
        O.order_date,
        Z.zone_name,
        O.status,
        COUNT(S.suborder_id) AS number_of_suborders,
        O.discount_amount,
        O.total_amount,
        P.method AS payment_method,
        P.refunded_amount
    FROM Orders O
    INNER JOIN Cart C ON C.cart_id = O.cart_id
    INNER JOIN Zone Z ON Z.zone_id = O.zone_id
    LEFT OUTER JOIN SubOrder S ON S.order_id = O.order_id
    LEFT OUTER JOIN Payment P ON P.order_id = O.order_id
    WHERE C.customer_id = @customer_id
    GROUP BY O.order_id, O.order_date, Z.zone_name, O.status, O.discount_amount,
             O.total_amount, P.method, P.refunded_amount
);
GO

-- Student 2: Karim Salah (64-13699)
CREATE PROCEDURE Toggle_Favorite
    @customer_id INT,
    @item_id INT,
    @item_type VARCHAR(20)
AS
BEGIN
    IF @item_id IS NULL OR @item_type IS NULL OR @item_type NOT IN ('Business', 'Product')
        RETURN -1;

    IF @item_type = 'Business'
    BEGIN
        IF EXISTS (SELECT 1 FROM Favorite_Business WHERE customer_id = @customer_id AND business_id = @item_id)
        BEGIN
            DELETE FROM Favorite_Business WHERE customer_id = @customer_id AND business_id = @item_id;
            RETURN 0;
        END;

        IF NOT EXISTS (SELECT 1 FROM Business WHERE business_id = @item_id AND status = 'Active')
            RETURN -4;

        INSERT INTO Favorite_Business (customer_id, business_id)
        VALUES (@customer_id, @item_id);
        RETURN 0;
    END;

    IF EXISTS (SELECT 1 FROM Favorite_Product WHERE customer_id = @customer_id AND product_id = @item_id)
    BEGIN
        DELETE FROM Favorite_Product WHERE customer_id = @customer_id AND product_id = @item_id;
        RETURN 0;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Product P
        INNER JOIN Business B ON B.business_id = P.business_id
        WHERE P.product_id = @item_id AND P.is_available = 1 AND B.status = 'Active'
    )
        RETURN -4;

    INSERT INTO Favorite_Product (customer_id, product_id)
    VALUES (@customer_id, @item_id);
    RETURN 0;
END;
GO

-- Student 2: Karim Salah (64-13699)
CREATE FUNCTION dbo.My_Favorites (@customer_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
        P.product_id,
        P.name AS product_name,
        B.name AS business_name,
        CAST(CASE WHEN P.is_available = 1 AND B.status = 'Active' THEN 1 ELSE 0 END AS BIT) AS is_orderable
    FROM Favorite_Product F
    INNER JOIN Product P ON P.product_id = F.product_id
    INNER JOIN Business B ON B.business_id = P.business_id
    WHERE F.customer_id = @customer_id
);
GO

-- Student 2: Karim Salah (64-13699) (Helper view: every item each customer has ordered)
CREATE VIEW Customer_Ordered_Items
AS
SELECT C.customer_id, P.product_id, P.category, CI.quantity
FROM CartItem CI
INNER JOIN Cart C ON C.cart_id = CI.cart_id
INNER JOIN Orders O ON O.cart_id = C.cart_id
INNER JOIN Product P ON P.product_id = CI.product_id;
GO

-- Student 2: Karim Salah (64-13699)
CREATE FUNCTION dbo.Recommended_Products (@customer_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 10
        P.product_id,
        P.name AS product_name,
        B.name AS business_name,
        P.category,
        CAST(P.price - P.discount_amount AS DECIMAL(10,2)) AS final_price
    FROM Product P
    INNER JOIN Business B ON B.business_id = P.business_id
    INNER JOIN Address A ON A.zone_id = B.zone_id
    INNER JOIN Customer_Ordered_Items COI ON COI.category = P.category
    WHERE A.customer_id = @customer_id
      AND A.is_active = 1
      AND B.status = 'Active'
      AND P.is_available = 1
      AND COI.customer_id = @customer_id
      AND P.product_id NOT IN (SELECT product_id FROM Customer_Ordered_Items WHERE customer_id = @customer_id)
    GROUP BY P.product_id, P.name, B.name, P.category, P.price, P.discount_amount
    ORDER BY SUM(COI.quantity) DESC, P.product_id
);
GO

-- Student 2: Karim Salah (64-13699)
CREATE FUNCTION dbo.Search_Platform (@customer_id INT, @keyword VARCHAR(100))
RETURNS TABLE
AS
RETURN
(
    SELECT
        B.business_id,
        B.name AS business_name,
        CASE
            WHEN B.name = @keyword THEN 1
            WHEN B.name LIKE @keyword + '%' THEN 2
            ELSE 3
        END AS priority
    FROM Business B
    INNER JOIN Address A ON A.zone_id = B.zone_id
    WHERE A.customer_id = @customer_id
      AND A.is_active = 1
      AND B.status = 'Active'
      AND @keyword <> ''
      AND B.name LIKE '%' + @keyword + '%'
);
GO

-- Student 2: Karim Salah (64-13699) (Helper view: average tracking_time of Delivered deliveries per zone)
CREATE VIEW Zone_Avg_Delivery_Time
AS
SELECT
    O.zone_id,
    CAST(AVG(CAST(D.tracking_time AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS avg_delivery_time
FROM Delivery D
INNER JOIN SubOrder S ON S.suborder_id = D.suborder_id
INNER JOIN Orders O ON O.order_id = S.order_id
WHERE S.status = 'Delivered'
GROUP BY O.zone_id;
GO

-- Student 2: Karim Salah (64-13699)
CREATE FUNCTION dbo.Nearby_Businesses_By_Category (@address_id INT, @product_category VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT
        B.business_id,
        B.name AS business_name,
        Z.zone_name,
        CAST(CASE WHEN B.zone_id = A.zone_id THEN 1 ELSE 0 END AS BIT) AS same_zone,
        V.avg_delivery_time AS zone_avg_delivery_time
    FROM Business B
    INNER JOIN Zone Z ON Z.zone_id = B.zone_id
    INNER JOIN Address A ON A.address_id = @address_id
    LEFT OUTER JOIN Zone_Avg_Delivery_Time V ON V.zone_id = B.zone_id
    WHERE B.status = 'Active'
      AND EXISTS
      (
          SELECT 1
          FROM Product P
          WHERE P.business_id = B.business_id
            AND P.category = @product_category
            AND P.is_available = 1
      )
);
GO
