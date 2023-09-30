import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'product_details_page.dart';



class ProductPage extends StatelessWidget {

  Widget _buildProduct({String? name, double? price , String? image}) {
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
                      image: DecorationImage(image : AssetImage("lib/images/$image"),)
                    ),
                  ),
                  Text("\$ $price",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xfff9b96d6)),),
                  Text("$name",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xfff9b96d6)),)
                ]),
            ), 
          );
  }

  Widget _buildCategory(String image , int color) {
    return CircleAvatar(
              maxRadius: 41,
              backgroundColor: Color(color),
              child: Container(
                height: 40,
                width: 35,
                child: Image(
                  color: Colors.white,
                  image: AssetImage("lib/images/$image")
                ),
              ),

            ); 
  }
  
  final String loggedInUserEmail;

  const ProductPage({Key? key, required this.loggedInUserEmail})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(

        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search Something",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30)
                )
              ),
            ),
            Container(
              height: 120,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:<Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget> [
                  Text(
                    "Products",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  Text(
                    "See All",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)
                    )],
                )
              ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              
                  Row(children: <Widget>[
                  _buildProduct(image: "Shirt.png" , price: 30.0 , name: "Mens Long Sleeve T-Shirt"),
                  _buildProduct(image: "Shirt.png" , price: 30.0 , name: "Mens Long Sleeve T-Shirt"),
              
                ],),
                Row(children: <Widget>[
                  _buildProduct(image: "Shirt.png" , price: 30.0 , name: "Mens Long Sleeve T-Shirt"),
                  _buildProduct(image: "Shirt.png" , price: 30.0 , name: "Mens Long Sleeve T-Shirt"),
              
                ],),
                Container(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                  Text(
                    "Categories",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  Text(
                    "See All",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)
                    )
                    ],
                  ),
                ),
                Container(
                  height: 60,
                  child: Row(
                    children: <Widget>[
                      _buildCategory( "t-shirt.svg" , 0xffDB76E4 ),
                      _buildCategory("trousers.png" , 0xff5CC9EB),
                      _buildCategory("hand-watch.png" , 0xff5BE5A3),
                      _buildCategory("sport-shoe.png" , 0xffEB8181),
                      _buildCategory("tie.png" , 0xffD3CD4C)
                    ],
                  ),
                )
                
                ],
            ),
          ],
        ),
      )
    );
  }
}
