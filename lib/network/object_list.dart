import 'package:flaxum_fileshare/dio_client.dart';
import 'package:flaxum_fileshare/models/context.dart';
import 'package:flaxum_fileshare/models/object_.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../providers/object_provider.dart';
import '../providers/context_provider.dart';

Future<List<Object_>> _fetchObjects(
    BuildContext context, String endpoint, Scope scope, String? id) async {
  final response = await dioUnauthorized.post(endpoint,
      data: {"parent_id": id},
      options: Options(contentType: "application/json", headers: {
        "Cache-Control": "no-cache",
        "authorization": getTokenFromCookie(),
      }));

  if (response.statusCode == 200) {
    final result = GetOwnObjectsResponse.fromJson(response.data);
    Provider.of<ObjectProvider>(context, listen: false).updateData(result.data);
    Provider.of<ContextProvider>(context, listen: false).updateScope(scope);
    return result.data;
  } else if (response.statusCode == 401) {
    Provider.of<ContextProvider>(context, listen: false).updateScope(null);
    Navigator.of(context).pushReplacementNamed('/auth');
    throw Exception('Unauthorized');
  } else {
    throw Exception('Failed to load objects');
  }
}

/// Посылает список объектов в буфер.
Future<List<Object_>> getOwnObjects(BuildContext context, String? id) async {
  return await _fetchObjects(context, '/object/own/list', Scope.own, id);
}

Future<List<Object_>> getTrashObjects(BuildContext context) async {
  return await _fetchObjects(context, '/object/trash/list', Scope.trash, null);
}

Future<List<Object_>> getSharedObjects(BuildContext context, String? id) async {
  return await _fetchObjects(context, '/object/shared/list', Scope.shared, id);
}
