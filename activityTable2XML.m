function activityTable2XML( T, fileName )

theStruct = activityTable2structure(T);

XmlTools.XmlTools.XmlTools.parseAttributes(theStruct, fileName);

end

