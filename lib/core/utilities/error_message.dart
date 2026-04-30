import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, PostgrestException, StorageException;

/// Maps any thrown error into a user-safe string.
///
/// The whole point of this helper is to stop leaking Supabase / Postgres
/// internals into dialog messages. Anything we don't explicitly translate
/// returns [fallback] and the original error is logged for debugging.
String errorMessage(
  Object e, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  // Network / IO — best-effort detection without a dart:io import (which
  // isn't available on web). We match on the type string instead.
  final typeName = e.runtimeType.toString();
  if (typeName == 'SocketException' || typeName == 'HttpException') {
    return 'No internet connection. Please check your network and try again.';
  }
  if (e is TimeoutException) {
    return 'The request timed out. Please try again.';
  }

  // Supabase Auth — these messages are already user-facing.
  if (e is AuthException) {
    return e.message;
  }

  // Storage failures (avatar upload etc.) — message can include URLs and
  // bucket names. Use the generic fallback.
  if (e is StorageException) {
    Get.log('StorageException: ${e.message} (statusCode=${e.statusCode})');
    return fallback;
  }

  // Postgres / PostgREST. Only a handful of codes have safe user-facing
  // translations. Everything else falls through to fallback.
  if (e is PostgrestException) {
    Get.log(
      'PostgrestException: code=${e.code} message=${e.message} details=${e.details}',
    );
    switch (e.code) {
      case '23505':
        // Unique violation. Generic on purpose — parsing the constraint
        // name out of the Postgres detail is fragile string-matching.
        // TODO: callers with known unique constraints (team name, team
        // code, email) should pass a context hint in a future pass so
        // we can surface field-specific messages.
        return 'A record with this value already exists.';
      case '42501':
        // RLS / insufficient privilege.
        return 'You don\'t have permission to do that.';
      case '22P02':
        // Invalid enum input — this is a client bug (we sent a value the
        // schema doesn\'t accept). Never expose the raw "invalid input
        // value for enum ..." string to users.
        return fallback;
      default:
        return fallback;
    }
  }

  // Anything else — strip the noisy "Exception:" prefix the Dart runtime
  // adds, but only if the message looks short and friendly. Otherwise use
  // the fallback.
  final raw = e.toString();
  Get.log('Unhandled error in errorMessage(): $raw');
  return fallback;
}
