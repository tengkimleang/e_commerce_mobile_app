// import 'package:flutter/material.dart';

// class ProductListView extends StatelessWidget {
//   const ProductListView({super.key});

//   static const _sample = [
//     {
//       'id': 'p1',
//       'title': 'TABASCO RED PEPPER SAUCE 150ML',
//       'image': 'https://i.imgur.com/BoN9kdC.png'
//     },
//     {
//       'id': 'p2',
//       'title': 'COCA-COLA 330ML',
//       'image': 'https://allansvending.com/wp-content/uploads/2024/05/coke-products.png'
//     },
//     {
//       'id': 'p3',
//       'title': 'NISSIN INSTANT NOODLE CUP',
//       'image': 'https://www.flavorchem.com/wp-content/uploads/2023/01/1-immunity.jpg'
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Products'), backgroundColor: const Color(0xFFEC407A)),
//       body: ListView.separated(
//         padding: const EdgeInsets.all(12),
//         itemCount: _sample.length,
//         separatorBuilder: (_, __) => const SizedBox(height: 12),
//         itemBuilder: (context, i) {
//           final p = _sample[i];
//           return InkWell(
//             onTap: () {
//               Navigator.of(context).pop({'id': p['id']!, 'title': p['title']!, 'image': p['image']!});
//             },
//             borderRadius: BorderRadius.circular(12),
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
//                 BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
//               ]),
//               child: Row(
//                 children: [
//                   Container(width: 56, height: 56, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]), child: Image.network(p['image']!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))),
//                   const SizedBox(width: 12),
//                   Expanded(child: Text(p['title']!, style: const TextStyle(fontWeight: FontWeight.w600))),
//                   const Icon(Icons.add_circle_outline, color: Color(0xFFEC407A))
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
