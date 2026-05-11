import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final user = FirebaseAuth.instance.currentUser!;
      final newUsername = _usernameController.text.trim();
      final usernameDoc = await FirebaseFirestore.instance.collection('usernames').doc(newUsername).get();

      if (usernameDoc.exists && usernameDoc.data()?['uid'] != user.uid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nome de usuário já em uso.')));
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código inválido.')));
      }
    }
  }

  Future<void> _refreshCommunityCode() async {
    if (_communityId == null) return;
    final newCode = await _generateUniqueCode();
    await FirebaseFirestore.instance.collection('communities').doc(_communityId).update({'code': newCode});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código de acesso atualizado!')));
    }
  }

  Future<void> _updateMemberRole(String memberUid, String newRole) async {
    if (_communityId != null) {
      await FirebaseFirestore.instance.collection('communities').doc(_communityId).update({'roles.$memberUid': newRole});
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

  void _showCreateDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Comunidade'),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) _createCommunity(nameController.text.trim());
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog() {
    final TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entrar em Comunidade'),
        content: TextField(controller: codeController, keyboardType: TextInputType.number, maxLength: 5),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (codeController.text.trim().length == 5) _joinCommunity(codeController.text.trim());
            },
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha Comunidade')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: _communityId != null ? _buildCommunityDashboard() : _buildSetupOptions(),
      ),
    );
  }

  Widget _buildSetupOptions() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUsernameForm(),
          if (_username != null) ...[
            const SizedBox(height: 40),
            ElevatedButton.icon(onPressed: _showCreateDialog, icon: const Icon(Icons.group_add), label: const Text('Criar Comunidade')),
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: _showJoinDialog, icon: const Icon(Icons.search), label: const Text('Entrar usando Código')),
          ]
        ],
      ),
    );
  }

  Widget _buildUsernameForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(_username == null ? 'Escolha seu Username' : 'Seu Username', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _saveUsername, child: Text(_username == null ? 'Salvar' : 'Atualizar')),
        ],
      ),
    );
  }

  Widget _buildCommunityDashboard() {
    final currentUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('communities').doc(_communityId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (!snapshot.data!.exists) return const Center(child: Text('Comunidade não encontrada.'));

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final roles = Map<String, String>.from(data['roles'] ?? {});
        final myRole = roles[currentUser.uid] ?? 'member';
        final canManage = myRole == 'superior' || myRole == 'admin';

        return Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(data['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Código: ${data['code']}', style: const TextStyle(fontSize: 16, letterSpacing: 1.2)),
                        IconButton(icon: const Icon(Icons.copy, size: 18), onPressed: () => Clipboard.setData(ClipboardData(text: data['code']))),
                        if (canManage)
                          IconButton(icon: const Icon(Icons.refresh, size: 18, color: Colors.blue), onPressed: _refreshCommunityCode),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Align(alignment: Alignment.centerLeft, child: Text('Membros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Expanded(child: _buildMembersList(List<String>.from(data['members']), roles, myRole)),
          ],
        );
      },
    );
  }

  Widget _buildMembersList(List<String> memberIds, Map<String, String> roles, String myRole) {
    if (memberIds.isEmpty) return const Center(child: Text('Nenhum membro.'));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, whereIn: memberIds).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Erro ao carregar membros.'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final users = snapshot.data!.docs;
        final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            final uid = users[index].id;
            final username = userData['username'] ?? 'Usuário';
            final role = roles[uid] ?? 'member';
            final isMe = uid == currentUserUid;

            String roleLabel = 'Membro';
            if (role == 'superior') roleLabel = 'Administrador Superior';
            if (role == 'admin') roleLabel = 'Administrador';

            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('$username${isMe ? " (Você)" : ""}', style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal)),
              subtitle: Text(roleLabel, style: const TextStyle(fontSize: 12)),
              trailing: _buildMemberMenu(uid, role, myRole, isMe),
            );
          },
        );
      },
    );
  }

  Widget? _buildMemberMenu(String targetUid, String targetRole, String myRole, bool isMe) {
    bool canAdmin = myRole == 'superior' || myRole == 'admin';
    if (isMe || targetRole == 'superior' || !canAdmin) return null;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'kick') _kickMember(targetUid);
        if (value == 'to_admin') _updateMemberRole(targetUid, 'admin');
        if (value == 'to_member') _updateMemberRole(targetUid, 'member');
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'kick', child: Text('Expulsar', style: TextStyle(color: Colors.red))),
        if (myRole == 'superior' && targetRole == 'member')
          const PopupMenuItem(value: 'to_admin', child: Text('Tornar Administrador')),
        if (myRole == 'superior' && targetRole == 'admin')
          const PopupMenuItem(value: 'to_member', child: Text('Remover Administrador')),
      ],
    );
  }
}