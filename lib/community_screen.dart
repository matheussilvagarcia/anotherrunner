import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anotherrunner/l10n/app_localizations.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String? _username;
  String? _communityId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        if (mounted) {
          setState(() {
            _username = doc.data()?['username'];
            _communityId = doc.data()?['communityId'];
            if (_username != null) {
              _usernameController.text = _username!;
            }
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveUsername() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final user = FirebaseAuth.instance.currentUser!;
      final newUsername = _usernameController.text.trim();
      final usernameDoc = await FirebaseFirestore.instance.collection('usernames').doc(newUsername).get();

      if (usernameDoc.exists && usernameDoc.data()?['uid'] != user.uid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.usernameInUse)));
          setState(() => _isLoading = false);
        }
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      if (_username != null && _username != newUsername) {
        batch.delete(FirebaseFirestore.instance.collection('usernames').doc(_username));
      }
      batch.set(FirebaseFirestore.instance.collection('usernames').doc(newUsername), {'uid': user.uid});
      batch.set(FirebaseFirestore.instance.collection('users').doc(user.uid), {'username': newUsername}, SetOptions(merge: true));
      await batch.commit();

      if (mounted) {
        setState(() {
          _username = newUsername;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUsernameFromDialog(String newUsername) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser!;
    final usernameDoc = await FirebaseFirestore.instance.collection('usernames').doc(newUsername).get();

    if (usernameDoc.exists && usernameDoc.data()?['uid'] != user.uid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.usernameInUse)));
        setState(() => _isLoading = false);
      }
      return;
    }

    final batch = FirebaseFirestore.instance.batch();
    if (_username != null && _username != newUsername) {
      batch.delete(FirebaseFirestore.instance.collection('usernames').doc(_username));
    }
    batch.set(FirebaseFirestore.instance.collection('usernames').doc(newUsername), {'uid': user.uid});
    batch.set(FirebaseFirestore.instance.collection('users').doc(user.uid), {'username': newUsername}, SetOptions(merge: true));
    await batch.commit();

    if (mounted) {
      setState(() {
        _username = newUsername;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.usernameUpdated)));
    }
  }

  Future<String> _generateUniqueCode() async {
    final random = Random();
    while (true) {
      String code = (random.nextInt(90000) + 10000).toString();
      final query = await FirebaseFirestore.instance.collection('communities').where('code', isEqualTo: code).get();
      if (query.docs.isEmpty) return code;
    }
  }

  Future<void> _createCommunity(String name) async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser!;
    final generatedCode = await _generateUniqueCode();
    final newCommunityRef = FirebaseFirestore.instance.collection('communities').doc();

    final batch = FirebaseFirestore.instance.batch();
    batch.set(newCommunityRef, {
      'name': name,
      'code': generatedCode,
      'ownerId': user.uid,
      'members': [user.uid],
      'roles': {user.uid: 'superior'},
      'reward1': '',
      'reward2': '',
      'reward3': '',
      'rewardDescription': '',
    });
    batch.set(FirebaseFirestore.instance.collection('users').doc(user.uid), {'communityId': newCommunityRef.id}, SetOptions(merge: true));
    await batch.commit();

    if (mounted) {
      setState(() {
        _communityId = newCommunityRef.id;
        _isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  Future<void> _joinCommunity(String code) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser!;
    final query = await FirebaseFirestore.instance.collection('communities').where('code', isEqualTo: code).get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final batch = FirebaseFirestore.instance.batch();
      batch.update(doc.reference, {
        'members': FieldValue.arrayUnion([user.uid]),
        'roles.${user.uid}': 'member'
      });
      batch.set(FirebaseFirestore.instance.collection('users').doc(user.uid), {'communityId': doc.id}, SetOptions(merge: true));
      await batch.commit();

      if (mounted) {
        setState(() {
          _communityId = doc.id;
          _isLoading = false;
        });
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invalidCode)));
      }
    }
  }

  Future<void> _refreshCommunityCode() async {
    final l10n = AppLocalizations.of(context)!;
    if (_communityId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10nDialog = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10nDialog.updateCodeTitle),
          content: Text(l10nDialog.updateCodeDesc),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10nDialog.cancel)),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10nDialog.update, style: const TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final newCode = await _generateUniqueCode();
    await FirebaseFirestore.instance.collection('communities').doc(_communityId).update({'code': newCode});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.accessCodeUpdated)));
    }
  }

  Future<void> _updateMemberRole(String memberUid, String newRole) async {
    if (_communityId != null) {
      await FirebaseFirestore.instance.collection('communities').doc(_communityId).update({'roles.$memberUid': newRole});
    }
  }

  Future<void> _transferSuperiorRole(String newSuperiorUid) async {
    if (_communityId != null) {
      final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      final batch = FirebaseFirestore.instance.batch();
      final communityRef = FirebaseFirestore.instance.collection('communities').doc(_communityId);

      batch.update(communityRef, {
        'roles.$newSuperiorUid': 'superior',
        'roles.$currentUserUid': 'admin',
      });

      await batch.commit();
    }
  }

  Future<void> _kickMember(String memberUid) async {
    if (_communityId != null) {
      final batch = FirebaseFirestore.instance.batch();
      batch.update(FirebaseFirestore.instance.collection('communities').doc(_communityId), {
        'members': FieldValue.arrayRemove([memberUid]),
        'roles.$memberUid': FieldValue.delete()
      });
      batch.update(FirebaseFirestore.instance.collection('users').doc(memberUid), {'communityId': FieldValue.delete()});
      await batch.commit();
    }
  }

  Future<void> _leaveCommunity(Map<String, dynamic> communityData) async {
    final l10n = AppLocalizations.of(context)!;
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final roles = Map<String, String>.from(communityData['roles'] ?? {});
    final members = List<String>.from(communityData['members'] ?? []);
    final myRole = roles[currentUserUid];

    if (members.length > 1 && myRole == 'superior') {
      showDialog(
        context: context,
        builder: (context) {
          final l10nDialog = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(l10nDialog.attention),
            content: Text(l10nDialog.transferSuperiorBeforeLeaving),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10nDialog.ok)),
            ],
          );
        },
      );
      return;
    }

    final isLastMember = members.length == 1;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10nDialog = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10nDialog.leaveCommunityTitle),
          content: Text(isLastMember ? l10nDialog.leaveCommunityLastMember : l10nDialog.leaveCommunityConfirm),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10nDialog.cancel)),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10nDialog.leave, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    final batch = FirebaseFirestore.instance.batch();
    final communityRef = FirebaseFirestore.instance.collection('communities').doc(_communityId);
    final userRef = FirebaseFirestore.instance.collection('users').doc(currentUserUid);

    if (isLastMember) {
      batch.delete(communityRef);
    } else {
      batch.update(communityRef, {
        'members': FieldValue.arrayRemove([currentUserUid]),
        'roles.$currentUserUid': FieldValue.delete()
      });
    }
    batch.update(userRef, {'communityId': FieldValue.delete()});

    await batch.commit();

    if (mounted) {
      setState(() {
        _communityId = null;
        _isLoading = false;
      });
    }
  }

  void _showCreateDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.createCommunity),
          content: TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.name)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) _createCommunity(nameController.text.trim());
              },
              child: Text(l10n.create),
            ),
          ],
        );
      },
    );
  }

  void _showJoinDialog() {
    final TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.joinCommunity),
          content: TextField(controller: codeController, keyboardType: TextInputType.number, maxLength: 5),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                if (codeController.text.trim().length == 5) _joinCommunity(codeController.text.trim());
              },
              child: Text(l10n.join),
            ),
          ],
        );
      },
    );
  }

  void _showEditCommunityNameDialog(String currentName) {
    final TextEditingController nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.editCommunity),
          content: TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.newName)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && newName != currentName) {
                  FirebaseFirestore.instance.collection('communities').doc(_communityId).update({'name': newName});
                }
                Navigator.pop(context);
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  void _showEditUsernameDialog() {
    final TextEditingController userController = TextEditingController(text: _username);
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.editUsername),
          content: TextField(controller: userController, decoration: InputDecoration(labelText: l10n.newUsername)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                final newName = userController.text.trim();
                if (newName.isNotEmpty && newName != _username) {
                  Navigator.pop(context);
                  _saveUsernameFromDialog(newName);
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  void _showEditRewardsDialog(Map<String, dynamic> currentData) {
    final TextEditingController r1 = TextEditingController(text: currentData['reward1'] ?? '');
    final TextEditingController r2 = TextEditingController(text: currentData['reward2'] ?? '');
    final TextEditingController r3 = TextEditingController(text: currentData['reward3'] ?? '');
    final TextEditingController desc = TextEditingController(text: currentData['rewardDescription'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.setRewardsTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: r1, decoration: InputDecoration(labelText: l10n.firstPlace)),
                TextField(controller: r2, decoration: InputDecoration(labelText: l10n.secondPlace)),
                TextField(controller: r3, decoration: InputDecoration(labelText: l10n.thirdPlace)),
                const SizedBox(height: 12),
                TextField(controller: desc, maxLines: 3, decoration: InputDecoration(labelText: l10n.weekDescription, border: const OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('communities').doc(_communityId).update({
                  'reward1': r1.text.trim(),
                  'reward2': r2.text.trim(),
                  'reward3': r3.text.trim(),
                  'rewardDescription': desc.text.trim(),
                });
                Navigator.pop(context);
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  void _showRankingHistory() {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.rankingHistoryTitle),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('communities')
                  .doc(_communityId)
                  .collection('ranking_history')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return Center(child: Text(l10n.noHistoryYet));

                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final weekName = data['weekName'] ?? l10n.unknownWeek;
                    final topUser = data['topUsername'] ?? l10n.noWinner;
                    final steps = data['topSteps'] ?? 0;
                    final r1 = data['reward1'] ?? '';
                    final desc = data['rewardDescription'] ?? '';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.emoji_events, color: Colors.amber, size: 36),
                          title: Text(weekName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('${l10n.winner}: $topUser', style: const TextStyle(color: Colors.grey)),
                          trailing: Text('$steps\n${l10n.steps}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        if (r1.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text('${l10n.prize} $r1', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue)),
                          ),
                        if (desc.isNotEmpty)
                          Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myCommunity)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: _communityId != null ? _buildCommunityDashboard() : _buildSetupOptions(),
      ),
    );
  }

  Widget _buildSetupOptions() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUsernameForm(),
          if (_username != null) ...[
            const SizedBox(height: 40),
            ElevatedButton.icon(onPressed: _showCreateDialog, icon: const Icon(Icons.group_add), label: Text(l10n.createCommunity)),
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: _showJoinDialog, icon: const Icon(Icons.search), label: Text(l10n.joinUsingCode)),
          ]
        ],
      ),
    );
  }

  Widget _buildUsernameForm() {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(_username == null ? l10n.chooseUsername : l10n.yourUsername, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: l10n.username, border: const OutlineInputBorder()),
            validator: (v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _saveUsername, child: Text(_username == null ? l10n.save : l10n.update)),
        ],
      ),
    );
  }

  Widget _buildWeeklyTimer() {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<void>(
      stream: Stream.periodic(const Duration(minutes: 1)),
      builder: (context, _) {
        final now = DateTime.now();
        final daysUntilSunday = DateTime.sunday - now.weekday;
        final endOfWeek = DateTime(now.year, now.month, now.day).add(Duration(days: daysUntilSunday, hours: 23, minutes: 59, seconds: 59));
        final remaining = endOfWeek.difference(now);
        final days = remaining.inDays;
        final hours = remaining.inHours % 24;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.timeLeft(days, hours),
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardsSection(Map<String, dynamic> data, bool isSuperior) {
    final l10n = AppLocalizations.of(context)!;
    final r1 = data['reward1'] ?? '';
    final r2 = data['reward2'] ?? '';
    final r3 = data['reward3'] ?? '';
    final desc = data['rewardDescription'] ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.weeklyRewards, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                ],
              ),
              if (isSuperior)
                GestureDetector(
                  onTap: () => _showEditRewardsDialog(data),
                  child: const Icon(Icons.edit, size: 18, color: Colors.amber),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (r1.isNotEmpty) Text('${l10n.firstPlacePrefix}$r1', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          if (r2.isNotEmpty) Text('${l10n.secondPlacePrefix}$r2', style: const TextStyle(fontSize: 13)),
          if (r3.isNotEmpty) Text('${l10n.thirdPlacePrefix}$r3', style: const TextStyle(fontSize: 13)),
          if (desc.isNotEmpty) ...[
            const Divider(height: 16),
            Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
          if (r1.isEmpty && r2.isEmpty && r3.isEmpty && desc.isEmpty)
            Text(l10n.noRewardsDefined, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCommunityDashboard() {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('communities').doc(_communityId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (!snapshot.data!.exists) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(context);
          });
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final membersList = List<String>.from(data['members'] ?? []);

        if (!membersList.contains(currentUser.uid)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(context);
          });
          return const Center(child: CircularProgressIndicator());
        }

        final roles = Map<String, String>.from(data['roles'] ?? {});
        final myRole = roles[currentUser.uid] ?? 'member';
        final isSuperior = myRole == 'superior';
        final canManage = isSuperior || myRole == 'admin';

        return Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(data['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        if (canManage)
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showEditCommunityNameDialog(data['name']),
                            padding: const EdgeInsets.only(left: 8.0),
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${l10n.code} ${data['code']}', style: const TextStyle(fontSize: 16, letterSpacing: 1.2)),
                        IconButton(icon: const Icon(Icons.copy, size: 18), onPressed: () => Clipboard.setData(ClipboardData(text: data['code']))),
                        if (canManage)
                          IconButton(icon: const Icon(Icons.refresh, size: 18, color: Colors.blue), onPressed: _refreshCommunityCode),
                        IconButton(icon: const Icon(Icons.exit_to_app, size: 18, color: Colors.red), onPressed: () => _leaveCommunity(data)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildWeeklyTimer(),
            _buildRewardsSection(data, isSuperior),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.weeklyRanking, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _showRankingHistory,
                  icon: const Icon(Icons.history, size: 18),
                  label: Text(l10n.history),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildMembersList(roles, myRole)),
          ],
        );
      },
    );
  }

  Widget _buildMembersList(Map<String, String> roles, String myRole) {
    final l10n = AppLocalizations.of(context)!;
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('communityId', isEqualTo: _communityId)
          .orderBy('weeklySteps', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final users = snapshot.data!.docs;
        if (users.isEmpty) return Center(child: Text(l10n.noMembers));

        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            final uid = users[index].id;
            final username = userData['username'] ?? l10n.username;
            final weeklySteps = userData['weeklySteps'] ?? 0;
            final role = roles[uid] ?? 'member';
            final isMe = uid == currentUserUid;

            String roleLabel = l10n.memberRole;
            if (role == 'superior') roleLabel = l10n.superiorAdminRole;
            if (role == 'admin') roleLabel = l10n.adminRole;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: index == 0 ? Colors.amber : (index == 1 ? Colors.grey[400] : (index == 2 ? Colors.brown[300] : Colors.blue.withOpacity(0.2))),
                child: Text('#${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              ),
              title: Text('$username${isMe ? " (${l10n.you})" : ""}', style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal)),
              subtitle: Text(roleLabel, style: const TextStyle(fontSize: 12)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$weeklySteps ${l10n.steps}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  if (isMe)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                      onPressed: _showEditUsernameDialog,
                      padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                      constraints: const BoxConstraints(),
                    ),
                  if (!isMe) const SizedBox(width: 8),
                  if (_buildMemberMenu(uid, role, myRole, isMe) != null) _buildMemberMenu(uid, role, myRole, isMe)!,
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget? _buildMemberMenu(String targetUid, String targetRole, String myRole, bool isMe) {
    final l10n = AppLocalizations.of(context)!;
    bool canAdmin = myRole == 'superior' || myRole == 'admin';
    if (isMe || targetRole == 'superior' || !canAdmin) return null;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'kick') _kickMember(targetUid);
        if (value == 'to_admin') _updateMemberRole(targetUid, 'admin');
        if (value == 'to_member') _updateMemberRole(targetUid, 'member');
        if (value == 'transfer_superior') _transferSuperiorRole(targetUid);
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'kick', child: Text(l10n.kickMember, style: const TextStyle(color: Colors.red))),
        if (myRole == 'superior' && targetRole == 'member')
          PopupMenuItem(value: 'to_admin', child: Text(l10n.makeAdmin)),
        if (myRole == 'superior' && targetRole == 'admin')
          PopupMenuItem(value: 'to_member', child: Text(l10n.removeAdmin)),
        if (myRole == 'superior')
          PopupMenuItem(value: 'transfer_superior', child: Text(l10n.transferSuperior)),
      ],
    );
  }
}