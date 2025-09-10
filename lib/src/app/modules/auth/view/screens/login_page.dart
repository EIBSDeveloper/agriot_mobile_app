import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../../core/app_images.dart';
import '../../../../../core/app_style.dart';
import '../../../../service/utils/utils.dart';
import '../../../../widgets/background_image.dart';
import '../../../../widgets/primary_button.dart';
import '../../controller/auth_controller.dart';
import '../widgets/my_behavior.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _transform;
  AuthController controller = Get.put(AuthController());
  final TextEditingController mobileNumber = TextEditingController();

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _opacity =
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _controller, curve: Curves.ease),
        )..addListener(() {
          setState(() {});
        });

    _transform = Tween<double>(begin: 2, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastLinearToSlowEaseIn,
      ),
    );

    _controller.forward();
    mobileNumber.text = controller.mobileNumber.value;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    controller.dispose();
    mobileNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isTablet = size.width >= 600; // Typical breakpoint for tablets

    return BackgroundImage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: SingleChildScrollView(
            child: SizedBox(
              height: size.height,
              child: Form(
                key: controller.formKey,
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: size.height * 0.3),
                  child: Opacity(
                    opacity: _opacity.value,
                    child: Transform.scale(
                      scale: _transform.value,
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: isTablet ? 400 : size.width * 0.9,
                                height: size.height * 0.8,

                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  // mainAxisAlignment:
                                  //     MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const SizedBox(height: 150),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        boxShadow: AppStyle.boxShadow,
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'Mobile Number OR Email',
                                          border: InputBorder.none,
                                        ),
                                        controller: mobileNumber,
                                        onChanged: (phone) {
                                          controller.mobileNumber.value = phone;
                                        },
                                        validator: (value) {
                                          if (isValidMobile(value!) ||
                                              isValidEmail(value)) {
                                            return null;
                                          } else {
                                            return 'Invalid input';
                                          }
                                        },
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Obx(
                                      () => PrimaryButton(
                                        text: 'Continue',
                                        isLoading: controller.isLoading.value,
                                        onPressed: () {
                                          controller.sendOtp();
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 60),
                                    Obx(() {
                                      if (controller.isLoading.value) {
                                        return LoadingAnimationWidget.waveDots(
                                          color: Get.theme.primaryColor,
                                          size: 100,
                                        );
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                        ),
                                        child: GoogleSignInButton(
                                          onPressed: () async {
                                            controller.signInWithGoogle();
                                          },
                                        ),
                                      );
                                    }),

                                    const SizedBox(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                height: 100,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(AppImages.logo),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
