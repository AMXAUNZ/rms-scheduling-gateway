PROGRAM_NAME='XmlUtil'


define_function char[256] XmlBuildHeader(char version[], char encoding[]) {
	return "'<?xml version="', version, '" encoding="', encoding, '"?>'";
}

define_function char[256] XmlBuildOpenTag(char tag[]) {
	return "'<', tag ,'>'";
}

define_function char[256] XmlBuildCloseTag(char tag[]) {
	return "'</', tag ,'>'";
}

define_function char[512] XmlBuildElement(char tag[], char value[]) {
	return "XmlBuildOpenTag(tag), value, XmlBuildCloseTag(tag)";
}

define_function char[2046] XmlBuildCData(char data[]) {
	return "'<![CDATA[', data, ']]>'";
}