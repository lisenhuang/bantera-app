import 'package:flutter/material.dart';

import '../../core/api_config_notifier.dart';
import '../../core/theme.dart';

enum _ApiBaseUrlOption {
  defaultDomain,
  custom,
}

class ApiBaseUrlScreen extends StatefulWidget {
  const ApiBaseUrlScreen({
    super.key,
    this.initialSetup = false,
  });

  final bool initialSetup;

  @override
  State<ApiBaseUrlScreen> createState() => _ApiBaseUrlScreenState();
}

class _ApiBaseUrlScreenState extends State<ApiBaseUrlScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  late _ApiBaseUrlOption _selectedOption;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final config = ApiConfigNotifier.instance;
    final useCustomByDefault = !config.hasConfiguredBaseUrl;
    _selectedOption = useCustomByDefault
        ? _ApiBaseUrlOption.custom
        : (config.isUsingDefaultBaseUrl
            ? _ApiBaseUrlOption.defaultDomain
            : _ApiBaseUrlOption.custom);
    _controller = TextEditingController(
      text: _selectedOption == _ApiBaseUrlOption.custom
          ? (config.isUsingDefaultBaseUrl && !config.hasConfiguredBaseUrl
              ? ApiConfigNotifier.defaultCustomBaseUrl
              : (config.isUsingDefaultBaseUrl
                  ? ApiConfigNotifier.defaultCustomBaseUrl
                  : config.baseUrl))
          : ApiConfigNotifier.defaultCustomBaseUrl,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.initialSetup ? 'Connect Bantera' : 'API Base URL',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: BanteraTheme.primaryColor,
                          fontSize: 28,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.initialSetup
                        ? 'Choose which backend this app should use. You can switch between the hosted API and your local network endpoint.'
                        : 'Update the backend URL for this app installation.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<_ApiBaseUrlOption>(
                    segments: const [
                      ButtonSegment<_ApiBaseUrlOption>(
                        value: _ApiBaseUrlOption.defaultDomain,
                        label: Text('api.bantera.app'),
                        icon: Icon(Icons.public),
                      ),
                      ButtonSegment<_ApiBaseUrlOption>(
                        value: _ApiBaseUrlOption.custom,
                        label: Text('Custom'),
                        icon: Icon(Icons.settings_ethernet),
                      ),
                    ],
                    selected: <_ApiBaseUrlOption>{_selectedOption},
                    onSelectionChanged: _isSaving
                        ? null
                        : (selection) {
                            setState(() {
                              _selectedOption = selection.first;
                              _errorMessage = null;
                              if (_selectedOption == _ApiBaseUrlOption.defaultDomain) {
                                _controller.text =
                                    ApiConfigNotifier.defaultCustomBaseUrl;
                              } else if (_controller.text.trim().isEmpty ||
                                  _controller.text.trim() ==
                                      ApiConfigNotifier.defaultBaseUrl) {
                                _controller.text =
                                    ApiConfigNotifier.defaultCustomBaseUrl;
                              }
                            });
                          },
                  ),
                  const SizedBox(height: 20),
                  if (_selectedOption == _ApiBaseUrlOption.defaultDomain) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Default domain',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ApiConfigNotifier.defaultBaseUrl,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _controller,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Custom API Base URL',
                          hintText: 'http://192.168.8.153:5218',
                          prefixIcon: Icon(Icons.link),
                        ),
                        validator: _validateBaseUrl,
                        onFieldSubmitted: (_) => _save(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Custom is prefilled with your local network API. You can edit it any time.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    _selectedOption == _ApiBaseUrlOption.defaultDomain
                        ? 'Use this for the hosted Bantera API.'
                        : 'Examples: http://192.168.8.153:5218 or another LAN/tunnel URL',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.red.shade700,
                          ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: Text(_isSaving
                        ? 'Saving...'
                        : (widget.initialSetup ? 'Continue' : 'Save')),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                            setState(() {
                              _selectedOption = _ApiBaseUrlOption.custom;
                              _controller.text =
                                  ApiConfigNotifier.defaultCustomBaseUrl;
                              _errorMessage = null;
                            });
                          },
                    child: const Text('Use local custom default'),
                  ),
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                            setState(() {
                              _selectedOption = _ApiBaseUrlOption.defaultDomain;
                              _errorMessage = null;
                            });
                          },
                    child: const Text('Use https://api.bantera.app'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.initialSetup) {
      return Scaffold(body: SafeArea(child: content));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Base URL'),
      ),
      body: SafeArea(child: content),
    );
  }

  String? _validateBaseUrl(String? value) {
    if (_selectedOption == _ApiBaseUrlOption.defaultDomain) {
      return null;
    }

    try {
      ApiConfigNotifier.normalizeBaseUrl(value ?? '');
      return null;
    } on ApiConfigException catch (error) {
      return error.message;
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = null;
    });

    if (_selectedOption == _ApiBaseUrlOption.custom &&
        !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final changed = await ApiConfigNotifier.instance.saveBaseUrl(
        _selectedOption == _ApiBaseUrlOption.defaultDomain
            ? ApiConfigNotifier.defaultBaseUrl
            : _controller.text,
      );

      if (!mounted) {
        return;
      }

      if (!widget.initialSetup) {
        Navigator.of(context).pop(changed);
      }
    } on ApiConfigException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
