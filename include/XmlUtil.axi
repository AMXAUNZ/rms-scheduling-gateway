PROGRAM_NAME='XmlUtil'

#IF_NOT_DEFINED __XML_UTIL__
#DEFINE __XML_UTIL__


define_variable

constant integer XML_MAX_HEADER_LENGTH = 256;
constant integer XML_MAX_TAG_LENGTH = 256;
constant integer XML_MAX_ELEMENT_SIZE = 4096;


define_function char[XML_MAX_HEADER_LENGTH] XmlBuildHeader(char version[], char encoding[]) {
	return "'<?xml version="', version, '" encoding="', encoding, '"?>'";
}

define_function char[XML_MAX_TAG_LENGTH] XmlBuildOpenTag(char tag[]) {
	return "'<', tag ,'>'";
}

define_function char[XML_MAX_TAG_LENGTH] XmlBuildCloseTag(char tag[]) {
	return "'</', tag ,'>'";
}

define_function char[XML_MAX_ELEMENT_SIZE] XmlBuildElement(char tag[], char value[]) {
	return "XmlBuildOpenTag(tag), value, XmlBuildCloseTag(tag)";
}

define_function char[XML_MAX_ELEMENT_SIZE] XmlBuildCData(char data[]) {
	return "'<![CDATA[', data, ']]>'";
}

#END_IF
