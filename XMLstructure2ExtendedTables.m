function [T, nodeIndexMatrix] = XMLstructure2ExtendedTables(nodeTreeStruct, unify)
[T, nodeIndexMatrix] = XMLstructure2XMLtable(nodeTreeStruct, true, unify);
end