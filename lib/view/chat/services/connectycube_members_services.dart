// import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:gaya/utils/logger.dart';

class ConnectyCubeMembersServices {
  CubeUser? currentUser;

  ConnectyCubeMembersServices({required this.currentUser});

  int membersLimit = 15;
  int _allUsersCurrentPage = 1;
  bool _hasMoreAllMembers = true;
  int _searchedUsersCurrentPage = 1;
  bool _hasMoreSearchedMembers = true;
  int _groupAllUsersCurrentPage = 1;
  bool _hasMoreGroupAllMembers = true;
  String searchQuery = '';
  void resetAllUsers() {
    _allUsersCurrentPage = 1;
    _hasMoreAllMembers = true;
  }

  void resetSearchedUsers() {
    _searchedUsersCurrentPage = 1;
    _hasMoreSearchedMembers = true;
    searchQuery = '';
  }

  void resetGroupAllUsers() {
    _groupAllUsersCurrentPage = 1;
    _hasMoreGroupAllMembers = true;
  }

// #1: Move the request posts into it's own function
  Future _requestAllMembers() async {
    List newMembers = [];
    Map<String, dynamic> params = {"page": _allUsersCurrentPage, "per_page": membersLimit};

    // #5: If we have a document start the query after it
    if (_allUsersCurrentPage != 1) {
      params = {"page": _allUsersCurrentPage, "per_page": membersLimit};
    }

    if (_hasMoreAllMembers == false) {
      MyLoggerServices.to.print("no more members from memberServices");
      return [];
    }
    PagedResult<CubeUser>? cubeUsers = await getAllPaginatedUsers(params);

    try {
      MyLoggerServices.to.print("paginatedUsers data length: ${cubeUsers?.items.length}");

      if (cubeUsers != null) {
        newMembers.addAll(cubeUsers.items.map<CubeUser>((user) => user).toList());
      } else {
        _hasMoreAllMembers = false;
      }
    } catch (_) {}
    if (cubeUsers != null) {
      _hasMoreAllMembers = (cubeUsers.totalEntries!.toInt() < membersLimit)
          ? false
          : ((_allUsersCurrentPage * membersLimit) < cubeUsers.totalEntries!.toInt())
              ? true
              : false;
      // _allUsersCurrentPage = _allUsersCurrentPage + 1;
      _allUsersCurrentPage = (cubeUsers.totalEntries!.toInt() < membersLimit)
          ? _allUsersCurrentPage
          : ((_allUsersCurrentPage * membersLimit) < cubeUsers.totalEntries!.toInt())
              ? _allUsersCurrentPage + 1
              : _allUsersCurrentPage;
    } else {
      _hasMoreAllMembers = false;
    }
    return newMembers;
  }

  // #1: Move the request posts into it's own function
  Future _requestSearchedMembers({String? query}) async {
    if (query != null && query != searchQuery) {
      searchQuery = query;
      _searchedUsersCurrentPage = 1;
      _hasMoreSearchedMembers = true;
    }
    List newMembers = [];
    Map<String, dynamic> params = {"page": _searchedUsersCurrentPage, "per_page": membersLimit};

    // #5: If we have a document start the query after it
    if (_searchedUsersCurrentPage != 1) {
      params = {"page": _searchedUsersCurrentPage, "per_page": membersLimit};
    }

    if (_hasMoreSearchedMembers == false) {
      MyLoggerServices.to.print("no more members from memberServices");
      return [];
    }
    PagedResult<CubeUser>? cubeUsers = await getPaginatedUsersByFullName(query ?? '', params);

    try {
      MyLoggerServices.to.print("paginatedUsers data length: ${cubeUsers?.items.length}");

      if (cubeUsers != null) {
        newMembers.addAll(cubeUsers.items.map<CubeUser>((user) => user).toList());
      } else {
        _hasMoreSearchedMembers = false;
      }
    } catch (_) {
      MyLoggerServices.to.print("error occured in catch(_) block: $_");
    }
    if (cubeUsers != null && cubeUsers.items.isNotEmpty == true) {
      _hasMoreSearchedMembers = (cubeUsers.totalEntries!.toInt() < membersLimit)
          ? false
          : ((_searchedUsersCurrentPage * membersLimit) < cubeUsers.totalEntries!.toInt())
              ? true
              : false;
      _searchedUsersCurrentPage = (cubeUsers.totalEntries!.toInt() < membersLimit)
          ? _searchedUsersCurrentPage
          : ((_searchedUsersCurrentPage * membersLimit) < cubeUsers.totalEntries!.toInt())
              ? _searchedUsersCurrentPage + 1
              : _searchedUsersCurrentPage;
    } else {
      _hasMoreSearchedMembers = false;
    }
    return newMembers;
  }

// #1: Move the request posts into it's own function
  Future _requestGroupAllMembers({String? groupId}) async {
    if (groupId == null || groupId == '') return [];
    List newMembers = [];
    Map<String, dynamic> params = {"page": _groupAllUsersCurrentPage, "per_page": membersLimit};

    // #5: If we have a document start the query after it
    if (_groupAllUsersCurrentPage != 1) {
      params = {"page": _groupAllUsersCurrentPage, "per_page": membersLimit};
    }

    if (_hasMoreGroupAllMembers == false) {
      MyLoggerServices.to.print("no more members from memberServices");
      return [];
    }
    PagedResult<CubeUser>? cubeUsers = await getDialogOccupants(groupId);

    try {
      MyLoggerServices.to.print("paginatedUsers data length: ${cubeUsers?.items.length}");

      if (cubeUsers != null) {
        newMembers.addAll(cubeUsers.items.map<CubeUser>((user) => user).toList());
      } else {
        _hasMoreGroupAllMembers = false;
      }
    } catch (_) {}
    if (cubeUsers != null) {
      _hasMoreGroupAllMembers = (cubeUsers.totalEntries!.toInt() < membersLimit)
          ? false
          : ((_groupAllUsersCurrentPage * membersLimit) < cubeUsers.totalEntries!.toInt())
              ? true
              : false;
      _groupAllUsersCurrentPage = (cubeUsers.totalEntries!.toInt() < membersLimit)
          ? _groupAllUsersCurrentPage
          : ((_groupAllUsersCurrentPage * membersLimit) < cubeUsers.totalEntries!.toInt())
              ? _groupAllUsersCurrentPage + 1
              : _groupAllUsersCurrentPage;
    } else {
      _hasMoreGroupAllMembers = false;
    }
    return newMembers;
  }

  Future requestAllUsersMoreData() async => await _requestAllMembers();
  Future requestSearchedUsersMoreData({String? query}) async => await _requestSearchedMembers(query: query);
  Future requestGroupAllUsersMoreData({String? groupId}) async => await _requestGroupAllMembers(groupId: groupId);
}
