insert into public.categories (name, slug, image_url, sort_order)
values
  ('Burgers', 'burgers', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=700', 1),
  ('Pizza', 'pizza', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=700', 2),
  ('Chicken', 'chicken', 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=700', 3),
  ('Sandwiches', 'sandwiches', 'https://images.unsplash.com/photo-1553909489-cd47e0ef937f?w=700', 4),
  ('Desserts', 'desserts', 'https://images.unsplash.com/photo-1551024506-0aaaa4e8d8a1?w=700', 5),
  ('Drinks', 'drinks', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=700', 6)
on conflict (slug) do update set
  name = excluded.name, image_url = excluded.image_url, sort_order = excluded.sort_order;

with category_map as (
  select id, slug from public.categories
),
seed_products(name, slug, category_slug, description, price, image_url, featured, popular) as (
  values
  ('Classic Beef Burger', 'classic-beef-burger', 'burgers', 'Juicy beef patty with lettuce, tomato and house sauce.', 145, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=900', true, true),
  ('Double Cheese Burger', 'double-cheese-burger', 'burgers', 'Two beef patties with melted cheddar cheese.', 185, 'https://images.unsplash.com/photo-1553979459-d2229ba7433a?w=900', true, true),
  ('Crispy Chicken Burger', 'crispy-chicken-burger', 'burgers', 'Crispy chicken fillet, pickles and creamy mayo.', 135, 'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=900', false, true),
  ('BBQ Bacon Burger', 'bbq-bacon-burger', 'burgers', 'Smoky barbecue sauce with a grilled beef patty.', 175, 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=900', false, false),
  ('Margherita Pizza', 'margherita-pizza', 'pizza', 'Tomato, mozzarella and fresh basil.', 160, 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=900', true, true),
  ('Pepperoni Pizza', 'pepperoni-pizza', 'pizza', 'Classic pepperoni with mozzarella cheese.', 210, 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=900', true, true),
  ('Four Cheese Pizza', 'four-cheese-pizza', 'pizza', 'A rich blend of four cheeses.', 225, 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=900', false, false),
  ('BBQ Chicken Pizza', 'bbq-chicken-pizza', 'pizza', 'Grilled chicken, onion and smoky BBQ sauce.', 215, 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=900', false, true),
  ('Crispy Chicken Meal', 'crispy-chicken-meal', 'chicken', 'Golden fried chicken served with fries.', 175, 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=900', true, true),
  ('Grilled Chicken Plate', 'grilled-chicken-plate', 'chicken', 'Tender grilled chicken with herbs and rice.', 195, 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=900', false, true),
  ('Chicken Wings', 'chicken-wings', 'chicken', 'Saucy wings with your choice of mild spice.', 155, 'https://images.unsplash.com/photo-1608039829572-78524f79c4c7?w=900', false, false),
  ('Chicken Tenders', 'chicken-tenders', 'chicken', 'Crunchy chicken strips with dipping sauce.', 145, 'https://images.unsplash.com/photo-1562967914-608f82629710?w=900', false, false),
  ('Club Sandwich', 'club-sandwich', 'sandwiches', 'Triple-layer sandwich with chicken and fresh vegetables.', 125, 'https://images.unsplash.com/photo-1553909489-cd47e0ef937f?w=900', true, true),
  ('Philly Steak Sandwich', 'philly-steak-sandwich', 'sandwiches', 'Sliced beef, peppers and melted cheese.', 165, 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=900', false, true),
  ('Tuna Sandwich', 'tuna-sandwich', 'sandwiches', 'Tuna salad with crisp lettuce and lemon mayo.', 110, 'https://images.unsplash.com/photo-1521390188846-e2a3a97453a0?w=900', false, false),
  ('Chocolate Brownie', 'chocolate-brownie', 'desserts', 'Rich chocolate brownie with a soft centre.', 75, 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=900', true, true),
  ('New York Cheesecake', 'new-york-cheesecake', 'desserts', 'Creamy cheesecake with a biscuit base.', 95, 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=900', false, true),
  ('Chocolate Donuts', 'chocolate-donuts', 'desserts', 'Soft donuts covered with chocolate glaze.', 65, 'https://images.unsplash.com/photo-1551024506-0aaaa4e8d8a1?w=900', false, false),
  ('Fresh Orange Juice', 'fresh-orange-juice', 'drinks', 'Freshly squeezed orange juice.', 55, 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=900', true, true),
  ('Iced Latte', 'iced-latte', 'drinks', 'Chilled espresso with milk over ice.', 70, 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=900', false, true)
)
insert into public.products (
  category_id, name, slug, description, price, image_url, is_featured, is_popular
)
select c.id, p.name, p.slug, p.description, p.price, p.image_url, p.featured, p.popular
from seed_products p
join category_map c on c.slug = p.category_slug
on conflict (slug) do update set
  category_id = excluded.category_id,
  name = excluded.name,
  description = excluded.description,
  price = excluded.price,
  image_url = excluded.image_url,
  is_featured = excluded.is_featured,
  is_popular = excluded.is_popular,
  is_active = true;
