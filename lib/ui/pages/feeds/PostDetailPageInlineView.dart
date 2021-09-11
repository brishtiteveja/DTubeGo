import 'package:dtube_togo/style/styledCustomWidgets.dart';
import 'package:dtube_togo/ui/pages/feeds/widgets/FullScreenButton.dart';
import 'package:dtube_togo/ui/widgets/players/BetterPlayerFullScreen.dart';
import 'package:dtube_togo/ui/widgets/players/YTPlayerFullScreen.dart';
import 'package:dtube_togo/ui/widgets/players/YTplayerIframe.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:dtube_togo/utils/navigationShortcuts.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:dtube_togo/bloc/auth/auth_bloc_full.dart';
import 'package:dtube_togo/bloc/settings/settings_bloc_full.dart';
import 'package:dtube_togo/bloc/user/user_bloc_full.dart';
import 'package:dtube_togo/bloc/transaction/transaction_bloc_full.dart';
import 'package:dtube_togo/bloc/postdetails/postdetails_bloc_full.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dtube_togo/ui/MainContainer/NavigationContainer.dart';

import 'package:dtube_togo/ui/pages/user/User.dart';
import 'package:dtube_togo/ui/widgets/players/BetterPlayer.dart';
import 'package:dtube_togo/ui/widgets/AccountAvatar.dart';
import 'package:dtube_togo/ui/pages/post/widgets/CollapsedDescription.dart';
import 'package:dtube_togo/ui/pages/post/widgets/Comments.dart';
import 'package:dtube_togo/ui/pages/post/widgets/ReplyButton.dart';
import 'package:dtube_togo/ui/pages/post/widgets/VoteButtons.dart';

import 'package:dtube_togo/utils/secureStorage.dart';

import 'package:dtube_togo/style/dtubeLoading.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
// import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';

class PostDetailPageInlineView extends StatefulWidget {
  String link;
  String author;
  bool recentlyUploaded;
  String directFocus;

  PostDetailPageInlineView(
      {required this.link,
      required this.author,
      required this.recentlyUploaded,
      required this.directFocus});

  @override
  _PostDetailPageInlineViewState createState() =>
      _PostDetailPageInlineViewState();
}

class _PostDetailPageInlineViewState extends State<PostDetailPageInlineView> {
  int reloadCount = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostBloc>(
          key: UniqueKey(),
          create: (BuildContext context) =>
              PostBloc(repository: PostRepositoryImpl())
                ..add(FetchPostEvent(widget.author, widget.link)),
        ),
        BlocProvider<UserBloc>(
            create: (BuildContext context) =>
                UserBloc(repository: UserRepositoryImpl())),
        BlocProvider<SettingsBloc>(
          create: (BuildContext context) =>
              SettingsBloc()..add(FetchSettingsEvent()),
        ),
      ],
      // child: WillPopScope(
      //     onWillPop: _onWillPop,
      child: BlocBuilder<PostBloc, PostState>(builder: (context, state) {
        if (state is PostLoadingState) {
          return Center(child: DTubeLogoPulse(size: 20.w));
        } else if (state is PostLoadedState) {
          reloadCount++;
          return
              // Padding(
              //   padding: const EdgeInsets.only(top: 100),
              //   child:
              PostDetails(
            post: state.post,
            directFocus: reloadCount <= 1 ? widget.directFocus : "none",

            //),
          );
        } else {
          return Center(child: DTubeLogoPulse(size: 20.w));
        }
      }),

      //)
    );
  }
}

class PostDetails extends StatefulWidget {
  final Post post;
  final String directFocus;

  PostDetails({
    Key? key,
    required this.post,
    required this.directFocus,
  }) : super(key: key);

  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  late UserBloc _userBloc;

  late double _defaultVoteWeightPosts = 0;
  late double _defaultVoteWeightComments = 0;
  late double _defaultVoteTipPosts = 0;
  late double _defaultVoteTipComments = 0;
  late int _currentVT = 0;

