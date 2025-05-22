
import 'package:intl/intl.dart';

class HumanFormats {

  static String humanReadbleNumber( int number ){

    final formatterNumber = NumberFormat.decimalPattern('es').format(number);
    return formatterNumber;
  }

}