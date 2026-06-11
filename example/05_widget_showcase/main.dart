import 'package:termora/termora.dart';

void main() async {
  final app = TermoraApp(child: const WidgetShowcaseDashboard());
  await app.run();
}

class WidgetShowcaseDashboard extends StatefulWidget {
  const WidgetShowcaseDashboard({super.key});

  @override
  State<WidgetShowcaseDashboard> createState() =>
      _WidgetShowcaseDashboardState();
}

class _WidgetShowcaseDashboardState extends State<WidgetShowcaseDashboard> {
  final FocusNode _menuFocus = FocusNode();
  final FocusNode _inputFocus = FocusNode();
  final FocusNode _btnDeployFocus = FocusNode();
  final FocusNode _btnRestartFocus = FocusNode();

  final TextEditingController _textController =
      TextEditingController(text: 'production-v2');

  String _statusMessage = 'System operational. Press Tab to cycle focus.';
  double _cpuProgress = 0.68;
  String _activeTab = 'services';

  @override
  void initState() {
    super.initState();
    _menuFocus.requestFocus();
  }

  @override
  void dispose() {
    _menuFocus.dispose();
    _inputFocus.dispose();
    _btnDeployFocus.dispose();
    _btnRestartFocus.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onMenuSelect(String value) {
    setState(() {
      _activeTab = value;
      _statusMessage = 'Switched view to $value.';
    });
  }

  void _onDeploy() {
    setState(() {
      _cpuProgress = 0.89;
      _statusMessage =
          '🚀 Deploying payload "${_textController.text}" to cloud cluster...';
    });
  }

  void _onRestart() {
    setState(() {
      _cpuProgress = 0.24;
      _statusMessage = '🔄 Restarting cluster pods in zero-downtime mode...';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      border: const Border.double(
        Style(
          foregroundColor: Color.brightCyan,
          modifiers: {TextModifier.bold},
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '⚡ TERMORA',
                    style: Style(
                      foregroundColor: Color.brightCyan,
                      modifiers: {TextModifier.bold},
                    ),
                  ),
                  Text(' '),
                  Text(
                    'Widget Showcase Dashboard',
                    style: Style(
                      foregroundColor: Color.white,
                      modifiers: {TextModifier.bold},
                    ),
                  ),
                ],
              ),
              Text(
                'v0.1.0 • Stable',
                style: Style(
                  foregroundColor: Color.brightGreen,
                  modifiers: {TextModifier.bold},
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          const Text(
            '────────────────────────────────────────────────────────────────────────',
            style: Style(foregroundColor: Color.brightBlack),
          ),
          const SizedBox(height: 1),

          // Main Content Area: Left Menu + Right View
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left navigation menu
              SizedBox(
                width: 24,
                child: Menu<String>(
                  title: 'NAVIGATION',
                  focusNode: _menuFocus,
                  items: const [
                    MenuItem(value: 'services', label: 'Services'),
                    MenuItem(value: 'metrics', label: 'Metrics'),
                    MenuItem(value: 'deploy', label: 'Deployments'),
                  ],
                  onSelected: _onMenuSelect,
                ),
              ),
              const SizedBox(width: 2),

              // Right details view
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // System Resource Meter
                    ProgressBar(
                      value: _cpuProgress,
                      width: 44,
                      label: 'CPU LOAD:',
                      filledStyle: const Style(
                        foregroundColor: Color.brightGreen,
                        modifiers: {TextModifier.bold},
                      ),
                    ),
                    const SizedBox(height: 1),

                    // Services Data Table
                    Table.fromStrings(
                      headers: ['SERVICE', 'REPLICAS', 'STATUS', 'UPTIME'],
                      data: [
                        ['api-gateway', '4 / 4', 'RUNNING', '99.98%'],
                        ['auth-server', '2 / 2', 'RUNNING', '100.0%'],
                        ['worker-pool', '8 / 8', 'HEALTHY', '99.95%'],
                        ['cache-redis', '3 / 3', 'RUNNING', '100.0%'],
                      ],
                    ),
                    const SizedBox(height: 1),

                    // Target Environment Input
                    Row(
                      children: [
                        const Text(
                          'Release Tag: ',
                          style: Style(
                            foregroundColor: Color.brightYellow,
                            modifiers: {TextModifier.bold},
                          ),
                        ),
                        SizedBox(
                          width: 28,
                          child: TextField(
                            controller: _textController,
                            focusNode: _inputFocus,
                            placeholder: 'Enter tag...',
                            onSubmitted: (tag) {
                              setState(() {
                                _statusMessage = 'Active release tag: $tag';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),

                    // Action Buttons
                    Row(
                      children: [
                        Button(
                          focusNode: _btnDeployFocus,
                          onPressed: _onDeploy,
                          child: const Text(' Deploy Release '),
                        ),
                        const SizedBox(width: 2),
                        Button(
                          focusNode: _btnRestartFocus,
                          onPressed: _onRestart,
                          child: const Text(' Restart Pods '),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 1),
          const Text(
            '────────────────────────────────────────────────────────────────────────',
            style: Style(foregroundColor: Color.brightBlack),
          ),

          // Footer Status & Navigation Help
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '[$_activeTab] STATUS: $_statusMessage',
                style: const Style(
                  foregroundColor: Color.brightYellow,
                  modifiers: {TextModifier.italic},
                ),
              ),
              const Text(
                'Tab: Cycle Focus • Enter: Select • Ctrl+C: Quit',
                style: Style(foregroundColor: Color.brightBlack),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
