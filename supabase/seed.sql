-- =====================================================================
-- The Beauty Bar: development seed data. DO NOT run in production.
-- Prices are in kobo (₦1 = 100 kobo).
-- =====================================================================

-- Store settings (ONE row). Update the bank details before launch.
insert into public.store_settings (
  store_name, contact_email, contact_phone, currency, delivery_fee,
  low_stock_threshold, stock_policy, restock_on_cancel,
  enabled_payment_methods, bank_transfer_instructions
) values (
  'The Beauty Bar', null, '+2348061445550', 'NGN', 0,
  5, 'deduct_on_confirm', false,
  array['bank_transfer']::public.payment_method[],
  'Pay by bank transfer to Opay, account number 8061445550, account name [ACCOUNT NAME]. Use your order reference as the transfer description. We confirm your order when we receive the payment.'
)
on conflict (id) do update set
  store_name = excluded.store_name,
  contact_phone = excluded.contact_phone,
  bank_transfer_instructions = excluded.bank_transfer_instructions;

-- Categories (PRD 6)
insert into public.categories (name, slug, description, sort_order) values
  ('Wigs',            'wigs',            'Human hair and synthetic wigs, ready to wear.', 1),
  ('Hair Extensions', 'hair-extensions', 'Bundles, clip-ins and closures.',               2),
  ('Hair Care',       'hair-care',       'Oils, serums and styling products.',            3),
  ('Beauty Products', 'beauty-products', 'Makeup and skincare.',                          4),
  ('Accessories',     'accessories',     'Bonnets, wig caps and tools.',                  5)
on conflict (slug) do nothing;

-- Products
insert into public.products (category_id, name, slug, description, price, compare_at_price, status, is_featured)
select c.id, p.name, p.slug, p.description, p.price, p.compare_at_price, p.status::public.product_status, p.is_featured
from (values
  ('wigs', 'Bone Straight Human Hair Wig', 'bone-straight-human-hair-wig',
   'Silky bone straight 100% human hair wig with a 13x4 HD lace front.', 18500000, 21000000, 'active', true),
  ('wigs', 'Body Wave Lace Front Wig', 'body-wave-lace-front-wig',
   'Soft, bouncy body wave wig with a natural hairline.', 16500000, null, 'active', true),
  ('wigs', 'Pixie Curl Short Wig', 'pixie-curl-short-wig',
   'Short pixie curls. Light, breathable and easy to style.', 6500000, 7500000, 'active', false),
  ('hair-extensions', 'Kinky Straight Bundles', 'kinky-straight-bundles',
   'Kinky straight human hair bundles that blend with natural hair.', 4500000, null, 'active', true),
  ('hair-extensions', 'Deep Wave Clip-in Extensions', 'deep-wave-clip-in-extensions',
   'Seven-piece deep wave clip-in set for instant volume.', 5500000, null, 'active', false),
  ('hair-care', 'Argan Oil Hair Serum', 'argan-oil-hair-serum',
   'Lightweight argan oil serum for shine and frizz control. 100 ml.', 850000, null, 'active', false),
  ('hair-care', 'Strong Hold Edge Control', 'strong-hold-edge-control',
   'Non-flaking edge control with a strong hold.', 450000, null, 'active', false),
  ('beauty-products', 'Velvet Matte Liquid Lipstick', 'velvet-matte-liquid-lipstick',
   'Long-wear matte liquid lipstick.', 550000, null, 'active', true),
  ('accessories', 'Satin Lined Bonnet', 'satin-lined-bonnet',
   'Double-layer satin bonnet that protects hair and wigs overnight.', 350000, null, 'active', false),
  ('wigs', 'Water Wave Bob Wig (coming soon)', 'water-wave-bob-wig',
   'Draft product for admin tests. Not visible in the shop.', 9500000, null, 'draft', false)
) as p(category_slug, name, slug, description, price, compare_at_price, status, is_featured)
join public.categories c on c.slug = p.category_slug
on conflict (slug) do nothing;

