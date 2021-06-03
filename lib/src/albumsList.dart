import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumsList extends StatefulWidget {
  ///albums list
  late final List<AssetPathEntity> albumsList;

  ///albums list onTap
  final ValueChanged<AssetPathEntity> onTap;

  AlbumsList(
    this.albumsList, {
    required this.onTap,
  });
  @override
  _AlbumsListState createState() => _AlbumsListState();
}

class _AlbumsListState extends State<AlbumsList> {
  List<AssetPathEntity> albums = [];
  List<Uint8List?> albumsThumb = [];
  @override
  void initState() {
    super.initState();
    _albumsList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _albumsList() async {
    List<AssetPathEntity> _albums = widget.albumsList;
    //sort by assetCount
    _albums.sort((a, b) => b.assetCount.compareTo(a.assetCount));
    albums.addAll(_albums);

    for (var item in albums) {
      final assetList = await item.getAssetListRange(start: 0, end: 1);
      if (assetList.isNotEmpty) {
        final Uint8List? _albums = await thumbDataWithSize(assetList.first);
        albumsThumb.add(_albums);
        if (mounted) setState(() {});
      }
    }
  }

  Future<Uint8List?> thumbDataWithSize(AssetEntity asset) async {
    return await asset.thumbData;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return imageList(index);
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: 0,
            color: Colors.grey[800],
          );
        },
        itemCount: widget.albumsList.length,
        physics: BouncingScrollPhysics(),
      ),
    );
  }

  Widget emptyList() {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      leading: Container(
        width: 50,
        height: 50,
        color: Colors.grey,
        margin: EdgeInsets.all(1.0),
      ),
      title: Container(
        constraints: BoxConstraints.tightForFinite(width: 100),
        child: Container(
          height: 30,
          color: Color(0xff4C4A48),
          margin: EdgeInsets.only(right: 150.0),
        ),
      ),
    );
  }

  Widget _leading(int index) {
    if (albumsThumb.length >= index + 1) {
      return Container(
        width: 50,
        height: 50,
        color: Colors.grey,
        margin: EdgeInsets.all(1.0),
        child: Image.memory(
          albumsThumb[index]!,
          fit: BoxFit.cover,
        ),
      );
    }

    // albumsThumb
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey,
      margin: EdgeInsets.all(1.0),
    );
  }

  Widget imageList(int index) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      leading: _leading(index),
      title: RichText(
        text: TextSpan(children: <InlineSpan>[
          TextSpan(
            text: '${albums[index].name}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
          TextSpan(
            text: ' ( ${albums[index].assetCount} )',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ]),
      ),
      onTap: () {
        widget.onTap(albums[index]);
      },
    );
  }
}
