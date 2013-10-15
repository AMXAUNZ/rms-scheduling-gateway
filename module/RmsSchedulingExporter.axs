MODULE_NAME='RmsSchedulingExporter'(dev vdvRms, integer exportLocations[], integer locationCount, char filename[])


#define INCLUDE_SCHEDULING_ACTIVE_RESPONSE_CALLBACK
#define INCLUDE_SCHEDULING_NEXT_ACTIVE_RESPONSE_CALLBACK
#define INCLUDE_SCHEDULING_ACTIVE_UPDATED_CALLBACK
#define INCLUDE_SCHEDULING_NEXT_ACTIVE_UPDATED_CALLBACK


#include 'RmsApi'
#include 'RmsSchedulingApi';
#include 'RmsSchedulingEventListener';


define_type

structure locationBookings {
	RmsLocation location;
	RmsEventBookingResponse activeBooking;
	RmsEventBookingResponse nextBooking;
}


define_variable

volatile locationBookings bookings[locationCount];


// RMS callbacks

define_function RmsEventSchedulingActiveResponse(char isDefaultLocation,
		integer recordIndex,
		integer recordCount,
		char bookingId[],
		RmsEventBookingResponse eventBookingResponse) {
	
}

define_function RmsEventSchedulingNextActiveResponse(CHAR isDefaultLocation,
		integer recordIndex,
		integer recordCount,
		char bookingId[],
		RmsEventBookingResponse eventBookingResponse) {
	
}

define_function RmsEventSchedulingActiveUpdated(CHAR bookingId[],
		RmsEventBookingResponse eventBookingResponse) {
	
}

define_function RmsEventSchedulingNextActiveUpdated(CHAR bookingId[],
		RmsEventBookingResponse eventBookingResponse) {
	
}