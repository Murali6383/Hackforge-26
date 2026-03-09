import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/volunteer_model.dart';
import '../widgets/volunteer_card.dart';

/// Volunteer emergency network screen
class VolunteerScreen extends StatelessWidget {
  const VolunteerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final volunteers = [
      VolunteerModel(id:'v1',name:'Rahul Verma',phone:'+919876543220',latitude:28.6149,longitude:77.2090,distance:0.3,isAvailable:true,emergenciesHandled:12,rating:4.8),
      VolunteerModel(id:'v2',name:'Sneha Gupta',phone:'+919876543221',latitude:28.6170,longitude:77.2110,distance:0.7,isAvailable:true,emergenciesHandled:8,rating:4.9),
      VolunteerModel(id:'v3',name:'Amit Patel',phone:'+919876543222',latitude:28.6200,longitude:77.2050,distance:1.2,isAvailable:true,emergenciesHandled:5,rating:4.5),
      VolunteerModel(id:'v4',name:'Deepa Nair',phone:'+919876543223',latitude:28.6100,longitude:77.2150,distance:1.5,isAvailable:false,status:'responding',emergenciesHandled:20,rating:5.0),
    ];
    final available = volunteers.where((v) => v.isAvailable).toList();
    final busy = volunteers.where((v) => !v.isAvailable).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Volunteer Network')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0x3343A047), Color(0x0D43A047)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x4D43A047)),
              ),
              child: Row(children: [
                Container(width:50,height:50,decoration: const BoxDecoration(color:Color(0x3343A047),shape:BoxShape.circle),child: const Icon(Icons.group,color:AppColors.safe,size:26)),
                const SizedBox(width:14),
                Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  const Text('Nearby Volunteers',style:TextStyle(color:Colors.white,fontSize:16,fontWeight:FontWeight.w700)),
                  Text('${available.length} available within 2 km',style: const TextStyle(color:AppColors.textSecondary,fontSize:12)),
                ])),
              ]),
            ),
            const SizedBox(height:24),
            Text('Available (${available.length})',style: const TextStyle(color:Colors.white,fontSize:16,fontWeight:FontWeight.w700)),
            const SizedBox(height:12),
            ...available.map((v)=>VolunteerCard(volunteer:v)),
            if(busy.isNotEmpty)...[
              const SizedBox(height:24),
              Text('Currently Busy (${busy.length})',style: const TextStyle(color:AppColors.textSecondary,fontSize:16,fontWeight:FontWeight.w700)),
              const SizedBox(height:12),
              ...busy.map((v)=>VolunteerCard(volunteer:v)),
            ],
          ],
        ),
      ),
    );
  }
}
