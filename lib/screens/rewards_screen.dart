import 'dart:convert';
import 'dart:typed_data';

import 'package:any_base/any_base.dart';
import 'package:blue/constants/app_colors.dart';
import 'package:blue/models/user.dart';
import 'package:blue/screens/settings_screen.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/dialogs/show_dialog.dart';
import 'package:blue/widgets/field_decoration.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:clipboard/clipboard.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class RewardsScreen extends StatefulWidget {
  static const routeName = 'rewards';
  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  var dec2f = AnyBase(AnyBase.dec, 'ABCDEFGHIJ');
  var f2dec = AnyBase('ABCDEFGHIJ', AnyBase.dec);
  var flickr = 'ABCDEFGHIJ';
  bool hideRedeem = true;
  bool redeemed = true;
  TextEditingController controller = TextEditingController();
  review() async {
    User user = await User.fromDocument(
        (await Hasura.getUser(self: true))['data']['users_by_pk']);

    if (user.reviewed != true) {
      await Future.delayed(Duration(seconds: 5));
      showDialog(
          context: context,
          builder: (context) {
            return ShowDialog(
              description: 'Would you like to give us 5 stars?',
              title: 'App Review',
              middleButtonText: "No",
              bottomButtonText: "Don't Show Again",
              topButtonText: "Yes",
              middleButtonFunction: () {
                Navigator.pop(context);
              },
              bottomButtonFunction: () {
                Navigator.pop(context);
                Hasura.updateUser(reviewed: true);
              },
              topButtonFunction: () {
                Navigator.pop(context);
                inAppReview.isAvailable().then((value) {
                  if (value == true) {
                    inAppReview.requestReview();
                  }
                  Hasura.updateUser(reviewed: true);
                });
              },
            );
          });
    }
  }

  @override
  void initState() {
    review();
    invitee();
    inviter();

    super.initState();
  }

  int amount = 0;
  inviter() async {
    var doc1 = await Hasura.referrals(false);
    amount = amount + 5;
    setState(() {
      amount = doc1['data']['referral'].length * 15 + amount;
    });
  }

  invitee() async {
    var doc1 = await Hasura.referrals(true);
    if (doc1['data']['referral'].length > 0) {
      setState(() {
        amount = amount + 10;
        hideRedeem = true;
      });
    } else {
      setState(() {
        hideRedeem = false;
      });
    }
  }

  redeem() {
    String code = controller.text;
    print(dec2f.convert(Boxes.currentUserBox.get('user_id').toString()));
    print(code);
    if (dec2f.convert(Boxes.currentUserBox.get('user_id').toString()) == code) {
      snackbar("You can't redeem your own code", context);
      return;
    }
    String peerId = f2dec.convert(code);

    try {
      bool success = Hasura.redeemCode(peerId);
      if (success)
        setState(() {
          hideRedeem = true;
          amount = amount + 10;
        });
    } catch (e) {
      snackbar('An Error Occurred', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var userId = Boxes.currentUserBox.get('user_id');

    return Scaffold(
      appBar: settingsHeader(
        context,
        'Rewards',
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Text(
                        'Account Balance',
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w900,
                            fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      amount == 0
                          ? Container(height: 60, child: circularProgress())
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${amount > 75 ? '75' : amount.toString()}' +
                                      '.00',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 50),
                                ),
                                Text(
                                  'USD',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30),
                                ),
                              ],
                            ),
                      TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.teal,
                            backgroundColor: Colors.yellow,
                            shadowColor: Colors.yellowAccent,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                        onPressed: () {
                          snackbar(
                              'Your Account Balance must be atleast \$100 to withdraw.',
                              context);
                        },
                        child: Text(
                          'Withdraw Amount',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      )
                    ],
                  ),
                )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'You have received \$5 as a signup reward',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                ),
              ),
              if (!hideRedeem)
                Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                      child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Redeem Code',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18),
                                ),
                              ),
                            ),
                            TextButton(
                              child: Text('Redeem'),
                              onPressed: () {
                                redeem();
                              },
                            )
                          ],
                        ),
                        ListTile(
                            title: TextField(
                                onSubmitted: (c) {
                                  redeem();
                                },
                                decoration: InputDecoration(
                                    hintText: 'Enter Redeem Code',
                                    isDense: true,
                                    filled: true,
                                    fillColor:
                                        Theme.of(context).backgroundColor,
                                    border: InputBorder.none,
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.red, width: 1.5)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.red, width: 1)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.transparent, width: 1),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.transparent, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.transparent, width: 1),
                                    )),
                                controller: controller))
                      ],
                    ),
                  )),
                ),
              SizedBox(
                height: 10,
              ),
              Stack(
                children: [
                  Container(
                      height: 280,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12)),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset('assets/images/present.png',
                              fit: BoxFit.cover))),
                  Positioned.fill(
                    child: Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text(
                              'Earn \$15 on every invite',
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 40),
                            ),
                            Text(
                              'You will receive \$15 when your friend installs and enters the referral code. You can invite unlimited number of people.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: Center(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      primary: Colors.teal,
                                      backgroundColor: Colors.yellow,
                                      shadowColor: Colors.yellowAccent,
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20))),
                                  onPressed: () {
                                    Share.share(
                                        "I'm inviting you to Stark https://starkinvite.page.link/i. Enter my referral code ${dec2f.convert(userId.toString())} in app to receive \$10.",
                                        subject: 'App Invitation');
                                  },
                                  child: Text(
                                    'Invite',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                    child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Column(
                    children: [
                      Text(
                        'Your Referral Code',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ListTile(
                          title: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  FlutterClipboard.copy(
                                      dec2f.convert(userId.toString()));
                                  snackbar('Referral Code copied!', context);
                                },
                                icon: Icon(FluentIcons.copy_16_regular)),
                            isDense: true,
                            filled: true,
                            fillColor: Theme.of(context).backgroundColor,
                            border: InputBorder.none,
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 1.5)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 1)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1),
                            )),
                        controller: TextEditingController(
                          text: dec2f.convert(userId.toString()),
                        ),
                      ))
                    ],
                  ),
                )),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                    child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Column(
                    children: [
                      Text(
                        'How to earn rewards',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ListTile(
                        title: Text('Step 1'),
                        subtitle: Text(
                          'Share your invite link with friends',
                          style: TextStyle(fontSize: 17),
                        ),
                        leading: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: Icon(FluentIcons.share_16_filled)),
                      ),
                      ListTile(
                        title: Text('Step 2'),
                        subtitle: Text(
                          'Invite your friends to install Stark using your invite link',
                          style: TextStyle(fontSize: 17),
                        ),
                        leading: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: AppColors.blue, shape: BoxShape.circle),
                            child: Icon(FluentIcons.arrow_download_16_filled)),
                      ),
                      ListTile(
                        title: Text('Step 3'),
                        subtitle: Text(
                          'Once they sign up with your referral code you will receive \$15 and your friend will receive \$10',
                          style: TextStyle(fontSize: 17),
                        ),
                        leading: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.amber, shape: BoxShape.circle),
                            child: Icon(FluentIcons.money_16_filled)),
                      )
                    ],
                  ),
                )),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
