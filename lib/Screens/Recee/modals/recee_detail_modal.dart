class receeDetailModal {
  List<Result>? result;

  receeDetailModal({this.result});

  receeDetailModal.fromJson(Map<String, dynamic> json) {
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
  String? username;
  String? vendorName;
  String? branchName;
  String? clientAddress;
  String? city;
  String? state;
  String? assignBy;
  String? date;
  String? logo;
  int? mmId;
  String? bmId;
  String? lat;
  String? lon;
  String? clientNo;
  String? clientName;
  String? element;
  int? elementPrice;
  String? type;
  String? status;

  Result(
      {this.id,
        this.username,
        this.vendorName,
        this.branchName,
        this.clientAddress,
        this.city,
        this.state,
        this.assignBy,
        this.date,
        this.logo,
        this.mmId,
        this.bmId,
        this.lat,
        this.lon,
        this.clientNo,
        this.clientName,
        this.element,
        this.elementPrice,
        this.type,
        this.status});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    vendorName = json['vendor_name'];
    branchName = json['branch_name'];
    clientAddress = json['client_address'];
    city = json['city'];
    state = json['state'];
    assignBy = json['assign_by'];
    date = json['date'];
    logo = json['logo'];
    mmId = json['mm_id'];
    bmId = json['bm_id'];
    lat = json['lat'];
    lon = json['lon'];
    clientNo = json['client_no'];
    clientName = json['client_name'];
    element = json['element'];
    elementPrice = json['element_price'];
    type = json['type'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['vendor_name'] = this.vendorName;
    data['branch_name'] = this.branchName;
    data['client_address'] = this.clientAddress;
    data['city'] = this.city;
    data['state'] = this.state;
    data['assign_by'] = this.assignBy;
    data['date'] = this.date;
    data['logo'] = this.logo;
    data['mm_id'] = this.mmId;
    data['bm_id'] = this.bmId;
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    data['client_no'] = this.clientNo;
    data['client_name'] = this.clientName;
    data['element'] = this.element;
    data['element_price'] = this.elementPrice;
    data['type'] = this.type;
    data['status'] = this.status;
    return data;
  }
}
