import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'albumsList.dart';

/// wechat photo selection can only choose pictures
///
/// 仿微信照片选择，只能选择图片
class GetPhoto extends StatefulWidget {
  GetPhoto({
    this.onTap,
    this.crossAxisCount = 4,
    this.lang = const {},
    this.showAlbumsList = false,
  });

  ///Select the callback return asse tentity type
  ///
  ///选择回调，返回AssetEntity类型
  final ValueChanged<AssetEntity>? onTap;

  ///list one line display quantity
  ///
  ///列表一行显示数量
  final int crossAxisCount;

  ///localization 本地化
  ///```dart
  ///lang:{
  ///   'Recent': '所有图片',
  ///   'Camera': '相机',
  ///   'WeiXin': '微信',
  ///}
  ///```
  final Map lang;

  ///whether the album list is displayed by default the default no
  ///
  ///默认是否显示相册列表，默认：否
  final bool showAlbumsList;
  @override
  _GetPhotoState createState() => _GetPhotoState();
}

class _GetPhotoState extends State<GetPhoto> {
  List<Widget> _mediaList = [];
  List<AssetEntity> media = [];
  List<AssetPathEntity>? albums;
  int currentPage = 0;
  int lastPage = -1;
  bool _showAlbumsList = false;
  AssetPathEntity? currentAlbums;
  bool isDark = false;
  @override
  void initState() {
    super.initState();
    _showAlbumsList = widget.showAlbumsList;
    _init();
  }

  _loadMore(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (currentPage != lastPage) {
        lastPage = currentPage;
        imageList();
      }
    }
  }

  _init() async {
    var result = await PhotoManager.requestPermission();

    if (result) {
      albums = await PhotoManager.getAssetPathList(
        onlyAll: false,
        type: RequestType.image,
      );
      if (albums != null) {
        for (var item in albums!) {
          item.name = _albumsName(item.name);
        }
        currentAlbums = albums![0];
        imageList();
      }
    } else {
      PhotoManager.openSetting();
    }
  }

  String _albumsName(String name) {
    if (widget.lang.length == 0) {
      return name;
    }
    if (widget.lang[name] != null) {
      return widget.lang[name];
    }
    return name;
  }

  void assetCallback(int index) {
    if (widget.onTap != null) {
      AssetEntity asset = media[index];
      widget.onTap!(asset);
    }
  }

  Future<void> imageList() async {
    media = await currentAlbums!.getAssetListPaged(currentPage, 60);
    if (media.isEmpty) return;

    for (var i = 0; i < media.length; i++) {
      // Uint8List? _thumb = await media[i].thumbData;
      Uint8List? _thumb = await media[i].thumbDataWithSize(200, 200);
      Widget asset;
      asset = InkWell(
        child: Container(
          margin: const EdgeInsets.all(0.5),
          child: Image.memory(
            _thumb!,
            fit: BoxFit.cover,
          ),
        ),
        onTap: () {
          assetCallback(i);
          Navigator.maybePop(context);
        },
      );
      _mediaList.add(asset);

      if (mounted) setState(() {});
    }
    currentPage++;
  }

  Widget _body() {
    if (_showAlbumsList) {
      if (albums != null) {
        return AlbumsList(
          albums!,
          onTap: (v) {
            currentPage = 0;
            lastPage = -1;
            _mediaList.clear();
            currentAlbums = v;
            imageList();
            if (mounted) setState(() => _showAlbumsList = false);
          },
        );
      }
      return Container();
    } else {
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scroll) {
          _loadMore(scroll);
          return false;
        },
        child: GridView.builder(
          itemCount: currentAlbums == null ? 0 : currentAlbums!.assetCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.crossAxisCount),
          itemBuilder: (BuildContext context, int index) {
            if (_mediaList.length >= index + 1) {
              return _mediaList[index];
            }

            return Container(
              margin: const EdgeInsets.all(0.5),
              height: 30,
              color: Color(0xff4C4A48),
            );
          },
        ),
      );
    }
  }

  Widget get albumName {
    if (currentAlbums == null) {
      return Text('Loading...');
    }
    return Text(
      '${currentAlbums!.name}',
      style: TextStyle(
        height: 1.1,
        textBaseline: TextBaseline.alphabetic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: CloseButton(),
        leadingWidth: 30.0,
        title: InkWell(
          child: Container(
            height: 35.0,
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            decoration: BoxDecoration(
              color: Color(0xFF4C4C4C),
              borderRadius: new BorderRadius.circular((20.0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: [
                albumName,
                Icon(
                  _showAlbumsList
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 30.0,
                ),
              ],
            ),
          ),
          onTap: () {
            if (mounted) {
              setState(() => _showAlbumsList = !_showAlbumsList);
            }
          },
        ),
      ),
      body: _body(),
    );
  }
}
