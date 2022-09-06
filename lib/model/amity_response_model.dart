class AmityResponse {
  String? status;
  String? message;
  int? code;
  AmityData? data;

  AmityResponse({this.status, this.message, this.code, this.data});

  AmityResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    code = json['code'];

    data = json['data'] != null ? new AmityData(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['code'] = this.code;

    return data;
  }
}

class AmityData {
  Map<String, dynamic>? json;
  AmityData(this.json);
}
