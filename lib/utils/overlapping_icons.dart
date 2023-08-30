import 'package:flutter/material.dart';

class OverlappingIncons extends StatelessWidget {
  final Widget? iconBase;
  final Widget? iconOver;
  final Color? colorBase;
  final Color? colorOver;
  final double? size;
  final bool? fullOverlapping;
  const OverlappingIncons({Key? key,required this.iconBase,required this.iconOver, this.colorBase,  this.colorOver, required this.size, this.fullOverlapping}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    double ico1=1.2;
    double ico2=0.01;
    if(fullOverlapping!=null && fullOverlapping!){
      ico1=1;
      ico2=2;
    }
    return SizedBox(
      width: size!,
      height: size!,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size!*ico1,
            height: size!*ico1,
            child: iconBase,
            // decoration: const BoxDecoration(
            //   color: Colors.white,
            //   shape: BoxShape.circle,
            // ),
          ),
          Container(
            child: Container(child: iconOver,width: size!*ico2,height: size!*ico2,),
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


