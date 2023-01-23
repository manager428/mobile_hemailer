class UserModel {
  String id;
  String userName;
  String userEmail;
  String userLevel;
  String userPhone;
  String parentID;
  String photoURL;

  String chatOn;
  String onlineChatOn;
  String optForm;
  String analyticOn;

  String salesFunnel;
  String contractSign;
  String invoiceOn;
  String emailChange;
  String selfDestruct;

  UserModel(
      this.id,
      this.userName,
      this.userEmail,
      this.userLevel,
      this.userPhone,
      this.parentID,
      this.photoURL,
      this.chatOn,
      this.onlineChatOn,
      this.optForm,
      this.salesFunnel,
      this.contractSign,
      this.invoiceOn,
      this.analyticOn,
      this.emailChange,
      this.selfDestruct);
}
