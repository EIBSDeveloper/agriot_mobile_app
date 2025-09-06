import 'package:argiot/src/app/widgets/bg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_images.dart';
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
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Mobile Number OR Email',
                                    ),
                                    controller: mobileNumber,
                                    onChanged: (phone) {
                                      controller.mobileNumber.value = phone;
                                    },
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 30),
                                  Obx(
                                    () => PrimaryButton(
                                      text: 'Continue',
                                      isLoading: controller.isLoading.value,
                                      onPressed: () {
                                        if (controller
                                            .mobileNumber
                                            .value
                                            .isNotEmpty) {
                                          controller.sendOtp();
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 60),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                    ),
                                    child: GoogleSignInButton(
                                      onPressed: () async {
                                        controller.signInWithGoogle();
                                      },
                                    ),
                                  ),

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
    );
  }

  Widget component1(
    IconData icon,
    String hintText,
    bool isPassword,
    bool isEmail,
  ) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.width / 8,
      width: size.width / 1.22,
      alignment: Alignment.center,
      padding: EdgeInsets.only(right: size.width / 30),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.black.withOpacity(.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        style: TextStyle(color: Colors.black.withOpacity(.8)),
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black.withOpacity(.7)),
          border: InputBorder.none,
          hintMaxLines: 1,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.black.withOpacity(.5),
          ),
        ),
      ),
    );
  }

  Widget component2(String string, double width, VoidCallback voidCallback) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: voidCallback,
      child: Container(
        height: size.width / 8,
        width: size.width / width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Get.theme.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          string,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

