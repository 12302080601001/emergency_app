import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/medical_profile.dart';
import '../models/ice_contact.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/emergency_service.dart';

class MedicalIdScreen extends StatefulWidget {
  const MedicalIdScreen({super.key});

  @override
  State<MedicalIdScreen> createState() => _MedicalIdScreenState();
}

class _MedicalIdScreenState extends State<MedicalIdScreen> {
  final List<String> _bloodTypes = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'Unknown'];
  final List<String> _commonAllergies = ['Penicillin', 'Peanuts', 'Latex', 'Aspirin', 'Sulfa', 'Dairy', 'Shellfish', 'Pollen'];
  final List<String> _commonConditions = ['Asthma', 'Diabetes', 'Hypertension', 'Heart Condition', 'Epilepsy', 'Seizures'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final profile = provider.medicalProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical ID & ICE'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (profile != null)
            IconButton(
              icon: const Icon(Icons.edit_note, size: 28),
              tooltip: 'Edit Medical Profile',
              onPressed: () => _showEditProfileSheet(context, provider, profile),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Speed Dial
            Text('Quick Emergency Hotlines', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _buildHotlinesRow(),
            const SizedBox(height: 25),

            // Medical Profile Header / Setup Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Medical Profile', style: Theme.of(context).textTheme.titleLarge),
                if (profile != null)
                  TextButton.icon(
                    onPressed: () => _showEditProfileSheet(context, provider, profile),
                    icon: const Icon(Icons.edit, size: 16, color: AppTheme.lightBlue),
                    label: const Text('Edit', style: TextStyle(color: AppTheme.lightBlue)),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (profile == null)
              _buildNewUserProfilePrompt(context, provider)
            else
              _buildProfileCard(context, provider, profile),

            const SizedBox(height: 30),

            // ICE Contacts Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ICE Contacts', style: Theme.of(context).textTheme.titleLarge),
                    const Text('In Case of Emergency Recipients', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddContactDialog(context, provider),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Contact'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.midBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (provider.iceContacts.isEmpty)
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.contact_phone_outlined, size: 48, color: Colors.white38),
                        const SizedBox(height: 10),
                        const Text(
                          'No Emergency Contacts Saved',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Add family members or close friends who should receive your GPS coordinates during SOS.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () => _showAddContactDialog(context, provider),
                          icon: const Icon(Icons.add),
                          label: const Text('Add First ICE Contact'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emergencyRed),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.iceContacts.length,
                itemBuilder: (context, index) {
                  final contact = provider.iceContacts[index];
                  return GlassCard(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppTheme.emergencyRed,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        contact.name.isNotEmpty ? contact.name : 'Emergency Contact',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        '${contact.relation.isNotEmpty ? "${contact.relation} • " : ""}${contact.phoneNumber}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.phone, color: Colors.greenAccent),
                            tooltip: 'Call Contact',
                            onPressed: () => EmergencyService.instance.makePhoneCall(contact.phoneNumber),
                          ),
                          IconButton(
                            icon: const Icon(Icons.message, color: Colors.blueAccent),
                            tooltip: 'Send Test SMS',
                            onPressed: () {
                              EmergencyService.instance.sendSmsToContacts(
                                contacts: [contact],
                                message: 'Test emergency alert from RescuSphere.',
                                context: context,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.white54),
                            tooltip: 'Delete Contact',
                            onPressed: () {
                              if (contact.id != null) {
                                provider.removeIceContact(contact.id!);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHotlinesRow() {
    final hotlines = [
      {'label': '112', 'sub': 'National SOS', 'color': Colors.redAccent},
      {'label': '108', 'sub': 'Ambulance', 'color': Colors.blueAccent},
      {'label': '100', 'sub': 'Police', 'color': Colors.tealAccent},
      {'label': '101', 'sub': 'Fire', 'color': Colors.orangeAccent},
    ];

    return Row(
      children: hotlines.map((h) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => EmergencyService.instance.makePhoneCall(h['label'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.slateDark.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (h['color'] as Color).withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      h['label'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: h['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      h['sub'] as String,
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNewUserProfilePrompt(BuildContext context, AppProvider provider) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.assignment_ind, size: 50, color: AppTheme.lightBlue),
            const SizedBox(height: 10),
            const Text(
              'No Medical Profile Set Up',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Set up your blood type, allergies, and critical health conditions so first responders can treat you properly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.midBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => _showEditProfileSheet(context, provider, null),
              icon: const Icon(Icons.person_add),
              label: const Text('Create Medical Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AppProvider provider, MedicalProfile profile) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.midBlue,
                    child: Text(
                      profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name.isNotEmpty ? profile.name : 'Unknown User',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'RescuSphere Medical ID',
                        style: TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),
              // Blood Type Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.emergencyRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.emergencyRed, width: 1.5),
                ),
                child: Column(
                  children: [
                    const Text('BLOOD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70)),
                    Text(
                      profile.bloodType.isNotEmpty ? profile.bloodType : '?',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 26),

          // Allergies
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 20, color: Colors.orangeAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Allergies', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.lightBlue)),
                    const SizedBox(height: 2),
                    Text(
                      profile.allergies.isNotEmpty ? profile.allergies : 'None recorded',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Conditions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.medical_services_outlined, size: 20, color: Colors.lightBlueAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Medical Conditions', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.lightBlue)),
                    const SizedBox(height: 2),
                    Text(
                      profile.medicalConditions.isNotEmpty ? profile.medicalConditions : 'None recorded',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 26),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showResetProfileDialog(context, provider),
                icon: const Icon(Icons.person_remove_outlined, size: 16, color: Colors.white54),
                label: const Text('Reset Profile', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.midBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: () => _showEditProfileSheet(context, provider, profile),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, AppProvider provider, MedicalProfile? existing) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    String selectedBlood = (existing?.bloodType.isNotEmpty == true && _bloodTypes.contains(existing!.bloodType))
        ? existing.bloodType
        : 'O+';
    final allergiesController = TextEditingController(text: existing?.allergies ?? '');
    final conditionsController = TextEditingController(text: existing?.medicalConditions ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.slateDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      existing == null ? 'Create Medical Profile' : 'Edit Medical Profile',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Information stored securely on your device for emergency alerts.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 18),

                    // Full Name
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Blood Type Selector
                    const Text('Blood Group', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _bloodTypes.map((bt) {
                        final isSel = selectedBlood == bt;
                        return ChoiceChip(
                          label: Text(bt, style: TextStyle(color: isSel ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
                          selected: isSel,
                          selectedColor: AppTheme.emergencyRed,
                          backgroundColor: AppTheme.darkSurface,
                          onSelected: (val) {
                            if (val) {
                              setModalState(() {
                                selectedBlood = bt;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Allergies + Quick Chips
                    const Text('Allergies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _commonAllergies.map((allergy) {
                        final current = allergiesController.text;
                        final isIncluded = current.toLowerCase().contains(allergy.toLowerCase());
                        return FilterChip(
                          label: Text(allergy, style: TextStyle(fontSize: 12, color: isIncluded ? Colors.white : Colors.white70)),
                          selected: isIncluded,
                          selectedColor: Colors.orange.shade800,
                          backgroundColor: AppTheme.darkSurface,
                          onSelected: (selected) {
                            setModalState(() {
                              List<String> items = current.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                              if (selected) {
                                if (!items.any((e) => e.toLowerCase() == allergy.toLowerCase())) {
                                  items.add(allergy);
                                }
                              } else {
                                items.removeWhere((e) => e.toLowerCase() == allergy.toLowerCase());
                              }
                              allergiesController.text = items.join(', ');
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: allergiesController,
                      decoration: const InputDecoration(
                        labelText: 'Allergies (comma-separated)',
                        hintText: 'e.g. Penicillin, Peanuts',
                        prefixIcon: Icon(Icons.warning_amber),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Conditions + Quick Chips
                    const Text('Medical Conditions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _commonConditions.map((cond) {
                        final current = conditionsController.text;
                        final isIncluded = current.toLowerCase().contains(cond.toLowerCase());
                        return FilterChip(
                          label: Text(cond, style: TextStyle(fontSize: 12, color: isIncluded ? Colors.white : Colors.white70)),
                          selected: isIncluded,
                          selectedColor: AppTheme.midBlue,
                          backgroundColor: AppTheme.darkSurface,
                          onSelected: (selected) {
                            setModalState(() {
                              List<String> items = current.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                              if (selected) {
                                if (!items.any((e) => e.toLowerCase() == cond.toLowerCase())) {
                                  items.add(cond);
                                }
                              } else {
                                items.removeWhere((e) => e.toLowerCase() == cond.toLowerCase());
                              }
                              conditionsController.text = items.join(', ');
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: conditionsController,
                      decoration: const InputDecoration(
                        labelText: 'Medical Conditions (comma-separated)',
                        hintText: 'e.g. Asthma, Diabetes',
                        prefixIcon: Icon(Icons.medical_information),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.emergencyRed,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          provider.updateMedicalProfile(MedicalProfile(
                            id: existing?.id,
                            name: nameController.text.trim(),
                            bloodType: selectedBlood,
                            allergies: allergiesController.text.trim(),
                            medicalConditions: conditionsController.text.trim(),
                          ));
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Medical Profile updated successfully! ✅'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Save Medical Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showResetProfileDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.slateDark,
        title: const Text('Reset Medical Profile?'),
        content: const Text('This will clear your personal profile details so a new user can configure their Medical ID.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              provider.resetMedicalProfile();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Medical profile reset. You can now set up a new user.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog(BuildContext context, AppProvider provider) {
    final nameController = TextEditingController();
    final relationController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.slateDark,
          title: const Text('Add ICE Contact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'e.g. Jane Doe',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: relationController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    hintText: 'e.g. Spouse, Parent, Doctor',
                    prefixIcon: Icon(Icons.family_restroom),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'e.g. +91 9099146980',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.midBlue),
              onPressed: () {
                final phone = phoneController.text.trim();
                if (phone.isNotEmpty) {
                  provider.addIceContact(IceContact(
                    name: nameController.text.trim(),
                    relation: relationController.text.trim(),
                    phoneNumber: phone,
                  ));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ICE Contact added successfully! ✅'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
