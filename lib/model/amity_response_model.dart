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

    data = json['data'] != null ? AmityData(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] =  status;
    data['message'] =  message;
    data['code'] =  code;

    return data;
  }
}

class AmityData {
  Map<String, dynamic>? json;
  AmityData(this.json);
}
