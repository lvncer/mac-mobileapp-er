-- マクドナルドモバイルアプリ データベース作成スクリプト
-- 物理ER図に基づくテーブル定義

-- データベース作成
CREATE DATABASE IF NOT EXISTS mcdonald_mobile_app 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE mcdonald_mobile_app;

-- 1. 会員テーブル
CREATE TABLE MEMBERS (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    postal_code CHAR(7),
    gender CHAR(20),
    birth_date DATE,
    children_count INT DEFAULT 0,
    youngest_child_birth_date DATE,
    notification_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    two_factor_auth BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,

    INDEX idx_email (email),
    INDEX idx_postal_code (postal_code),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB COMMENT='会員情報';

-- 2. 店舗テーブル
CREATE TABLE STORES (
    store_id INT AUTO_INCREMENT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    capacity INT,
    parking_available BOOLEAN NOT NULL DEFAULT FALSE,
    mobile_order_available BOOLEAN NOT NULL DEFAULT TRUE,
    phone_number VARCHAR(20),
    services_json TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,

    INDEX idx_store_name (store_name),
    INDEX idx_mobile_order (mobile_order_available)
) ENGINE=InnoDB COMMENT='店舗情報';

-- 3. 店舗営業時間テーブル
CREATE TABLE STORE_HOURS (
    store_hour_id INT AUTO_INCREMENT PRIMARY KEY,
    store_id INT NOT NULL,
    service_type VARCHAR(20) NOT NULL,
    open_time TIME NOT NULL,
    close_time TIME NOT NULL,
    day_of_week VARCHAR(10) NOT NULL,
    
    FOREIGN KEY (store_id) REFERENCES STORES(store_id) ON DELETE CASCADE,
    INDEX idx_store_service (store_id, service_type),
    INDEX idx_day_of_week (day_of_week)
) ENGINE=InnoDB COMMENT='店舗営業時間';

-- 4. 住所テーブル
CREATE TABLE ADDRESSES (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    postal_code CHAR(7) NOT NULL,
    prefecture_city VARCHAR(100) NOT NULL,
    detailed_address VARCHAR(200) NOT NULL,
    building_type VARCHAR(50) NOT NULL,
    nameplate_name VARCHAR(100) NOT NULL,
    building_appearance VARCHAR(200),
    company_name VARCHAR(100),
    department_name VARCHAR(100),
    delivery_notes TEXT,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    
    FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id) ON DELETE CASCADE,
    INDEX idx_member_id (member_id),
    INDEX idx_postal_code (postal_code),
    INDEX idx_is_default (is_default)
) ENGINE=InnoDB COMMENT='配送先住所';

-- 5. 商品テーブル
CREATE TABLE ITEMS (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    description TEXT,
    base_price DECIMAL(8,2) NOT NULL,
    category VARCHAR(50) NOT NULL,
    image_url VARCHAR(255),
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    
    INDEX idx_item_name (item_name),
    INDEX idx_category (category),
    INDEX idx_is_available (is_available)
) ENGINE=InnoDB COMMENT='商品マスター';

-- 6. メニューテーブル
CREATE TABLE MENUS (
    menu_id INT AUTO_INCREMENT PRIMARY KEY,
    menu_name VARCHAR(100) NOT NULL,
    menu_type VARCHAR(20) NOT NULL,
    base_price DECIMAL(8,2) NOT NULL,
    sale_start_date DATE NOT NULL,
    sale_end_date DATE,
    time_period VARCHAR(20) NOT NULL,
    store_pickup_available BOOLEAN NOT NULL DEFAULT TRUE,
    delivery_available BOOLEAN NOT NULL DEFAULT TRUE,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    
    INDEX idx_menu_name (menu_name),
    INDEX idx_menu_type (menu_type),
    INDEX idx_sale_period (sale_start_date, sale_end_date),
    INDEX idx_time_period (time_period),
    INDEX idx_is_available (is_available)
) ENGINE=InnoDB COMMENT='メニューマスター';

