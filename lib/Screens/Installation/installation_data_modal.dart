class GetInstallationDataPptModal {
  List<Result>? result;

  GetInstallationDataPptModal({this.result});

  GetInstallationDataPptModal.fromJson(Map<String, dynamic> json) {
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
  String? clientName;
  String? branchName;
  String? clientLogo;
  String? clientAddress;
  String? city;
  String? state;
  int? clientNo;
  String? vendorName;
  String? userName;
  String? reportDate;
  String? element;
  String? elementPrice;
  String? comment;
  String? height;
  String? width;
  String? imageUrl;
  String? buildingPhoto;
  String? gsbPhoto;

  Result(
      {this.id,
        this.clientName,
        this.branchName,
        this.clientLogo,
        this.clientAddress,
        this.city,
        this.state,
        this.clientNo,
        this.vendorName,
        this.userName,
        this.reportDate,
        this.element,
        this.elementPrice,
        this.comment,
        this.height,
        this.width,
        this.imageUrl,
        this.buildingPhoto,
        this.gsbPhoto});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientName = json['client_name'];
    branchName = json['branch_name'];
    clientLogo = json['client_logo'];
    clientAddress = json['client_address'];
    city = json['city'];
    state = json['state'];
    clientNo = json['client_no'];
    vendorName = json['vendor_name'];
    userName = json['user_name'];
    reportDate = json['report_date'];
    element = json['element'];
    elementPrice = json['element_price'];
    comment = json['comment'];
    height = json['height'];
    width = json['width'];
    imageUrl = json['image_url'];
    buildingPhoto = json['building_photo'];
    gsbPhoto = json['gsb_photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['client_name'] = this.clientName;
    data['branch_name'] = this.branchName;
    data['client_logo'] = this.clientLogo;
    data['client_address'] = this.clientAddress;
    data['city'] = this.city;
    data['state'] = this.state;
    data['client_no'] = this.clientNo;
    data['vendor_name'] = this.vendorName;
    data['user_name'] = this.userName;
    data['report_date'] = this.reportDate;
    data['element'] = this.element;
    data['element_price'] = this.elementPrice;
    data['comment'] = this.comment;
    data['height'] = this.height;
    data['width'] = this.width;
    data['image_url'] = this.imageUrl;
    data['building_photo'] = this.buildingPhoto;
    data['gsb_photo'] = this.gsbPhoto;
    return data;
  }
}
