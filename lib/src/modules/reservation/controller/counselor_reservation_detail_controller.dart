import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:simlk_app/src/data/model/reservation/reservation_schedule.dart';
import 'package:simlk_app/src/modules/common/widgets/bottom_sheet/textfield_bottomsheet.dart';
import 'package:simlk_app/src/modules/common/widgets/bottom_sheet/upload_file_bottomsheet.dart';
import 'package:simlk_app/src/modules/common/widgets/simlk_report_dialog.dart';
import 'package:simlk_app/src/modules/common/widgets/simlk_snackbar.dart';
import 'package:simlk_app/src/modules/reservation/controller/counselor_reservation_controller.dart';
import 'package:simlk_app/src/services/api/api_services.dart';
import 'package:simlk_app/src/services/base/base_object_controller.dart';
import 'package:simlk_app/src/services/errorhandler/error_handler.dart';
import 'package:simlk_app/src/utils/helper/snackbar_state_enum.dart';

class CounselorReservationDetailController
    extends BaseObjectController<ReservationSchedule> {
  final counselingLocationController = TextEditingController();
  final counselingFinalReportController = TextEditingController();
  final RxString uploadedFilename = "".obs;

  @override
  void onInit() {
    id = Get.parameters['id'].toString();
    getReservationDetail(
        id: int.tryParse(Get.parameters['id'].toString()) ?? 0);
    super.onInit();
  }

  void showFinalReportDialog({required int id}) {
    Get.dialog(
      SIMLKReportDialog(
        title: 'Penulisan Laporan Akhir',
        description:
            'Pilih metode yang anda gunakan untuk menulis laporan akhir konseling',
        onTextPressed: () {
          Get.back();
          Get.bottomSheet(
            TextfieldBottomsheet(
              textInputController: counselingFinalReportController,
              label: 'Laporan Akhir Konseling',
              onSave: (report) async {
                await setReservationReport(
                  id: id,
                  report: counselingFinalReportController.text,
                );
                await setReservationStatus(id: id, status: 4);
                counselingFinalReportController.clear();
              },
            ),
          );
        },
        onFilePressed: () {
          Get.back();
          Get.bottomSheet(
            UploadFileBottomsheet(
              label: 'Laporan Akhir Konseling',
              onSave: (report) async {
                print(report.path);
                await setReservationReport(
                  id: id,
                  file: report,
                );
                await setReservationStatus(id: id, status: 4);
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> getReservationDetail({required int id}) async {
    loadingState();
    await client().then((value) {
      value
          .fetchMahasiswaReservationDetail(id: id)
          .validateStatus()
          .then((data) {
        counselingLocationController.text = data.data?.location ?? "";
        setFinishCallbacks(data.data);
      }).handleError((onError) {
        debugPrint(onError.toString());
        finishLoadData(errorMessage: onError.toString());
      });
    });
  }

  Future<void> setReservationStatus(
      {required int id, required int status}) async {
    loadingState();
    await client().then((value) {
      value
          .updateReservationStatus(
            status: status,
            reservationId: id,
            location: counselingLocationController.text,
          )
          .validateStatus()
          .then((data) {
        finishLoadData();
        Get.showSnackbar(SIMLKSnackbar(
          snackbarMessage:
              'Berhasil mengubah status reservasi: ${status == 2 ? 'TERJADWAL' : status == 3 ? 'PENANGANAN' : 'SELESAI'}',
          snackbarStateEnum: SnackbarStateEnum.POSITIVE,
        ));
        if (status < 4) {
          getReservationDetail(id: id);
        } else {
          Get.find<CounselorReservationController>().getOngoingReservations();
          goToHistoryDetail(id: id);
        }
      }).handleError((onError) {
        debugPrint(onError.toString());
        finishLoadData(errorMessage: onError.toString());
      });
    });
  }

  Future<void> setReservationReport(
      {required int id, String? report, File? file}) async {
    loadingState();
    await client().then((value) {
      value
          .updateMahasiswaReservationReport(
              id: id, report: report, fileReport: file)
          .validateStatus()
          .then((data) {
        mData?.report = counselingFinalReportController.text;
        mData?.reportFileUrl = uploadedFilename.value;
        finishLoadData();
      }).handleError((onError) {
        debugPrint(onError.toString());
        finishLoadData(errorMessage: onError.toString());
      });
    });
  }

  void goToHistoryDetail({required int id}) {
    Get.offNamed('/konselor/history/$id');
  }
}