-- 7. メニュー構成テーブル
CREATE TABLE MENU_ITEMS (
    menu_item_id INT AUTO_INCREMENT PRIMARY KEY,
    menu_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    is_replaceable BOOLEAN NOT NULL DEFAULT FALSE,
    replacement_category VARCHAR(50),
    additional_price DECIMAL(8,2) DEFAULT 0.00,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (menu_id) REFERENCES MENUS(menu_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES ITEMS(item_id) ON DELETE CASCADE,
    UNIQUE KEY uk_menu_item (menu_id, item_id),
    INDEX idx_menu_id (menu_id),
    INDEX idx_item_id (item_id)
) ENGINE=InnoDB COMMENT='メニュー構成';

-- 8. 商品バリエーションテーブル
CREATE TABLE ITEM_VARIATIONS (
    variation_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    variation_name VARCHAR(50) NOT NULL,
    price_difference DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (item_id) REFERENCES ITEMS(item_id) ON DELETE CASCADE,
    INDEX idx_item_id (item_id),
    INDEX idx_variation_name (variation_name),
    INDEX idx_is_available (is_available)
) ENGINE=InnoDB COMMENT='商品バリエーション';

-- 9. 店舗別価格加算テーブル
CREATE TABLE STORE_MENU_ADDITIONS (
    store_menu_addition_id INT AUTO_INCREMENT PRIMARY KEY,
    store_id INT NOT NULL,
    menu_id INT NOT NULL,
    price_addition DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    effective_from DATETIME NOT NULL,
    effective_until DATETIME,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (store_id) REFERENCES STORES(store_id) ON DELETE CASCADE,
    FOREIGN KEY (menu_id) REFERENCES MENUS(menu_id) ON DELETE CASCADE,
    UNIQUE KEY uk_store_menu_period (store_id, menu_id, effective_from),
    INDEX idx_store_id (store_id),
    INDEX idx_menu_id (menu_id),
    INDEX idx_effective_period (effective_from, effective_until),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB COMMENT='店舗別価格加算';

-- 10. クーポンテーブル
CREATE TABLE COUPONS (
    coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    coupon_code VARCHAR(50) NOT NULL UNIQUE,
    coupon_name VARCHAR(100) NOT NULL,
    max_order_quantity INT,
    expiry_date DATETIME NOT NULL,
    discount_amount DECIMAL(8,2),
    discount_percentage DECIMAL(5,2),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_coupon_code (coupon_code),
    INDEX idx_expiry_date (expiry_date),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB COMMENT='クーポンマスター';

-- 11. クーポン適用店舗テーブル
CREATE TABLE COUPON_STORES (
    coupon_store_id INT AUTO_INCREMENT PRIMARY KEY,
    coupon_id INT NOT NULL,
    store_id INT NOT NULL,
    
    FOREIGN KEY (coupon_id) REFERENCES COUPONS(coupon_id) ON DELETE CASCADE,
    FOREIGN KEY (store_id) REFERENCES STORES(store_id) ON DELETE CASCADE,
    UNIQUE KEY uk_coupon_store (coupon_id, store_id),
    INDEX idx_coupon_id (coupon_id),
    INDEX idx_store_id (store_id)
) ENGINE=InnoDB COMMENT='クーポン適用店舗';

-- 12. クーポン適用商品テーブル
CREATE TABLE COUPON_MENUS (
    coupon_menu_id INT AUTO_INCREMENT PRIMARY KEY,
    coupon_id INT NOT NULL,
    menu_id INT NOT NULL,
    item_id INT,
    
    FOREIGN KEY (coupon_id) REFERENCES COUPONS(coupon_id) ON DELETE CASCADE,
    FOREIGN KEY (menu_id) REFERENCES MENUS(menu_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES ITEMS(item_id) ON DELETE CASCADE,
    UNIQUE KEY uk_coupon_menu_item (coupon_id, menu_id, item_id),
    INDEX idx_coupon_id (coupon_id),
    INDEX idx_menu_id (menu_id),
    INDEX idx_item_id (item_id)
) ENGINE=InnoDB COMMENT='クーポン適用商品';

-- 13. お気に入り店舗テーブル
CREATE TABLE FAVORITE_STORES (
    favorite_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    store_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id) ON DELETE CASCADE,
    FOREIGN KEY (store_id) REFERENCES STORES(store_id) ON DELETE CASCADE,
    UNIQUE KEY uk_member_store (member_id, store_id),
    INDEX idx_member_id (member_id),
    INDEX idx_store_id (store_id)
) ENGINE=InnoDB COMMENT='お気に入り店舗';

-- 14. 注文テーブル
CREATE TABLE ORDERS (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    store_id INT NOT NULL,
    address_id INT,
    order_status VARCHAR(20) NOT NULL,
    delivery_method VARCHAR(20) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) NOT NULL,
    delivery_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL,
    order_date DATETIME NOT NULL,
    pickup_time DATETIME,
    delivery_time DATETIME,
    special_instructions TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id),
    FOREIGN KEY (store_id) REFERENCES STORES(store_id),
    FOREIGN KEY (address_id) REFERENCES ADDRESSES(address_id),
    INDEX idx_member_id (member_id),
    INDEX idx_store_id (store_id),
    INDEX idx_order_status (order_status),
    INDEX idx_order_date (order_date),
    INDEX idx_delivery_method (delivery_method)
) ENGINE=InnoDB COMMENT='注文';

-- 15. 注文詳細テーブル
CREATE TABLE ORDER_DETAILS (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    menu_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(8,2) NOT NULL,
    total_price DECIMAL(8,2) NOT NULL,
    unit_price_at_order DECIMAL(8,2) NOT NULL,
    standard_price DECIMAL(8,2) NOT NULL,
    price_adjustment DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    adjustment_reason VARCHAR(100),
    is_replacement BOOLEAN NOT NULL DEFAULT FALSE,
    customizations TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES ORDERS(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES ITEMS(item_id),
    FOREIGN KEY (menu_id) REFERENCES MENUS(menu_id),
    INDEX idx_order_id (order_id),
    INDEX idx_item_id (item_id),
    INDEX idx_menu_id (menu_id)
) ENGINE=InnoDB COMMENT='注文詳細';

-- 16. 注文クーポンテーブル
CREATE TABLE ORDER_COUPONS (
    order_coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    coupon_id INT NOT NULL,
    discount_applied DECIMAL(8,2) NOT NULL,
    
    FOREIGN KEY (order_id) REFERENCES ORDERS(order_id) ON DELETE CASCADE,
    FOREIGN KEY (coupon_id) REFERENCES COUPONS(coupon_id),
    INDEX idx_order_id (order_id),
    INDEX idx_coupon_id (coupon_id)
) ENGINE=InnoDB COMMENT='注文クーポン';

-- 17. カートテーブル
CREATE TABLE CARTS (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    item_id INT NOT NULL,
    menu_id INT,
    quantity INT NOT NULL DEFAULT 1,
    customizations TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES ITEMS(item_id) ON DELETE CASCADE,
    FOREIGN KEY (menu_id) REFERENCES MENUS(menu_id) ON DELETE CASCADE,
    INDEX idx_member_id (member_id),
    INDEX idx_item_id (item_id),
    INDEX idx_menu_id (menu_id)
) ENGINE=InnoDB COMMENT='ショッピングカート';

-- 18. 決済テーブル
CREATE TABLE PAYMENTS (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_provider VARCHAR(100),
    transaction_id VARCHAR(100),
    amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    payment_date DATETIME NOT NULL,
    payment_details_json TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES ORDERS(order_id) ON DELETE CASCADE,
    UNIQUE KEY uk_order_payment (order_id),
    INDEX idx_payment_method (payment_method),
    INDEX idx_payment_status (payment_status),
    INDEX idx_payment_date (payment_date),
    INDEX idx_transaction_id (transaction_id)
) ENGINE=InnoDB COMMENT='決済情報';

-- 19. 地域テーブル
CREATE TABLE REGIONS (
    region_id INT AUTO_INCREMENT PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL,
    postal_code_prefix VARCHAR(10) NOT NULL,
    delivery_available BOOLEAN NOT NULL DEFAULT TRUE,
    delivery_fee DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    delivery_time_minutes INT NOT NULL DEFAULT 30,
    
    INDEX idx_region_name (region_name),
    INDEX idx_postal_code_prefix (postal_code_prefix),
    INDEX idx_delivery_available (delivery_available)
) ENGINE=InnoDB COMMENT='配達地域';

-- 20. 店舗地域テーブル
CREATE TABLE STORE_REGIONS (
    store_region_id INT AUTO_INCREMENT PRIMARY KEY,
    store_id INT NOT NULL,
    region_id INT NOT NULL,
    
    FOREIGN KEY (store_id) REFERENCES STORES(store_id) ON DELETE CASCADE,
    FOREIGN KEY (region_id) REFERENCES REGIONS(region_id) ON DELETE CASCADE,
    UNIQUE KEY uk_store_region (store_id, region_id),
    INDEX idx_store_id (store_id),
    INDEX idx_region_id (region_id)
) ENGINE=InnoDB COMMENT='店舗配達地域';

-- パフォーマンス向上のための追加インデックス
CREATE INDEX idx_members_birth_date ON MEMBERS(birth_date);
CREATE INDEX idx_addresses_member_default ON ADDRESSES(member_id, is_default);
CREATE INDEX idx_orders_member_date ON ORDERS(member_id, order_date DESC);
CREATE INDEX idx_order_details_order_item ON ORDER_DETAILS(order_id, item_id);
CREATE INDEX idx_store_menu_additions_active ON STORE_MENU_ADDITIONS(store_id, menu_id, is_active);

-- 制約チェック用のトリガー
DELIMITER //

-- 住所のデフォルト設定チェック
CREATE TRIGGER tr_addresses_default_check
BEFORE INSERT ON ADDRESSES
FOR EACH ROW
BEGIN
    IF NEW.is_default = TRUE THEN
        UPDATE ADDRESSES 
        SET is_default = FALSE 
        WHERE member_id = NEW.member_id AND is_deleted = FALSE;
    END IF;
END//

-- 注文詳細の価格計算チェック
CREATE TRIGGER tr_order_details_price_check
BEFORE INSERT ON ORDER_DETAILS
FOR EACH ROW
BEGIN
    SET NEW.total_price = NEW.unit_price * NEW.quantity;
END//

-- カートの重複チェック
CREATE TRIGGER tr_carts_duplicate_check
BEFORE INSERT ON CARTS
FOR EACH ROW
BEGIN
    DECLARE existing_count INT DEFAULT 0;
    
    SELECT COUNT(*) INTO existing_count
    FROM CARTS 
    WHERE member_id = NEW.member_id 
      AND item_id = NEW.item_id 
      AND (menu_id = NEW.menu_id OR (menu_id IS NULL AND NEW.menu_id IS NULL));
    
    IF existing_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Duplicate cart item not allowed';
    END IF;
END//

DELIMITER ;

-- 初期設定完了メッセージ
SELECT 'マクドナルドモバイルアプリ データベース作成完了' AS message; 
