import 'package:flutter/material.dart';

class OverlappingIncons extends StatelessWidget {
  final Icon? iconBase;
  final Icon? iconOver;
  final Color? colorBase;
  final Color? colorOver;
  final double? size;
  const OverlappingIncons({Key? key,required this.iconBase,required this.iconOver, this.colorBase,  this.colorOver, required this.size}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size!,
      height: size!,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size!*1.2,
            height: size!*1.2,
            child: iconBase,
            // decoration: const BoxDecoration(
            //   color: Colors.white,
            //   shape: BoxShape.circle,
            // ),
          ),
          Container(
            child: Container(child: iconOver,width: size!*0.01,height: size!*0.01,),
            // decoration: const BoxDecoration(
            //   color: Colors.white,
            //   shape: BoxShape.circle,
            // ),
          ),
        ],
      ),
    );
  }
}


