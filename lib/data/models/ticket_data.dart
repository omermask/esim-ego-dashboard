class TicketUser {
  final String id;
  final String name;
  final String phone;
  TicketUser({required this.id, required this.name, required this.phone});
  factory TicketUser.fromJson(Map<String, dynamic> json) => TicketUser(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    phone: json['phone'] ?? '',
  );
}

class TicketAssignee {
  final String id;
  final String name;
  TicketAssignee({required this.id, required this.name});
  factory TicketAssignee.fromJson(Map<String, dynamic> json) => TicketAssignee(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
  );
}

class AdminTicket {
  final String id;
  final TicketUser? user;
  final String subject;
  final String status;
  final String priority;
  final int messageCount;
  final TicketAssignee? assignedTo;
  final String? createdAt;
  final String? updatedAt;

  AdminTicket({
    required this.id, this.user, required this.subject,
    this.status = 'open', this.priority = 'medium', this.messageCount = 0,
    this.assignedTo, this.createdAt, this.updatedAt,
  });

  factory AdminTicket.fromJson(Map<String, dynamic> json) => AdminTicket(
    id: json['id'] ?? '',
    user: json['user'] != null ? TicketUser.fromJson(json['user']) : null,
    subject: json['subject'] ?? '',
    status: json['status'] ?? 'open',
    priority: json['priority'] ?? 'medium',
    messageCount: json['message_count'] ?? 0,
    assignedTo: json['assigned_to'] != null ? TicketAssignee.fromJson(json['assigned_to']) : null,
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );
}

class TicketMessage {
  final String id;
  final String message;
  final String sender;
  final String senderName;
  final String? ticketId;
  final String? createdAt;
  TicketMessage({
    required this.id, required this.message, this.sender = '', this.senderName = '',
    this.ticketId, this.createdAt,
  });
  factory TicketMessage.fromJson(Map<String, dynamic> json) => TicketMessage(
    id: json['id'] ?? '',
    message: json['message'] ?? '',
    sender: json['sender'] ?? '',
    senderName: json['sender_name'] ?? '',
    ticketId: json['ticket_id']?.toString(),
    createdAt: json['created_at'],
  );
}

class TicketDetail {
  final String id;
  final TicketUser? user;
  final String subject;
  final String status;
  final String priority;
  final TicketAssignee? assignedTo;
  final List<TicketMessage> messages;
  final String? createdAt;
  final String? updatedAt;
  final String? closedAt;

  TicketDetail({
    required this.id, this.user, required this.subject,
    this.status = 'open', this.priority = 'medium', this.assignedTo,
    this.messages = const [], this.createdAt, this.updatedAt, this.closedAt,
  });

  factory TicketDetail.fromJson(Map<String, dynamic> json) => TicketDetail(
    id: json['id'] ?? '',
    user: json['user'] != null ? TicketUser.fromJson(json['user']) : null,
    subject: json['subject'] ?? '',
    status: json['status'] ?? 'open',
    priority: json['priority'] ?? 'medium',
    assignedTo: json['assigned_to'] != null ? TicketAssignee.fromJson(json['assigned_to']) : null,
    messages: (json['messages'] as List?)?.map((e) => TicketMessage.fromJson(e)).toList() ?? [],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
    closedAt: json['closed_at'],
  );
}
