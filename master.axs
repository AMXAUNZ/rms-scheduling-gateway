PROGRAM_NAME='master'


define_device

vdvRms = 41001:1:0;


define_variable

volatile char exportFile[] = 'sydney.xml';

volatile long locationIds[] = {
	10,		// Sydney boardroom
	11,		// Sydney training room
	43,		// Sydney quiet room
	44		// Sydney demo area
};

volatile char locationNames[][16] = {
	'Boardroom',
	'Training Room',
	'Quiet Room',
	'Demo Area'
};


define_module 'RmsNetLinxAdapter_dr4_0_0' mdlRms(vdvRms);

define_module 'RmsSchedulingExporter' mdlRmsExport(vdvRms, locationIds, locationNames, exportFile);