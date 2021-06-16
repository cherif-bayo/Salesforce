public class Converter{
    public Enum Locale{
        US,
        FR
    }

    public static String DateToLocaleDate(Date dateToConvert, Locale loc){
        if(loc == Locale.US){
            return dateToConvert.year() + '-' + dateToConvert.month() + '-' + dateToConvert.day();
        }else{
            return dateToConvert.day() + '/' + dateToConvert.month() + '/' + dateToConvert.year();
        }
    }
}