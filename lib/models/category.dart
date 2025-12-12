
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Category {
  final String name;
  final String iconName;
  final IconData iconData;

  Category({required this.name, required this.iconName, required this.iconData});
}

// Створюємо глобальний список доступних категорій
final List<Category> availableCategories = [
  Category(name: 'Продукти', iconName: 'carrot', iconData: FontAwesomeIcons.carrot),
  Category(name: 'Ремонт', iconName: 'paintRoller', iconData: FontAwesomeIcons.paintRoller),
  Category(name: 'Подорож', iconName: 'campground', iconData: FontAwesomeIcons.campground),
  Category(name: 'Вечірка', iconName: 'birthdayCake', iconData: FontAwesomeIcons.birthdayCake),
  Category(name: 'Побут', iconName: 'soap', iconData: FontAwesomeIcons.soap),
  Category(name: 'Інше', iconName: 'asterisk', iconData: FontAwesomeIcons.asterisk),
];