import 'all_imports.dart';

class ImageBox extends StatelessWidget {
  const ImageBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width / 2) - 24,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text("PHOTO", style: TextStyle(color: Colors.grey)),
          Positioned(
            right: 5,
            bottom: 5,
            child: Column(
              children: const [
                Icon(Icons.photo, size: 24, color: Colors.black54),
                SizedBox(height: 6),
                Icon(Icons.camera_alt, size: 24, color: Colors.black54),
              ],
            ),
          )
        ],
      ),
    );
  }
}