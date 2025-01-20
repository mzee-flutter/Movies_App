abstract class BaseApiServices {
  Future<dynamic> getGetApiRequest(String url);
  Future<dynamic> getPostApiRequest(String url, var data);
}
