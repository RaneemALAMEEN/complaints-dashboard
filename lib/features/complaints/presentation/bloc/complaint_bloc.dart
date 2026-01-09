import 'package:bloc/bloc.dart';
import 'package:complaints/features/complaints/domain/entities/complaint.dart';
import 'package:complaints/core/services/permissions_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'complaint_event.dart';
import 'complaint_state.dart';

class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  final Dio _dio = Dio();
  String? _pendingToastMessage;
  bool _pendingToastIsError = false;

  ComplaintBloc() : super(ComplaintInitial()) {
    on<FetchAllComplaints>(_onFetchAllComplaints);
    on<DeleteComplaint>(_onDeleteComplaint);
    on<FetchComplaintStats>(_onFetchComplaintStats);
    on<FetchDashboardData>(_onFetchDashboardData);
    on<UpdateComplaintStatus>(_onUpdateComplaintStatus);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<String> _getComplaintsEndpoint() async {
    final user = await PermissionsService.getCurrentUser();
    if (user != null && PermissionsService.isEmployee(user)) {
      return '/api/complaint/employee-complaints';
    }
    return '/api/complaint/all';
  }

  Future<void> _onFetchAllComplaints(
    FetchAllComplaints event,
    Emitter<ComplaintState> emit,
  ) async {
    print('=== FetchAllComplaints called with page: ${event.page} ===');
    emit(ComplaintLoading());
    try {
      final token = await _getToken();
      if (token == null) {
        print('خطأ: التوكن غير موجود');
        emit(const ComplaintFailure('Token not found'));
        return;
      }

      final endpoint = await _getComplaintsEndpoint();
      print('Using endpoint: $endpoint');
      final response = await _dio.get(
        'http://localhost:4002$endpoint',
        queryParameters: {'page': event.page},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Handle different response structure for employee endpoint
        final complaintsData = data['complaints'] ?? data;
        final complaints = (complaintsData['data'] as List)
            .map((json) => Complaint.fromJson(json))
            .toList();
        final pagination = Pagination.fromJson(complaintsData['pagination']);
        final toast = _pendingToastMessage;
        final toastIsError = _pendingToastIsError;
        _pendingToastMessage = null;
        _pendingToastIsError = false;

        emit(ComplaintsLoaded(
          complaints,
          pagination,
          toastMessage: toast,
          isError: toastIsError,
        ));
      print('=== ComplaintsLoaded state emitted with ${complaints.length} complaints ===');
      } else {
        print('خطأ في جلب الشكاوى: Status ${response.statusCode}');
        emit(const ComplaintFailure('Failed to load complaints'));
      }
    } catch (e) {
      print('خطأ في جلب الشكاوى: $e');
      emit(ComplaintFailure(e.toString()));
    }
  }

  Future<void> _onDeleteComplaint(
    DeleteComplaint event,
    Emitter<ComplaintState> emit,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        _pendingToastMessage = 'لا يمكن الحذف: التوكن غير موجود';
        _pendingToastIsError = true;
        add(FetchAllComplaints(event.page));
        return;
      }

      final url = 'http://localhost:4002/api/complaint/admin/${event.complaintId}';
      print('=== DELETE COMPLAINT ===');
      print('Request: DELETE $url');

      final response = await _dio.delete(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          },
        ),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('========================');

      final success = response.statusCode == 200 && (response.data?['success'] == true);
      if (success) {
        _pendingToastMessage = 'تم حذف الشكوى بنجاح';
        _pendingToastIsError = false;
        add(FetchAllComplaints(event.page));
      } else {
        _pendingToastMessage = 'فشل حذف الشكوى';
        _pendingToastIsError = true;
        add(FetchAllComplaints(event.page));
      }
    } on DioException catch (e) {
      print('=== DELETE COMPLAINT ERROR (DioException) ===');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Message: ${e.message}');
      print('============================================');

      _pendingToastMessage = e.response?.statusCode == 404
          ? 'الشكوى غير موجودة'
          : 'حدث خطأ أثناء حذف الشكوى';
      _pendingToastIsError = true;
      add(FetchAllComplaints(event.page));
    } catch (e) {
      _pendingToastMessage = 'حدث خطأ أثناء حذف الشكوى';
      _pendingToastIsError = true;
      add(FetchAllComplaints(event.page));
    }
  }

  Future<void> _onFetchComplaintStats(
    FetchComplaintStats event,
    Emitter<ComplaintState> emit,
  ) async {
    emit(ComplaintLoading());
    try {
      final token = await _getToken();
      if (token == null) {
        print('خطأ: التوكن غير موجود');
        emit(const ComplaintFailure('Token not found'));
        return;
      }

      // Fetch all complaints by iterating through pages
      List<Complaint> allComplaints = [];
      int page = 1;
      bool hasMore = true;
      final endpoint = await _getComplaintsEndpoint();

      while (hasMore) {
        final response = await _dio.get(
          'http://localhost:4002$endpoint',
          queryParameters: {'page': page},
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'accept': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          // Handle different response structure for employee endpoint
          final complaintsData = data['complaints'] ?? data;
          final complaints = (complaintsData['data'] as List)
              .map((json) => Complaint.fromJson(json))
              .toList();
          allComplaints.addAll(complaints);

          final pagination = Pagination.fromJson(complaintsData['pagination']);
          if (page >= pagination.totalPages) {
            hasMore = false;
          } else {
            page++;
          }
        } else {
          print('خطأ في جلب الشكاوى للإحصائيات: Status ${response.statusCode}');
          emit(const ComplaintFailure('Failed to load complaints for stats'));
          return;
        }
      }

      // Calculate stats
      final newComplaints = allComplaints.where((c) => c.status == ComplaintStatus.newOne).length;
      final inProgressComplaints = allComplaints.where((c) => c.status == ComplaintStatus.inProgress).length;
      final resolvedComplaints = allComplaints.where((c) => c.status == ComplaintStatus.resolved).length;
      final totalComplaints = allComplaints.length;
      
      // Print stats for debugging
      print('=== إحصائيات الشكاوى ===');
      print('مجموع الشكاوى: $totalComplaints');
      print('الشكاوى الجديدة: $newComplaints');
      print('الشكاوى قيد المعالجة: $inProgressComplaints');
      print('الشكاوى المنجزة: $resolvedComplaints');
      print('========================================');
      
      // Print complaint details
      print('=== تفاصيل الشكاوى ===');
      for (int i = 0; i < allComplaints.length; i++) {
        final complaint = allComplaints[i];
        print('الشكوى ${i + 1}: ID=${complaint.id}, الرقم=${complaint.referenceNumber}, الحالة=${complaint.status}');
      }
      print('========================================');

      final stats = ComplaintStats(
        newComplaints: newComplaints,
        totalComplaints: totalComplaints,
        inProgressComplaints: inProgressComplaints,
        resolvedComplaints: resolvedComplaints,
      );

      emit(ComplaintStatsLoaded(stats));
    } catch (e) {
      print('خطأ في جلب إحصائيات الشكاوى: $e');
      emit(ComplaintFailure(e.toString()));
    }
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<ComplaintState> emit,
  ) async {
    emit(ComplaintLoading());
    try {
      final token = await _getToken();
      if (token == null) {
        print('خطأ: التوكن غير موجود');
        emit(const ComplaintFailure('Token not found'));
        return;
      }

      // Fetch first page complaints for display
      final endpoint = await _getComplaintsEndpoint();
      final complaintsResponse = await _dio.get(
        'http://localhost:4002$endpoint',
        queryParameters: {'page': 1},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          },
        ),
      );

      if (complaintsResponse.statusCode != 200) {
        print('خطأ في جلب الشكاوى: Status ${complaintsResponse.statusCode}');
        emit(const ComplaintFailure('Failed to load complaints'));
        return;
      }

      final complaintsData = complaintsResponse.data;
      // Handle different response structure for employee endpoint
      final complaintsResponseData = complaintsData['complaints'] ?? complaintsData;
      final complaints = (complaintsResponseData['data'] as List)
          .map((json) => Complaint.fromJson(json))
          .toList();
      final pagination = Pagination.fromJson(complaintsResponseData['pagination']);

      // Fetch all complaints for stats calculation
      List<Complaint> allComplaints = [];
      int page = 1;
      bool hasMore = true;

      while (hasMore) {
        final response = await _dio.get(
          'http://localhost:4002$endpoint',
          queryParameters: {'page': page},
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'accept': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          // Handle different response structure for employee endpoint
          final pageData = data['complaints'] ?? data;
          final pageComplaints = (pageData['data'] as List)
              .map((json) => Complaint.fromJson(json))
              .toList();
          allComplaints.addAll(pageComplaints);

          final pagePagination = Pagination.fromJson(pageData['pagination']);
          if (page >= pagePagination.totalPages) {
            hasMore = false;
          } else {
            page++;
          }
        } else {
          print('خطأ في جلب الشكاوى للإحصائيات: Status ${response.statusCode}');
          // Continue with available data
          break;
        }
      }

      // Calculate stats
      final newComplaints = allComplaints.where((c) => c.status == ComplaintStatus.newOne).length;
      final inProgressComplaints = allComplaints.where((c) => c.status == ComplaintStatus.inProgress).length;
      final resolvedComplaints = allComplaints.where((c) => c.status == ComplaintStatus.resolved).length;
      final totalComplaints = allComplaints.length;
      
      // Print stats for debugging
      print('=== إحصائيات الشكاوى ===');
      print('مجموع الشكاوى: $totalComplaints');
      print('الشكاوى الجديدة: $newComplaints');
      print('الشكاوى قيد المعالجة: $inProgressComplaints');
      print('الشكاوى المنجزة: $resolvedComplaints');
      print('========================================');
      
      // Print complaint details
      print('=== تفاصيل الشكاوى ===');
      for (int i = 0; i < allComplaints.length; i++) {
        final complaint = allComplaints[i];
        print('الشكوى ${i + 1}: ID=${complaint.id}, الرقم=${complaint.referenceNumber}, الحالة=${complaint.status}');
      }
      print('========================================');

      final stats = ComplaintStats(
        newComplaints: newComplaints,
        totalComplaints: totalComplaints,
        inProgressComplaints: inProgressComplaints,
        resolvedComplaints: resolvedComplaints,
      );

      emit(DashboardDataLoaded(complaints, pagination, stats));
    } catch (e) {
      print('خطأ في جلب بيانات الـ dashboard: $e');
      emit(ComplaintFailure(e.toString()));
    }
  }

  Future<void> _onUpdateComplaintStatus(
    UpdateComplaintStatus event,
    Emitter<ComplaintState> emit,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        emit(const ComplaintFailure('Token not found'));
        return;
      }

      // Get user role to determine endpoint
      final user = await PermissionsService.getCurrentUser();
      final isEmployee = user != null && PermissionsService.isEmployee(user);
      
      String endpoint;
      Map<String, dynamic> requestData;
      
      if (isEmployee) {
        // Employee endpoint with notes
        endpoint = 'http://localhost:4002/api/complaint/updateComplaintByEmployee/${event.complaintId}';
        requestData = {
          'notes': event.notes ?? '',
          'status': event.status,
        };
        print('Employee: Updating complaint ${event.complaintId} with status: ${event.status}');
      } else {
        // Admin endpoint (existing)
        endpoint = 'http://localhost:4002/api/complaint/${event.complaintId}/status';
        requestData = {'status': event.status};
        print('Admin: Updating complaint ${event.complaintId} with status: ${event.status}');
      }

      final response = await _dio.put(
        endpoint,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Complaint updated successfully');
        print('Response data: ${response.data}');
        // Refresh the complaints list
        print('Adding FetchAllComplaints event...');
        add(const FetchAllComplaints(1));
      } else {
        print('Failed to update status: ${response.statusCode}');
        print('Response data: ${response.data}');
        emit(ComplaintFailure('Failed to update status: ${response.statusCode}'));
      }
    } catch (e) {
      emit(ComplaintFailure('Error updating status: $e'));
    }
  }
}
