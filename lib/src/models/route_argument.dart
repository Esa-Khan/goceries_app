class RouteArgument {
  String id;
  String heroTag;
  dynamic param;
  dynamic param2;

  RouteArgument({this.id, this.heroTag, this.param, this.param2});

  @override
  String toString() {
    return '{id: $id, heroTag:${heroTag.toString()}}';
  }
}
