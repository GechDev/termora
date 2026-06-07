/// Termora is a declarative, widget-driven Terminal UI framework for Dart.
library termora;

// Core Application & Component Model
export 'src/core/app.dart';
export 'src/core/build_context.dart';
export 'src/core/element.dart';
export 'src/core/key.dart';
export 'src/core/widget.dart';

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

// Styling, Borders & Colors
export 'src/style/border.dart';
export 'src/style/color.dart';
export 'src/style/modifier.dart';
export 'src/style/style.dart';

// Widgets
export 'src/widgets/align.dart';
export 'src/widgets/basic.dart';
export 'src/widgets/constrained_box.dart';
export 'src/widgets/container.dart';
export 'src/widgets/flex.dart';
export 'src/widgets/flexible.dart';

/// The current version of Termora.
const String termoraVersion = '0.1.0';
