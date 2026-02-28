import 'package:flutter/material.dart';
import 'supermarket_main_view.dart';

class HomeView extends StatelessWidget {
	const HomeView({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: const Color(0xFFEC407A),
				elevation: 0,
        flexibleSpace: const Padding(
        padding: EdgeInsets.only(left: 16, bottom: 30, right: 70),  // ← adjust these numbers
        child: Align(
          alignment: Alignment.bottomLeft,        // title sticks to bottom
          child: Text(
        'Login or Signup',
        style: TextStyle(fontSize: 15, color: Colors.white),
      ),
    ),
  ),
				actions: [
					IconButton(
						icon: const Icon(Icons.menu,color: Colors.white,),
						onPressed: () {},
					),
				],
        toolbarHeight: 220,
        shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(32),
        )
        ),
        automaticallyImplyLeading: false,   // No back arrow
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.end,
					children: [
						
						const SizedBox(height: 20),
						Card(
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
							child: Column(
								children: [
									ClipRRect(
										borderRadius: const BorderRadius.vertical(top: Radius.circular(16),),
										child: Image.network(
											'https://www.chipmong.com/wp-content/uploads/2020/04/2.Chip-mong-Supermarket-.jpg',
											fit: BoxFit.cover,
											height: 180,
											width: double.infinity
										),
									),
									const Padding(
										padding: EdgeInsets.all(16),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text("Chip Mong Mall", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
												Text("Shopping global brand", style: TextStyle(fontSize: 16, color: Colors.grey)),
											],
										),
									),
								],
							),
						),
						const SizedBox(height: 16),
					InkWell(
						onTap: () {
							Navigator.of(context).push(
								MaterialPageRoute(
									builder: (_) => const SupermarketMainView(),
								),
							);
						},
						borderRadius: BorderRadius.circular(16),
						child: Card(
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
							child: Column(
								children: [
									ClipRRect(
										borderRadius: const BorderRadius.vertical(top: Radius.circular(16),),
										child: Image.network(
											'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
											fit: BoxFit.cover,
											height: 180,
											width: double.infinity
										),
									),
									const Padding(
										padding: EdgeInsets.all(16),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text("Chip Mong Supermarket", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,)),
												Text("Explore our marketplace.", style: TextStyle(fontSize: 16, color: Colors.grey)),
											],
										),
									),
								],
							),
						),
					),
			
					
					],
				),
			),
		);
	}
}