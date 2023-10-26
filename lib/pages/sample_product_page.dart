import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:new_app/pages/ProductList.dart';

class ProductPage extends StatelessWidget {
  final List<Widget> carouselItems = [
    Image.asset("lib/images/spring-fashion-sale-banner-design-template_2239-1180.png"),
    Image.asset("lib/images/Carousel1.jpg"),
    Image.asset("lib/images/carousel2.jpeg"),
  ];

  Widget _buildProduct({String? name, double? price, String? image}) {
    return Card(
      child: Container(
        height: 210,
        width: 180,
        child: Column(
          children: <Widget>[
            Container(
              height: 145,
              width: 140,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("lib/images/$image"),
                ),
              ),
            ),
            Text(
              "\$ $price",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xfff9b96d6),
              ),
            ),
            Text(
              "$name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xfff9b96d6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String image, int color) {
    return CircleAvatar(
      maxRadius: 37,
      backgroundColor: Color(color),
      child: Container(
        height: 40,
        width: 40,
        child: Image(
          color: Colors.white,
          image: AssetImage("lib/images/$image"),
        ),
      ),
    );
  }

  final String loggedInUserEmail;

   ProductPage({Key? key, required this.loggedInUserEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              CarouselSlider(
                items: carouselItems,
                options: CarouselOptions(
                  height: 240,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 1.0, // Display one item at a time
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "search".tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              Container(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "category".tr,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "seeall".tr,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                height: 60,
                child: Row(
                  children: <Widget>[
                    _buildCategory("shirtCat.webp", 0xffDB76E4),
                    _buildCategory("trousers.png", 0xff5CC9EB),
                    _buildCategory("Watch.png", 0xff5BE5A3),
                    _buildCategory("ShoeCat.png", 0xffEB8181),
                    _buildCategory("TieCat.png", 0xffD3CD4C),
                  ],
                ),
              ),
              Container(
                height: 120,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "product".tr,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProductsView(),
                              ),
                            );
                          },
                          child: Text(
                            "seeall".tr,
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _buildProduct(image: "Shirt.png", price: 30.0, name: "Mens Long Sleeve T-Shirt"),
                      _buildProduct(image: "trousers.png", price: 100.0, name: "Mens Trouser"),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      _buildProduct(image: "Watch.png", price: 150.0, name: "Timewear Mens Watch"),
                      _buildProduct(image: "ShoeCat.png", price: 60.0, name: "Nike Shoe"),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
