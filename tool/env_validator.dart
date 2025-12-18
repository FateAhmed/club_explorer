#!/usr/bin/env dart
// Pre-build validator to prevent shipping dev credentials
// Run before release builds: dart run tool/env_validator.dart

import 'dart:io';

void main() {
  print('🔍 Validating environment configuration...\n');

  final envFile = File('lib/config/env.dart');

  if (!envFile.existsSync()) {
    _exitWithError('env.dart not found at lib/config/env.dart');
  }

  final content = envFile.readAsStringSync();

  // Development indicators that should not be in production
  final devIndicators = {
    'localhost': 'Development server detected',
    '127.0.0.1': 'Loopback address detected',
    '0.0.0.0': 'Wildcard address detected',
    'http://10.': 'Private network address detected',
    'http://192.168.': 'Private network address detected',
  };

  final foundIssues = <String, String>{};

  for (final entry in devIndicators.entries) {
    if (content.contains(entry.key)) {
      foundIssues[entry.key] = entry.value;
    }
  }

  if (foundIssues.isNotEmpty) {
    _printError(foundIssues);
    exit(1);
  }

  print('✅ Environment validation passed');
  print('✅ No development credentials detected\n');
  exit(0);
}

void _printError(Map<String, String> issues) {
  print('');
  print('╔═══════════════════════════════════════════════════════════════╗');
  print('║  ❌ CRITICAL: Development Credentials Detected!              ║');
  print('╚═══════════════════════════════════════════════════════════════╝');
  print('');
  print('Found development indicators in lib/config/env.dart:');
  print('');

  for (final entry in issues.entries) {
    print('  ❌ ${entry.key}');
    print('     └─ ${entry.value}');
    print('');
  }

  print('📋 Action Required:');
  print('   1. Update lib/config/env.dart with production URLs');
  print('   2. Remove all localhost and development server references');
  print('   3. Run this validator again before building');
  print('');
  print('💡 Tip: Use environment-specific configs and build flavors');
  print('');
  print('❌ Build validation failed!');
  print('');
}

void _exitWithError(String message) {
  print('❌ Error: $message');
  exit(1);
}
