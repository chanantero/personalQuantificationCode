function activityTable2XML( T, fileName )

theStruct = activityTable2structure(T);

structure2XML(theStruct, fileName);

end

