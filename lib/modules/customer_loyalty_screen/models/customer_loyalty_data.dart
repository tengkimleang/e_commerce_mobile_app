import 'package:e_commerce_mobile_app/core/models/product_item.dart';

class CustomerLoyaltyData {
  final String username;
  final String phone;
  final String points;
  final String promoPeriodText;
  final String exchangePointsImageUrl;
  final String priceCheckingImageUrl;

  const CustomerLoyaltyData({
    required this.username,
    required this.phone,
    required this.points,
    required this.promoPeriodText,
    required this.exchangePointsImageUrl,
    required this.priceCheckingImageUrl,
  });
}

const customerLoyaltyDefaultData = CustomerLoyaltyData(
  username: 'Jame Taki',
  phone: '099 123 4567',
  points: '0',
  promoPeriodText: '01-28 Feb 2026 - Special promotions and bundles.',
  exchangePointsImageUrl:
      'https://www.shutterstock.com/image-vector/cashback-reward-program-advertising-idea-600nw-2553858371.jpg',
  priceCheckingImageUrl:
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZ5i8QBjeV3H4nA5m5T3ILCaeeQYcWN0pg9Q&s',
);

const List<ProductItem> PriceCheckingProducts = <ProductItem>[
  ProductItem(
    id: 'p0',
    name: 'NR-OSTRA FZ-BABY WHOLE OCTOPUS',
    price: 8.50,
    imageUrl:
        'https://allansvending.com/wp-content/uploads/2024/05/coke-products.png',
  ),
  ProductItem(
    id: 'p1',
    name: 'NR-OSTRA FZ-SQUID FLOWER 500G',
    price: 5.50,
    imageUrl:
        'https://media.allure.com/photos/66b399da6d09ec3641ed7e7a/16:9/w_2560%2Cc_limit/Best%2520Japanese%2520Skin%2520Care%2520082024%2520Lede.jpg',
  ),
  ProductItem(
    id: 'p2',
    name: 'NR-OSTRA FZ-TUNA SAKU 300-350G',
    price: 8.00,
    imageUrl:
        'https://foodindustryexecutive.com/wp-content/uploads/2023/03/daring-new-products.png',
  ),
  ProductItem(
    id: 'p3',
    name: 'NR-OSTRA FZ-SALMON FIN 500G',
    price: 3.75,
    imageUrl:
        'https://camboticket.com/blog/wp-content/uploads/2024/07/Nom-Banh-Chok-edited.jpg',
  ),
  ProductItem(
    id: 'p4',
    name: 'NR-OSTRA FZ-USA SCALLOPS 500G',
    price: 23.00,
    imageUrl:
        'https://www.flavorchem.com/wp-content/uploads/2023/01/1-immunity.jpg',
  ),
  ProductItem(
    id: 'p5',
    name: 'NR-OSTRA FZ-JUMBO LUMP CRAB',
    price: 24.50,
    imageUrl:
        'https://eatanytime.in/cdn/shop/files/Artboard2_9508d23c-e023-4424-b2fe-e39176856f33.png?v=1761777624&width=533',
  ),
  ProductItem(
    id: 'p6',
    name: 'NR-OSTRA FZ-SHRIMP TEMPURA',
    price: 14.25,
    imageUrl:
'https://food.fnr.sndimg.com/content/dam/images/food/fullset/2016/6/12/3/FNM070116_Penne-with-Vodka-Sauce-and-Mini-Meatballs-recipe_s4x3.jpg.rend.hgtvcom.616.462.85.suffix/1465939620872.webp'  ),
  ProductItem(
    id: 'p7',
    name: 'NR-OSTRA FZ-MIX SEAFOOD',
    price: 19.80,
    imageUrl:
        'https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=800&q=80',
  ),
  ProductItem(
    id: 'p8',
    name: 'NR-OSTRA FZ-FISH FILLET',
    price: 9.95,
    imageUrl:
        'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=800&q=80',
  ),
   ProductItem(
    id: 'p9',
    name: 'NR-OSTRA FZ-FISH FILLET',
    price: 9.95,
    imageUrl:
        'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=800&q=80',
  ),
   ProductItem(
    id: 'p10',
    name: 'NR-OSTRA FZ-FISH FILLET',
    price: 9.95,
    imageUrl:
        'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=800&q=80',
  ),
   ProductItem(
    id: 'p11',
    name: 'NR-OSTRA FZ-FISH FILLET',
    price: 9.95,
    imageUrl:
        'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=800&q=80',
  ),
   ProductItem(
    id: 'p12',
    name: 'NR-OSTRA FZ-FISH FILLET',
    price: 9.95,
    imageUrl:
        'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=800&q=80',
  ),
];
