// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_food_log_app/models/food.dart';
import 'package:flutter_food_log_app/services/supabase_service.dart';
import 'package:intl/intl.dart';

class UpdateDelFoodUi extends StatefulWidget {
  //สร้างตัวแปรเพื่อรับข้อมูลจากหน้า ShowAllFoodUi
  Food? food;

  //เอาตัวยแปรคที่สร้างมารับค่าที่ส่งมาจากหน้า ShowAllFoodUi
  UpdateDelFoodUi({super.key, this.food});

  @override
  State<UpdateDelFoodUi> createState() => _UpdateDelFoodUiState();
}

class _UpdateDelFoodUiState extends State<UpdateDelFoodUi> {
  //ตัวควบคุม TextField
  TextEditingController foodNameCtrl = TextEditingController();
  TextEditingController foodPriceCtrl = TextEditingController();
  TextEditingController foodPersonCtrl = TextEditingController();
  TextEditingController foodDateCtrl = TextEditingController();

  //ตัวแปรเก็บมื้ออาหารที่เลือก
  String foodMeal = 'เช้า';

  //ตัวแปรเก็บวันที่กิน
  DateTime? foodDate;

  //เมธอดเปิดปฏิทินให้ผู้ใช้เลือก แล้วกำหนดค่าวันที่เลือกให้กับตัวแปร foodDate ที่สร้างไว้กับแสดงที่ TextField
  Future<void> pickDate() async {
    //เปิดปฏิทิน
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        //กําหนดค่าให้กับตัวแปร
        foodDate = picked;
        //แสดงที่ TextField
        foodDateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //เอาข้อมูลส่งมาจากหน้า ShowAllFoodUi มาแสดงที่ TextField และปุ่มเลือกมื้ออาหาร
    foodNameCtrl.text = widget.food!.foodName;
    foodMeal = widget.food!.foodMeal;
    foodPriceCtrl.text = widget.food!.foodPrice.toString();
    foodPersonCtrl.text = widget.food!.foodPerson.toString();
    foodDateCtrl.text = widget.food!.foodDate;
    //กำหนดค่าวันที่กินให้กับตัวแปร foodDate ด้วยการแปลงจาก String ที่ได้จาก widget.food!.foodDate ให้เป็น DateTime
    foodDate = DateTime.parse(widget.food!.foodDate);
  }

