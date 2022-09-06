class ChannelList {
  List<Channels>? channels;
  List<ChannelUsers>? channelUsers;
  List<Users>? users;
  List<Files>? files;

  ChannelList({this.channels, this.channelUsers, this.users, this.files});

  ChannelList.fromJson(Map<String, dynamic> json) {
    if (json['channels'] != null) {
      channels = <Channels>[];
      json['channels'].forEach((v) {
        channels!.add(new Channels.fromJson(v));
      });
    }
    if (json['channelUsers'] != null) {
      channelUsers = <ChannelUsers>[];
      json['channelUsers'].forEach((v) {
        channelUsers!.add(new ChannelUsers.fromJson(v));
      });
    }
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(new Users.fromJson(v));
      });
    }
    if (json['files'] != null) {
      files = <Files>[];
      json['files'].forEach((v) {
        files!.add(new Files.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.channels != null) {
      data['channels'] = this.channels!.map((v) => v.toJson()).toList();
    }
    if (this.channelUsers != null) {
      data['channelUsers'] = this.channelUsers!.map((v) => v.toJson()).toList();
    }
    if (this.users != null) {
      data['users'] = this.users!.map((v) => v.toJson()).toList();
    }
    if (this.files != null) {
      data['files'] = this.files!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Channels {
  String? channelId;
  bool? isDistinct;
  Metadata? metadata;
  String? type;
  List<String>? tags;
  bool? isMuted;
  bool? isRateLimited;
  String? muteTimeout;
  int? rateLimit;
  int? rateLimitWindow;
  String? rateLimitTimeout;
  String? displayName;
  bool? messageAutoDeleteEnabled;
  int? autoDeleteMessageByFlagLimit;
  int? memberCount;
  int? messageCount;
  String? lastActivity;
  String? createdAt;
  String? updatedAt;
  String? avatarFileId;
  bool? isDeleted;
  int unreadCount = 0;
  String latestMessage = "No message yet";

  Channels(
      {this.channelId,
      this.isDistinct,
      this.metadata,
      this.type,
      this.tags,
      this.isMuted,
      this.isRateLimited,
      this.muteTimeout,
      this.rateLimit,
      this.rateLimitWindow,
      this.rateLimitTimeout,
      this.displayName,
      this.messageAutoDeleteEnabled,
      this.autoDeleteMessageByFlagLimit,
      this.memberCount,
      this.messageCount,
      this.lastActivity,
      this.createdAt,
      this.updatedAt,
      this.avatarFileId,
      this.isDeleted});

  Channels.fromJson(Map<String, dynamic> json) {
    channelId = json['channelId'];
    isDistinct = json['isDistinct'];
    metadata = json['metadata'] != null
        ? new Metadata.fromJson(json['metadata'])
        : null;
    type = json['type'];
    if (json['tags'] != null) {
      List<String> _tags = [];
      json['tags'].forEach((v) {
        _tags.add(v);
      });
      tags = _tags;
    }
    isMuted = json['isMuted'];
    isRateLimited = json['isRateLimited'];
    muteTimeout = json['muteTimeout'];
    rateLimit = json['rateLimit'];
    rateLimitWindow = json['rateLimitWindow'];
    rateLimitTimeout = json['rateLimitTimeout'];
    displayName = json['displayName'];
    messageAutoDeleteEnabled = json['messageAutoDeleteEnabled'];
    autoDeleteMessageByFlagLimit = json['autoDeleteMessageByFlagLimit'];
    memberCount = json['memberCount'];
    messageCount = json['messageCount'];
    lastActivity = json['lastActivity'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    avatarFileId = json['avatarFileId'];
    isDeleted = json['isDeleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['channelId'] = this.channelId;
    data['isDistinct'] = this.isDistinct;
    if (this.metadata != null) {
      data['metadata'] = this.metadata!.toJson();
    }
    data['type'] = this.type;
    data['tags'] = this.tags;
    data['isMuted'] = this.isMuted;
    data['isRateLimited'] = this.isRateLimited;
    data['muteTimeout'] = this.muteTimeout;
    data['rateLimit'] = this.rateLimit;
    data['rateLimitWindow'] = this.rateLimitWindow;
    data['rateLimitTimeout'] = this.rateLimitTimeout;
    data['displayName'] = this.displayName;
    data['messageAutoDeleteEnabled'] = this.messageAutoDeleteEnabled;
    data['autoDeleteMessageByFlagLimit'] = this.autoDeleteMessageByFlagLimit;
    data['memberCount'] = this.memberCount;
    data['messageCount'] = this.messageCount;
    data['lastActivity'] = this.lastActivity;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['avatarFileId'] = this.avatarFileId;
    data['isDeleted'] = this.isDeleted;
    return data;
  }

  void setUnreadCount(int count) {
    unreadCount = count;
  }

  void setLatestMessage(String text) {
    latestMessage = text;
  }
}

class Metadata {
  // Metadata({});

  Metadata.fromJson(Map<String, dynamic> json) {}

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }
}

class ChannelUsers {
  String? userId;
  String? channelId;
  String? membership;
  bool? isBanned;
  String? lastActivity;
  List<String>? roles;
  List<String>? permissions;
  int? readToSegment;
  int? lastMentionedSegment;
  bool? isMuted;
  String? muteTimeout;
  String? createdAt;
  String? updatedAt;

  ChannelUsers(
      {this.userId,
      this.channelId,
      this.membership,
      this.isBanned,
      this.lastActivity,
      this.roles,
      this.permissions,
      this.readToSegment,
      this.lastMentionedSegment,
      this.isMuted,
      this.muteTimeout,
      this.createdAt,
      this.updatedAt});

  ChannelUsers.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    channelId = json['channelId'];
    membership = json['membership'];
    isBanned = json['isBanned'];
    lastActivity = json['lastActivity'];
    roles = json['roles'].cast<String>();
    permissions = json['permissions'].cast<String>();
    readToSegment = json['readToSegment'];
    lastMentionedSegment = json['lastMentionedSegment'];
    isMuted = json['isMuted'];
    muteTimeout = json['muteTimeout'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['channelId'] = this.channelId;
    data['membership'] = this.membership;
    data['isBanned'] = this.isBanned;
    data['lastActivity'] = this.lastActivity;
    data['roles'] = this.roles;
    data['permissions'] = this.permissions;
    data['readToSegment'] = this.readToSegment;
    data['lastMentionedSegment'] = this.lastMentionedSegment;
    data['isMuted'] = this.isMuted;
    data['muteTimeout'] = this.muteTimeout;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class Users {
  String? sId;
  String? path;
  String? userId;
  List<String>? roles;
  List<String>? permissions;
  String? displayName;
  String? description;
  String? avatarFileId;
  String? avatarCustomUrl;
  int? flagCount;

  Metadata? metadata;
  bool? isGlobalBan;
  String? createdAt;
  String? updatedAt;

  Users(
      {this.sId,
      this.path,
      this.userId,
      this.roles,
      this.permissions,
      this.displayName,
      this.description,
      this.avatarFileId,
      this.avatarCustomUrl,
      this.flagCount,
      this.metadata,
      this.isGlobalBan,
      this.createdAt,
      this.updatedAt});

  Users.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    path = json['path'];
    userId = json['userId'];
    roles = json['roles'].cast<String>();
    permissions = json['permissions'].cast<String>();
    displayName = json['displayName'];
    description = json['description'];
    avatarFileId = json['avatarFileId'];
    avatarCustomUrl = json['avatarCustomUrl'];
    flagCount = json['flagCount'];

    metadata = json['metadata'] != null
        ? new Metadata.fromJson(json['metadata'])
        : null;
    isGlobalBan = json['isGlobalBan'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['path'] = this.path;
    data['userId'] = this.userId;
    data['roles'] = this.roles;
    data['permissions'] = this.permissions;
    data['displayName'] = this.displayName;
    data['description'] = this.description;
    data['avatarFileId'] = this.avatarFileId;
    data['avatarCustomUrl'] = this.avatarCustomUrl;
    data['flagCount'] = this.flagCount;

    if (this.metadata != null) {
      data['metadata'] = this.metadata!.toJson();
    }
    data['isGlobalBan'] = this.isGlobalBan;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class Files {
  String? fileId;
  String? fileUrl;
  String? type;
  String? createdAt;
  String? updatedAt;
  Attributes? attributes;

  Files(
      {this.fileId,
      this.fileUrl,
      this.type,
      this.createdAt,
      this.updatedAt,
      this.attributes});

  Files.fromJson(Map<String, dynamic> json) {
    fileId = json['fileId'];
    fileUrl = json['fileUrl'];
    type = json['type'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    // attributes = json['attributes'] != null ? new Attributes.fromJson(json['attributes']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fileId'] = this.fileId;
    data['fileUrl'] = this.fileUrl;
    data['type'] = this.type;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    // if (this.attributes != null) {
    //   data['attributes'] = this.attributes!.toJson();
    // }
    return data;
  }
}

class Attributes {
  String? name;
  String? extension;
  String? size;
  String? mimeType;
  Metadata? metadata;

  Attributes(
      {this.name, this.extension, this.size, this.mimeType, this.metadata});

  Attributes.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    extension = json['extension'];
    size = json['size'];
    mimeType = json['mimeType'];
    metadata = json['metadata'] != null
        ? new Metadata.fromJson(json['metadata'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['extension'] = this.extension;
    data['size'] = this.size;
    data['mimeType'] = this.mimeType;
    if (this.metadata != null) {
      data['metadata'] = this.metadata!.toJson();
    }
    return data;
  }
}

class FileMetadata {
  FileMetadata? exif;
  FileMetadata? gps;
  int? height;
  int? width;
  bool? isFull;

  FileMetadata({this.exif, this.gps, this.height, this.width, this.isFull});

  FileMetadata.fromJson(Map<String, dynamic> json) {
    exif =
        json['exif'] != null ? new FileMetadata.fromJson(json['exif']) : null;
    gps = json['gps'] != null ? new FileMetadata.fromJson(json['gps']) : null;
    height = json['height'];
    width = json['width'];
    isFull = json['isFull'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.exif != null) {
      data['exif'] = this.exif!.toJson();
    }
    if (this.gps != null) {
      data['gps'] = this.gps!.toJson();
    }
    data['height'] = this.height;
    data['width'] = this.width;
    data['isFull'] = this.isFull;
    return data;
  }
}
