import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../services/websocket_service.dart';
import '../config/api_config.dart';

class DebugOverlay extends StatefulWidget {
  const DebugOverlay({super.key});

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  bool _isVisible = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Debug toggle button
        Positioned(
          top: 50,
          right: 10,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: _isVisible ? Colors.red : Colors.blue,
            onPressed: () {
              setState(() {
                _isVisible = !_isVisible;
              });
            },
            child: Icon(
              _isVisible ? Icons.close : Icons.bug_report,
              color: Colors.white,
            ),
          ),
        ),

        // Debug panel
        if (_isVisible)
          Positioned(
            top: 110,
            right: 10,
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bug_report, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Debug Panel',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  if (_isExpanded) ...[
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDebugInfo(),
                          const SizedBox(height: 12),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDebugInfo() {
    final chatController = Get.find<ChatController>();
    final webSocketService = WebSocketService.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('API Base URL', ApiConfig.baseUrl),
        _buildInfoRow('WebSocket URL', ApiConfig.wsUrl),
        _buildInfoRow('WebSocket Status', webSocketService.isConnected ? 'Connected' : 'Disconnected'),
        _buildInfoRow('Auth Token',
            chatController.currentUserId != null ? 'Set (User: ${chatController.currentUserId})' : 'Not Set'),
        _buildInfoRow('Chats Count', '${chatController.chats.length}'),
        _buildInfoRow('Messages Count', '${chatController.messages.length}'),
        _buildInfoRow('Is Loading', chatController.isLoading ? 'Yes' : 'No'),
        _buildInfoRow(
            'Error Message', chatController.errorMessage.isNotEmpty ? chatController.errorMessage : 'None'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final chatController = Get.find<ChatController>();
    final webSocketService = WebSocketService.instance;

    return Column(
      children: [
        // Retry get chats button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              chatController.loadUserChats();
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry Get Chats'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Connect WebSocket button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              chatController.connectWebSocket();
            },
            icon: const Icon(Icons.wifi, size: 16),
            label: const Text('Connect WebSocket'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Disconnect WebSocket button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              webSocketService.disconnect();
            },
            icon: const Icon(Icons.wifi_off, size: 16),
            label: const Text('Disconnect WebSocket'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Clear error button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              chatController.clearError();
            },
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Clear Error'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Test API connection button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              chatController.testApiConnection();
            },
            icon: const Icon(Icons.network_check, size: 16),
            label: const Text('Test API'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}
