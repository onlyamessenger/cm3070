Future<dynamic> handlePing(final dynamic context) async {
  return context.res.json({'ok': true, 'message': 'Fortify admin server is running'});
}
