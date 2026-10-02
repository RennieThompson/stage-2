# PRODUCT REQUIREMENTS DOCUMENT

## Beauty & Hair E-commerce Platform

**Document Version:** 1.0
**Project Type:** E-commerce Web Application
**Status:** Proposed
**Primary Products:** Beauty Products, Hair Extensions, and Wigs

---

# 1. PRODUCT OVERVIEW

The goal of this project is to build a modern e-commerce website for a beauty and hair business that sells beauty products, hair extensions, and wigs.

Customers should be able to browse products, search and filter the catalog, view product details, add products to a shopping cart, and complete an order through either guest checkout or authenticated checkout.

The platform will support Google authentication alongside traditional email/password authentication. Application data will be persisted using Supabase or Neon, while Mailgun will be used for transactional emails.

The initial version will not include online payment processing. However, the checkout and order architecture must be designed so that a payment provider can be integrated in the future without requiring a major rewrite.

---

# 2. PRODUCT GOALS

## 2.1 Primary Goals

The platform should:

1. Allow customers to discover beauty products, hair extensions, and wigs.
2. Provide a smooth shopping-cart and checkout experience.
3. Support both guest checkout and authenticated checkout.
4. Allow customers to create accounts and manage their orders.
5. Allow customers to view their order history and order status.
6. Provide an admin dashboard for managing products, inventory, and orders.
7. Support Google authentication alongside email/password authentication.
8. Send transactional emails using Mailgun.
9. Persist application data using a PostgreSQL-compatible database.
10. Keep the architecture extensible for future payment integration.

## 2.2 Non-Goals for Version 1

The following features are outside the scope of the initial release:

- Online payment processing
- Payment gateway integration
- Loyalty/rewards program
- Multi-vendor marketplace functionality
- Native mobile applications
- Advanced shipping-rate calculation
- AI-powered product recommendations

---

# 3. USER TYPES

## 3.1 Customer

Customers should be able to:

- Browse products
- Search for products
- Filter and sort products
- View product details
- Select product variants
- Add products to a shopping cart
- Modify cart quantities
- Remove products from their cart
- Checkout as a guest
- Create an account
- Sign in with email/password
- Sign in with Google
- Complete authenticated checkout
- View order confirmations
- View previous orders
- View individual order details
- Receive transactional emails
- Receive order status notifications

## 3.2 Administrator

Administrators should be able to:

- Sign in securely
- Create products
- Edit products
- Archive products
- Manage product images
- Manage categories
- Manage product variants
- Manage inventory
- View orders
- Search and filter orders
- Update order status
- View customer and order information
- Manage featured products

---

# 4. CORE USER JOURNEYS

## 4.1 Guest Checkout

The guest checkout flow should follow this sequence:

Home → Browse Products → Product Details → Add to Cart → Cart → Checkout → Customer Information → Delivery Information → Order Review → Place Order → Order Confirmation → Confirmation Email

The customer should not be required to create an account before placing an order.

After placing the order, the customer should receive a unique order reference.

## 4.2 Authenticated Checkout

The authenticated checkout flow should follow this sequence:

Home → Sign In/Register → Browse Products → Product Details → Add to Cart → Cart → Checkout → Customer Information → Delivery Information → Order Review → Place Order → Order Confirmation → Confirmation Email → Order History

Authenticated customers should have their orders associated with their account.

---

# 5. AUTHENTICATION

The application must support multiple authentication methods.

## 5.1 Required Authentication Methods

- Email/password registration
- Email/password login
- Google OAuth
- Logout
- Password reset

## 5.2 Google Authentication

Google authentication should be configured using Google Cloud Console.

The authentication flow should:

1. Allow the customer to select "Continue with Google."
2. Redirect the customer to Google's authentication page.
3. Authenticate the customer.
4. Create or retrieve the corresponding application account.
5. Create/update the customer's profile.
6. Redirect the customer back to the application.

## 5.3 Customer Profile

A customer profile should contain:

- User ID
- First name
- Last name
- Email
- Profile image/avatar where available
- Authentication provider
- Phone number
- Created date
- Updated date

---

# 6. PRODUCT CATALOG

Products should be organized into configurable categories.

Suggested initial categories include:

- Wigs
- Hair Extensions
- Hair Care
- Beauty Products
- Accessories

Categories should be managed through the admin dashboard rather than being permanently hard-coded into the application.

## 6.1 Product Information

Each product should support:

- Product name
- Slug
- Description
- Category
- Price
- Compare-at/original price
- SKU
- Inventory quantity
- Product images
- Product status
- Featured status
- Created date
- Updated date

## 6.2 Product Variants

The system should support product variants.

Example wig variants:

- Length: 12", 14", 16", 18"
- Color: Natural Black, Brown, Blonde

Example hair-extension variants:

- Length
- Texture
- Color

