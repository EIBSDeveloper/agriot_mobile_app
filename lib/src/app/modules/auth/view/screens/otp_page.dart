import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../../core/app_images.dart';
import '../../../../widgets/background_image.dart';
import '../../../../widgets/primary_button.dart';
import '../../controller/auth_controller.dart';
import '../widgets/my_behavior.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _transform;
  TextEditingController otp = TextEditingController();
  AuthController controller = Get.put(AuthController());
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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

    Future.delayed(const Duration(seconds: 4), () {
      otp.text = controller.tempOtp.value;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isTablet = size.width >= 600; // Tablet breakpoint

    Widget otpForm = Container(
      width: isTablet ? size.width * 0.4 : size.width * 0.9,
      height: isTablet ? size.height * 0.7 : size.width * 0.95,
      margin: const EdgeInsets.only(top: 70),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('OTP Verification', style: Get.theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: 'Enter the OTP sent to ',
                  style: Get.theme.textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: controller.mobileNumber.value,
                      style: Get.theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PinCodeTextField(
                controller: otp,
                appContext: context,
                length: 4,
                onChanged: (value) {
                  controller.otp.value = value;
                },
                onCompleted: (vlu) {
                  controller.verifyOtp();
                },
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  activeFillColor: Colors.white,
                  activeColor: Get.theme.primaryColor,
                  selectedColor: Get.theme.primaryColor,
                  inactiveColor: Colors.black,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ),
          Column(
            children: [
              Obx(
                () => PrimaryButton(
                  text: 'Verify OTP',
                  isLoading: controller.isLoading.value,
                  onPressed: () {
                    if (controller.otp.value.length == 4) {
                      controller.verifyOtp();
                    } else {
                     showWarning(
                      'Please enter 4-digit OTP',
                     );
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    controller.sendOtp();
                  },
                  child: Text(
                    "Didn't receive OTP? Resend",
                    style: Get.theme.textTheme.bodyMedium!.copyWith(
                      color: Get.theme.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    Widget logoWidget = SizedBox(
      width: 200,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(AppImages.logo),
      ),
    );

    return BackgroundImage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              controller.currentStep.value = 0;
              Get.back();
            },
          ),
          elevation: 0,
        ),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: SingleChildScrollView(
            child: SizedBox(
              height: size.height,
              child: Container(
                alignment: Alignment.center,
                child: Opacity(
                  opacity: _opacity.value,
                  child: Transform.scale(
                    scale: _transform.value,
                    child: isTablet
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Center(child: logoWidget),
                              ),
                              Expanded(flex: 2, child: Center(child: otpForm)),
                            ],
                          )
                        : Stack(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [otpForm],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [logoWidget],
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
}
