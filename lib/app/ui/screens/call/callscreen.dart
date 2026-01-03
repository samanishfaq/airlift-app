import 'package:airlift/commons/colors.dart';
import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  final String peerName;
  final bool isIncoming; 

  const CallScreen({super.key, required this.peerName, this.isIncoming = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black87,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              child: Text(peerName[0], style: const TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 20),
            Text(
              isIncoming ? "Incoming call from $peerName" : "Calling $peerName",
              style: const TextStyle(color: AppColors.textWhite, fontSize: 22),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isIncoming)
                  ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, shape: const CircleBorder(), padding: const EdgeInsets.all(20)),
                    child: const Icon(Icons.call, color: AppColors.textWhite, size: 32),
                  ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); 
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed, shape: const CircleBorder(), padding: const EdgeInsets.all(20)),
                  child: const Icon(Icons.call_end, color: AppColors.textWhite, size: 32),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
