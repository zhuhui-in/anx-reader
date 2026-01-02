import 'package:anx_reader/config/shared_preference_provider.dart';
import 'package:anx_reader/enums/lang_list.dart';
import 'package:anx_reader/service/translate/index.dart';
import 'package:anx_reader/widgets/common/axis_flex.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class TranslationMenu extends StatefulWidget {
  const TranslationMenu({
    super.key,
    required this.content,
    required this.decoration,
    required this.axis,
    this.contextText,
  });
  final String content;
  final BoxDecoration decoration;
  final Axis axis;
  final String? contextText;

  @override
  State<TranslationMenu> createState() => _TranslationMenuState();
}

// Static cache that persists across state recreations
class _TranslationMenuCache {
  static final Map<String, _CacheEntry> _cache = {};

  static String _generateKey(String content, String? contextText) {
    return '${content.hashCode}_${contextText?.hashCode ?? 0}';
  }

  static Widget getOrCreate(
    String content,
    String? contextText,
    TranslateService service,
    LangListEnum from,
    LangListEnum to,
  ) {
    final key = _generateKey(content, contextText);
    final entry = _cache[key];

    // Check if cache entry exists and parameters match
    if (entry != null &&
        entry.service == service &&
        entry.from == from &&
        entry.to == to) {
      return entry.widget;
    }

    // Create new widget and cache it
    final widget = translateText(
      content,
      contextText: contextText,
      service: service,
    );
    _cache[key] = _CacheEntry(
      widget: widget,
      service: service,
      from: from,
      to: to,
    );
    return widget;
  }

  static void clear() {
    _cache.clear();
  }
}

class _CacheEntry {
  _CacheEntry({
    required this.widget,
    required this.service,
    required this.from,
    required this.to,
  });

  final Widget widget;
  final TranslateService service;
  final LangListEnum from;
  final LangListEnum to;
}

class _TranslationMenuState extends State<TranslationMenu> {
  Widget? _cachedTranslateWidget;

  @override
  void initState() {
    super.initState();
    _updateTranslateWidgetIfNeeded();
  }

  @override
  void didUpdateWidget(TranslationMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content ||
        oldWidget.contextText != widget.contextText) {
      _updateTranslateWidgetIfNeeded();
    }
  }

  void _updateTranslateWidgetIfNeeded() {
    final effectiveContextText =
        (widget.contextText?.trim().isEmpty ?? true) ? null : widget.contextText;
    final service = Prefs().translateService;
    final from = Prefs().translateFrom;
    final to = Prefs().translateTo;

    _cachedTranslateWidget = _TranslationMenuCache.getOrCreate(
      widget.content,
      effectiveContextText,
      service,
      from,
      to,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _langPicker(bool isFrom) {
    final MenuController menuController = MenuController();

    return PointerInterceptor(
      child: MenuAnchor(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.secondaryContainer,
          ),
          maximumSize: WidgetStateProperty.all(const Size(300, 300)),
        ),
        controller: menuController,
        menuChildren: [
          for (var lang in LangListEnum.values)
            PointerInterceptor(
              child: MenuItemButton(
                onPressed: () {
                  if (isFrom) {
                    Prefs().translateFrom = lang;
                  } else {
                    Prefs().translateTo = lang;
                  }
                  // Clear cache and rebuild to get new translation with updated language
                  _TranslationMenuCache.clear();
                  setState(() {
                    _updateTranslateWidgetIfNeeded();
                  });
                },
                child: Text(lang.getNative(context)),
              ),
            ),
        ],
        builder: (context, controller, child) {
          return GestureDetector(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: Text(
              isFrom
                  ? Prefs().translateFrom.getNative(context)
                  : Prefs().translateTo.getNative(context),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // print('Building TranslationMenu');
    // Update cache if translation settings changed
    _updateTranslateWidgetIfNeeded();
    return Expanded(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Container(
          height: widget.axis == Axis.vertical ? double.infinity : 150,
          width: widget.axis == Axis.vertical ? 100 : double.infinity,
          decoration: widget.decoration,
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.content,
                  style: const TextStyle(
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     _cachedTranslateWidget!,
                    const Divider(),
                    AxisFlex(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      axis: widget.axis,
                      children: [
                        _langPicker(true),
                        Transform.rotate(
                            angle: widget.axis == Axis.horizontal ? 0 : 1.57,
                            child: Icon(Icons.arrow_forward_ios, size: 16)),
                        _langPicker(false),
                        if (widget.axis == Axis.horizontal) const Spacer(),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
