function habitTable2XML(T, fileName)

theStruct = habitTable2structure(T);

XmlTools.structure2XML(theStruct, fileName, true, true);

end