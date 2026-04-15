import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'wallet_loading_screen.dart';

class WalletInputScreen extends StatefulWidget {
  const WalletInputScreen({super.key});

  @override
  State<WalletInputScreen> createState() => _WalletInputScreenState();
}

class _WalletInputScreenState extends State<WalletInputScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Wallet Explain',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Paste a public Ethereum wallet to get plain-English transaction summaries.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _controller,
                  style: const TextStyle(fontFamily: 'monospace'),
                  autocorrect: false,
                  enableSuggestions: false,
                  enableInteractiveSelection: true,
                  keyboardType: TextInputType.text,
                  contextMenuBuilder: (context, editableTextState) {
                    final filteredItems =
                        editableTextState.contextMenuButtonItems.where((item) {
                      final lower = item.label?.toLowerCase() ?? '';
                      return !lower.contains('scan text');
                    }).toList();

                    return AdaptiveTextSelectionToolbar.buttonItems(
                      anchors: editableTextState.contextMenuAnchors,
                      buttonItems: filteredItems,
                    );
                  },
                  decoration: InputDecoration(
                    labelText: 'Ethereum wallet address',
                    hintText: '0x...',
                    suffixIcon: IconButton(
                      tooltip: 'Paste',
                      onPressed: _pasteFromClipboard,
                      icon: const Icon(Icons.content_paste_rounded),
                    ),
                  ),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  validator: _validateAddress,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _onAnalyze,
                    child: const Text('Analyze Wallet'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onAnalyze() {
    if (!_formKey.currentState!.validate()) return;
    final address = _controller.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WalletLoadingScreen(address: address)),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (!mounted) return;
    if (text == null || text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clipboard is empty.')),
      );
      return;
    }
    _controller
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
    setState(() {});
  }

  String? _validateAddress(String? value) {
    final address = value?.trim() ?? '';
    final regex = RegExp(r'^0x[a-fA-F0-9]{40}$');
    if (!regex.hasMatch(address)) {
      return 'Enter a valid Ethereum address.';
    }
    return null;
  }
}
