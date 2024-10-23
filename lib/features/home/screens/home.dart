import 'package:assets_inventory_app_ghum/common/models/office.dart';
import 'package:assets_inventory_app_ghum/features/home/controllers/office_list_provider.dart';
import 'package:assets_inventory_app_ghum/features/home/widgets/drawer.dart';
import 'package:assets_inventory_app_ghum/common/widgets/office_tile.dart';
import 'package:assets_inventory_app_ghum/features/home/widgets/sub_office_widget.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/search_screen.dart';
import 'package:assets_inventory_app_ghum/services/controller/office_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  late Future<List<Office>> _getOfficeList;

  @override
  void initState() {
    super.initState();
    _getOfficeList = getOfficeList(ref);
  }

  Future<List<Office>> getOfficeList(WidgetRef ref) async {
    return ref.read(officeControllerProvider.notifier).getOfficeList();
  }

  Future<void> refreshData(WidgetRef ref) async {
    setState(() {
      _getOfficeList = getOfficeList(ref);
    });
  }

  void navigateToSearch() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SearchInventoryScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    List<Office> offices = ref.watch(officeListProvider);
    List<String> officesName = offices.map((e) => e.name).toList();

    return Scaffold(
        drawer: offices.isEmpty ? null : const MyDrawer(),
        appBar: AppBar(
          centerTitle: true,
          title: const CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 30,
            child: Image(image: AssetImage("assets/images/abia_logo.png")),
          ),
          surfaceTintColor: Colors.transparent,
          actions: offices.isEmpty
              ? null
              : [
                  IconButton(
                      onPressed: navigateToSearch,
                      icon: const Icon(Icons.search))
                ],
        ),
        body: RefreshIndicator(
          onRefresh: () => refreshData(ref),
          child: CustomScrollView(
            slivers: [
              FutureBuilder(
                future: _getOfficeList,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    default:
                      if (snapshot.hasData) {
                        return SliverList.builder(
                          itemCount: officesName.length,
                          itemBuilder: (context, index) {
                            var officeName = officesName[index];
                            var selectedOffice = offices.firstWhere(
                                (office) => office.name == officeName);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: OfficeTile(
                                name: officeName,
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SubOfficeWidget(
                                          office: selectedOffice),
                                    )),
                              ),
                            );
                          },
                        );
                      } else {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "Error, pull down to refresh.",
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }
                  }
                },
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 50),
              ),
            ],
          ),
        ));
  }
}
