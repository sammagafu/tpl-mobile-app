import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/update.dart';
import '../../providers/update_provider.dart';
import 'latest_page_detail.dart';

class LatestPage extends StatefulWidget {
  const LatestPage({super.key});

  @override
  _LatestPageState createState() => _LatestPageState();
}

class _LatestPageState extends State<LatestPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UpdateProvider>(context, listen: false).fetchUpdates(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final updateProvider = Provider.of<UpdateProvider>(context);

    return Column(
      children: [
        if (updateProvider.error != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Error: ${updateProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        Expanded(
          child: updateProvider.updates.isEmpty && !updateProvider.isLoading
              ? const Center(child: Text('No updates found.'))
              : RefreshIndicator(
                  onRefresh: () async {
                    await updateProvider.fetchUpdates(context);
                  },
                  child: ListView.builder(
                    itemCount: updateProvider.updates.length,
                    itemBuilder: (context, index) {
                      final update = updateProvider.updates[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(update: update),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 7.41,
                            horizontal: 12.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    update.cover,
                                    width: double.infinity,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 100,
                                            ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        update.title,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        update.category.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
