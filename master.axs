PROGRAM_NAME='master'


define_device

vdvRms = 41001:1:0;


define_variable

volatile char exportFile[] = 'sydney.xml';

volatile integer exportLocations[] = {
	10,		// Sydney boardroom
	11,		// Sydney training room
	43,		// Sydney quiet room
	44		// Sydney demo area
};

volatile integer locationCount = 4;



define_module 'RmsNetLinxAdapter_dr4_0_0' mdlRms(vdvRms);

define_module 'RmsSchedulingExporter' mdlRmsExport(vdvRms, exportLocations, locationCount, exportFile);