
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localedemo_intl/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  set locale(Locale? value) {
    setState(() {
      //调用set方法
      _locale = value;
    });
  }
  Future<Locale?> getLanguageCode() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? languageIndex = prefs.get("language") as int?;
    if (languageIndex != null) {
      //存了语言
      switch(languageIndex) {
        case 0: return Locale.fromSubtags(languageCode: 'zh',scriptCode:"Hans");
        case 1: return Locale.fromSubtags(languageCode: 'zh',scriptCode:"Hant");
        default : return Locale.fromSubtags(languageCode: 'en');
      }
    }else {
      //没存语言
      return null;
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getLanguageCode().then((languageCode) {
      //获取语言
      locale = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate
      ],
      home: GCHomePage(),
    );
  }
}

class GCHomePage extends StatelessWidget {
  const GCHomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).home)),
      body: GCHomeContent(),
    );
  }
}

class GCHomeContent extends StatelessWidget {
  const GCHomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(S.of(context).testInfo,),
          TextButton(onPressed: () => pushLanguageSetting(context), child: Text(S.of(context).language))
        ],
      ),
    );
  }
  void pushLanguageSetting(BuildContext context) {
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) {
            return GCLanguagePage();
          },
          fullscreenDialog: true,
        )
    );
  }
}

class GCLanguagePage extends StatelessWidget {
  const GCLanguagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(S.of(context).lanSeting, style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: double.infinity,
        leading: TextButton(
          child: Container(
            child: Text(S.of(context).cancel,style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 17),),
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 10),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GCLanguageContent(),
    );
  }
}

class GCLanguageContent extends StatelessWidget {
  const GCLanguageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> localeList = ["zh_Hans", "zh_Hant", "en"];
    List<String> lanList = ["简体中文", "繁體中文", "English"];
    String lanString = "en";
    if (Localizations.localeOf(context).scriptCode != null) {
      lanString = "zh_${Localizations.localeOf(context).scriptCode}";
    }

    int iconIndex = localeList.indexOf(lanString);
    return ListView.separated(
      itemCount: lanList.length,
      itemBuilder: (ctx, index){
        Icon? checkIcon = iconIndex == index ? Icon(Icons.check, color: Theme.of(context).primaryColor,) : null;
        return buildListTile(context, lanList[index],localeList[index], checkIcon, index);
      },
      separatorBuilder: (ctx, index) => Divider(),
    );
  }

  ListTile buildListTile(BuildContext context,String title,String language,Icon? checkIcon, int index){
    return ListTile(
      leading: Text(title, style: TextStyle(fontSize: 17),),
      trailing: checkIcon,
      onTap: () async {
        switch(index) {
          case 0:MyApp.of(context).locale = Locale.fromSubtags(languageCode: 'zh',scriptCode:"Hans");break;
          case 1:MyApp.of(context).locale = Locale.fromSubtags(languageCode: 'zh',scriptCode:"Hant");break;
          case 2:MyApp.of(context).locale = Locale.fromSubtags(languageCode: 'en');break;
        }
        //保存语言
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt("language", index);
        Navigator.of(context).pop();
      },
    );
  }
}

