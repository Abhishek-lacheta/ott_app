import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../bloc/video_feed_bloc.dart';
import '../bloc/video_feed_event.dart';
import '../bloc/video_feed_state.dart';
import '../manager/video_controller_manager.dart';
import '../widgets/feed_bottom_nav_bar.dart';
import '../widgets/video_player_item.dart';

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  late final PageController _pageController;
  late final VideoControllerManager _controllerManager;
  int _currentNavIndex = 0;
  bool _hasRestoredInitialIndex = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _controllerManager = VideoControllerManager();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controllerManager.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, VideoFeedState state) {
    _controllerManager.onPageChanged(index, state.videos);
    context.read<VideoFeedBloc>().add(VideoFeedPageChanged(index));

    // Trigger pagination when reaching within threshold of the end
    if (index >= state.videos.length - AppConstants.paginationThreshold &&
        !state.hasReachedMax &&
        state.status != VideoFeedStatus.loadingMore) {
      context.read<VideoFeedBloc>().add(const VideoFeedLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<VideoFeedBloc, VideoFeedState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.videos.length != current.videos.length,
        listener: (context, state) {
          if (state.status == VideoFeedStatus.loaded &&
              state.videos.isNotEmpty) {
            _controllerManager.updateVideos(state.videos);

            // Restore saved browsing index on first successful load
            if (!_hasRestoredInitialIndex) {
              _hasRestoredInitialIndex = true;
              final targetIndex = state.initialIndex;
              if (targetIndex > 0 && targetIndex < state.videos.length) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_pageController.hasClients) {
                    _pageController.jumpToPage(targetIndex);
                    _controllerManager.onPageChanged(targetIndex, state.videos);
                  }
                });
              } else {
                _controllerManager.onPageChanged(0, state.videos);
              }
            }
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // 1. Main Feed Content
              _buildFeedBody(context, state),

              // 2. Top Header Overlay (Following / For You tabs)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 0,
                right: 0,
                child: _buildTopHeader(),
              ),

              // 3. Offline notification banner
              if (state.isOffline)
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  child: const OfflineBanner(),
                ),

              // 4. Loading More indicator at bottom if paginating
              if (state.status == VideoFeedStatus.loadingMore)
                const Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: FeedBottomNavBar(
        selectedIndex: _currentNavIndex,
        onItemSelected: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          if (index != 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  index == 1
                      ? 'Discover screen coming soon'
                      : index == 2
                      ? 'Camera recording coming soon'
                      : index == 3
                      ? 'Inbox coming soon'
                      : 'User profile coming soon',
                ),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFeedBody(BuildContext context, VideoFeedState state) {
    switch (state.status) {
      case VideoFeedStatus.initial:
      case VideoFeedStatus.loading:
        return const LoadingView(message: 'Loading feed...');

      case VideoFeedStatus.error:
        return ErrorView(
          message: state.errorMessage ?? 'Failed to load videos.',
          onRetry: () =>
              context.read<VideoFeedBloc>().add(const VideoFeedFetchInitial()),
        );

      case VideoFeedStatus.empty:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.video_library_outlined,
                size: 64,
                color: Colors.white38,
              ),
              const SizedBox(height: 16),
              const Text(
                'No videos available right now',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    context.read<VideoFeedBloc>().add(const VideoFeedRefresh()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Refresh Feed'),
              ),
            ],
          ),
        );

      case VideoFeedStatus.loaded:
      case VideoFeedStatus.loadingMore:
      case VideoFeedStatus.refreshing:
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            context.read<VideoFeedBloc>().add(const VideoFeedRefresh());
          },
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: state.videos.length,
            onPageChanged: (index) => _onPageChanged(index, state),
            itemBuilder: (context, index) {
              final video = state.videos[index];
              return VideoPlayerItem(
                key: ValueKey(video.id),
                index: index,
                video: video,
                controllerManager: _controllerManager,
                onLike: () {
                  context.read<VideoFeedBloc>().add(
                    VideoFeedToggleLike(video.id),
                  );
                },
                onCommentCountUpdated: (newCount) {
                  context.read<VideoFeedBloc>().add(
                    VideoFeedUpdateCommentCount(
                      videoId: video.id,
                      count: newCount,
                    ),
                  );
                },
              );
            },
          ),
        );
    }
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Following',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 18),
        Container(width: 1, height: 12, color: Colors.white24),
        const SizedBox(width: 18),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'For You',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 28,
              height: 2.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