The system should be flexible enough to support different variant attributes for different products.

---

# 7. PRODUCT DISCOVERY

## 7.1 Homepage

The homepage should include:

- Hero/banner section
- Featured products
- Product categories
- New arrivals
- Promotional content
- Calls-to-action
- Links to the main product catalog

## 7.2 Product Listing

Customers should be able to:

- Browse products
- Search products
- Filter products
- Sort products

Filtering should support:

- Category
- Price
- Availability

Sorting should support:

- Newest
- Price: Low to High
- Price: High to Low
- Featured/Popular

## 7.3 Product Details

A product detail page should display:

- Product image gallery
- Product name
- Price
- Original price where applicable
- Description
- Available variants
- Stock availability
- Quantity selector
- Add-to-cart button
- Related products

---

# 8. SHOPPING CART

The shopping cart must support:

- Adding products
- Removing products
- Increasing quantities
- Decreasing quantities
- Selecting product variants
- Displaying subtotal
- Displaying total quantity
- Persisting cart data for authenticated users

For guest users, the cart should persist locally so that navigating between pages does not cause cart contents to be lost.

If a guest signs in, the system should merge the guest cart with the customer's existing account cart where appropriate.

---

# 9. CHECKOUT

## 9.1 Version 1 Payment Behavior

Version 1 will not include online payment processing.

Customers will be able to submit orders without making an online payment.

The application should keep order and payment concepts separate.

### Order Status

Possible order statuses:

- Pending
- Confirmed
- Processing
- Shipped
- Delivered
- Cancelled

### Payment Status

Possible payment statuses:

- Not Required
- Pending
- Paid
- Failed
- Refunded

The separation between order status and payment status will make it easier to introduce online payments later.

---

# 10. CHECKOUT INFORMATION

## 10.1 Customer Information

The checkout should collect:

- First name
- Last name
- Email
- Phone number

For authenticated customers, existing profile information should be pre-populated.

Customers should be able to edit their information during checkout.

## 10.2 Delivery Information

The checkout should collect:

- Delivery address
- City
- State/region
- Country
- Phone number
- Optional delivery instructions

## 10.3 Order Review

Before submitting an order, customers should see:

- Products
- Product variants
- Quantities
- Individual prices
- Subtotal
- Delivery information
- Customer information
- Total order value

The customer should then select:

**Place Order**

---

# 11. ORDER MANAGEMENT

When an order is successfully placed, the system should:

1. Validate the cart.
2. Validate product availability.
3. Retrieve current product prices from the database.
4. Create the order.
5. Create the order items.
6. Save the customer's checkout information.
7. Update/reserve inventory according to the inventory policy.
8. Generate a unique order reference.
9. Clear the customer's cart.
10. Send an order confirmation email.
11. Display an order confirmation page.

## 11.1 Order Reference

Each order should have a customer-friendly reference number.

Example:

**ORD-2026-000123**

The internal database ID should not be used as the primary customer-facing order reference.

---

# 12. CUSTOMER ORDER HISTORY

Authenticated customers should have an Orders section in their account.

Each order should display:

- Order reference
- Order date
- Number of items
- Total order value
- Order status
- Payment status
- Delivery information

Customers should be able to select an order to view its complete details.

## 12.1 Order Details

The order detail page should display:

- Order reference
- Products purchased
- Product variants
- Quantities
- Individual prices
- Subtotal
- Total
- Order status
- Payment status
- Delivery address
- Order date

---

# 13. ADMIN DASHBOARD

An administrative dashboard is required for managing the e-commerce platform.

## 13.1 Dashboard Overview

The dashboard should display:

- Total orders
- Pending orders
- Order value
- Number of products
- Low-stock products
- Recent orders

Because online payment is not included in Version 1, "revenue" should be treated as order value rather than confirmed collected revenue.

## 13.2 Product Management

Administrators should be able to:

- Create products
- Edit products
- Archive products
- Upload product images
- Set prices
- Set inventory
- Configure product variants
- Assign categories
- Mark products as featured
- Publish/unpublish products

## 13.3 Inventory Management

Administrators should be able to:

- View current stock
- Update stock
- Identify low-stock products
- Mark products as out of stock

## 13.4 Order Management

Administrators should be able to:

- View all orders
- Search orders
- Filter orders by status
- View complete order details
- Update order status
- Cancel orders where appropriate

---

# 14. EMAIL SYSTEM

Mailgun will be used for transactional emails.

## 14.1 Welcome Email

A welcome email should be sent when a customer creates an account.

## 14.2 Order Confirmation Email

An order confirmation email should be sent after a successful order.

The email should contain:

- Customer name
- Order reference
- Products purchased
- Quantities
- Prices
- Total order value
- Delivery information
- Current order status
- Store information

## 14.3 Order Status Email

When an administrator changes the order status, the customer should receive a relevant email notification.

