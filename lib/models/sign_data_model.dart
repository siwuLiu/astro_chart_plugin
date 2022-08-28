class SignPosition {
  SignPosition({this.degree, this.arcminute});
  final num degree;
  final num arcminute;
}

class PlanetsPosition {
  PlanetsPosition({this.sign, this.position});
  final String sign;
  final SignPosition position;
}

class PlanetsItem {
  PlanetsItem({
    this.name,
    this.positionSign,
    this.startPosition, // 需要更具House每个宫头位置角度计算
    this.positionDegree,
    this.positionArcminute,
    this.status,
    this.house,
  });

  final String name;
  final String positionSign;
  final int startPosition;
  final int positionDegree;
  final int positionArcminute;
  final bool status;
  final int house;

  static PlanetsItem fromJson(Map<String, dynamic> json){
    return PlanetsItem(
      name: json['name'],
      positionSign: json["position"]["sign"],
      startPosition: json["start_position"],
      positionDegree: json["position"]["position"]["degree"],
      positionArcminute: json["position"]["position"]["arcminute"],
      status: json["status"],
      house: json["house"],
    );
  }
}

class HouseItem {
  HouseItem({
    this.index,
    this.cuspSign,
    this.cuspPositionDegree,
    this.cuspPositionArcminute,
    this.startAngleDegree,
    this.startAnglePositionArcminute,
  });

  final int index;
  final String cuspSign;
  final num cuspPositionDegree;
  final num cuspPositionArcminute;
  final num startAngleDegree;
  final num startAnglePositionArcminute;

  static HouseItem fromJson(Map<String, dynamic> json){
    return HouseItem(
      index: json["index"],
      cuspSign: json["cusp"]["sign"],
      cuspPositionDegree: json["cusp"]["position"]["degree"],
      cuspPositionArcminute: json["cusp"]["position"]["arcminute"],
      startAngleDegree: json["startAngle"]["degree"],
      startAnglePositionArcminute: json["startAngle"]["arcminute"],
    );
  }
}

class SignItem {
  SignItem({
    this.name,
    this.startDegree,
    this.startArcminute,
    this.endDegree,
    this.endArcminute
  });

  final String name;
  final num startDegree;
  final num startArcminute;
  final num endDegree;
  final num endArcminute;

  static SignItem fromJson(Map<String, dynamic> json){
    return SignItem(
      name: json["name"],
      startDegree: json["start"]["degree"],
      startArcminute: json["start"]["arcminute"],
      endDegree: json["end"]["degree"],
      endArcminute: json["end"]["arcminute"],
    );
  }
}

enum aspectTypes { /// 相位类型
  Con, // 合项
  Opp, // 对分相
  Tri, // 三分相
  Squ, // 四分相
  Sex  // 六分相
} 

class AspectItem {
  AspectItem({
    this.destObj, // 目的行星
    this.orb, // 容许度
    this.power, // 权重
    this.srcObj, // 源行星
    this.t, // 相位类型
  });

  final String destObj;
  final num orb;
  final num power;
  final String srcObj;
  final String t;
    

  static AspectItem fromJson(Map<String, dynamic> json){
    return AspectItem(
      srcObj: json['srcObj'],
      destObj: json['destObj'],
      orb: json['orb'],
      power: json['power'],
      t: json['t']
    );
  }
}



class SignsData {
  SignsData({this.person, this.planets, this.houses, this.signs, this.aspects});

  final dynamic person;
  final List<PlanetsItem> planets;
  final List<HouseItem> houses;
  final List<SignItem> signs;
  final List<AspectItem> aspects;

  /// 通过接口返回的json对象创建实例
  /// ```json
  /// {
  ///   "person": null,
  ///   "planets": [{
  ///     "name": "Sun",
  ///     "position": {
  ///       "sign": "Gem",
  ///       "position": {"degree": 11, "arcminute": 26}
  ///     },
  ///     "status": null,
  ///     "house": 2
  ///   }],
  ///   "houses": [{
  ///     "index": 1,
  ///     "cusp": {"sign": "Ari", "position": {"degree": 11, "arcminute": 26}},
  ///     "startAngle": {"degree": 11, "arcminute": 26}
  ///   }],
  ///   "signs": [{
  ///     "name": "Ari",
  ///     "start": {"degree": 11, "arcminute": 26},
  ///     "end": {"degree": 110, "arcminute": 26}
  ///   }],
  ///   "aspects": [{
  ///     "dest_obj": "",
  ///     "src_obj": "",
  ///     "orb": "",
  ///     "power": 0.0,
  ///     "t": ""
  ///   }]
  /// }
  /// ```
  static SignsData fromJson(Map<String, dynamic> json) {
    List<PlanetsItem> planets = [];
    List<HouseItem> houses = [];
    List<SignItem> signs = [];
    List<AspectItem> aspects = [];
    Map<int, num> houseDeg = {};

    for(int i = 0; i < json["houses"].length; i++){
      HouseItem item = HouseItem.fromJson(json["houses"][i]);
      houses.add(item);
      houseDeg[item.index] = item.startAngleDegree;
      item = null;
    }

    for(int i = 0; i < json["planets"].length; i++){
      Map<String, dynamic> item = json["planets"][i];
      item["start_position"] = 
        houseDeg[item["house"]].toInt() + item["position"]["position"]["degree"];
      planets.add(PlanetsItem.fromJson(item));
    }

    for(int i = 0; i < json["signs"].length; i++){
      signs.add(SignItem.fromJson(json["signs"][i]));
    }

    for(int i = 0; i < json["aspects"].length; i++){
      aspects.add(AspectItem.fromJson(json["aspects"][i]));
    }

    return SignsData(
      person: json["person"],
      planets: planets,
      houses: houses,
      signs: signs,
      aspects: aspects
    );
  }
}