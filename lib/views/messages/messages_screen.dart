import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/message_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../widgets/common/empty_state_widget.dart';
import '../../models/message.dart';
import '../../models/message_thread.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    final isMobile = Responsive.isMobile(context);

    return Obx(() {
      if (controller.isLoading.value && controller.messageThreads.isEmpty) {
        return LoadingWidget(message: 'Loading messages...');
      }

      if (controller.errorMessage.value.isNotEmpty && controller.messageThreads.isEmpty) {
        return custom_error.CustomErrorWidget(
          message: controller.errorMessage.value,
          onRetry: controller.refresh,
        );
      }

      if (isMobile) {
        // Mobile: Show either thread list or conversation
        return controller.selectedUserId.value.isEmpty
            ? _buildThreadsList(context, controller)
            : _buildConversation(context, controller);
      }

      // Desktop/Tablet: Split view
      return Row(
        children: [
          // Thread List
          Container(
            width: 350,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColors.grey200, width: 1),
              ),
            ),
            child: _buildThreadsList(context, controller),
          ),

          // Conversation
          Expanded(
            child: controller.selectedUserId.value.isEmpty
                ? EmptyStateWidget(
                    message: 'Select a conversation',
                    icon: Icons.message_outlined,
                  )
                : _buildConversation(context, controller),
          ),
        ],
      );
    });
  }

  Widget _buildThreadsList(BuildContext context, MessageController controller) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.grey200, width: 1),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Conversations',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: controller.loadMessageThreads,
              ),
            ],
          ),
        ),

        // Thread List
        Expanded(
          child: Obx(() {
            if (controller.messageThreads.isEmpty) {
              return EmptyStateWidget(
                message: 'No messages yet',
                icon: Icons.inbox_outlined,
              );
            }

            return ListView.builder(
              itemCount: controller.messageThreads.length,
              itemBuilder: (context, index) {
                final thread = controller.messageThreads[index];
                return _buildThreadItem(context, thread, controller);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildThreadItem(
      BuildContext context, MessageThread thread, MessageController controller) {
    return Obx(() {
      final isSelected = controller.selectedUserId.value == thread.userId;

      return Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
          border: Border(
            bottom: BorderSide(color: AppColors.grey200, width: 1),
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              thread.userName.isNotEmpty ? thread.userName[0].toUpperCase() : 'U',
              style: TextStyle(color: Colors.white),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  thread.userName,
                  style: TextStyle(
                    fontWeight: thread.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (thread.unreadCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    thread.unreadCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                thread.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.grey600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                Formatters.formatRelativeTime(thread.lastMessageAt),
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
          onTap: () => controller.loadUserMessages(thread.userId),
        ),
      );
    });
  }

  Widget _buildConversation(BuildContext context, MessageController controller) {
    final isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        // Conversation Header
        Container(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.grey200, width: 1),
            ),
          ),
          child: Row(
            children: [
              if (isMobile)
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => controller.selectedUserId.value = '',
                ),
              Expanded(
                child: Obx(() {
                  final thread = controller.messageThreads.firstWhereOrNull(
                    (t) => t.userId == controller.selectedUserId.value,
                  );
                  return Text(
                    thread?.userName ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall,
                  );
                }),
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () => controller.loadUserMessages(
                  controller.selectedUserId.value,
                ),
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.currentThreadMessages.isEmpty) {
              return LoadingWidget();
            }

            if (controller.currentThreadMessages.isEmpty) {
              return EmptyStateWidget(
                message: 'No messages in this conversation',
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              reverse: false,
              itemCount: controller.currentThreadMessages.length,
              itemBuilder: (context, index) {
                final message = controller.currentThreadMessages[index];
                return _buildMessageBubble(message);
              },
            );
          }),
        ),

        // Reply Box
        _buildReplyBox(context, controller),
      ],
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isFromUser = message.isFromUser;

    return Align(
      alignment: isFromUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isFromUser
              ? AppColors.grey100
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFromUser
                ? AppColors.grey300
                : AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.body,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              Formatters.formatRelativeTime(message.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyBox(BuildContext context, MessageController controller) {
    final replyController = TextEditingController();

    return Container(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.grey200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: replyController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Type your reply...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 8),
          Obx(() => IconButton(
            icon: controller.isSendingMessage.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : Icon(Icons.send),
            color: AppColors.primary,
            onPressed: controller.isSendingMessage.value
                ? null
                : () {
                    final text = replyController.text.trim();
                    if (text.isEmpty) return;

                    controller.sendReply(
                      controller.selectedUserId.value,
                      text,
                    ).then((_) {
                      replyController.clear();
                    });
                  },
          )),
        ],
      ),
    );
  }
}