Examples include:

- Order confirmed
- Order processing
- Order shipped
- Order delivered
- Order cancelled

## 14.4 Password Emails

Password reset functionality should be supported for email/password accounts.

---

# 15. DATABASE

The application should use Supabase or Neon as the persistent database.

The database should use PostgreSQL.

## 15.1 Core Entities

The proposed database entities are:

- Users
- Profiles
- Categories
- Products
- Product Images
- Product Variants
- Carts
- Cart Items
- Orders
- Order Items
- Order Status History
- Addresses
- Email Events

## 15.2 Entity Relationships

A user can have:

- One profile
- One active cart
- Multiple orders
- Multiple addresses

A category can have multiple products.

A product can have:

- Multiple images
- Multiple variants

A cart can have multiple cart items.

An order can have:

- Multiple order items
- A delivery address
- Multiple status history records

---

# 16. ORDER DATA INTEGRITY

Order items must store a snapshot of relevant product information at the time of purchase.

For example:

- Product ID
- Product name
- Variant ID
- Variant name
- Unit price
- Quantity
- Subtotal

This ensures historical orders remain accurate even if the product's name, price, or other details are changed later.

---

# 17. SECURITY REQUIREMENTS

The application must:

- Never expose database credentials to the client.
- Store sensitive credentials in environment variables.
- Protect administrative routes.
- Verify admin permissions server-side.
- Validate all user input.
- Prevent customers from accessing another customer's orders.
- Prevent unauthorized inventory changes.
- Validate product prices on the server.
- Validate product availability on the server.
- Use secure authentication/session management.
- Restrict sensitive database operations.

## 17.1 Server-Side Price Validation

The browser must never be trusted as the source of truth for product prices.

For example, if the browser submits a product price, the server must ignore the submitted price and retrieve the actual current price from the database before creating an order.

The same principle applies to inventory.

---

# 18. USER EXPERIENCE REQUIREMENTS

The website should be:

- Responsive
- Mobile-friendly
- Fast
- Accessible
- Easy to navigate
- Visually polished
- Optimized for product discovery
- Optimized for a simple checkout experience

The visual design should reflect a premium beauty and hair brand.

Suggested design characteristics include:

- High-quality product photography
- Elegant typography
- Clean product cards
- Clear calls-to-action
- Consistent color palette
- Simple navigation
- Mobile-first shopping experience

---

# 19. REQUIRED PAGES

## 19.1 Public Pages

- Home
- Shop
- Category
- Product Details
- Cart
- Checkout
- Login
- Register
- Forgot Password

## 19.2 Customer Pages

- Account Dashboard
- Profile
- Orders
- Order Details

## 19.3 Admin Pages

- Admin Dashboard
- Products
- Create Product
- Edit Product
- Categories
- Inventory
- Orders
- Order Details

---

# 20. TECHNICAL ARCHITECTURE

The application should follow a modular architecture.

### High-Level Architecture

Frontend
↓
Application/API Layer
↓
Database / Authentication / Email Services

The major services are:

- Frontend application
- Application/API layer
- PostgreSQL database
- Authentication
- Google OAuth
- Mailgun
- Admin dashboard

## 20.1 Suggested Technology Direction

The implementation may use:

- React-based frontend
- PostgreSQL
- Supabase or Neon
- Google OAuth
- Mailgun
- Server-side API/actions
- Secure environment configuration

The final technology stack can be selected during technical implementation planning.

---

# 21. PAYMENT ARCHITECTURE

Although payments are not required in Version 1, the application should be designed to support future payment integration.

The order system should not assume that an order is automatically paid.

Future payment providers could include:

- Paystack
- Stripe
- Flutterwave
- Other compatible payment providers

## 21.1 Future Payment Flow

Checkout
↓
Create Pending Order
↓
Initialize Payment
↓
Redirect to Payment Provider
↓
Payment Provider
↓
Payment Webhook
↓
Verify Payment
↓
Mark Order as Paid
↓
Send Confirmation

Payment confirmation should be verified server-side rather than relying solely on a browser redirect.

---

# 22. FUNCTIONAL REQUIREMENTS

| **ID** | **Requirement**                            | **Priority** |
| ------ | ------------------------------------------ | ------------ |
| FR-01  | Customers can browse products              | Must         |
| FR-02  | Customers can search products              | Must         |
| FR-03  | Customers can filter products              | Should       |
| FR-04  | Customers can view product details         | Must         |
| FR-05  | Customers can add products to cart         | Must         |
| FR-06  | Customers can modify cart quantities       | Must         |
| FR-07  | Customers can checkout as guests           | Must         |
| FR-08  | Authenticated customers can checkout       | Must         |
| FR-09  | Customers can register with email/password | Must         |
| FR-10  | Customers can authenticate with Google     | Must         |
| FR-11  | Customers can view order history           | Must         |
| FR-12  | Administrators can manage products         | Must         |
| FR-13  | Administrators can manage inventory        | Must         |
| FR-14  | Administrators can manage orders           | Must         |
| FR-15  | Mailgun sends order confirmations          | Must         |
| FR-16  | Mailgun sends account emails               | Should       |
| FR-17  | Product variants are supported             | Must         |
| FR-18  | Online payments are supported              | Future       |
| FR-19  | Order status notifications are sent        | Must         |
| FR-20  | Admin dashboard is available               | Must         |

