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
      ? Padding(
          padding: EdgeInsets.only(top: Get.size.height * 0.1),
          child: Center(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Get.theme.colorScheme.onPrimaryContainer,
                      Get.theme.colorScheme.onPrimaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        AppImages.landMark,
                        width: 320,
                        height: 240,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Land Added Yet!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Get.theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start by adding your land to explore opportunities.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Get.theme.primaryColor,
                          elevation: 0,
                        ),
                        onPressed: () {
                          Get.toNamed(Routes.addLand)?.then((result) {
                            if (result ?? false) {
                              refresh?.call();
                            }
                          });
                        },
                        child: const Text(
                          "Add Your Land",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      : const SizedBox.shrink();
}
