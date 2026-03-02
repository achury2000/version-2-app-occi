// Modelos para la aplicación
class Tour {
  final String id;
  final String name;
  final String description;
  final String image;
  final double rating;
  final double price;
  final String location;
  final String duration;

  Tour({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.rating,
    required this.price,
    required this.location,
    required this.duration,
  });
}

class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.phone,
  });
}
