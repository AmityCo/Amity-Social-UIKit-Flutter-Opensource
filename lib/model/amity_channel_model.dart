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
        channels!.add(Channels.fromJson(v));
      });
    }
    if (json['channelUsers'] != null) {
      channelUsers = <ChannelUsers>[];
      json['channelUsers'].forEach((v) {
        channelUsers!.add(ChannelUsers.fromJson(v));
      });
    }
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(Users.fromJson(v));
      });
    }
    if (json['files'] != null) {
      files = <Files>[];
      json['files'].forEach((v) {
        files!.add(Files.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (channels != null) {
      data['channels'] = channels!.map((v) => v.toJson()).toList();
    }
    if (channelUsers != null) {
      data['channelUsers'] = channelUsers!.map((v) => v.toJson()).toList();
    }
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    if (files != null) {
      data['files'] = files!.map((v) => v.toJson()).toList();
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
    metadata =
        json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null;
    type = json['type'];
    if (json['tags'] != null) {
      List<String> tags = [];
      json['tags'].forEach((v) {
        tags.add(v);
      });
      tags = tags;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['channelId'] = channelId;
    data['isDistinct'] = isDistinct;
    if (metadata != null) {
      data['metadata'] = metadata!.toJson();
    }
    data['type'] = type;
    data['tags'] = tags;
    data['isMuted'] = isMuted;
    data['isRateLimited'] = isRateLimited;
    data['muteTimeout'] = muteTimeout;
    data['rateLimit'] = rateLimit;
    data['rateLimitWindow'] = rateLimitWindow;
    data['rateLimitTimeout'] = rateLimitTimeout;
    data['displayName'] = displayName;
    data['messageAutoDeleteEnabled'] = messageAutoDeleteEnabled;
    data['autoDeleteMessageByFlagLimit'] = autoDeleteMessageByFlagLimit;
    data['memberCount'] = memberCount;
    data['messageCount'] = messageCount;
    data['lastActivity'] = lastActivity;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['avatarFileId'] = avatarFileId;
    data['isDeleted'] = isDeleted;
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

  Metadata.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['channelId'] = channelId;
    data['membership'] = membership;
    data['isBanned'] = isBanned;
    data['lastActivity'] = lastActivity;
    data['roles'] = roles;
    data['permissions'] = permissions;
    data['readToSegment'] = readToSegment;
    data['lastMentionedSegment'] = lastMentionedSegment;
    data['isMuted'] = isMuted;
    data['muteTimeout'] = muteTimeout;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
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
        ? Metadata.fromJson(json['metadata'])
        : null;
    isGlobalBan = json['isGlobalBan'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['path'] =  path;
    data['userId'] =  userId;
    data['roles'] =  roles;
    data['permissions'] =  permissions;
    data['displayName'] =  displayName;
    data['description'] =  description;
    data['avatarFileId'] =  avatarFileId;
    data['avatarCustomUrl'] =  avatarCustomUrl;
    data['flagCount'] =  flagCount;

    if ( metadata != null) {
      data['metadata'] =  metadata!.toJson();
    }
    data['isGlobalBan'] =  isGlobalBan;
    data['createdAt'] =  createdAt;
    data['updatedAt'] =  updatedAt;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fileId'] =  fileId;
    data['fileUrl'] =  fileUrl;
    data['type'] =  type;
    data['createdAt'] =  createdAt;
    data['updatedAt'] =  updatedAt;
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
        ? Metadata.fromJson(json['metadata'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] =  name;
    data['extension'] =  extension;
    data['size'] =  size;
    data['mimeType'] =  mimeType;
    if ( metadata != null) {
      data['metadata'] =  metadata!.toJson();
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
        json['exif'] != null ? FileMetadata.fromJson(json['exif']) : null;
    gps = json['gps'] != null ? FileMetadata.fromJson(json['gps']) : null;
    height = json['height'];
    width = json['width'];
    isFull = json['isFull'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if ( exif != null) {
      data['exif'] =  exif!.toJson();
    }
    if ( gps != null) {
      data['gps'] =  gps!.toJson();
    }
    data['height'] =  height;
    data['width'] =  width;
    data['isFull'] =  isFull;
    return data;
  }
}
