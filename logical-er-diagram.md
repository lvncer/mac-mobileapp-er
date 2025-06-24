# Logical ER Diagram

```mermaid
erDiagram
    MEMBERS {
        member_id PK "NN"
        name "NN"
        email UK "NN"
        password_hash "NN"
        postal_code
        gender
        birth_date
        children_count
        youngest_child_birth_date
        notification_enabled "NN"
        two_factor_auth "NN"
        created_at "NN"
        updated_at "NN"
        is_deleted "NN"
    }

    STORES {
        store_id PK "NN"
        store_name "NN"
        capacity
        parking_available "NN"
        mobile_order_available "NN"
        phone_number
        services_json
        created_at "NN"
        updated_at "NN"
        is_deleted "NN"
    }

    STORE_HOURS {
        store_hour_id PK "NN"
        store_id FK "NN"
        service_type "NN"
        open_time "NN"
        close_time "NN"
        day_of_week "NN"
    }

    ADDRESSES {
        address_id PK "NN"
        member_id FK "NN"
        postal_code "NN"
        prefecture_city "NN"
        detailed_address "NN"
        building_type "NN"
        nameplate_name "NN"
        building_appearance
        company_name
        department_name
        delivery_notes
        is_default "NN"
        created_at "NN"
        updated_at "NN"
        is_deleted "NN"
    }

    ITEMS {
        item_id PK "NN"
        item_name "NN"
        description
        base_price "NN"
        category "NN"
        image_url
        is_available "NN"
        created_at "NN"
        updated_at "NN"
        is_deleted "NN"
    }

    MENUS {
        menu_id PK "NN"
        menu_name "NN"
        menu_type "NN"
        base_price "NN"
        sale_start_date "NN"
        sale_end_date
        time_period "NN"
        store_pickup_available "NN"
        delivery_available "NN"
        is_available "NN"
        created_at "NN"
        updated_at "NN"
        is_deleted "NN"
    }

    MENU_ITEMS {
        menu_item_id PK "NN"
        menu_id FK "NN"
        item_id FK "NN"
        quantity "NN"
        is_replaceable "NN"
        replacement_category
        additional_price
        created_at "NN"
        updated_at "NN"
    }

    ITEM_VARIATIONS {
        variation_id PK "NN"
        item_id FK "NN"
        variation_name "NN"
        price_difference "NN"
        is_available "NN"
        created_at "NN"
        updated_at "NN"
    }

    STORE_MENU_ADDITIONS {
        store_menu_addition_id PK "NN"
        store_id FK "NN"
        menu_id FK "NN"
        price_addition "NN"
        effective_from "NN"
        effective_until
        is_active "NN"
        created_at "NN"
        updated_at "NN"
    }

    COUPONS {
        coupon_id PK "NN"
        coupon_code UK "NN"
        coupon_name "NN"
        max_order_quantity
        expiry_date "NN"
        discount_amount
        discount_percentage
        is_active "NN"
        created_at "NN"
        updated_at "NN"
    }

    COUPON_STORES {
        coupon_store_id PK "NN"
        coupon_id FK "NN"
        store_id FK "NN"
    }

    COUPON_MENUS {
        coupon_menu_id PK "NN"
        coupon_id FK "NN"
        menu_id FK "NN"
        item_id FK
    }

    FAVORITE_STORES {
        favorite_id PK "NN"
        member_id FK "NN"
        store_id FK "NN"
        created_at "NN"
    }

    ORDERS {
        order_id PK "NN"
        member_id FK "NN"
        store_id FK "NN"
        address_id FK
        order_status "NN"
        delivery_method "NN"
        subtotal "NN"
        tax_amount "NN"
        delivery_fee "NN"
        discount_amount "NN"
        total_amount "NN"
        order_date "NN"
        pickup_time
        delivery_time
        special_instructions
        created_at "NN"
        updated_at "NN"
    }

    ORDER_DETAILS {
        order_detail_id PK "NN"
        order_id FK "NN"
        item_id FK "NN"
        menu_id FK
        quantity "NN"
        unit_price "NN"
        total_price "NN"
        unit_price_at_order "NN"
        standard_price "NN"
        price_adjustment "NN"
        adjustment_reason
        is_replacement "NN"
        customizations
        created_at "NN"
        updated_at "NN"
    }

    ORDER_COUPONS {
        order_coupon_id PK "NN"
        order_id FK "NN"
        coupon_id FK "NN"
        discount_applied "NN"
    }

    CARTS {
        cart_id PK "NN"
        member_id FK "NN"
        item_id FK "NN"
        menu_id FK
        quantity "NN"
        customizations
        created_at "NN"
        updated_at "NN"
    }

    PAYMENTS {
        payment_id PK "NN"
        order_id FK "NN"
        payment_method "NN"
        payment_provider
        transaction_id
        amount "NN"
        payment_status "NN"
        payment_date "NN"
        payment_details_json
        created_at "NN"
        updated_at "NN"
    }

    REGIONS {
        region_id PK "NN"
        region_name "NN"
        postal_code_prefix "NN"
        delivery_available "NN"
        delivery_fee "NN"
        delivery_time_minutes "NN"
    }

    STORE_REGIONS {
        store_region_id PK "NN"
        store_id FK "NN"
        region_id FK "NN"
    }

    %% Relationships (Foreign Key Based)
    MEMBERS ||--o{ ADDRESSES : ""
    MEMBERS ||--o{ FAVORITE_STORES : ""
    MEMBERS ||--o{ ORDERS : ""
    MEMBERS ||--o{ CARTS : ""

    STORES ||--o{ STORE_HOURS : ""
    STORES ||--o{ FAVORITE_STORES : ""
    STORES ||--o{ ORDERS : ""
    STORES ||--o{ COUPON_STORES : ""
    STORES ||--o{ STORE_REGIONS : ""
    STORES ||--o{ STORE_MENU_ADDITIONS : ""

    ITEMS ||--o{ MENU_ITEMS : ""
    ITEMS ||--o{ ITEM_VARIATIONS : ""
    ITEMS ||--o{ ORDER_DETAILS : ""
    ITEMS ||--o{ CARTS : ""

    MENUS ||--o{ MENU_ITEMS : ""
    MENUS ||--o{ COUPON_MENUS : ""
    MENUS ||--o{ STORE_MENU_ADDITIONS : ""

    COUPONS ||--o{ COUPON_STORES : ""
    COUPONS ||--o{ COUPON_MENUS : ""
    COUPONS ||--o{ ORDER_COUPONS : ""

    ORDERS ||--o{ ORDER_DETAILS : ""
    ORDERS ||--o{ ORDER_COUPONS : ""
    ORDERS ||--|| PAYMENTS : ""
    ADDRESSES ||--o{ ORDERS : ""

    REGIONS ||--o{ STORE_REGIONS : ""
```

