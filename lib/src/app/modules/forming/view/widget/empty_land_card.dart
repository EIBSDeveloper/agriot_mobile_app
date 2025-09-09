import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:argiot/src/core/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class EmptyLandCard extends StatelessWidget {
  const EmptyLandCard({super.key, required this.refresh, this.view = false});

  final void Function()? refresh;
  final bool view;

  @override
  Widget build(BuildContext context) => view
      ? Container(
          margin: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Image.asset(
                AppImages.landMark,
                width: 300,
                height: 250,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 8,),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(Routes.addLand)?.then((result) {
                      if (result ?? false) {
                        refresh?.call();  
                      }
                    });
                  },
                  child: const Text("Add Your Land"),
                ),
              ),
            ],
          ),
        )
      : const SizedBox.shrink();
}
