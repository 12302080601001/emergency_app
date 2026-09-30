import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/incident_log.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/emergency_service.dart';

class IncidentLogsScreen extends StatefulWidget {
  const IncidentLogsScreen({super.key});

  @override
  State<IncidentLogsScreen> createState() => _IncidentLogsScreenState();
}

class _IncidentLogsScreenState extends State<IncidentLogsScreen> {
  String _selectedFilter = 'All'; // 'All', 'Active', 'Resolved'

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final allLogs = provider.incidentLogs;

    final filteredLogs = allLogs.where((log) {
      if (_selectedFilter == 'Active') {
        return log.status.toLowerCase() == 'active';
      } else if (_selectedFilter == 'Resolved') {
        return log.status.toLowerCase() == 'resolved';
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Logs'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (allLogs.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (val) {
                if (val == 'clear_all') {
                  _showClearAllDialog(context, provider);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text('Clear All Logs', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildFilterChip('All', allLogs.length),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Active',
                  allLogs.where((l) => l.status.toLowerCase() == 'active').length,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Resolved',
                  allLogs.where((l) => l.status.toLowerCase() == 'resolved').length,
                  color: Colors.greenAccent,
                ),
              ],
            ),
          ),

          // Incident List
          Expanded(
            child: filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedFilter == 'Active'
                              ? Icons.check_circle_outline
                              : Icons.history,
                          size: 64,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _selectedFilter == 'Active'
                              ? 'No active emergency incidents.'
                              : _selectedFilter == 'Resolved'
                                  ? 'No resolved incidents yet.'
                                  : 'No incident logs recorded.',
                          style: const TextStyle(color: Colors.white60, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return _buildIncidentCard(context, provider, log);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterName, int count, {Color? color}) {
    final isSelected = _selectedFilter == filterName;
    return ChoiceChip(
      label: Text(
        '$filterName ($count)',
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: color ?? AppTheme.midBlue,
      backgroundColor: AppTheme.slateDark,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = filterName;
          });
        }
      },
    );
  }

  Widget _buildIncidentCard(BuildContext context, AppProvider provider, IncidentLog log) {
    DateTime date;
    try {
      date = DateTime.parse(log.timestamp);
    } catch (_) {
      date = DateTime.now();
    }
    final formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(date);

    final isResolved = log.status.toLowerCase() == 'resolved';

    IconData iconData = Icons.warning;
    Color iconColor = Colors.white;

    switch (log.type.toLowerCase()) {
      case 'medical':
        iconData = Icons.medical_services;
        iconColor = Colors.blueAccent;
        break;
      case 'fire':
        iconData = Icons.local_fire_department;
        iconColor = Colors.orange;
        break;
      case 'security':
        iconData = Icons.local_police;
        iconColor = Colors.blueGrey;
        break;
      case 'sos':
        iconData = Icons.sos;
        iconColor = AppTheme.emergencyRed;
        break;
    }

    final hasValidCoordinates = log.latitude != 0.0 || log.longitude != 0.0;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Type + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(iconData, color: iconColor),
                  const SizedBox(width: 8),
                  Text(
                    log.type.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  if (log.id != null) {
                    _toggleStatus(context, provider, log);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isResolved
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isResolved ? Colors.greenAccent : Colors.redAccent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isResolved ? Icons.check_circle : Icons.radio_button_checked,
                        size: 14,
                        color: isResolved ? Colors.greenAccent : Colors.redAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        log.status,
                        style: TextStyle(
                          color: isResolved ? Colors.greenAccent : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Date & Time
          Text(formattedDate, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),

          // Incident Summary
          Text(
            log.summary,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 12),

          // Location link
          InkWell(
            onTap: hasValidCoordinates
                ? () => EmergencyService.instance.openMapLocation(log.latitude, log.longitude)
                : null,
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: hasValidCoordinates ? AppTheme.softPastelRed : Colors.white54,
                ),
                const SizedBox(width: 4),
                Text(
                  hasValidCoordinates
                      ? 'Lat: ${log.latitude.toStringAsFixed(4)}, Lng: ${log.longitude.toStringAsFixed(4)}'
                      : 'Location: Not available',
                  style: TextStyle(
                    color: hasValidCoordinates ? AppTheme.lightBlue : Colors.white54,
                    fontSize: 12,
                    decoration: hasValidCoordinates ? TextDecoration.underline : TextDecoration.none,
                  ),
                ),
                if (hasValidCoordinates) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.open_in_new, size: 12, color: AppTheme.lightBlue),
                ],
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 24),

          // Bottom Action Buttons (Resolve / Reopen & Delete)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.white54),
                tooltip: 'Delete Log',
                onPressed: () {
                  if (log.id != null) {
                    _showDeleteConfirm(context, provider, log.id!);
                  }
                },
              ),
              const SizedBox(width: 8),

              // Status Toggle Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isResolved ? AppTheme.midBlue : Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  if (log.id != null) {
                    _toggleStatus(context, provider, log);
                  }
                },
                icon: Icon(
                  isResolved ? Icons.replay : Icons.done_all,
                  size: 16,
                ),
                label: Text(
                  isResolved ? 'Reopen Incident' : 'Mark as Resolved',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleStatus(BuildContext context, AppProvider provider, IncidentLog log) {
    final newStatus = log.status.toLowerCase() == 'active' ? 'Resolved' : 'Active';
    provider.updateIncidentStatus(log.id!, newStatus);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus == 'Resolved'
              ? 'Incident #${log.id} marked as RESOLVED ✅'
              : 'Incident #${log.id} re-opened as ACTIVE ⚠️',
        ),
        backgroundColor: newStatus == 'Resolved' ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, AppProvider provider, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.slateDark,
        title: const Text('Delete Incident Log'),
        content: const Text('Are you sure you want to delete this incident log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              provider.deleteIncidentLog(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.slateDark,
        title: const Text('Clear All Incident Logs'),
        content: const Text('This will permanently delete all incident history. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              provider.clearAllIncidentLogs();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
