class VerificationResponseModel {
  List<Result>? result;

  VerificationResponseModel({this.result});

  VerificationResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(new Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.result != null) {
      data['result'] = this.result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  String? verification;

  Result({this.verification});

  Result.fromJson(Map<String, dynamic> json) {
    verification = json['verification'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['verification'] = this.verification;
    return data;
  }
}
