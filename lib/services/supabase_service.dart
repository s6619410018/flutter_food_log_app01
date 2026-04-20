//คลาสใช้สำหรับเขียนโค้ดคำสั่ง

import 'package:flutter_food_log_app/models/food.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  //ส่วนของเมธอด
  final supabase = Supabase.instance.client;

  //เมธอดสำหรับการทำงาน
  //เพิ่ม ลบ แก้ไข

  //สร้างเมธอดสำหรับการเพิ่มข้อมูลอาหาร
  Future<List<Food>> getAllFood() async {
    //ดึงข้อมูลจากตาราง food ใน Supabase
    final data = await supabase
        .from('food_tb')
        .select('*')
        .order('foodDate', ascending: false);

    //แปลงข้อมูลที่ได้จาก Supabase ให้เป็น Json
    return data.map<Food>((e) => Food.fromJson(e)).toList();
  }

  //สร้างเมธอดสำหรับการเพิ่มข้อมูลอาหาร
  Future insertFood(Food food) async {
    //เพิ่มข้อมูลอาหารลงในตาราง food ใน Supabase
    await supabase.from('food_tb').insert(food.toJson());
  }

  //สร้างเมธอดสำหรับการแก้ไขข้อมูลอาหาร

  Future updateFood(String id, Food food) async {
    //แก้ไขข้อมูลอาหารในตาราง food ใน Supabase
    await supabase.from('food_tb').update(food.toJson()).eq('id', id);
  }

  //สร้างเมธอดสำหรับการลบข้อมูลอาหาร
  Future deleteFood(String id) async {
    //ลบข้อมูลอาหารจากตาราง food ใน Supabase
    await supabase.from('food_tb').delete().eq('id', id);
  }
}