-- Variants (price null = use the product price)
insert into public.product_variants (product_id, name, sku, options, price, stock_quantity, sort_order)
select pr.id, v.name, v.sku, v.options::jsonb, v.price, v.stock, v.sort_order
from (values
  -- Bone straight wig: length and color
  ('bone-straight-human-hair-wig', '12" / Natural Black', 'BSW-12-NB', '{"length":"12\"","color":"Natural Black"}', 14500000, 6, 1),
  ('bone-straight-human-hair-wig', '14" / Natural Black', 'BSW-14-NB', '{"length":"14\"","color":"Natural Black"}', 16500000, 8, 2),
  ('bone-straight-human-hair-wig', '16" / Natural Black', 'BSW-16-NB', '{"length":"16\"","color":"Natural Black"}', 18500000, 4, 3),
  ('bone-straight-human-hair-wig', '18" / Natural Black', 'BSW-18-NB', '{"length":"18\"","color":"Natural Black"}', 20500000, 2, 4),
  ('bone-straight-human-hair-wig', '16" / Brown',         'BSW-16-BR', '{"length":"16\"","color":"Brown"}',         18500000, 0, 5),
  -- Body wave wig
  ('body-wave-lace-front-wig', '14" / Natural Black', 'BWW-14-NB', '{"length":"14\"","color":"Natural Black"}', 14500000, 5, 1),
  ('body-wave-lace-front-wig', '16" / Natural Black', 'BWW-16-NB', '{"length":"16\"","color":"Natural Black"}', 16500000, 7, 2),
  ('body-wave-lace-front-wig', '18" / Natural Black', 'BWW-18-NB', '{"length":"18\"","color":"Natural Black"}', 18500000, 3, 3),
  ('body-wave-lace-front-wig', '16" / Blonde',        'BWW-16-BL', '{"length":"16\"","color":"Blonde"}',        17500000, 2, 4),
  -- Pixie curl wig: color only
  ('pixie-curl-short-wig', 'Natural Black', 'PCW-NB', '{"color":"Natural Black"}', null, 10, 1),
  ('pixie-curl-short-wig', 'Brown',         'PCW-BR', '{"color":"Brown"}',         null, 4,  2),
  -- Kinky straight bundles: length and texture
  ('kinky-straight-bundles', '12" / Kinky Straight', 'KSB-12', '{"length":"12\"","texture":"Kinky Straight"}', 4500000, 15, 1),
  ('kinky-straight-bundles', '16" / Kinky Straight', 'KSB-16', '{"length":"16\"","texture":"Kinky Straight"}', 5500000, 12, 2),
  ('kinky-straight-bundles', '20" / Kinky Straight', 'KSB-20', '{"length":"20\"","texture":"Kinky Straight"}', 6500000, 3,  3),
  -- Deep wave clip-ins: length, texture, color
  ('deep-wave-clip-in-extensions', '16" / Deep Wave / Natural Black', 'DWC-16-NB', '{"length":"16\"","texture":"Deep Wave","color":"Natural Black"}', 5500000, 9, 1),
  ('deep-wave-clip-in-extensions', '20" / Deep Wave / Natural Black', 'DWC-20-NB', '{"length":"20\"","texture":"Deep Wave","color":"Natural Black"}', 6500000, 6, 2),
  -- Single-variant products
  ('argan-oil-hair-serum',     'Default', 'AOS-100',  '{}', null, 40, 1),
  ('strong-hold-edge-control', 'Default', 'SHEC-01',  '{}', null, 25, 1),
  -- Lipstick shades
  ('velvet-matte-liquid-lipstick', 'Ruby',        'VML-RUBY',  '{"shade":"Ruby"}',        null, 20, 1),
  ('velvet-matte-liquid-lipstick', 'Nude Cocoa',  'VML-COCOA', '{"shade":"Nude Cocoa"}',  null, 18, 2),
  ('velvet-matte-liquid-lipstick', 'Berry Pink',  'VML-BERRY', '{"shade":"Berry Pink"}',  null, 0,  3),
  -- Bonnet colors
  ('satin-lined-bonnet', 'Black', 'SLB-BLK', '{"color":"Black"}', null, 30, 1),
  ('satin-lined-bonnet', 'Pink',  'SLB-PNK', '{"color":"Pink"}',  null, 22, 2),
  -- Draft product
  ('water-wave-bob-wig', '10" / Natural Black', 'WWB-10-NB', '{"length":"10\"","color":"Natural Black"}', null, 5, 1)
) as v(product_slug, name, sku, options, price, stock, sort_order)
join public.products pr on pr.slug = v.product_slug
on conflict (sku) do nothing;
