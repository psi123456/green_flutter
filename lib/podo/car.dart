class Car {
  List<String>? imgs; // 여러 이미지 경로를 저장하기 위해 List<String> 타입으로 변경
  String? name;
  List<String>? type; // List<String> 타입으로 변경

  Car({
    this.imgs,
    this.name,
    this.type,
  });

  Car.fromJson(Map<String, dynamic> json) {
    // JSON 배열에서 이미지 경로 리스트를 읽어옴
    imgs = json['imgs']?.cast<String>();
    name = json['name'];
    type = json['type']?.cast<String>(); // List<String>로 변환
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imgs'] = this.imgs;
    data['name'] = this.name;
    data['type'] = this.type;
    return data;
  }
}