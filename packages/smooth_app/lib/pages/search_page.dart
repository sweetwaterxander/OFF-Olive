import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/search/search_field.dart';
import 'package:smooth_app/pages/search/search_product_helper.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class SearchPage extends StatelessWidget {
  const SearchPage(this.searchHelper, {Key? key}) : super(key: key);

  final SearchProductHelper searchHelper;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.of(context).canPop(),
      child: SmoothScaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(MEDIUM_SPACE),
                child: SearchField(
                  searchHelper: searchHelper,
                  autofocus: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}