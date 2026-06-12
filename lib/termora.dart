/// # Termora: Declarative Terminal UI Framework for Dart
///
/// Termora provides a Flutter-inspired component model and rendering engine
/// specifically engineered for command-line applications and interactive terminals.
///
/// ## Core Concepts
///
/// - **Component Model**: Build applications by composing [Widget]s into an immutable
///   declarative tree. Subclass [StatelessWidget] for pure presentation or
///   [StatefulWidget] to manage mutable state across rebuilds.
/// - **Double-Buffered Renderer**: Differential updates via [DoubleBuffer] ensure
///   only modified [Cell]s are flushed to stdout, minimizing terminal flicker.
/// - **Box Constraints**: Integer-based layout geometry with [BoxConstraints],
///   [Row], [Column], [Expanded], [Center], and [Padding].
/// - **Input & Focus**: Low-level ANSI parser ([AnsiInputParser]) translating escape
///   sequences to [KeyEvent]s dispatched across a hierarchy of [FocusNode]s.
/// - **Terminal Safety**: The [TerminalManager] and [ErrorBoundary] ensure the terminal
///   is cleanly restored even if unhandled exceptions occur.
///
/// ## Quick Start Example
///
/// ```dart
/// import 'package:termora/termora.dart';
///
/// void main() async {
///   final app = TermoraApp(
///     child: Center(
///       child: Container(
///         border: const Border.rounded(),
///         padding: const EdgeInsets.all(1),
///         child: const Text('Hello, Termora!'),
///       ),
///     ),
///   );
///   await app.run();
/// }
/// ```
library termora;

// Core Application & Component Model
export 'src/core/app.dart';
export 'src/core/build_context.dart';
export 'src/core/element.dart';
export 'src/core/inherited_widget.dart';
export 'src/core/key.dart';
export 'src/core/widget.dart';

// Input, Keyboard & Focus
export 'src/input/ansi_parser.dart';
export 'src/input/event.dart';
export 'src/input/focus_manager.dart';
export 'src/input/focus_node.dart';
export 'src/input/key_code.dart';

// Layout & Geometry
export 'src/layout/box_constraints.dart';
export 'src/layout/edge_insets.dart';
export 'src/layout/flex_layout.dart';
export 'src/layout/geometry.dart';

// Rendering & Output Engine
export 'src/rendering/ansi.dart';
export 'src/rendering/backend.dart';
export 'src/rendering/cell.dart';
export 'src/rendering/double_buffer.dart';
export 'src/rendering/render_object.dart';
export 'src/rendering/screen_buffer.dart';
export 'src/rendering/terminal_manager.dart';
export 'src/rendering/unicode_width.dart';

// Styling, Themes, Borders & Colors
export 'src/style/border.dart';
export 'src/style/color.dart';
export 'src/style/modifier.dart';
export 'src/style/palette.dart';
export 'src/style/style.dart';
export 'src/style/theme.dart';

// Widgets
export 'src/widgets/align.dart';
export 'src/widgets/basic.dart';
export 'src/widgets/button.dart';
export 'src/widgets/constrained_box.dart';
export 'src/widgets/container.dart';
export 'src/widgets/error_boundary.dart';
export 'src/widgets/flex.dart';
export 'src/widgets/flexible.dart';
export 'src/widgets/menu.dart';
export 'src/widgets/progress_bar.dart';
export 'src/widgets/rich_text.dart';
export 'src/widgets/scroll_view.dart';
export 'src/widgets/table.dart';
export 'src/widgets/text_field.dart';

/// The current semantic version of the Termora package.
const String termoraVersion = '0.1.0';
