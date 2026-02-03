enum Flavor {
  stage,
  prod
  ;

  static var current = Flavor.prod;

  static bool get isStage => current == Flavor.stage;

  static bool get isProd => current == Flavor.prod;
}