---

# 23. ACCEPTANCE CRITERIA

## 23.1 Product Catalog

- Customers can browse available products.
- Customers can search products.
- Customers can filter products.
- Customers can view complete product information.
- Customers can select available variants.
- Unavailable products/variants cannot be purchased.

## 23.2 Shopping Cart

- Customers can add products to the cart.
- Customers can increase quantities.
- Customers can decrease quantities.
- Customers can remove products.
- Cart totals are calculated correctly.
- Cart state survives normal page navigation.

## 23.3 Checkout

- Guests can complete checkout without creating an account.
- Authenticated customers can complete checkout.
- Required fields are validated.
- The server calculates the final order total.
- A unique order reference is generated.
- The order is stored in the database.
- The cart is cleared after a successful order.

## 23.4 Authentication

- Customers can register.
- Customers can log in.
- Customers can log out.
- Customers can authenticate using Google.
- Customers can reset their password.
- Authenticated users can access their own orders.
- Customers cannot access another customer's orders.

## 23.5 Orders

- Customers can view their orders.
- Administrators can view all orders.
- Administrators can update order status.
- Customers receive relevant order status notifications.

## 23.6 Email

- Successful orders trigger confirmation emails.
- New accounts trigger appropriate welcome emails.
- Order status changes trigger appropriate notifications.
- Email failures do not cause an otherwise valid order to be lost.

## 23.7 Administration

- Administrators can create products.
- Administrators can edit products.
- Administrators can manage inventory.
- Administrators can manage categories.
- Administrators can view orders.
- Administrators can update order statuses.
- Non-admin users cannot access administrative functionality.

---

# 24. FUTURE ENHANCEMENTS

The following features may be introduced after Version 1:

- Online payment processing
- Paystack integration
- Stripe integration
- Flutterwave integration
- Promo/discount codes
- Product reviews and ratings
- Wishlist
- Guest order tracking
- Advanced delivery pricing
- Multiple admin roles
- Customer loyalty program
- Abandoned-cart emails
- Product recommendations
- Advanced analytics
- Sales reporting
- Customer segmentation
- Inventory alerts
- Social login providers beyond Google

---

# 25. VERSION 1 DEFINITION OF DONE

Version 1 will be considered complete when:

1. The storefront is responsive on mobile and desktop.
2. Customers can browse and search products.
3. Products support variants.
4. Customers can add, remove, and update cart items.
5. Guest checkout works successfully.
6. Authenticated checkout works successfully.
7. Email/password authentication works.
8. Google authentication works.
9. Orders are persisted in PostgreSQL.
10. Customers can view their order history.
11. Administrators can manage products.
12. Administrators can manage inventory.
13. Administrators can manage orders.
14. Mailgun sends transactional emails.
15. Order status emails work.
16. Online payment is not required to place an order.
17. Sensitive operations are protected server-side.
18. The system is structured so payment integration can be added later without redesigning the checkout system.

---

# 26. SUCCESS CRITERIA

The project will be considered successful when a customer can go from discovering a product to successfully placing an order with minimal friction, while the business can manage its catalog, inventory, and orders through the administrative dashboard.

The technical implementation should prioritize:

- Data integrity
- Security
- Maintainability
- Responsive design
- Good user experience
- Extensibility
- Reliable transactional email delivery
- Future payment integration

---

# 27. PROJECT SCOPE SUMMARY

| **Area**               | **Version 1** |
| ---------------------- | ------------- |
| Product Catalog        | Included      |
| Beauty Products        | Included      |
| Hair Extensions        | Included      |
| Wigs                   | Included      |
| Product Variants       | Included      |
| Search                 | Included      |
| Filtering              | Included      |
| Shopping Cart          | Included      |
| Guest Checkout         | Included      |
| Authenticated Checkout | Included      |
| Email/Password Auth    | Included      |
| Google Auth            | Included      |
| Customer Accounts      | Included      |
| Order History          | Included      |
| Admin Dashboard        | Included      |
| Product Management     | Included      |
| Inventory Management   | Included      |
| Order Management       | Included      |
| Mailgun Emails         | Included      |
| Online Payments        | Not Included  |
| Payment Architecture   | Future-ready  |
| Product Reviews        | Future        |
| Promo Codes            | Future        |
| Loyalty Program        | Future        |

---