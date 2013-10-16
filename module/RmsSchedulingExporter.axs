MODULE_NAME='RmsSchedulingExporter'(dev vdvRms, long locationIds[], char locationNames[][], char filename[])


#define INCLUDE_RMS_EVENT_CLIENT_ONLINE_CALLBACK
#define INCLUDE_RMS_EVENT_CLIENT_OFFLINE_CALLBACK
#define INCLUDE_SCHEDULING_ACTIVE_RESPONSE_CALLBACK
#define INCLUDE_SCHEDULING_NEXT_ACTIVE_RESPONSE_CALLBACK
#define INCLUDE_SCHEDULING_ACTIVE_UPDATED_CALLBACK
#define INCLUDE_SCHEDULING_NEXT_ACTIVE_UPDATED_CALLBACK


#include 'RmsApi'
#include 'RmsEventListener';
#include 'RmsSchedulingApi';
#include 'RmsSchedulingEventListener';
#include 'XmlUtil'


define_type

structure bookingTracker {
	RmsLocation location;
	RmsEventBookingResponse activeBooking;
	RmsEventBookingResponse nextBooking;
}


define_variable

constant integer MAX_LOCATIONS = 10;
constant integer POLL_INTERVAL = 300; // seconds
constant integer XML_WRITE_DELAY = 15; // seconds

constant long POLL_TL = 1;

volatile bookingTracker bookings[MAX_LOCATIONS];


define_function log(char msg[]) {
	send_string 0, msg;
}

define_function init() {
	stack_var integer i;

	for (i = 1; i <= length_array(locationIds); i++) {
		setBookingTracker(i, locationIds[i], locationNames[i]);
	}

	set_length_array(bookings, length_array(locationIds));
}

define_function startPolling() {
	stack_var long pollTimes[1];

	log('Starting scheduling sync');

	pollTimes[1] = POLL_INTERVAL * 1000;

	if (timeline_active(POLL_TL)) {
		timeline_kill(POLL_TL);
	}

	timeline_create(POLL_TL,
			pollTImes,
			1,
			TIMELINE_RELATIVE,
			TIMELINE_REPEAT);

	queryBookings();
}

define_function stopPolling() {
	log('Scheduling sync stopped');

	if (timeline_active(POLL_TL)) {
		timeline_kill(POLL_TL);
	}
}

define_function setBookingTracker(integer idx, long locationId, char locationName[]) {
	bookings[idx].location.id = type_cast(locationId);
	bookings[idx].location.name = locationName;
	// TODO we shouldn't have to pass in names but there doesn't seem to be a
	// way to query location info without there being an asset in there
}


define_function integer getLocationIdx(long locationId) {
	stack_var integer idx;
	for (idx = 1; idx <= length_array(bookings); idx++) {
		if (bookings[idx].location.id == locationId) {
			return idx;
		}
	}
}

define_function updateActiveBooking(RmsEventBookingResponse booking) {
	stack_var integer idx;
	idx = getLocationIdx(booking.location);
	if (idx) {
		bookings[idx].activeBooking = booking;
	}
}

define_function updateNextBooking(RmsEventBookingResponse booking) {
	stack_var integer idx;
	idx = getLocationIdx(booking.location);
	if (idx) {
		bookings[idx].nextBooking = booking;
	}
}

define_function queryBookings() {
	stack_var RmsEventBookingResponse nullBooking;
	stack_var integer i;

	log('Resycning scheduling data');

	cancel_wait 'delayedXmlWrite';

	for (i = 1; i <= length_array(bookings); i++) {
		bookings[i].activeBooking = nullBooking;
		bookings[i].nextBooking = nullBooking;
		RmsBookingActiveRequest(bookings[i].location.id);
		RmsBookingNextActiveRequest(bookings[i].location.id);
	}

	wait (XML_WRITE_DELAY * 10) 'delayedXmlWrite' {
		exportBookingXml();
	}
}

define_function char[2048] bookingToXmlElement(RmsLocation location, RmsEventBookingResponse booking) {
	return XmlBuildElement('booking', "
			XmlBuildElement('id', booking.bookingId),
			XmlBuildElement('location', "
				XmlBuildElement('id', itoa(location.id)),
				XmlBuildElement('name', location.name)
			"),
			XmlBuildElement('isPrivate', RmsBooleanString(booking.isPrivateEvent)),
			XmlBuildElement('startDate', booking.startDate),
			XmlBuildElement('startTime', booking.startTime),
			XmlBuildElement('endDate', booking.endDate),
			XmlBuildElement('endTime', booking.endTime),
			XmlBuildElement('subject', booking.subject),
			XmlBuildElement('details', booking.details),
			XmlBuildElement('isAllDayEvent', RmsBooleanString(booking.isAllDayEvent)),
			XmlBuildElement('organizer', booking.organizer),
			XmlBuildElement('attendees', booking.attendees)
		");
}

define_function writeLine(slong fileHandle, char buf[]) {
	if (fileHandle < 1) {
		log("'Bad file handle (error ', itoa(fileHandle), ')'");
		return;
	}

	file_write_line(fileHandle, buf, length_string(buf));
}

define_function exportBookingXml() {
	stack_var char tmp[2048];
	stack_var slong fileHandle;
	stack_var integer i;

	log("'Exporting scheduling data to ', filename");

	fileHandle = file_open(filename, FILE_RW_NEW);

	if (fileHandle < 0) {
		log("'Could not open file (error ', itoa(fileHandle), ')'");
		return;
	}

	writeLine(fileHandle, XmlBuildHeader('1.0', 'UTF-8'));

	writeLine(fileHandle, XmlBuildOpenTag('bookings'));

	// loop through each of our locations and...
	for (i = 1; i <= length_array(bookings); i++) {

		// add in active bookings
		if (bookings[i].activeBooking.bookingId) {
			writeLine(fileHandle, bookingToXmlElement(bookings[i].location, bookings[i].activeBooking));
		}

		// as well as thouse starting in the next 10 minutes
		if (bookings[i].nextBooking.bookingId <> '' &&
				bookings[i].nextBooking.minutesUntilStart <= 10) {
			writeLine(fileHandle, bookingToXmlElement(bookings[i].location, bookings[i].nextBooking));
		}
	}

	writeLine(fileHandle, XmlBuildCloseTag('bookings'));

	file_close(fileHandle);
}


// RMS callbacks

define_function RmsEventClientOnline() {
	startPolling();
}

define_function RmsEventClientOffline() {
	stopPolling();
}

define_function RmsEventSchedulingActiveResponse(char isDefaultLocation,
		integer recordIndex,
		integer recordCount,
		char bookingId[],
		RmsEventBookingResponse eventBookingResponse) {
	updateActiveBooking(eventBookingResponse);
}

define_function RmsEventSchedulingNextActiveResponse(CHAR isDefaultLocation,
		integer recordIndex,
		integer recordCount,
		char bookingId[],
		RmsEventBookingResponse eventBookingResponse) {
	updateNextBooking(eventBookingResponse);
}

define_function RmsEventSchedulingActiveUpdated(CHAR bookingId[],
		RmsEventBookingResponse eventBookingResponse) {
	updateActiveBooking(eventBookingResponse);
}

define_function RmsEventSchedulingNextActiveUpdated(CHAR bookingId[],
		RmsEventBookingResponse eventBookingResponse) {
	updateNextBooking(eventBookingResponse);
}


define_start

init();


define_event

timeline_event[POLL_TL] {
	queryBookings();
}
