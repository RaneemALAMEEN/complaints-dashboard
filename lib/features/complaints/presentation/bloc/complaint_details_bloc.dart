import 'package:complaints/features/complaints/data/repositories/complaint_repository.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_details_event.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_details_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:complaints/core/services/permissions_service.dart';

class ComplaintDetailsBloc extends Bloc<ComplaintDetailsEvent, ComplaintDetailsState> {
  final ComplaintRepository _repository;
  final Dio _dio = Dio();

  ComplaintDetailsBloc([ComplaintRepository? repository])
      : _repository = repository ?? ComplaintRepository(),
        super(ComplaintDetailsInitial()) {
    on<FetchComplaintDetails>(_onFetchComplaintDetails);
    on<UpdateComplaintDetailsStatus>(_onUpdateComplaintDetailsStatus);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _onFetchComplaintDetails(
    FetchComplaintDetails event,
    Emitter<ComplaintDetailsState> emit,
  ) async {
    print('Fetching complaint details for ID: ${event.complaintId}');
    emit(ComplaintDetailsLoading());
    try {
      final complaint = await _repository.getComplaintDetails(event.complaintId);
      print('Successfully fetched complaint: ${complaint.referenceNumber}');
      emit(ComplaintDetailsLoaded(complaint));
    } catch (e) {
      print('Error fetching complaint details: $e');
      emit(ComplaintDetailsFailure(e.toString(), event.complaintId));
    }
  }

  Future<void> _onUpdateComplaintDetailsStatus(
    UpdateComplaintDetailsStatus event,
    Emitter<ComplaintDetailsState> emit,
  ) async {
    emit(ComplaintDetailsLoading());
    try {
      final token = await _getToken();
      if (token == null) {
        emit(ComplaintDetailsFailure('Token not found', event.complaintId));
        return;
      }

      final user = await PermissionsService.getCurrentUser();
      final isEmployee = user != null && PermissionsService.isEmployee(user);

      String endpoint;
      Map<String, dynamic> requestData;

      if (isEmployee) {
        endpoint = 'http://localhost:4002/api/complaint/updateComplaintByEmployee/${event.complaintId}';
        requestData = {
          'notes': event.notes ?? '',
          'status': event.status,
        };
      } else {
        endpoint = 'http://localhost:4002/api/complaint/${event.complaintId}/status';
        requestData = {'status': event.status};
      }

      final response = await _dio.put(
        endpoint,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        emit(ComplaintDetailsFailure('Failed to update status: ${response.statusCode}', event.complaintId));
        return;
      }

      final complaint = await _repository.getComplaintDetails(event.complaintId);
      emit(ComplaintDetailsLoaded(complaint));
    } catch (e) {
      emit(ComplaintDetailsFailure('Error updating status: $e', event.complaintId));
    }
  }
}