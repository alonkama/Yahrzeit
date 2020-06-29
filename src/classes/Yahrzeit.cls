global with sharing class Yahrzeit {
	
	// Warning: Can't call this method in a loop! Salesforce can't have 
	// multiple callouts interleaved with insert/update. All callouts
	// have to be done first, the values stored in memory, then update
	// all the objects.
	// See http://boards.developerforce.com/t5/Apex-Code-Development/Error-while-saving-external-web-service-response-to-salesforce/td-p/79560
	public static List<Deceased__c> updateYahrzeitForDeceased(List<Deceased__c> deceasedList) {
		// separated because the trigger needs to call the logic but not do the update.
        deceasedList = calculateHebrewDateAndFridayOfObservance(deceasedList);
        update deceasedList;
        return deceasedList;
	}
    
    private static List<Deceased__c> calculateHebrewDateAndFridayOfObservance(List<Deceased__c> deceasedList) {
		for (Deceased__c d : deceasedList) {
            
            // If Hebrew date is not filled in, fetch the values
            if (d.Month_Hebrew__c == null && d.Day_Hebrew__c == null &&
                d.Day_Gregorian__c != null && d.Month_Gregorian__c != null & d.Year_Gregorian__c != null) {
                    String[] hebrewDate = Yahrzeit.getHebrewDateFromGregorian(d.Day_Gregorian__c, d.Month_Gregorian__c, 
                                                                              d.Year_Gregorian__c, d.After_Sunset__c);
                    d.Year_Hebrew__c = hebrewDate[0];
                    d.Month_Hebrew__c = hebrewDate[1];
                    d.Day_Hebrew__c = hebrewDate[2];
            }
            
			Date dateForThisYear = getNextObservanceDate(d);
			d.Yahrzeit_this_year__c = dateForThisYear;
            Date fridayOfObservance = getFridayOfObservance(dateForThisYear);
            d.Friday_of_observance__c = fridayOfObservance;
		}
        
        return deceasedList;

    
    }
        
    private static Date getFridayOfObservance(Date observanceDate) {
        // Calculate days between the observance date and a known Friday (1/1/2016)
        Integer modValue = Math.mod(Date.newInstance(2016, 1, 1).daysBetween(observanceDate), 7);
        // Rabbi Milder's instructions: https://drive.google.com/file/d/0B-cVQENnYKfObDVJbTllWDRGTVk/view?usp=sharing
        // Names will be read on the next Shabbat following the date of the Yahrzeit.
        // If the Yahrzeit occurs on Shabbat, the name will be read on that Shabbat.
        // So Friday (mod=0) and Saturday (mod=1) will be this Friday. Sun-Thurs will be next Friday.
        Date fridayOfObservance = modValue < 2 ? observanceDate.addDays(-modValue) : observanceDate.addDays(7-modValue);
        return fridayOfObservance;
    }
	
	private static Date getNextObservanceDate(Deceased__c d) {
		Boolean isHebrewDate = d.Hebrew_date_observed__c;
		String day = isHebrewDate ? d.Day_Hebrew__c : d.Day_Gregorian__c;
		String month = isHebrewDate ? d.Month_Hebrew__c : d.Month_Gregorian__c; 
		
		if (day == null || day.length() == 0 || month == null || month.length() == 0)
			return null;

        Date today = Date.today();
        Integer observanceYear = today.year();
        if (isHebrewDate)
        	observanceYear += 3760; // bring 2013 to 5774
        Date nextObservance = yahrzeitForYear(isHebrewDate, month, day, observanceYear);

        if (today > nextObservance) {
            observanceYear++;
            nextObservance = yahrzeitForYear(d.Hebrew_date_observed__c, month, day, observanceYear);
        }

		return nextObservance;
	}
	
	public static Date yahrzeitForYear(Boolean hebrewDateObserved, String monthGregorianOrHebrew, 
                                       String dayGregorianOrHebrew, Integer observanceYear) {
		System.debug(hebrewDateObserved);
		if (!hebrewDateObserved) {
			Integer day = Integer.valueOf(dayGregorianOrHebrew);
			Integer month = Integer.valueOf(monthGregorianOrHebrew);
						
			Date dateThisYear = Date.newInstance(observanceYear, month, day);
			return dateThisYear;
		}
		else {
			System.debug('Calling webservice hebcal');
			return getDateBasedOnHebrew(monthGregorianOrHebrew, dayGregorianOrHebrew, observanceYear);
		}
	}
	
	public static String constructHebcalURL(String hebrewMonth, String hebrewDay, Integer hebrewYear) {
		if (hebrewMonth.equals('Adar') || hebrewMonth.equals('Adar I'))
			hebrewMonth = 'Adar1';
		else if (hebrewMonth.equals('Adar II'))
			hebrewMonth = 'Adar2';

		String urlPrefix = 'http://www.hebcal.com/converter/?cfg=json&h2g=1';
		String retUrl = urlPrefix;
		retUrl += '&hy=' + hebrewYear;
		retUrl += '&hm=' + hebrewMonth;
		retUrl += '&hd=' + hebrewDay;
		return retUrl;
	}
    
    private static String getContent(String url) {
		// Instantiate a new http object 
            Http h = new Http();
            
            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint 
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod('GET');
            
            // Send the request, and return a response 
            HttpResponse res = h.send(req);
            return res.getBody();
    }
	
	private static Date getDateBasedOnHebrew(String hebrewMonth, String hebrewDay, Integer hebrewYear) {
		String url = constructHebcalURL(hebrewMonth, hebrewDay, hebrewYear);
		String json = getContent(url);
		
		Integer month;
		Integer day;
		Integer year;
		
		JSONParser parser = System.Json.createParser(json);
		while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                if (parser.getText() == 'error') {
                    parser.nextToken();
                    String errorMessage = parser.getText();
//                    https://www.chabad.org/library/article_cdo/aid/1679830/jewish/Yahrtzeit-When-the-Date-Does-Not-Exist.htm
                    if (errorMessage.startsWith('Hebrew day 30 out of valid range 1-29 for Kislev')) {
                        hebrewMonth = 'Tevet';
                        hebrewDay = '1';
                    }
                    else if (errorMessage.startsWith('Hebrew day 30 out of valid range 1-29 for Chesvan')) {
                        hebrewMonth = 'Kislev';
                        hebrewDay = '1';
                    }
                    else
                        System.debug('Error: ' + errorMessage);
                    return getDateBasedOnHebrew(hebrewMonth, hebrewDay, hebrewYear);
                   
                }
            	if (parser.getText() == 'gm') {
	                // Get the value. 
    	            parser.nextToken();
        	        month = parser.getIntegerValue();
        	        System.debug('Month='+month);
            	}
            	if (parser.getText() == 'gd') {
            		parser.nextToken();
            		day = parser.getIntegerValue();
        	        System.debug('Day='+day);
            	} 
            	if (parser.getText() == 'gy') {
            		parser.nextToken();
            		year = parser.getIntegerValue();
        	        System.debug('Year='+year);
            	} 
            }
		}
		
		if (month == null || day == null || year == null)
			return null;
		return Date.newInstance(year, month, day);
	}	
	
    // Returns:
    // [0] Year (5770, etc)
    // [1] Month (Tishri, Cheshvan, etc)
    // [2] Day (1, 2, 3)
    public static String[] getHebrewDateFromGregorian(String dayGregorian, String monthGregorian, 
                                                      String yearGregorian, Boolean afterSunset) {
    	String url = constructHebcalUrlForGregorianToHebrew(dayGregorian, monthGregorian, yearGregorian, afterSunset);
		System.debug(url);
        String json = getContent(url);

		String[] ret = new String[3];
		JSONParser parser = System.Json.createParser(json);
		while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
            	if (parser.getText() == 'hy') {
	                // Get the value. 
    	            parser.nextToken();
        	        ret[0] = parser.getText();
        	        System.debug('Year='+ret[0]);
            	}
            	else if (parser.getText() == 'hm') {
	                // Get the value. 
    	            parser.nextToken();
        	        ret[1] = parser.getText();
                    if (ret[1].equals('Adar') || ret[1].equals('Adar1'))
						ret[1] = 'Adar I';
					else if (ret[1].equals('Adar2'))
						ret[1] = 'Adar II';

        	        System.debug('Month='+ret[1]);
                }
                else if (parser.getText() == 'hd') {
                    // Get the value. 
                    parser.nextToken();
                    ret[2] = parser.getText();
                    System.debug('Day='+ret[2]);
                }
            }
        }
		return ret;        
    }

    public static String constructHebcalUrlForGregorianToHebrew(String dayGregorian, String monthGregorian, 
                                                                 String yearGregorian, Boolean afterSunset) {
        String urlPrefix = 'http://www.hebcal.com/converter/?cfg=json&g2h=1';
        String retUrl = urlPrefix;
        retUrl += '&gy=' + yearGregorian;
        retUrl += '&gm=' + monthGregorian;
        retUrl += '&gd=' + dayGregorian;
        retUrl += '&gs=' + (afterSunset ? '1' : '0');
        return retUrl;
    }
    
    
    

}
