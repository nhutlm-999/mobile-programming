import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab3/database/database_helper.dart';
import 'package:lab3/model/brand.dart';
import 'package:lab3/providers/brand_notifier.dart';

class BrandListScreen extends ConsumerStatefulWidget {
  const BrandListScreen({super.key});

  @override
  ConsumerState<BrandListScreen> createState() => _BrandListScreenState();
}

class _BrandListScreenState extends ConsumerState<BrandListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _showBrandDialog({Brand? brand}) async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final countryCtrl = TextEditingController();
    final foundedYearCtrl = TextEditingController(
      text: brand != null ? brand.foundedYear.toString() : '',
    );
    String? dupplicateError;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(brand == null ? 'Add Brand' : 'Edit Brand'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Brand Name',
                        errorText: dupplicateError,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter brand name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: countryCtrl,
                      decoration: const InputDecoration(labelText: 'Country'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter country';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: foundedYearCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Founded Year',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter founded year';
                        }
                        final year = int.tryParse(value.trim());
                        if (year == null ||
                            year <= 1900 ||
                            year > DateTime.now().year) {
                          return 'Please enter a valid year';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => setDialogState(() async {
                    dupplicateError = null;
                    if (!formKey.currentState!.validate()) return;

                    final isDup = await DatabaseHelper.instance
                        .isBrandNameDuplicate(
                          nameCtrl.text.trim(),
                          excludeId: brand?.id,
                        );

                    if (isDup) {
                      setDialogState(() {
                        dupplicateError = 'Brand name already exists';
                      });
                      return;
                    }

                    final newBrand = Brand(
                      id: brand?.id,
                      brandName: nameCtrl.text.trim(),
                      country: countryCtrl.text.trim(),
                      foundedYear: int.parse(foundedYearCtrl.text.trim()),
                    );

                    if (brand == null) {
                      await ref
                          .read(brandNotifierProvider.notifier)
                          .addBrand(newBrand);

                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Brand added successfully.'),
                          ),
                        );
                      }
                    } else {
                      ref
                          .read(brandNotifierProvider.notifier)
                          .updateBrand(newBrand);

                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Brand updated successfully.'),
                          ),
                        );
                      }
                    }
                  }),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteBrand(int brandId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
          'Are you sure you want to delete this brand? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(brandNotifierProvider.notifier)
          .deleteBrand(brandId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Brand deleted successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Cannot delete brand. There are computers associated with it.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandsAsync = ref.watch(brandNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brand List'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add),
        //     onPressed: () {
        //       _showBranchDialog();
        //     },
        //   ),
        // ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by brand name or country',
                // suffixIcon: IconButton(
                //   icon: const Icon(Icons.search),
                //   onPressed: () {
                //     ref.read(brandNotifierProvider.notifier)._searchKeyword =
                //         _searchCtrl.text;
                //     ref.invalidate(brandNotifierProvider);
                //   },
                // ),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                ref.read(brandNotifierProvider.notifier).searchBrands(val);
              },
            ),
          ),
          Expanded(
            child: brandsAsync.when(
              data: (brands) => brands.isEmpty
                  ? const Center(child: Text("Nobrand founds."))
                  : ListView.builder(
                      itemCount: brands.length,
                      itemBuilder: (context, index) {
                        final brand = brands[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(
                              brand.brandName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Country: ${brand.country}'),
                                Text('Founded Year: ${brand.foundedYear}'),
                                Text('Total Products: ${brand.totalProducts}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    _showBrandDialog(brand: brand);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _confirmDeleteBrand(brand.id!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              error: (error, stackTrace) =>
                  Center(child: Text('Error: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBrandDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
