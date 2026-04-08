import 'package:e_commerce_mobile_app/core/models/product_item.dart';

/// Local data source for supermarket product categories.
/// Replace with API calls when the backend is ready.
abstract final class ProductData {
  static const List<String> sectionTitles = [
    'ដឹកជញ្ជូនឥតគិតថ្លៃពេញមួយខែ 🗓️',
    'Fresh Orange',
    'Bakery & Pastry',
    'Snacks & Chips',
    'Soft Drinks',
    'Instant Noodles',
    'Frozen Foods',
    'Household Essentials',
    'Personal Care',
    'Baby & Kids',
  ];

  static const List<String> sectionImages = [
    'https://www.chipmong.com/wp-content/uploads/2020/04/2.Chip-mong-Supermarket-.jpg',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThxysu6Ll2xNQDH-3bhYnyYu75uzsCzF2QWQ&s',
    'https://thumbs.dreamstime.com/b/adorable-bakery-scene-featuring-whimsical-storefront-adorned-adorable-bakery-scene-featuring-whimsical-storefront-adorned-370748772.jpg',
    'https://img.freepik.com/free-vector/hand-drawn-food-elements-collection_23-2148903178.jpg',
    'https://img.freepik.com/free-vector/kawaii-fast-food-cute-drinks-illustration_24908-60622.jpg?semt=ais_rp_progressive&w=740&q=80',
    'https://cdn.apartmenttherapy.info/image/upload/f_jpg,q_auto:eco,c_fill,g_auto,w_1500,ar_1:1/tk%2Fphoto%2F2025%2F09-2025%2F2025-09-korean-noodles%2Fkorean-noodles-020',
    'https://platform.eater.com/wp-content/uploads/sites/2/chorus/uploads/chorus_asset/file/25524135/Comparisons.png?quality=90&strip=all&crop=0,3.4613147178592,100,93.077370564282',
    'https://cdn.shopify.com/s/files/1/0064/8439/4039/files/Household-Essentials.jpg?v=1566467543',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpPkz9FU5o9eUhqXeZuExREfblaKrs2--TGQ&s',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRsMliwTws9_e78uKQca3wnv8dZFSX4CUk5MQ&s',
  ];

  static List<List<ProductModel>> get allSections => [
    milkProducts,
    orangeProducts,
    bakeryProducts,
    snackProducts,
    softDrinkProducts,
    noodleProducts,
    frozenProducts,
    householdProducts,
    personalCareProducts,
    babyProducts,
  ];

  static List<ProductModel> get allProducts =>
      allSections.expand((s) => s).toList();

  static List<ProductModel> sectionAt(int index) =>
      index >= 0 && index < allSections.length ? allSections[index] : const [];

  // ── Fresh Milk ──
  static const milkProducts = <ProductModel>[
    ProductModel(id: '1', name: 'PHKA CHHOUK STERILISE MILK', price: 0.60, imageUrl: 'https://www.waangoo.com/cdn/shop/files/WhatsAppImage2025-02-17at4.14.38PM_15930882-ceb7-436e-9131-6bd97d63499f.jpg?v=1755173771'),
    ProductModel(id: '2', name: 'Milk PHKA CHHOUK', price: 1.10, imageUrl: 'https://media.makrocambodiaclick.com/PRODUCT_1768386378570.jpeg'),
    ProductModel(id: '3', name: 'Condensed Milk', price: 0.85, imageUrl: 'https://megastorecambodia.com/files/products/442_cow-head-pure-milk-1l.gif'),
    ProductModel(id: '4', name: 'Yogurt Plain', price: 1.25, imageUrl: 'https://foodpanda.dhmedia.io/image/darkstores/nv-global-catalog/kh/de56639d-e599-46d1-97cb-3cf102b2e7f3.jpg?height=176'),
  ];

