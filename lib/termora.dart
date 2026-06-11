/// Termora is a declarative, widget-driven Terminal UI framework for Dart.
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
export 'src/widgets/flex.dart';
export 'src/widgets/flexible.dart';
export 'src/widgets/menu.dart';
export 'src/widgets/progress_bar.dart';
export 'src/widgets/rich_text.dart';
export 'src/widgets/scroll_view.dart';
export 'src/widgets/table.dart';
export 'src/widgets/text_field.dart';

/// The current version of Termora.
const String termoraVersion = '0.1.0';
