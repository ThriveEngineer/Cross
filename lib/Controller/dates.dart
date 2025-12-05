// Get current month as integer (1-12)
int month = DateTime.now().month;
String monthNumber = month.toString();

// Get month name
final monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];

final monthNamesShort = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String monthName = monthNames[DateTime.now().month - 1];
String monthNameShort = monthNamesShort[DateTime.now().month - 1];