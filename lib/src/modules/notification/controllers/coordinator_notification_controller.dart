import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:simlk_app/src/data/model/notification/notification.dart';
import 'package:simlk_app/src/modules/home/controller/coordinator_home_controller.dart';
import 'package:simlk_app/src/modules/home/controller/counselor_home_controller.dart';
import 'package:simlk_app/src/services/api/api_services.dart';
import 'package:simlk_app/src/services/base/base_list_controller.dart';
import 'package:simlk_app/src/services/errorhandler/error_handler.dart';
import 'package:simlk_app/src/utils/routes/page_name.dart';

class CoordinatorNotificationController
    extends BaseListController<Notification> {
  final RxInt badgeNumber = 0.obs;

  @override
  void loadNextPage() {
    // TODO: implement loadNextPage
  }

  @override
  void refreshPage() {
    getAllNotifications();
  }

  Future<void> goToDetail({
    required int id,
    required int status,
  }) async {
    if (status < 6) {
      Get.toNamed('/coordinator/reservation/$id');
    } else {
      Get.toNamed('${PageName.reservationHistorySupervisor}/$id');
    }
  }

  Future<void> getAllNotifications() async {
    loadingState();
    await client().then((value) {
      value.fetchAllNotifications().validateStatus().then((data) {
        final notifUnreadCount =
            data.data?.where((element) => element.isRead == 0).length;

        Get.find<CoordinatorHomeController>()
            .notificationCount(notifUnreadCount);

        dataList.clear();
        setFinishCallbacks(data.data?.reversed.toList() ?? []);
      }).handleError((onError) {
        debugPrint(onError.toString());
        finishLoadData(errorMessage: onError.toString());
      });
    });
  }

  Future<void> markReadNotificationById({required int id, int? status}) async {
    loadingState();
    await client().then((value) {
      value
          .markNotificationById(notificationId: id)
          .validateStatus()
          .then((data) {
        finishLoadData();
        getAllNotifications();
        goToDetail(id: id, status: status ?? 0);
      }).handleError((onError) {
        debugPrint(onError.toString());
        finishLoadData(errorMessage: onError.toString());
      });
    });
  }

  Future<void> markReadAllNotifications() async {
    loadingState();
    await client().then((value) {
      value.markAllNotifications().validateStatus().then((data) {
        finishLoadData();
        getAllNotifications();
      }).handleError((onError) {
        debugPrint(onError.toString());
        finishLoadData(errorMessage: onError.toString());
      });
    });
  }
}
