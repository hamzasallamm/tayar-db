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
