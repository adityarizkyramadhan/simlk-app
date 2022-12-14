import 'package:get/get.dart';
import 'package:simlk_app/src/modules/reservation/controller/supervisor_new_reservation_controller.dart';

class SupervisorNewReservationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SupervisorNewReservationController());
  }
}
