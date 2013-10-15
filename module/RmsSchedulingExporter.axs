MODULE_NAME='RmsSchedulingExporter'(dev vdvRms, long locationIds[], char locationNames[][], integer locationCount, char filename[])


#define INCLUDE_RMS_EVENT_CLIENT_ONLINE_CALLBACK
#define INCLUDE_RMS_EVENT_CLIENT_OFFLINE_CALLBACK
#define INCLUDE_SCHEDULING_ACTIVE_RESPONSE_CALLBACK
#define INCLUDE_SCHEDULING_NEXT_ACTIVE_RESPONSE_CALLBACK
#define INCLUDE_SCHEDULING_ACTIVE_UPDATED_CALLBACK
#define INCLUDE_SCHEDULING_NEXT_ACTIVE_UPDATED_CALLBACK


#include 'RmsApi'
#include 'RmsSchedulingApi';
#include 'RmsSchedulingEventListener';


define_type

structure bookingTracker {
	RmsLocation location;
	RmsEventBookingResponse activeBooking;
	RmsEventBookingResponse nextBooking;
}


define_variable

constant long POLL_TL = 1;
constant integer POLL_INTERVAL = 5; // minutes

volatile bookingTracker bookings[locationCount];


define_function init() {
	stack_var integer i;
	
	for (i = 1; i <= locationCount; i++) {
		setBookingTracker(i, locationIds[i], locationNames[i]);
	}
}

define_function startPolling() {
	stack_var long pollTimes[1];
	
	pollTimes[1] = POLL_INTERVAL * 1000;
	
	if (!timeline_active(POLL_TL)) {
		timeline_create(POLL_TL,
				pollTImes, 
				1, 
				TIMELINE_RELATIVE, 
				TIMELINE_REPEAT);
	}
}

define_function stopPolling() {
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
	for (idx = locationCount; idx; idx--) {
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
		// TODO write to file here
	}
}

define_function updateNextBooking(RmsEventBookingResponse booking) {
	stack_var integer idx;
	idx = getLocationIdx(booking.location);
	if (idx) {
		bookings[idx].nextBooking = booking;
		// TODO write to file here
	}
}

define_function queryBookings() {
	stack_var integer i;
	
	for (i = 1; i <= locationCount; i++) {
		RmsBookingActiveRequest(bookings[i].location.id);
		RmsBookingNextActiveRequest(bookings[i].location.id);
	}
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
