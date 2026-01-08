import 'package:complaints/features/complaints/data/repositories/complaint_repository.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_details_event.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_details_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ComplaintDetailsBloc extends Bloc<ComplaintDetailsEvent, ComplaintDetailsState> {
  final ComplaintRepository _repository;

  ComplaintDetailsBloc([ComplaintRepository? repository])
      : _repository = repository ?? ComplaintRepository(),
        super(ComplaintDetailsInitial()) {
    on<FetchComplaintDetails>(_onFetchComplaintDetails);
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
}