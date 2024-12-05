import 'dart:math';

import 'package:ai_music/modules/explore/repos/play_list_repo.dart';
import 'package:ai_music/widgets/status_bar_playce_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../common/log_util.dart';
import '../../themes/theme_color.dart';
import '../../themes/theme_size.dart';
import 'bloc/play_list_bloc.dart';
import 'bloc/play_list_event.dart';
import 'bloc/play_list_state.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  static const String _tag = "ExplorePage";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        LogUtil.i("ExplorePage initState called", tag: _tag);
        context.read<PlayListBloc>().add(RequestHotPlayListEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Scaffold _buildBody(BuildContext context) {
    return Scaffold(
      backgroundColor: defaultBgColor,
      body: Column(
        children: [
          const StatusBarPlaceHolder(),
          Expanded(
            child: _buidMainContent(context),
          ),
          SizedBox(
            height: defaultBottomNavigationBarHeight,
          )
        ],
      ),
    );
  }

  _buidMainContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          _buildSearchBar(context),
          // 可滚动的内容部分
          Expanded(
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildHotCategoryList(context),
                        const SizedBox(height: 20),
                        _buildLiveMusicList(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ];
              },
              body: _buildCategoryList(context),
            ),
          ),
        ],
      ),
    );
  }

  _buildSearchBar(BuildContext context) {
    const double iconSize = 25.0;
    const int textAlpha = 80;
    return SizedBox(
      height: defaultActionBarHeight.toDouble(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
          ),
          height: defaultActionBarHeight.toDouble(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: iconSize,
                color: Colors.white.withAlpha(textAlpha),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  "搜索歌手, 歌曲, 专辑",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white.withAlpha(textAlpha)),
                ),
              ),
              Icon(
                Icons.camera_alt,
                size: iconSize,
                color: Colors.white.withAlpha(textAlpha),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildHotCategoryList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "听腻了?试试别的",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: BlocBuilder<PlayListBloc, PlayListState>(
            builder: (context, state) {
              LogUtil.i(state, tag: _tag);
              if (state is RequestHotPlayListLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is RequestHotPlayListError) {
                return Center(child: Text(state.error));
              }
              if (state is RequestHotPlayListSuccess) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.playList.tags.length,
                  itemBuilder: (context, index) {
                    return _buildHotCategoryItem(state, index, context);
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  Padding _buildHotCategoryItem(
      RequestHotPlayListSuccess state, int index, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Container(
        height: 180, // 宽高比1:1
        width: 130,
        decoration: BoxDecoration(
          color: Color((0xFF000000 + ((index * 3 * 0x0F0F0F - 25) % 0xFFFFFF)))
              .withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  "https://picsum.photos/80/80?random=$index", // 添加random参数使每个图片不同
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                state.playList.tags[index].name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildLiveMusicList(BuildContext context) {
    const borderColor = Color(0xFFE80063);
    const double totalHeight = 80 + 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "正在直播 >",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: totalHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: borderColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(50),
                        image: const DecorationImage(
                          image: NetworkImage(
                            "https://picsum.photos/180/180",
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: 45,
                        margin: const EdgeInsets.symmetric(horizontal: 17),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "直播中",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
            dividerColor: Colors.transparent,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: "歌单漫游"),
              Tab(text: "流行"),
              Tab(text: "华语"),
              Tab(text: "欧美"),
              Tab(text: "摇滚"),
              Tab(text: "民谣"),
            ],
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                return TabBarView(
                  children: [
                    _buildGridView(context, "歌单漫游"),
                    _buildGridView(context, "流行"),
                    _buildGridView(context, "华语"),
                    _buildGridView(context, "欧美"),
                    _buildGridView(context, "摇滚"),
                    _buildGridView(context, "民谣"),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(BuildContext context, String category) {
    // 生成随机高度列表，实际项目中应该根据实际内容高度来设置
    final List<double> heights = List.generate(
      20,
      (index) => (index % 3 + 2) * 100.0, // 200-400之间的高度
    );

    return MasonryGridView.builder(
      itemCount: 20,
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  // 使用不同高度的图片来模拟瀑布流效果
                  'https://picsum.photos/400/${heights[index].toInt()}',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$category 项目 $index',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '副标题描述文本',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
