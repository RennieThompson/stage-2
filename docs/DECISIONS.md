# DECISIONS

Fill in each item before Task 1. The agent uses these answers. Change an answer here, not in a prompt.
Values marked (settings) are in the `store_settings` table. An admin can change them later without code changes.

## Store
- Store name: The Beauty Bar
- Store contact phone: +2348061445550
- Store contact email (for emails and footer): ibiyemi2samson@gmail.com
- Admin email (first admin account): ibiyemi2samson@gmail.com

## Money and delivery
- Currency: NGN (settings)
- Delivery fee:(settings, now ₦0)
- Countries and states that you deliver to:"Nigeria, all states"

## Payment in Version 1 (no online payment)
- How customers pay: Bank transfer only (settings)
- Payment instructions: Opay, account number 8061445550, account name The Beauty bar. Use the order reference as the transfer description. (settings)
- Payment status of a new order: Pending
- Can an admin change the payment status to "Paid" by hand? Yes
- Online payment provider that you expect to use later: decide later
- Later, with online payment: how long does an unpaid order hold stock? decide later

## Inventory
- When does stock decrease? When the admin confirms the order (settings: deduct_on_confirm)
- Does stock go back up when an order is cancelled? (settings: restock_on_cancel = false). 
- Low-stock limit for the dashboard: 5 (settings)

## Cart
- When a guest signs in, merge rule: add the quantities together, but not more than the stock

## Brand
- Colors: #F433AB (accent pink), #191923 (dark), #EEE2DF (light blush), #FFFFFF (white)
- Contrast rule: do not put white text on #F433AB. Use #191923 text on pink buttons. Use pink for buttons, badges and accents, not for body text on white.
- Heading font: Playfair Display. Body font: DM Sans. (Google Fonts through next/font)
- Logo: text logo for now

## Hosting
- Hosting provider: Vercel (Pro plan when the store starts to sell)
- Production domain: [FILL IN when known]
