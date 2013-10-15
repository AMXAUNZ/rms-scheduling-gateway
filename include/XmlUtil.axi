PROGRAM_NAME='XmlUtil'


define_function char[256] XmlBuildHeader(char version[], char encoding[]) {
	return "'<?xml version="', version, '" encoding="', encoding, '"?>'";
}

define_function char[512] XmlBuildElement(char tag[], char value[]) {
	return "'<', tag, '>', value, '</', tag, '>'";
}