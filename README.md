# Yahrzeit
Salesforce package for synagogues' tracking of deceased remembrance dates

This package automatically calculates the Hebrew date and the upcoming commemoration date via an integration with Hebcal.com . It can generate a mail merge to inform the family of the event. 

![Detail View](https://raw.githubusercontent.com/alonkama/Yahrzeit/master/Yahrzeit%20detail%20view.png)
![List View](https://raw.githubusercontent.com/alonkama/Yahrzeit/master/Yahrzeit%20list%20view.png)
[Sample letter](https://github.com/alonkama/Yahrzeit/blob/master/Sample%20letter.pdf)

Installation URL: [https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1M0000003zNS](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1M0000003zNS)

# Administration 

The upcoming remembrance date is calculated when editing the Yahrzeit record, or by clicking the "Update Yarhrzeit Date" button. Once the date has passed, a button click is necessary to calculate next year's date.

The button appears in two locations:
1. On each individual record
2. On a List View (not on the Recently Viewed listview - create a new one and save it)

Listviews give the ability to calculate new dates for several records at a time. The ones with Gregorian Date Observed can be done two hundred at a time. The ones with Hebrew Date Observed require an outbound webservice call to hebcal.com . Those requests are limited to 10 at a time. It is a best practice to create separate listviews for Gregorian and Hebrew dates, in order to process them in different batch sizes. 


