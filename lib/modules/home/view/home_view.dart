import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
	const HomeView({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: const Color(0xFFEC407A),
				elevation: 0,
				title: const Text("Chip Mong", style: TextStyle(fontWeight: FontWeight.bold)),
        
				actions: [
					IconButton(
						icon: const Icon(Icons.menu),
						onPressed: () {},
					),
				],
        toolbarHeight: 220,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						const Text(
							"Login or Sign up",
							style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: Colors.black87),
						),
						const SizedBox(height: 20),
						Card(
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
							child: Column(
								children: [
									ClipRRect(
										borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
										child: Image.network(
											'https://www.chipmong.com/wp-content/uploads/2020/04/2.Chip-mong-Supermarket-.jpg',
											fit: BoxFit.cover,
											height: 180,
											width: double.infinity,
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
						Card(
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
							child: Column(
								children: [
									ClipRRect(
										borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
										child: Image.network(
											'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
											fit: BoxFit.cover,
											height: 180,
											width: double.infinity,
										),
									),
									const Padding(
										padding: EdgeInsets.all(16),
										child: Row(
											children: [
												Expanded(
													child: Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Text("Chip Mong Supermarket", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
															Text("Explore our marketplace.", style: TextStyle(fontSize: 16, color: Colors.grey)),
														],
													),
												),
											],
										),
									),
								],
							),
						),
					],
				),
			),
		);
	}
}