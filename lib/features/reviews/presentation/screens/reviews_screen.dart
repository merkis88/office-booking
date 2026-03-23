import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/app/navigation/app_tab_navigator.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/core/widgets/dialogs/app_confirmation_dialog.dart';
import 'package:wordpice/core/widgets/layout/app_constrained_scroll_view.dart';
import 'package:wordpice/core/widgets/layout/app_shell.dart';
import 'package:wordpice/features/reviews/domain/entities/create_review_params.dart';
import 'package:wordpice/features/reviews/domain/entities/update_review_params.dart';
import 'package:wordpice/features/reviews/presentation/models/review_item.dart';
import 'package:wordpice/features/reviews/presentation/states/review_submission_error_state.dart';
import 'package:wordpice/features/reviews/presentation/widgets/forms/reviews_submission_form.dart';
import 'package:wordpice/features/reviews/presentation/widgets/sections/reviews_filter_section.dart';
import 'package:wordpice/features/reviews/presentation/widgets/sections/reviews_list_section.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  static const int _tabIndex = 4;
  static const double _contentWidth = 360;
  static const List<int> _ratingFilters = [0, 5, 4, 3, 2, 1];

  int _selectedBottomIndex = _tabIndex;
  int _selectedFilterIndex = 0;
  int _rating = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasLoadedOnce = false;
  int? _deletingReviewId;
  String? _errorMessage;
  String? _successMessage;
  ReviewItem? _editingReview;
  List<ReviewItem> _reviews = const <ReviewItem>[];
  ReviewSubmissionErrorState _formErrors = ReviewSubmissionErrorState.empty;

  final TextEditingController _reviewController = TextEditingController();
  final PageController _reviewsPageController = PageController(
    viewportFraction: 0.9,
  );
  final GlobalKey _formKey = GlobalKey();

  int get _selectedFilterRating => _ratingFilters[_selectedFilterIndex];
  bool get _isEditing => _editingReview != null;
  bool _matchesSelectedFilter(ReviewItem item) {
    return _selectedFilterRating == 0 || item.rating == _selectedFilterRating;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedOnce) return;
    _hasLoadedOnce = true;
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reviews = await AppScope.of(
        context,
      ).reviewsRepository.getReviews(rating: _selectedFilterRating == 0 ? null : _selectedFilterRating);
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
      });
    } on ApiConnectionException catch (error) {
      if (!mounted) return;
      setState(() {
        _reviews = const <ReviewItem>[];
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reviews = const <ReviewItem>[];
        _errorMessage = 'Не удалось загрузить отзывы.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitReview() async {
    final user = AppScope.of(context).appSession.currentUser;
    if (user == null) return;

    final errors = ReviewSubmissionErrorState.validate(
      rating: _rating,
      text: _reviewController.text,
    );

    setState(() {
      _formErrors = errors;
      _successMessage = null;
      _errorMessage = null;
    });

    if (errors.hasErrors) return;

    setState(() => _isSubmitting = true);

    try {
      if (_editingReview == null) {
        final result = await AppScope.of(context).reviewsRepository.createReview(
          CreateReviewParams(
            text: _reviewController.text.trim(),
            rating: _rating,
            userId: user.id,
          ),
        );

        if (!mounted) return;
        setState(() {
          _reviews = _matchesSelectedFilter(result.review)
              ? <ReviewItem>[result.review, ..._reviews]
              : _reviews;
          _successMessage = result.message;
          _errorMessage = null;
          _rating = 0;
          _reviewController.clear();
          _formErrors = ReviewSubmissionErrorState.empty;
        });
        if (_reviewsPageController.hasClients) {
          _reviewsPageController.jumpToPage(0);
        }
        return;
      }

      final reviewId = _editingReview!.id;
      final result = await AppScope.of(context).reviewsRepository.updateReview(
        UpdateReviewParams(
          reviewId: reviewId,
          text: _reviewController.text.trim(),
          rating: _rating,
        ),
      );

      if (!mounted) return;
      setState(() {
        final updatedReviews = _reviews
            .map((item) => item.id == reviewId ? result.review : item)
            .toList();
        _reviews = _matchesSelectedFilter(result.review)
            ? updatedReviews
            : updatedReviews.where((item) => item.id != reviewId).toList();
        _successMessage = 'Отзыв успешно обновлен';
        _errorMessage = null;
        _clearEditingState();
      });
    } on ApiConnectionException catch (error) {
      if (!mounted) return;
      setState(() {
        final message = error.message.toLowerCase();
        _formErrors = ReviewSubmissionErrorState(
          rating: message.contains('рейтинг') ? error.message : null,
          text: message.contains('отзыв') || message.contains('текст')
              ? error.message
              : null,
        );
        if (_formErrors.rating == null && _formErrors.text == null) {
          _errorMessage = error.message;
        }
        _successMessage = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteReview(ReviewItem review) async {
    final shouldDelete = await AppConfirmationDialog.show<bool>(
      context,
      title: 'Удаление',
      message: 'Вы действительно хотите удалить отзыв?',
      confirmLabel: 'Удалить',
      cancelLabel: 'Отмена',
      confirmResult: true,
      cancelResult: false,
    );

    if (shouldDelete != true || !mounted) return;

    setState(() {
      _deletingReviewId = review.id;
      _successMessage = null;
      _errorMessage = null;
    });

    try {
      final result = await AppScope.of(context).reviewsRepository.deleteReview(
        review.id,
      );

      if (!mounted) return;
      setState(() {
        _reviews = _reviews.where((item) => item.id != review.id).toList();
        _successMessage = result.message;
        if (_editingReview?.id == review.id) {
          _clearEditingState();
        }
      });

      if (_reviewsPageController.hasClients && _reviews.isNotEmpty) {
        final currentPage = _reviewsPageController.page?.round() ?? 0;
        final targetPage = currentPage >= _reviews.length
            ? _reviews.length - 1
            : currentPage;
        _reviewsPageController.jumpToPage(targetPage);
      }
    } on ApiConnectionException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() => _deletingReviewId = null);
      }
    }
  }

  void _startEditingReview(ReviewItem review) {
    setState(() {
      _editingReview = review;
      _rating = review.rating;
      _reviewController.text = review.text;
      _formErrors = ReviewSubmissionErrorState.empty;
      _successMessage = null;
      _errorMessage = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _formKey.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _cancelEditing() {
    setState(() {
      _clearEditingState();
      _successMessage = null;
      _errorMessage = null;
    });
  }

  void _clearEditingState() {
    _editingReview = null;
    _rating = 0;
    _reviewController.clear();
    _formErrors = ReviewSubmissionErrorState.empty;
  }

  void _onBottomChanged(int index) {
    if (index == _tabIndex) return;
    setState(() => _selectedBottomIndex = index);
    AppTabNavigator.goToTab(context, index);
  }

  void _changeFilter(int delta) {
    setState(() {
      _selectedFilterIndex =
          (_selectedFilterIndex + delta + _ratingFilters.length) %
          _ratingFilters.length;
      _successMessage = null;
      _errorMessage = null;
    });
    if (_reviewsPageController.hasClients) {
      _reviewsPageController.jumpToPage(0);
    }
    _loadReviews();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _reviewsPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _reviews;
    final isAdmin = AppScope.of(context).appSession.currentUser?.isAdmin ?? false;

    return AppShell(
      selectedBottomIndex: _selectedBottomIndex,
      onBottomChanged: _onBottomChanged,
      body: AppConstrainedScrollView(
        maxWidth: _contentWidth,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          children: [
            ReviewsFilterSection(
              rating: _selectedFilterRating,
              onPrevious: () => _changeFilter(-1),
              onNext: () => _changeFilter(1),
            ),
            const SizedBox(height: 6),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              )
            else ...[
              if (_errorMessage != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
              ReviewsListSection(
                reviews: reviews,
                controller: _reviewsPageController,
                onDeleteReview: _deleteReview,
                onEditReview: _startEditingReview,
                isAdmin: isAdmin,
                deletingReviewId: _deletingReviewId,
              ),
            ],
            if (_successMessage != null) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFB9EE63),
                  border: Border.all(
                    color: Colors.black87,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _successMessage!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
            Container(
              key: _formKey,
              child: ReviewsSubmissionForm(
                rating: _rating,
                onRatingChanged: (value) => setState(() {
                  _rating = value;
                  _formErrors = ReviewSubmissionErrorState(
                    rating: null,
                    text: _formErrors.text,
                  );
                }),
                reviewController: _reviewController,
                onSubmit: _submitReview,
                isSubmitting: _isSubmitting,
                ratingError: _formErrors.rating,
                textError: _formErrors.text,
                submitLabel: _isEditing ? 'Сохранить' : 'Отправить',
                onCancel: _isEditing ? _cancelEditing : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
