import 'package:expen/core/theme.dart';
import 'package:expen/core/currency_symbol.dart';
import 'package:expen/provider/amount_provider.dart';
import 'package:expen/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_material_pickers/helpers/show_scroll_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../bloc/currency/currency_bloc.dart';
import '../bloc/currency/currency_event.dart';
import '../bloc/currency/currency_state.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  //Controllers
  TextEditingController rangeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //Provider
    var rangeProvider = Provider.of<AmountProvider>(context);
    var themeProvider = Provider.of<ThemeProvider>(context);

    //For finding current app theme
    AppTheme currentTheme = AppTheme.values.firstWhere(
      (theme) =>
          themeProvider.themeMode == ThemeMode.system &&
              theme == AppTheme.system ||
          themeProvider.themeMode == ThemeMode.light &&
              theme == AppTheme.light ||
          themeProvider.themeMode == ThemeMode.dark && theme == AppTheme.dark,
      orElse: () => AppTheme.system,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 10),

            //For selecting currency
            settingsList(
              "Choose Currency",
              TextButton(
                onPressed: () {
                  //This will open a currecny picker where user can select their currency
                  picker(context);
                },
                child: BlocBuilder<CurrencyBloc, CurrencyState>(
                  builder: (context, state) {
                    return Text(
                      "${currencySymbol[state.selectedCurrencyIndex]["name"] ?? ""} - ${currencySymbol[state.selectedCurrencyIndex]["symbol"] ?? ""} ",
                      style: const TextStyle(fontSize: 16),
                    );
                  },
                ),
              ),
            ),

            //For selecting app theme
            settingsList(
              "Select App Theme ",
              DropdownButton<AppTheme>(
                value: currentTheme,
                items: const [
                  DropdownMenuItem(
                    value: AppTheme.system,
                    child: Text("System"),
                  ),
                  DropdownMenuItem(value: AppTheme.light, child: Text("Light")),
                  DropdownMenuItem(value: AppTheme.dark, child: Text("Dark")),
                ],

                //For changing the theme
                onChanged: (AppTheme? newTheme) {
                  if (newTheme != null) {
                    themeProvider.setTheme(newTheme);
                  }
                },
              ),
            ),

            //For setting target
            settingsList(
              "Set Target",
              TextButton(
                onPressed: () {
                  //This will open a dialog box where user can add their target
                  showDialog<String>(
                    context: context,
                    builder:
                        (BuildContext context) => AlertDialog(
                          title: const Text('Set Expense Target'),
                          content: TextField(
                            controller: rangeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Enter your target",
                              prefixIcon: BlocBuilder<
                                CurrencyBloc,
                                CurrencyState
                              >(
                                builder: (context, state) {
                                  return SizedBox(
                                    width: 0,
                                    child: Center(
                                      heightFactor: 0.2,
                                      child: Text(
                                        currencySymbol[state
                                                .selectedCurrencyIndex]["symbol"] ??
                                            "",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: AppColors.darkGrey,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: AppColors.grey,
                                ),
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                //verify if input is empty or not
                                if (rangeController.text.isNotEmpty) {
                                  double limit = double.parse(
                                    rangeController.text,
                                  );
                                  rangeProvider.setRange(limit);
                                  rangeController.clear();
                                }
                                context.pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                  );
                },
                child: Text(rangeProvider.range.toString()),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            //This will take user to about page
            ListTile(
              onTap: () => context.push('/about'),
              title: const Text("About"),
              leading: const Icon(Icons.info_outline),
            ),
          ],
        ),
      ),
    );
  }

  //Widget for setting list
  Widget settingsList(String text, specificWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 16),
            //
          ),
          specificWidget,
        ],
      ),
    );
  }

  //Currencny Picker
  Future<String?> picker(BuildContext context) {
    return showMaterialScrollPicker<String>(
      context: context,
      title: 'Select Your Currency',
      items:
          currencySymbol.map((e) => '${e["name"]} (${e["symbol"]})').toList(),
      selectedItem:
          currencySymbol[context
              .read<CurrencyBloc>()
              .state
              .selectedCurrencyIndex]["name"]!,
      onChanged: (value) {
        var newIndex = currencySymbol.indexWhere(
          (e) => '${e["name"]} (${e["symbol"]})' == value,
        );

        if (newIndex != -1) {
          context.read<CurrencyBloc>().add(SelectCurrency(newIndex));
        }
      },
    );
  }
}