  //เรียกใช้งานเมธอดบันทึกแก้ไขข้อมูลอาหาร
  void editFood() async {
    //Validate ข้อมูลที่ป้อนเข้ามา
    if (foodNameCtrl.text.isEmpty ||
        foodPriceCtrl.text.isEmpty ||
        foodPersonCtrl.text.isEmpty ||
        foodDateCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบ'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    //แพ็กข้อมูลที่จะส่ง
    Food food = Food(
      foodName: foodNameCtrl.text,
      foodMeal: foodMeal,
      foodPrice: double.parse(foodPriceCtrl.text),
      foodPerson: int.parse(foodPersonCtrl.text),
      foodDate: foodDate!.toIso8601String(),
    );

    //เรียกใช้เมธอดแก้ไขข้อมูล
    //สร้าง instance/object/ตัวแทน ของ SupabaseService
    final service = SupabaseService();
    await service.updateFood(widget.food!.id!, food);
    //แจ้งผลการทำงาน
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    //ย้อนกลับไปหน้า ShowAllFoodUi พร้อมส่งค่ากลับไปเพื่อให้ ShowAllFoodUi รีเฟรชข้อมูล
    Navigator.pop(context);
  }

  //เมธอดลบข้อมูลอาหาร
  Future<void> delFood() async {
    //แสดง Dialog เพื่อยืนยันการลบข้อมูลอาหาร
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("ยืนยันการลบข้อมูล"),
        content: Text("คุณต้องการลบข้อมูลอาหารนี้หรือไม่?"),
        actions: [
          //ปุ่มยกเลิก
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: Text("ยกเลิก", style: TextStyle(color: Colors.white)),
          ),
          //ปุ่มยืนยันการลบ
          ElevatedButton(
            onPressed: () async {
              //เรียกใช้เมธอดลบข้อมูลอาหาร
              final service = SupabaseService();
              await service.deleteFood(widget.food!.id!);
              //แจ้งผลการทำงาน
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('ลบข้อมูลเรียบร้อยแล้ว'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              //ย้อนกลับไปหน้า ShowAllFoodUi พร้อมส่งค่ากลับไปเพื่อให้ ShowAllFoodUi รีเฟรชข้อมูล
              Navigator.pop(context); //ปิด Dialog ก่อน
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("ยืนยัน", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 105, 104, 104),
        title: Text(
          'แซ่บอีหลี (แก้ไข/ลบข้อมูลอาหาร)',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      //ส่วนของ body
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 40, bottom: 50, left: 40, right: 40),
          child: Center(
            child: Column(
              children: [
                // ส่วนแสดง Logo
                Image.asset(
                  'assets/images/logo.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20),
                // ป้อนกินอะไร
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('กินอะไร', style: TextStyle(fontSize: 18)),
                ),
                TextField(
                  controller: foodNameCtrl,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    hintText: 'เช่น KFC, Pizza',
                  ),
                ),
                SizedBox(height: 20),
                // เลือกกินมื้อไหน
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('กินมื้อไหน', style: TextStyle(fontSize: 18)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          foodMeal = 'เช้า';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: foodMeal == 'เช้า'
                            ? Colors.green
                            : Colors.grey,
                      ),
                      child: Text(
                        'เช้า',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          foodMeal = 'กลางวัน';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: foodMeal == 'กลางวัน'
                            ? Colors.green
                            : Colors.grey,
                      ),
                      child: Text(
                        'กลางวัน',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          foodMeal = 'เย็น';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: foodMeal == 'เย็น'
                            ? Colors.green
                            : Colors.grey,
                      ),
                      child: Text(
                        'เย็น',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          foodMeal = 'ว่าง';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: foodMeal == 'ว่าง'
                            ? Colors.green
                            : Colors.grey,
                      ),
                      child: Text(
                        'ว่าง',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // ป้อนกินไปเท่าไหร่
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('กินไปเท่าไหร่', style: TextStyle(fontSize: 18)),
                ),
                TextField(
                  controller: foodPriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    hintText: 'เช่น 299.50',
                  ),
                ),
                SizedBox(height: 20),
                // ป้อนกินกันกี่คน
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('กินกันกี่คน', style: TextStyle(fontSize: 18)),
                ),
                TextField(
                  controller: foodPersonCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    hintText: 'เช่น 3',
                  ),
                ),
                SizedBox(height: 20),
                // เลือกกินไปวันไหน
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('กินไปวันไหน', style: TextStyle(fontSize: 18)),
                ),
                TextField(
                  controller: foodDateCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    hintText: 'เช่น 2020-01-31',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () {
                    //เปิดปฏิทิน ให้ผู้ใช้เลือกแล้วเอามาแสดงที่ TextField นี้
                    pickDate();
                  },
                ),
                SizedBox(height: 20),
                // ปุ่มบันทึก
                ElevatedButton(
                  onPressed: () {
                    //เรียกใช้เมธอดบันทึกแก้ไขข้อมูลอาหาร
                    editFood();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    fixedSize: Size(MediaQuery.of(context).size.width, 50),
                  ),
                  child: Text(
                    "บันทึกแก้ไข",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                // ปุ่มยกเลิก
                ElevatedButton(
                  onPressed: () {
                    delFood().then((value) {
                      //ย้อนกลับไปหน้า ShowAllFoodUi พร้อมส่งค่ากลับไปเพื่อให้ ShowAllFoodUi รีเฟรชข้อมูล
                      Navigator.pop(context);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    fixedSize: Size(MediaQuery.of(context).size.width, 50),
                  ),
                  child: Text(
                    "ลบข้อมูล",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