  // ── Fresh Orange ──
  static const orangeProducts = <ProductModel>[
    ProductModel(id: '5', name: 'PAPA MANDARIN PRC 1XKG', price: 2.45, originalPrice: 4.98, discountPercent: 51, imageUrl: 'https://cdn.britannica.com/24/174524-050-A851D3F2/Oranges.jpg'),
    ProductModel(id: '6', name: 'FUJI APPLE PRC', price: 2.99, originalPrice: 3.99, discountPercent: 25, imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/1/15/Red_Apple.jpg'),
    ProductModel(id: '7', name: 'Fresh Orange', price: 1.99, imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/c/c4/Orange-Fruit-Pieces.jpg'),
    ProductModel(id: '8', name: 'Banana Bunch', price: 0.99, originalPrice: 1.49, discountPercent: 33, imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/8/8a/Banana-Single.jpg'),
  ];

  // ── Bakery & Pastry ──
  static const bakeryProducts = <ProductModel>[
    ProductModel(id: '9', name: 'Baguette Bread', price: 1.50, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSaKirtgDcOcqy_UrduOm6SZ5QT3RNt9z8DNQ&s'),
    ProductModel(id: '10', name: 'Chocolate Croissant', price: 2.25, imageUrl: 'https://theculinarycollectiveatl.com/wp-content/uploads/2024/03/2148516578.webp'),
    ProductModel(id: '11', name: 'Blueberry Muffin', price: 1.75, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1pAgeowdlTw4VQZOR7TF9Vw9Rn1lZNiKU-Q&s'),
    ProductModel(id: '12', name: 'Cinnamon Roll', price: 2.00, imageUrl: 'https://dev.bakerpedia.com/wp-content/uploads/2020/06/Pastry_baking-processes-e1593464950587.jpg'),
  ];

  // ── Snacks & Chips ──
  static const snackProducts = <ProductModel>[
    ProductModel(id: '13', name: 'Potato Chips', price: 1.99, imageUrl: 'https://images-na.ssl-images-amazon.com/images/I/517Pa8vUG0L.jpg'),
    ProductModel(id: '14', name: 'Chocolate Bar', price: 0.99, imageUrl: 'https://frontierbiscuit.com/cdn/shop/products/Potato_chips.webp?v=1692429566'),
    ProductModel(id: '15', name: 'Mixed Nuts', price: 3.50, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSOJA-6dmtS-xNlx1kUX25V48MTz9QAc3I_qA&s'),
    ProductModel(id: '16', name: 'Granola Bar', price: 1.25, imageUrl: 'https://caribshopper.com/cdn/shop/products/sunshine-snacks-potato-chips-6-or-12-pack-caribshopper-940101_1080x.jpg?v=1663023573'),
  ];

  // ── Soft Drinks ──
  static const softDrinkProducts = <ProductModel>[
    ProductModel(id: '17', name: 'Cola Soda', price: 1.50, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3-gxDPR43rg5voQTtrQ5mBCOMLhWQUpHINg&s'),
    ProductModel(id: '18', name: 'Lemon-Lime Soda', price: 1.25, imageUrl: 'https://at.coca-colahellenic.com/en/our-24-7-portfolio/sparkling/_jcr_content/root/sectionteaser_image/container/teaser.coreimg.jpeg/1651242522120/brands.jpeg'),
    ProductModel(id: '19', name: 'Orange Soda', price: 1.30, imageUrl: 'https://i5.walmartimages.com/seo/Sunkist-Orange-Soda-Pop-2-L-Bottle_3002740e-3996-4c0f-84eb-eceb88ea2ead.504b27cdf06e785897b7ef739ccf9b25.jpeg'),
    ProductModel(id: '20', name: 'Ginger Ale', price: 1.75, imageUrl: 'https://media.makrocambodiaclick.com/PRODUCT_1630310862860.jpeg'),
  ];

  // ── Instant Noodles ──
  static const noodleProducts = <ProductModel>[
    ProductModel(id: '21', name: 'Instant Ramen', price: 0.75, imageUrl: 'https://m.media-amazon.com/images/I/710yLnSkQgL._SL1200_.jpg'),
    ProductModel(id: '22', name: 'Rice Noodles', price: 1.50, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ742i14MS2X5sGAWjpgiDFj3GmWfPmuQ1Wbg&s'),
    ProductModel(id: '23', name: 'Egg Noodles', price: 1.25, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQb-WQMWCruEHVvvOPT-w6CIgsKkU5-k4wRKA&s'),
    ProductModel(id: '24', name: 'Soba Noodles', price: 2.00, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTa6B-JmTnu6MAnnUuh-PVdraga0Mt7zFZ9zw&s'),
  ];

  // ── Frozen Foods ──
  static const frozenProducts = <ProductModel>[
    ProductModel(id: '25', name: 'Frozen Pizza', price: 4.99, imageUrl: 'https://grillonadime.com/wp-content/uploads/2024/06/Frozen-Pizza-on-Blackstone-low-res-13-1.jpg'),
    ProductModel(id: '26', name: 'Ice Cream Tub', price: 3.50, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQl-bR-NeaPgq1GrUR1P5IEiO3JyoUwVkao6w&s'),
    ProductModel(id: '27', name: 'Frozen Vegetables', price: 2.25, imageUrl: 'https://i5.walmartimages.com/seo/Great-Value-Frozen-Peas-Carrots-Gluten-Free-12-oz-Steamable-Bag_4965b44b-d7c1-4714-96aa-5bab328cf176.f446c946f8892a1799264540713146d5.jpeg'),
    ProductModel(id: '28', name: 'Frozen Berries', price: 3.00, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTU_bGfm9veREzjRbSr0A2nY8s4I4UyyKKYHA&s'),
  ];

  // ── Household Essentials ──
  static const householdProducts = <ProductModel>[
    ProductModel(id: '29', name: 'Laundry Detergent', price: 5.99, imageUrl: 'https://cdn.thewirecutter.com/wp-content/media/2025/12/BEST-LAUNDRY-DETERGENTS-2048px-0210-2x1-1.jpg?width=2048&quality=75&crop=2:1&auto=webp'),
    ProductModel(id: '30', name: 'Dish Soap', price: 2.50, imageUrl: 'https://images.thdstatic.com/productImages/d9bd2952-5230-45db-81e7-8f7e99f18794/svn/dawn-dish-soap-003077209403-64_1000.jpg'),
    ProductModel(id: '31', name: 'All-Purpose Cleaner', price: 3.75, imageUrl: 'https://hips.hearstapps.com/hmg-prod/images/gh-062222-best-all-purpose-cleaners-1655921002.png?crop=0.6666666666666666xw:1xh;center,top&resize=1200:*'),
    ProductModel(id: '32', name: 'Paper Towels', price: 4.00, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRGbJ53pxoCBjgdiY1a_8YpG6wqi_C8eh50iw&s'),
  ];

  // ── Personal Care ──
  static const personalCareProducts = <ProductModel>[
    ProductModel(id: '33', name: 'Shampoo Bottle', price: 6.99, imageUrl: 'https://t4.ftcdn.net/jpg/00/47/30/15/360_F_47301594_mLvjoHeB4UvNvZ0zOotvrhPfqLQlIDRv.jpg'),
    ProductModel(id: '34', name: 'Body Wash', price: 5.50, imageUrl: 'https://acmarca.com/en/wp-content/uploads/sites/2/2025/02/areas_personal_care_higiene_bdg_internacional_03.png'),
    ProductModel(id: '36', name: 'Toothpaste Tube', price: 3.25, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSPnlafGFZRIvGcqzU4hbYNl87wM4cKpBZjxQ&s'),
    ProductModel(id: '37', name: 'Deodorant Stick', price: 4.00, imageUrl: 'https://i5.walmartimages.com/seo/Dove-Men-Care-Extra-Fresh-72H-Men-s-Antiperspirant-Deodorant-Stick-2-7-oz_d855a43f-f964-49f0-bff4-851f3b0ebe72.ac132ca29b5044d8184e96410526bbdd.jpeg'),
  ];

  // ── Baby & Kids ──
  static const babyProducts = <ProductModel>[
    ProductModel(id: '38', name: 'Baby Diapers', price: 19.99, imageUrl: 'https://www.menmoms.in/cdn/shop/files/MM-3060-M-_PK-of-28_-1.jpg?v=1734341164&width=600'),
    ProductModel(id: '39', name: 'Baby Wipes', price: 4.50, imageUrl: 'https://i5.walmartimages.com/seo/WaterWipes-Original-99-9-Water-Based-Baby-Wipes-Unscented-9-Resealable-Packs-540-Wipes_acb2b827-b0f5-454f-988c-9be4e1fae873.4622633907b4c335e5e290f9fe1c9319.jpeg'),
    ProductModel(id: '40', name: 'Baby Formula', price: 29.99, imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRlfplo8vbKxzEyGQ65R-ATUQqUnZreBVXYUw&s'),
    ProductModel(id: '41', name: 'Baby Lotion', price: 6.25, imageUrl: 'https://themothercare.pk/cdn/shop/files/Baby_Lotion_French_Berries_Family_300ml.jpg?v=1748253694'),
  ];
}
