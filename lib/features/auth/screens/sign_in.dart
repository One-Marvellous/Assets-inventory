import 'package:assets_inventory_app_ghum/common/widgets/link_text.dart';
import 'package:assets_inventory_app_ghum/common/widgets/my_button.dart';
import 'package:assets_inventory_app_ghum/common/widgets/my_textfield.dart';
import 'package:assets_inventory_app_ghum/common/widgets/textfield_description.dart';
import 'package:assets_inventory_app_ghum/helpers/validator.dart';
import 'package:assets_inventory_app_ghum/services/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool obscureText = true;
  bool isSignUp = false;
  final signUpFormKey = GlobalKey<FormState>();
  final signInFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(authControllerProvider);
    return isSignUp
        ? Scaffold(
            body: Container(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Center(
                        child: Text(
                          'Create an Account',
                          style: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Form(
                          key: signUpFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TextFieldDescription(text: "Name"),
                              const SizedBox(height: 5),
                              MyTextfield(
                                prefixIcon: const Icon(Icons.person),
                                controller: nameController,
                                hintText: "John Doe",
                                validator: (value) =>
                                    Validator.validateName(value),
                              ),
                              const SizedBox(height: 20),
                              const TextFieldDescription(text: "Email"),
                              const SizedBox(height: 5),
                              MyTextfield(
                                prefixIcon: const Icon(Icons.email),
                                keyboardType: TextInputType.emailAddress,
                                controller: emailController,
                                hintText: "Johndoe@gmail.com",
                                validator: (value) =>
                                    Validator.validateEmail(value),
                              ),
                              const SizedBox(height: 20.0),
                              const TextFieldDescription(text: "Password"),
                              const SizedBox(height: 5),
                              MyTextfield(
                                maxLines: 1,
                                obscureText: obscureText,
                                suffixIcon: IconButton(
                                  onPressed: showPassword,
                                  icon: Icon(obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                                prefixIcon: const Icon(Icons.lock),
                                controller: passwordController,
                                hintText: "*********",
                                textCapitalization: TextCapitalization.none,
                                validator: (value) =>
                                    Validator.validatePassword(value),
                              ),
                            ],
                          )),
                      const SizedBox(height: 20.0),
                      MyButton(
                          isLoading: isLoading,
                          onPressed: () {
                            FocusScope.of(context).unfocus();

                            signUp(
                                email: emailController.text.trim(),
                                name: nameController.text.trim(),
                                password: passwordController.text.trim(),
                                context: context);
                          },
                          text: "Sign Up"),
                      const SizedBox(
                        height: 40,
                      ),
                      Center(
                        child: LinkText(
                            preText: "Already have an account? ",
                            linkText: "Sign In",
                            onTap: changeState),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        // Sign in
        : Scaffold(
            body: Container(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Center(
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Form(
                          key: signInFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TextFieldDescription(text: "Email"),
                              const SizedBox(height: 5),
                              MyTextfield(
                                prefixIcon: const Icon(Icons.email),
                                keyboardType: TextInputType.emailAddress,
                                controller: emailController,
                                hintText: "Johndoe@gmail.com",
                                validator: (value) =>
                                    Validator.validateEmail(value),
                              ),
                              const SizedBox(height: 20.0),
                              const TextFieldDescription(text: "Password"),
                              const SizedBox(height: 5),
                              MyTextfield(
                                maxLines: 1,
                                obscureText: obscureText,
                                suffixIcon: IconButton(
                                  onPressed: showPassword,
                                  icon: Icon(obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                                prefixIcon: const Icon(Icons.lock),
                                controller: passwordController,
                                hintText: "*********",
                                textCapitalization: TextCapitalization.none,
                                validator: (value) =>
                                    Validator.validatePassword(value),
                              ),
                            ],
                          )),
                      const SizedBox(height: 20.0),
                      MyButton(
                          isLoading: isLoading,
                          onPressed: () {
                            FocusScope.of(context).unfocus();

                            signIn(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                context: context);
                          },
                          text: "Sign In"),
                      const SizedBox(
                        height: 40,
                      ),
                      Center(
                        child: LinkText(
                            preText: "Don't have an account? ",
                            linkText: "Sign Up",
                            onTap: changeState),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  void changeState() {
    setState(() {
      isSignUp = !isSignUp;
    });
  }

  void showPassword() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  void signIn(
      {required String email,
      required String password,
      required BuildContext context}) {
    if (signInFormKey.currentState!.validate()) {
      ref
          .watch(authControllerProvider.notifier)
          .signInWithEmailAndPassword(email, password, context);
    }
  }

  void signUp({
    required String email,
    required String name,
    required String password,
    required BuildContext context,
  }) {
    if (signUpFormKey.currentState!.validate()) {
      ref
          .watch(authControllerProvider.notifier)
          .signUpWithEmailAndPassword(name, email, password, context);
    }
  }
}

const Color kPrimaryColor = Color.fromARGB(255, 0, 150, 80);
