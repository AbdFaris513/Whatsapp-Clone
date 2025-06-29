import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_clone/utils/my_colors.dart';
import 'package:whatsapp_clone/widget/search.dart';

class ChatMenusList extends StatelessWidget {
  const ChatMenusList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChartMenuAppBar(),
        SizedBox(height: 12),
        ChartMenuSearchBar(),
        SizedBox(height: 12),
        ChartMenuCategories(
          categoriesList: ['All', 'Unread', 'Favourites', 'Groups'],
        ),
        SizedBox(height: 12),
      ],
    );
  }
}

class ChartMenuCategories extends StatefulWidget with MyColors {
  final List<String> categoriesList;
  const ChartMenuCategories({super.key, required this.categoriesList});

  @override
  State<ChartMenuCategories> createState() => _ChartMenuCategoriesState();
}

class _ChartMenuCategoriesState extends State<ChartMenuCategories>
    with MyColors {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categoriesList.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? MyColors.cetagorySelectedContainerBackgroundColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: MyColors.cetagoryContainerBorderColor,
                ),
              ),
              child: Center(
                child: Text(
                  widget.categoriesList[index],
                  style: GoogleFonts.roboto(
                    color: isSelected
                        ? MyColors.cetagorySelectedContainerForegroundColor
                        : MyColors.searchHintTextColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChartMenuAppBar extends StatelessWidget with MyColors {
  const ChartMenuAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Chats',
          style: GoogleFonts.roboto(
            color: MyColors.foregroundColor,
            fontWeight: FontWeight.w900,
            fontSize: 34,
          ),
        ),
        Row(
          children: [
            SvgPicture.asset("assets/camera.svg", width: 25, height: 25),
            SizedBox(width: 6),
            CircleAvatar(radius: 14, child: Icon(Icons.add)),
          ],
        ),
      ],
    );
  }
}
