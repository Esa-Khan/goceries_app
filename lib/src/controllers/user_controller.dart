
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
  bool supportsAppleSignIn = false;


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
    Helper.checkiOSVersion().then((value) => setState(() => supportsAppleSignIn = value));

  }

  void login() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.login(user).then((value) {
        if (value != null && value.apiToken != null) {
          if (value.isDriver) {
            Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 1);
          } else {
            Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 1);
          }
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(e.message, textAlign: TextAlign.center,),
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
        return 'signInWithGoogle succeeded: $user';
      } else {
        Helper.hideLoader(loader);
      }

    } catch (e) {
      print("ERROR: " + e.toString());
      Helper.hideLoader(loader);
    }
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
    print("User Sign Out");
  }

  void signInWithFacebook() async {
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
          Helper.hideLoader(loader);
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
            print("Successfull apple sign in");
            final AppleIdCredential appleIdCredential = result.credential;

            OAuthProvider oAuthProvider =
            new OAuthProvider(providerId: "apple.com");
            final AuthCredential credential = oAuthProvider.getCredential(
              idToken:
              String.fromCharCodes(appleIdCredential.identityToken),
              accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
            );

            final AuthResult _res = await FirebaseAuth.instance.signInWithCredential(credential);

            FirebaseAuth.instance.currentUser().then((val) async {
              UserUpdateInfo updateUser = UserUpdateInfo();
              updateUser.displayName =
              "${appleIdCredential.fullName.givenName} ${appleIdCredential
                  .fullName.familyName}";
              updateUser.photoUrl =
              "define an url";
              await val.updateProfile(updateUser);
              print(val.displayName);
              print(val.email);
              print(val.uid);
              this.user.email = val.email;
              this.user.name = val.displayName == 'null null' ? '' : val.displayName;
              this.user.password =val.uid;
              thirdPartyLogin();
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
    timeout();
    repository.login(this.user).then((value) {
      if (value != null && value.apiToken != null && loading) {
        loading = false;
        print("-------------Login Success-------------");
        if (value.isDriver) {
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 1);
        } else {
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/StoreSelect');
          // Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
        }
        Helper.hideLoader(loader);
      } else {
        Helper.hideLoader(loader);
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).wrong_email_or_password),
        ));
      }
    }).catchError((e) {
      print("-------------Login Failed-------------\n" + e.toString());
      switch (e.message) {
        case 'No account with this email':
          repository.register(this.user).then((value) {
            if (value != null && value.apiToken != null && loading) {
              loading = false;
              print("-------------Register Success-------------");
              if (value.isDriver) {
                Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 1);
              } else {
                Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/StoreSelect');
              }
              Helper.hideLoader(loader);
            } else {
              Helper.hideLoader(loader);
              scaffoldKey?.currentState?.showSnackBar(SnackBar(
                content: Text(S.of(context).wrong_email_or_password),
              ));
            }
          }).catchError((e) {
            Helper.hideLoader(loader);
            print("-------------Register Failed-------------");
            if (e.toString() == "Exception: Account already exits") {
              scaffoldKey?.currentState?.showSnackBar(SnackBar(
                content: Text("Wrong password. Try a different login method."),
              ));
            }
          });
          break;
        case 'Incorrect Password':
          Helper.hideLoader(loader);
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text("Wrong password. Try a different login method."),
          ));
          break;
        default:
          Helper.hideLoader(loader);
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text("Unknown error, please try again"),
          ));
          break;
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
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 1);
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

  Future<void> timeout() async {
    if (!loading) {
      loading = true;
      Future.delayed(Duration(seconds: 8)).whenComplete(() {
        if (loading) {
          print("---------TIMEDOUT----------");
          Helper.hideLoader(loader);
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Login');
          loading = false;
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text('Request timed out, please try again.'),
          ));
        }
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
