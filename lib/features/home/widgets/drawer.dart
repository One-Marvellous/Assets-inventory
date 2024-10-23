import 'package:assets_inventory_app_ghum/common/utils.dart';
import 'package:assets_inventory_app_ghum/features/auth/provider/user_provider.dart';
import 'package:assets_inventory_app_ghum/features/auth/screens/sign_in.dart';
import 'package:assets_inventory_app_ghum/features/home/models/drawer_model.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/maintenance_preview.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/new_inventory.dart';
import 'package:assets_inventory_app_ghum/features/inventory/widgets/logout_dialog.dart';
import 'package:assets_inventory_app_ghum/features/reports/screen/report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyDrawer extends ConsumerStatefulWidget {
  const MyDrawer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyDrawerState();
}

class _MyDrawerState extends ConsumerState<MyDrawer> {
  List<DrawerModel> drawer = [
    DrawerModel(
        iconName: "New inventory",
        icon: Icons.add_box,
        navigationDestination: const NewInventory()),
    DrawerModel(
        iconName: "Maintenance",
        icon: Icons.build,
        navigationDestination: const MaintenancePreviewScreen()),
    DrawerModel(
        iconName: "Login",
        icon: Icons.login,
        navigationDestination: const SignInScreen()),
    DrawerModel(
        iconName: "Reports",
        icon: Icons.edit_document,
        navigationDestination: const Reports())
  ];

  @override
  Widget build(BuildContext context) {
    var user = ref.watch(userProvider);
    return Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        child: CustomScrollView(slivers: [
          const SliverToBoxAdapter(
            child: DrawerHeader(
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 50,
                child: Image(image: AssetImage("assets/images/abia_logo.png")),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: drawer.length,
            itemBuilder: (context, index) {
              var item = drawer[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    if (index == 0 && user?.role == 'admin') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => item.navigationDestination,
                          ));
                    } else if (index == 0) {
                      showSnackbar(
                          context, "Only Admin has access to this feature");
                    } else if (index == 2 && user != null) {
                      showDialog(
                        context: context,
                        builder: (context) => const LogoutDialog(),
                      );
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => item.navigationDestination,
                          ));
                    }
                  },
                  leading: Icon(
                      (index == 2 && user != null) ? Icons.logout : item.icon),
                  title: Text(
                      (index == 2 && user != null) ? "Logout" : item.iconName),
                ),
              );
            },
          ),
        ]));
  }
}
