class UserDataModel {
  List<Result>? result;

  UserDataModel({this.result});

  UserDataModel.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? email;
  String? contectNo;
  String? iMG;
  String? loginStatus;
  String? userName;
  String? vendorName;
  String? createdAt;

  Result(
      {this.id,
        this.email,
        this.contectNo,
        this.iMG,
        this.loginStatus,
        this.vendorName,
        this.userName,
        this.createdAt});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    contectNo = json['Contect_no'];
    iMG = json['IMG'];
    loginStatus = json['Login_status'];
    userName = json['User_name'];
    createdAt = json['created_at'];
    vendorName = json['vendor_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['Contect_no'] = this.contectNo;
    data['IMG'] = this.iMG;
    data['Login_status'] = this.loginStatus;
    data['User_name'] = this.userName;
    data['created_at'] = this.createdAt;
    data['vendor_name'] = this.vendorName;
    return data;
  }
}