## Key Constraints

### Primary Keys (PK)

- Each table has a single primary key that uniquely identifies each record
- Primary keys are auto-incrementing integers where applicable

### Foreign Keys (FK)

- All foreign key relationships are properly defined to maintain referential integrity
- Some foreign keys are nullable (optional relationships)

### Unique Keys (UK)

- `MEMBERS.email`: Each member must have a unique email address
- `COUPONS.coupon_code`: Each coupon must have a unique code

### Not Null Constraints (NN)

- Essential business fields are marked as NOT NULL
- System fields (created_at, updated_at, IDs) are always NOT NULL
- Optional fields (descriptions, notes, etc.) allow NULL values

## Business Rules

### Menu Structure

- Items represent individual products (burgers, fries, drinks)
- Menus can be single items or sets composed of multiple items
- Menu items define the composition of set menus
- Item variations handle size/customization options

### Pricing Strategy

- Base prices are defined at the menu level
- Store-specific price additions are applied per store-menu combination
- Final price = base_price + store_price_addition

### Order Processing

- Orders are linked to both items (for inventory) and menus (for display)
- Price at order time is recorded for historical accuracy
- Customizations and replacements are tracked

### Temporal Data

- Menu availability is controlled by sale dates
- Store menu additions have effective date ranges
- Coupon expiry dates control validity periods
