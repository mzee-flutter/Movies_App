import 'package:movies/data/api_status.dart';

class ApiResponses<T> {
  Status? status;
  T? data;
  String? message;

  ApiResponses(
    this.status,
    this.data,
    this.message,
  );

  /// ApiResponses.loading()=> this is special constructor
  ///the part after the : is called initializer list
  ///the below line says that as soon as the loading constructor is initialize set the status value is Status.LOADING.
  ApiResponses.loading()
      : status = Status.LOADING,
        data = null,
        message = null;

  ApiResponses.complete(data) : status = Status.COMPLETED;

  ApiResponses.error(message)
      : status = Status.ERROR,
        data = null;
  @override
  String toString() {
    return 'status: $status \n Message: $message \n Data:$data';
  }
}
