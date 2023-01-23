import 'dart:convert';
import 'package:http/http.dart' as http;

class URLS {
  static const String BASE_URL = 'http://192.168.110.62/api';
  static const String BASE_HTTP_URL = 'http://192.168.110.62/';
  // static const String BASE_URL = 'https://hemailer.com/api';
  // static const String BASE_HTTP_URL = 'https://hemailer.com/';
}

class ApiService {
  static Future<dynamic> login(body) async {
    final response = await http.post('${URLS.BASE_URL}/login', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> resetPassword(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/reset_password', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> updateToken(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/update_token', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> uploadProfileImage(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/upload_profile_image', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<List<dynamic>> getUsers(body) async {
    final response = await http.post('${URLS.BASE_URL}/get_users', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<List<dynamic>> getUsersAdmin(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/get_users_admin', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> getOneUser(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/get_one_user', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> deleteUser(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/delete_user', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> saveUser(body) async {
    final response = await http.post('${URLS.BASE_URL}/save_user', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> getStatistics(body) async {
    final response = await http.post('${URLS.BASE_URL}/stastics', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  ////////////////// **** expenses ***** ////////////////
  static Future<dynamic> getExpenses(body) async {
    final response = await http.post('${URLS.BASE_URL}/expenses', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> saveExpense(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/save_expense', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> deleteExpense(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/delete_expense', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  ////////////////// **** payments ***** ////////////////
  static Future<dynamic> getPayments(body) async {
    final response = await http.post('${URLS.BASE_URL}/payments', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> savePayment(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/save_payment', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> deletePayment(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/delete_payment', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  ////////////////// **** extra info ***** ////////////////
  static Future<dynamic> getExtraInfos(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/extra_infos', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> saveExtraInfo(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/save_extra_info', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> deleteExtraInfo(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/delete_extra_info', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  ////////////////// **** notes ***** ////////////////
  static Future<dynamic> getNotes(body) async {
    final response = await http.post('${URLS.BASE_URL}/notes', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> saveNote(body) async {
    final response = await http.post('${URLS.BASE_URL}/save_note', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> deleteNote(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/delete_note', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  ////////////////// **** contacts ***** ////////////////
  static Future<dynamic> getContacts(body) async {
    final response = await http.post('${URLS.BASE_URL}/contacts', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> getSearchContacts(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/search_contacts', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> saveContact(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/save_contact', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> updateContact(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/update_contact', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> getOneContact(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/get_one_contact', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> updateNotesContact(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/update_notes_contact', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> deleteContact(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/delete_contact', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // send email template
  static Future<dynamic> getTemplates(body) async {
    final response = await http.post('${URLS.BASE_URL}/templates', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> sendEmailTmp(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/send_email_tmp', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // send contract template
  static Future<dynamic> getContractTmp(body) async {
    final response = await http.post('${URLS.BASE_URL}/contracts', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> sendContractTmp(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/send_contract_tmp', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // send sales funnel template
  static Future<dynamic> getSalesFunnelTmp(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/sales_funnel', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> sendSalesFunnelTmp(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/send_sales_funnel_tmp', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // send contract template
  static Future<dynamic> getInvoiceTmp(body) async {
    final response = await http.post('${URLS.BASE_URL}/invoices', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> sendInvoiceTmp(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/send_invoice_tmp', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // contact's subscriber
  static Future<List<dynamic>> getContactSubs(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/contact_subs', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> deleteContactSub(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/delete_contact_sub', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // user's subscriber
  static Future<List<dynamic>> getSubscribers(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/subscribers', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // user's reminders
  static Future<List<dynamic>> getReminders(body) async {
    final response = await http.post('${URLS.BASE_URL}/reminders', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> deleteReminder(body) async {
    final response = await http
        .post('${URLS.BASE_URL}/cancel_schedule_reminder', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<List<dynamic>> getImportants(body) async {
    final response = await http.post('${URLS.BASE_URL}/importants', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> deleteImportant(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/cancel_note_important', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // user's email history
  static Future<List<dynamic>> getEmailHistory(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/email_history', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> deleteEmailHistory(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/delete_email_history', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // user's contracts history
  static Future<List<dynamic>> getContractHistory(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/contract_history', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> deleteContractHistory(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/delete_contract_history', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // user's sales funnel history
  static Future<List<dynamic>> getSalesFunnelHistory(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/sales_funnel_history', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> deleteSalesFunnelHistory(body) async {
    final response = await http
        .post('${URLS.BASE_URL}/delete_sales_funnel_history', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // Online Chat
  static Future<dynamic> deleteOnlineClient(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/delete_online_client', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> saveOnlineClient(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/save_online_client', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // Online Chat
  static Future<dynamic> deleteOnlineChatHistory(body) async {
    final response = await http
        .post('${URLS.BASE_URL}/delete_onlinechat_history', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> getOnlineChatHistory(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/get_onlinechat_history', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> getOnlineChatNewMsg(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/get_onlinechat_new_msg', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> readOnlineChatMsg(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/update_onlinechat_read', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // chat page
  static Future<List<dynamic>> getChatUsers(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/get_chat_users', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> getChatHistory(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/get_chat_history', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> readChatMsg(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/update_chat_read', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> deleteChatHistory(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/delete_chat_history', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> getChatNewMsg(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/get_chat_new_msg', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> uploadChatFile(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/upload_chat_file', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // Recurring page
  static Future<List<dynamic>> getRecurring(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/get_recurring', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> getContactsAllAndOne(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/get_contacts_all_one', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> deleteRecurring(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/delete_recurring', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> sendNotification(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/send_notification', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> ipTrack(body) async {
    final response = await http.post('${URLS.BASE_URL}/ip_track', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<List<dynamic>> getIps(body) async {
    final response = await http.post('${URLS.BASE_URL}/get_ips', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> activeStatus(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/active_status', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> getAgents(body) async {
    final response = await http.post(
      '${URLS.BASE_URL}/get_agents',
      body: body,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<List<dynamic>> getSchedule(body) async {
    final response = await http.post(
      '${URLS.BASE_URL}/get_schedule',
      body: body,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> updateSchedule(body) async {
    final response =
        await http.post('${URLS.BASE_URL}/update_schedule', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<List<dynamic>> getRespond(body) async {
    final response = await http.post(
      '${URLS.BASE_URL}/get_respond',
      body: body,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }
  
}
