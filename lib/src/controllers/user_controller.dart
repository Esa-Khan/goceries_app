import 'dart:io';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class UserController extends ControllerMVC {
  User user = new User();
  bool hidePassword = true;
  bool loading = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  FirebaseMessaging _firebaseMessaging;
  OverlayEntry loader;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool fb_isLoggedIn = false;

  UserController() {
    loader = Helper.overlayLoader(context);
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((String _deviceToken) {
      user.deviceToken = _deviceToken;
    }).catchError((e) {
      print('Notification not configured');
    });
  }

  void login() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.login(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_account_not_exist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  // ignore: missing_return
  Future<String> signInWithGoogle() async {
    try {
      Overlay.of(context).insert(loader);
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =  await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final AuthResult authResult = await _auth.signInWithCredential(credential);
        final FirebaseUser user = authResult.user;

        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);

        final FirebaseUser currentUser = await _auth.currentUser();
        assert(user.uid == currentUser.uid);
        this.user.email = currentUser.email;
        this.user.name = currentUser.displayName;
        this.user.password = currentUser.uid;

        thirdPartyLogin();
        Helper.hideLoader(loader);
        return 'signInWithGoogle succeeded: $user';
      }

    } catch (e) {
      print("ERROR: " + e.toString());
      Helper.hideLoader(loader);
    }
    Helper.hideLoader(loader);
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
    print("User Sign Out");
  }

  void initiateFacebookLogin() async {
    try {
      Overlay.of(context).insert(loader);
      var facebookLogin = FacebookLogin();
      var facebookLoginResult = await facebookLogin.logIn(['email']);
      switch (facebookLoginResult.status) {
        case FacebookLoginStatus.error:
          print("Error");
          onLoginStatusChanged(false);
          break;
        case FacebookLoginStatus.cancelledByUser:
          print("CancelledByUser");
          onLoginStatusChanged(false);
          break;
        case FacebookLoginStatus.loggedIn:
          print("LoggedIn");
          var graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${facebookLoginResult.accessToken.token}');
          var profile = json.decode(graphResponse.body);
          print(profile.toString());
          this.user.email = profile['email'];
          this.user.name = profile['first_name'] + " " + profile['last_name'];
          this.user.password = profile['id'];
          thirdPartyLogin();
          //        onLoginStatusChanged(true, profileData: profile);
          break;
      }
    } catch (e) {
      print("---------ERROR: " + e.toString() + "----------");
      Helper.hideLoader(loader);
    }
    Helper.hideLoader(loader);
  }

  void onLoginStatusChanged(bool fb_isLoggedIn) {
    setState(() => this.fb_isLoggedIn = fb_isLoggedIn);
  }


  void signInWithApple() async {
    Overlay.of(context).insert(loader);
    try {
      final AuthorizationResult result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      switch (result.status) {
        case AuthorizationStatus.authorized:
          try {
            print("successfull sign in");
            final AppleIdCredential appleIdCredential = result.credential;

            OAuthProvider oAuthProvider =
            new OAuthProvider(providerId: "apple.com");
            final AuthCredential credential = oAuthProvider.getCredential(
              idToken:
              String.fromCharCodes(appleIdCredential.identityToken),
              accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
            );

            final AuthResult _res = await FirebaseAuth.instance
                .signInWithCredential(credential);

            FirebaseAuth.instance.currentUser().then((val) async {
              UserUpdateInfo updateUser = UserUpdateInfo();
              updateUser.displayName =
              "${appleIdCredential.fullName.givenName} ${appleIdCredential
                  .fullName.familyName}";
              updateUser.photoUrl =
              "define an url";
              await val.updateProfile(updateUser);
            });
          } catch (e) {
            print("error");
          }
          break;
        case AuthorizationStatus.error:
          print("-------------Apple Signin Failed-------------");

          // do something
          break;

        case AuthorizationStatus.cancelled:
          print('User cancelled');
          break;
      }
    } catch (error) {
      print("error with apple sign in");
      Helper.hideLoader(loader);
    }
    Helper.hideLoader(loader);
  }

  void thirdPartyLogin() async {
    repository.login(this.user).then((value) {
      if (value != null && value.apiToken != null) {
        print("-------------Login Success-------------");
        Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
      } else {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).wrong_email_or_password),
        ));
      }
    }).catchError((e) {
      print("-------------Login Failed-------------" + e.toString());
      if (e.toString() == "Exception: No Account with this Email") {
        repository.register(this.user).then((value) {
          if (value != null && value.apiToken != null) {
            print("-------------Register Success-------------");
            Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
          } else {
            scaffoldKey?.currentState?.showSnackBar(SnackBar(
              content: Text(S.of(context).wrong_email_or_password),
            ));
          }
        }).catchError((e) {
          print("-------------Register Failed-------------");
          if (e.toString() == "Exception: Account already exits") {
            scaffoldKey?.currentState?.showSnackBar(SnackBar(
              content: Text("Wrong password. Try a different login method."),
            ));
          }
        });
      }
      });
  }

  void register() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate() && user.password == user.confirm_password) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.register(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader?.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_email_account_exists),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void resetPassword() {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.resetPassword(user).then((value) {
        if (value != null && value == true) {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).your_reset_link_has_been_sent_to_your_email),
            action: SnackBarAction(
              label: S.of(context).login,
              onPressed: () {
                Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Login');
              },
            ),
            duration: Duration(seconds: 10),
          ));
        } else {
          loader.remove();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).error_verify_email_settings),
          ));
        }
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }
}
