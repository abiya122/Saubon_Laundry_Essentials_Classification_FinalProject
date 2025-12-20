class LaundryItem {
  final int id;
  final String name;
  final String imagePath;
  final String description;

  const LaundryItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.description,
  });
}

const List<LaundryItem> laundryItems = [
  LaundryItem(
    id: 0,
    name: 'Iron',
    imagePath: 'assets/images/Iron.jpg',
    description: 'A device used to remove wrinkles from fabric using heat and pressure.',
  ),
  LaundryItem(
    id: 1,
    name: 'Iron Board',
    imagePath: 'assets/images/Iron Board.jpg',
    description: 'A flat, padded board used as a surface for ironing clothes.',
  ),
  LaundryItem(
    id: 2,
    name: 'Clothes Hanger',
    imagePath: 'assets/images/Clothes Hanger.jpg',
    description: 'A device in the shape of human shoulders used to hang clothes.',
  ),
  LaundryItem(
    id: 3,
    name: 'Laundry Basket',
    imagePath: 'assets/images/Laundry Basket.jpg',
    description: 'A container used for holding dirty clothes before washing or clean clothes after.',
  ),
  LaundryItem(
    id: 4,
    name: 'Clothesline',
    imagePath: 'assets/images/Clothesline.jpg',
    description: 'A cord or rope stretched between two points on which clothes are hung to dry.',
  ),
  LaundryItem(
    id: 5,
    name: 'Laundry Detergent',
    imagePath: 'assets/images/Laundry Detergent.jpg',
    description: 'A chemical substance used for cleaning laundry.',
  ),
  LaundryItem(
    id: 6,
    name: 'Fabric Softener',
    imagePath: 'assets/images/Fabric Softener.jpg',
    description: 'A liquid composition added to washing machines to soften clothes.',
  ),
  LaundryItem(
    id: 7,
    name: 'Lint Roller',
    imagePath: 'assets/images/Lint Roller.jpg',
    description: 'A roll of adhesive paper mainly used to remove lint or pet hair from textile.',
  ),
  LaundryItem(
    id: 8,
    name: 'Washing Machine',
    imagePath: 'assets/images/Washing Machine.jpg',
    description: 'A home appliance used to wash laundry.',
  ),
  LaundryItem(
    id: 9,
    name: 'Dryer',
    imagePath: 'assets/images/Dryer.jpg',
    description: 'A powered household appliance that is used to remove moisture from a load of clothing.',
  ),
];
