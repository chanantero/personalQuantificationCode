function habitTable2XML(T, fileName)

theStruct = habitTable2structure(T);

structure2XML(theStruct, fileName);

end