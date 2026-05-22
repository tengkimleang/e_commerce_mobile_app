import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'address_geocoding_service.dart';

class AddressSearchSelection {
  const AddressSearchSelection({
    required this.address,
    required this.location,
    required this.searchText,
  });

  final String address;
  final LatLng location;
  final String searchText;
}

class AddressSearchView extends StatefulWidget {
  const AddressSearchView({super.key, this.initialQuery = '', this.origin});

  final String initialQuery;
  final LatLng? origin;

  @override
  State<AddressSearchView> createState() => _AddressSearchViewState();
}

class _AddressSearchViewState extends State<AddressSearchView> {
  static const _accent = Color(0xFFEC0C6E);
  static const _textColor = Color(0xFF1D1B24);

  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final String _sessionToken = DateTime.now().microsecondsSinceEpoch.toString();

  Timer? _debounce;
  List<AddressSearchSuggestion> _suggestions = const [];
  String? _suggestionError;
  bool _isLoading = false;
  bool _isSubmitting = false;
  int _requestSequence = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery.trim());
    _controller.addListener(_onQueryChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      _scheduleSuggestions(immediate: true);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    _scheduleSuggestions();
  }

  void _scheduleSuggestions({bool immediate = false}) {
    _debounce?.cancel();
    final query = _controller.text.trim();

    if (query.length < 2) {
      setState(() {
        _suggestions = const [];
        _suggestionError = null;
        _isLoading = false;
      });
      return;
    }

    if (immediate) {
      _loadSuggestions(query);
    } else {
      _debounce = Timer(
        const Duration(milliseconds: 300),
        () => _loadSuggestions(query),
      );
    }
  }

  Future<void> _loadSuggestions(String query) async {
    final request = ++_requestSequence;
    setState(() => _isLoading = true);

    try {
      final suggestions = await AddressGeocodingService.instance.suggestions(
        query,
        origin: widget.origin,
        sessionToken: _sessionToken,
      );

      if (!mounted || request != _requestSequence) return;
      setState(() {
        _suggestions = suggestions;
        _suggestionError = null;
        _isLoading = false;
      });
    } on AddressSearchException catch (error) {
      if (!mounted || request != _requestSequence) return;
      setState(() {
        _suggestions = const [];
        _suggestionError = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || request != _requestSequence) return;
      setState(() {
        _suggestions = const [];
        _suggestionError = 'Address suggestions are unavailable right now.';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitSearch() async {
    if (_isSubmitting) return;
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    if (_suggestions.isNotEmpty) {
      await _selectSuggestion(_suggestions.first);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = await AddressGeocodingService.instance.searchResult(query);
      if (result == null) {
        _showNotFound();
        return;
      }
      if (!mounted) return;
      Navigator.of(context).pop(
        AddressSearchSelection(
          address: result.address,
          location: result.location,
          searchText: query,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _selectSuggestion(AddressSearchSuggestion suggestion) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final result = await AddressGeocodingService.instance.resolveSuggestion(
        suggestion,
        sessionToken: _sessionToken,
      );
      if (result == null) {
        _showNotFound();
        return;
      }
      if (!mounted) return;
      Navigator.of(context).pop(
        AddressSearchSelection(
          address: result.address,
          location: result.location,
          searchText: suggestion.primaryText.isEmpty
              ? suggestion.description
              : suggestion.primaryText,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showNotFound() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address not found. Try more specific keywords.'),
      ),
    );
  }

  void _clearSearch() {
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 22,
            color: Color(0xFF60606A),
          ),
        ),
        title: const Text(
          'Search Address',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 14, 28, 16),
            child: _buildSearchField(),
          ),
          Expanded(child: _buildSuggestions(query)),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        cursorColor: _accent,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _submitSearch(),
        style: const TextStyle(
          fontSize: 18,
          color: _textColor,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'Search address',
          hintStyle: const TextStyle(color: Color(0xFFA2A0AA)),
          suffixIcon: _isSubmitting
              ? const Padding(
                  padding: EdgeInsets.all(15),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : (_controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.close_rounded),
                        color: Color(0xFF9B99A3),
                      )),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _accent, width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _accent, width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions(String query) {
    if (query.length < 2) {
      return const SizedBox.shrink();
    }

    if (_isLoading && _suggestions.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_suggestions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _suggestionError ??
                'No address suggestions found. Try more specific keywords.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF77737F),
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        ListView.separated(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          itemCount: _suggestions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final suggestion = _suggestions[index];
            return _AddressSuggestionTile(
              suggestion: suggestion,
              onTap: () => _selectSuggestion(suggestion),
            );
          },
        ),
        if (_isLoading)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}

class _AddressSuggestionTile extends StatelessWidget {
  const _AddressSuggestionTile({required this.suggestion, required this.onTap});

  final AddressSearchSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 84,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 21,
                    backgroundColor: Color(0xFFEDEDF0),
                    child: Icon(
                      Icons.access_time_rounded,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatDistance(suggestion.distanceMeters),
                    style: const TextStyle(
                      color: Color(0xFF696774),
                      fontSize: 12,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                suggestion.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF34313B),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDistance(double? meters) {
    if (meters == null) return '';
    if (meters < 1000) return '${meters.round()} m';
    final kilometers = meters / 1000;
    return '${kilometers.toStringAsFixed(kilometers < 10 ? 2 : 1)} km';
  }
}
