import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:provider/provider.dart';

import '../providers/signin_provider.dart';
import '../services/my_image/my_im.dart';

class BaseLoggedPage extends StatefulWidget {

  const BaseLoggedPage({Key? key}) : super(key: key);

  @override
  State<BaseLoggedPage> createState() => _BaseLoggedPageState();
}

class _BaseLoggedPageState extends State<BaseLoggedPage> {

  late final SignInProvider _signIn;
  drive.FileList fotos = drive.FileList(files: []);
  bool _isInit = false;

  @override
  Widget build(BuildContext context) {

    Widget sp = const SizedBox(height: 10);
    if(!_isInit) {
      _isInit = true;
      _signIn = context.read<SignInProvider>();
    }

    // FutureBuilder(
    //     future: SignInProvider.isLogin(),
    //     builder: (_, AsyncSnapshot snap) {
    //       if(snap.connectionState == ConnectionState.done){
    //         if(snap.hasData) {
    //           if(snap.data) {
    //             userAccount.setData(SignInProvider.data());
    //             return _verFotos();
    //           }
    //         }
    //       }
    //       return const Center(child: Text('logeate'));
    //     },
    // ),

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logeando con Google'),
      ),
      body: const Text('sabe'),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: _login,
            tooltip: 'Login',
            child: const Icon(Icons.add),
          ),
          sp,
          FloatingActionButton(
            onPressed: _logout,
            tooltip: 'Login',
            child: const Icon(Icons.close),
          ),
          sp,
          FloatingActionButton(
            onPressed: _data,
            tooltip: 'Login',
            child: const Icon(Icons.data_array),
          ),
          sp,
          FloatingActionButton(
            onPressed: () async => await  _getFoto(context, 'c'),
            tooltip: 'Login',
            child: const Icon(Icons.camera),
          ),
          sp,
          FloatingActionButton(
            onPressed: () async => await  _getFoto(context, 'g'),
            tooltip: 'Login',
            child: const Icon(Icons.folder),
          ),
        ],
      )
    );
  }

  ///
  Widget _verFotos() {

    return FutureBuilder(
      future: _getFotos(),
      builder: (_, AsyncSnapshot snap) {

        if(fotos.files != null) {
          if(fotos.files!.isNotEmpty) {
            return ListView.builder(
              itemCount: fotos.files!.length,
              itemBuilder: (_, index) {
                if(fotos.files![index].mimeType!.contains('image')) {
                  return AspectRatio(
                    aspectRatio: 4/3,
                    child: CachedNetworkImage(
                      imageUrl: fotos.files![index].thumbnailLink!,
                    ),
                  );
                }
                return const SizedBox();
              }
            );
          }
        }
        return const Center(child: Text('Sin Fotos'));
      },
    );
  }

  ///
  Future<void> _login() async {

    // final user = await SignInProvider.login();
    // if(user != null) {
    //   if(user.email.contains('@')) {
    //     GetIt.I<AccountUser>().setData(user);
    //   }
    // }
  }

  ///
  Future<void> _logout() async => await _signIn.logout();

  ///
  Future<void> _data() async => _signIn.data();

  ///
  Future<void> _getFoto(BuildContext context, String src) async {

    List<XFile>? imgs = [];

    if(src == 'c') {
      XFile? img = await MyIm.camera();
      if(img != null) {
        imgs.add(img);
      }
    }

    if(src == 'g') {
      imgs = await MyIm.galeria();
    }

    if(imgs != null) {
      if(imgs.isNotEmpty) {
        //DriverApi upp = DriverApi(await GetIt.I<AccountUser>().getData().authHeaders);
        // final fotoUp = await upp.upFoto(foto: imgs.first);
        // if(fotoUp.isNotEmpty) {
        //   print(fotoUp);
        // }
      }
    }

  }

  ///
  Future<void> _getFotos() async {

    // DriverApi upp = DriverApi(await GetIt.I<AccountUser>().account.authHeaders);
    // fotos = await upp.getAllFotos();
  }
}