  @override
  void initState() {
    super.initState();

    _userBloc = BlocProvider.of<UserBloc>(context);

    _userBloc.add(FetchAccountDataEvent(username: widget.post.author));
    _userBloc.add(FetchDTCVPEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserDTCVPLoadedState) {
          setState(() {
            _currentVT = state.vtBalance["v"]!;
          });
        }
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 16.h),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                widget.post.videoSource == "youtube"
                    ? YTPlayerIFrame(
                        videoUrl: widget.post.videoUrl!,
                        autoplay: false,
                        allowFullscreen: false)
                    : ["ipfs", "sia"].contains(widget.post.videoSource)
                        ? BP(
                            videoUrl: widget.post.videoUrl!,
                            autoplay: !(widget.directFocus != "none"),
                            looping: false,
                            localFile: false,
                            controls: true,
                            usedAsPreview: false,
                            allowFullscreen: false,
                          )
                        : Text("no player detected"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InputChip(
                      label: AccountAvatarBase(
                        username: widget.post.author,
                        avatarSize: 5.h,
                        showVerified: true,
                        showName: true,
                        width: 15.w,
                      ),
                      onPressed: () {
                        navigateToUserDetailPage(context, widget.post.author);
                      },
                    ),
                    FullScreenButton(
                      videoUrl: widget.post.videoUrl!,
                      videoSource: widget.post.videoSource,
                      iconSize: 15,
                    ),
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 49.w,
                        child: Text(
                          widget.post.jsonString!.title,
                          style: Theme.of(context).textTheme.headline6,
                          maxLines: 4,
                        ),
                      ),
                    ]),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.post.tags.length > 0
                        ? Row(
                            children: [
                              widget.post.jsonString!.oc == 1
                                  ? SizedBox(
                                      width: 23,
                                      child: FaIcon(FontAwesomeIcons.award))
                                  : SizedBox(width: 0),
                              Container(
                                width: 25.w,
                                height: 50,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: widget.post.tags.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: InputChip(
                                            label: Text(
                                                widget.post.tags[index]
                                                    .toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2)),
                                      );
                                    }),
                              ),
                            ],
                          )
                        : SizedBox(height: 0),
                    Text((widget.post.dist / 100).round().toString() + " DTC",
                        style: Theme.of(context).textTheme.bodyText1),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BlocBuilder<SettingsBloc, SettingsState>(
                        builder: (context, state) {
                      if (state is SettingsLoadedState) {
                        _defaultVoteWeightPosts = double.parse(
                            state.settings[settingKey_defaultVotingWeight]!);
                        _defaultVoteTipPosts = double.parse(
                            state.settings[settingKey_defaultVotingWeight]!);
                        _defaultVoteWeightComments = double.parse(state
                            .settings[settingKey_defaultVotingWeightComments]!);
                        return VotingButtons(
                            author: widget.post.author,
                            link: widget.post.link,
                            alreadyVoted: widget.post.alreadyVoted!,
                            alreadyVotedDirection:
                                widget.post.alreadyVotedDirection!,
                            upvotes: widget.post.upvotes,
                            downvotes: widget.post.downvotes,
                            defaultVotingWeight: _defaultVoteWeightPosts,
                            defaultVotingTip: _defaultVoteTipPosts,
                            currentVT: _currentVT,
                            scale: 0.8,
                            isPost: true,
                            focusVote: widget.directFocus);
                      } else {
                        return SizedBox(height: 0);
                      }
                    }),
                  ],
                ),
                CollapsedDescription(
                    description: widget.post.jsonString!.desc != null
                        ? widget.post.jsonString!.desc!
                        : ""),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputChip(
                      label: FaIcon(FontAwesomeIcons.shareAlt),
                      onPressed: () {
                        Share.share('https://d.tube/c/' +
                            widget.post.author +
                            '/' +
                            widget.post.link);
                      },
                    ),
                    SizedBox(width: 8),
                    ReplyButton(
                      icon: FaIcon(FontAwesomeIcons.comment),
                      author: widget.post.author,
                      link: widget.post.link,
                      parentAuthor: widget.post.author,
                      parentLink: widget.post.link,
                      votingWeight: _defaultVoteWeightComments,
                      scale: 1,
                      focusOnNewComment: widget.directFocus == "newcomment",
                    ),
                  ],
                ),
                // SizedBox(height: 16),
                widget.post.comments != null && widget.post.comments!.length > 0
                    ? Container(
                        height: 200.w,
                        child: ListView.builder(
                          itemCount: widget.post.comments!.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (BuildContext context, int index) =>
                              CommentDisplay(
                                  widget.post.comments![index],
                                  _defaultVoteWeightComments,
                                  _currentVT,
                                  widget.post.author,
                                  widget.post.link,
                                  _defaultVoteTipComments,
                                  context),
                        ),
                      )
                    : SizedBox(height: 0),
                SizedBox(height: 200)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
