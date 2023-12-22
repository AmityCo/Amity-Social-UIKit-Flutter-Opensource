class AmityMessage {
  List<Messages>? messages;
  List<Users>? users;
  Paging? paging;

  AmityMessage({this.messages, this.users, this.paging});

  AmityMessage.fromJson(Map<String, dynamic> json) {
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));
      });
    }
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(Users.fromJson(v));
      });
    }

    paging = json["paging"] == null ? null : Paging.fromJson(json["paging"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if ( messages != null) {
      data['messages'] =  messages!.map((v) => v.toJson()).toList();
    }
    if ( users != null) {
      data['users'] =  users!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Messages {
  String? type;
  bool? isDeleted;
  String? createdAt;
  String? editedAt;
  int? channelSegment;
  String? updatedAt;
  int? childrenNumber;
  String? channelId;
  String? userId;
  String? messageId;
  int? flagCount;
  int? reactionsCount;
  Reactions? reactions;
  Data? data;

  Messages(
      {this.type,
      this.isDeleted,
      this.createdAt,
      this.editedAt,
      this.channelSegment,
      this.updatedAt,
      this.childrenNumber,
      this.channelId,
      this.userId,
      this.messageId,
      this.flagCount,
      this.reactionsCount,
      this.reactions,
      this.data});

  Messages.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    editedAt = json['editedAt'];
    channelSegment = json['channelSegment'];
    updatedAt = json['updatedAt'];
    childrenNumber = json['childrenNumber'];
    channelId = json['channelId'];
    userId = json['userId'];
    messageId = json['messageId'];
    flagCount = json['flagCount'];
    reactionsCount = json['reactionsCount'];
    reactions = json['reactions'] != null
        ?  Reactions.fromJson(json['reactions'])
        : null;
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] =  type;
    data['isDeleted'] =  isDeleted;
    data['createdAt'] =  createdAt;
    data['editedAt'] =  editedAt;
    data['channelSegment'] =  channelSegment;
    data['updatedAt'] =  updatedAt;
    data['childrenNumber'] =  childrenNumber;
    data['channelId'] =  channelId;
    data['userId'] =  userId;
    data['messageId'] =  messageId;
    data['flagCount'] =  flagCount;
    data['reactionsCount'] =  reactionsCount;
    if ( reactions != null) {
      data['reactions'] =  reactions!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Reactions {
  int? like;

  Reactions({this.like});

  Reactions.fromJson(Map<String, dynamic> json) {
    like = json['Like'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Like'] =  like;
    return data;
  }
}

class Data {
  String? text = "";

  Data({this.text});

  Data.fromJson(Map<String, dynamic> json) {
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    return data;
  }
}

class Users {
  String? sId;
  String? path;
  String? displayName;
  String? updatedAt;
  String? createdAt;
  String? userId;
  List<String>? roles;
  int? flagCount;

  Users({
    this.sId,
    this.path,
    this.displayName,
    this.updatedAt,
    this.createdAt,
    this.userId,
    this.roles,
    this.flagCount,
  });

  Users.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    path = json['path'];
    displayName = json['displayName'];
    updatedAt = json['updatedAt'];
    createdAt = json['createdAt'];
    userId = json['userId'];
    roles = json['roles'].cast<String>();
    flagCount = json['flagCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] =  sId;
    data['path'] =  path;
    data['displayName'] =  displayName;
    data['updatedAt'] =  updatedAt;
    data['createdAt'] =  createdAt;
    data['userId'] =  userId;
    data['roles'] =  roles;
    data['flagCount'] =  flagCount;

    return data;
  }
}

class Paging {
  String? next;
  String? previous;

  Paging({this.next, this.previous});

  Paging.fromJson(Map<String, dynamic> json) {
    next = json['next'];
    previous = json['previous'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['next'] =  next;
    data['previous'] =  previous;
    return data;
  }
}
